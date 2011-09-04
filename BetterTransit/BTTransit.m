//
//  BTTransit.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTTransit.h"
#import "BTStationList.h"
#import "AppSettings.h"


@implementation BTTransit

@synthesize routes, routesDict, routesToDisplay;
@synthesize stations, stationsDict, tiles, nearbyStations, favoriteStations;
@synthesize db;


#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super init];
	if (self) {
		routes = [[NSMutableArray alloc] initWithCapacity:NUM_ROUTES];
		routesDict = [[NSMutableDictionary alloc] initWithCapacity:NUM_ROUTES];
		routesToDisplay = nil;
		stations = [[NSMutableArray alloc] initWithCapacity:NUM_STOPS];
		stationsDict = [[NSMutableDictionary alloc] initWithCapacity:NUM_STOPS];
		
#if NUM_TILES > 1
		tiles = [[NSMutableArray alloc] initWithCapacity:NUM_TILES];
		for (int i=0; i<NUM_TILES; i++) {
			NSMutableArray *tile = [[NSMutableArray alloc] initWithCapacity:20];
			[tiles addObject:tile];
			[tile release];
		}
#else
		tiles = nil;
#endif
			
		nearbyStations = [[NSMutableArray alloc] init];
		favoriteStations = [[NSMutableArray alloc] init];
		
		[self loadData];
		
		// Observe notifications
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(didUpdateToLocation:)
													 name:kDidUpdateToLocationNotification
												   object:nil];
	}
	return self;
}

- (void)loadData
{
	// Load data from database
	NSString *path = [[NSBundle mainBundle] pathForResource:MAIN_DB ofType:@"db"];
	self.db = [FMDatabase databaseWithPath:path];
	if (![db open]) {
		NSLog(@"Could not open db.");
	}
	
	[self loadRoutesFromDB];
	[self loadRoutesToDisplayFromPlist:@"routesToDisplay"];
	[self loadScheduleForRoutes];
	[self loadStationsFromDB];
	[self loadFavoriteStations];
}

- (void)loadRoutesFromDB
{	
	FMResultSet *rs = [db executeQuery:@"select * from routes"];
	while ([rs next]) {
		BTRoute *route = [[BTRoute alloc] init];
		route.routeId = [rs stringForColumn:@"route_id"];
		route.style = [rs stringForColumn:@"style"];
		route.owner = [rs intForColumn:@"owner"];
		route.subroutes = [rs stringForColumn:@"subroutes"];
		route.desc = [rs stringForColumn:@"desc"];
		[self.routes addObject:route];
		[self.routesDict setObject:route forKey:route.routeId];
		[route release];
	}
	[rs close];
}

- (void)loadStationsFromDB
{
	FMResultSet *rs = [db executeQuery:@"select * from stations"];
	while ([rs next]) {
		BTStation *station = [[BTStation alloc] init];
		station.stationId = [rs stringForColumn:@"station_id"];
		station.owner = [rs intForColumn:@"owner"];
		station.latitude = [rs doubleForColumn:@"latitude"];
		station.longitude = [rs doubleForColumn:@"longitude"];
		station.desc = [rs stringForColumn:@"desc"];
		[self.stations addObject:station];
		[self.stationsDict setObject:station forKey:station.stationId];
		
#if NUM_TILES > 1
		station.tileNumber = [rs intForColumn:@"tile"];
		NSMutableArray *tile = [tiles objectAtIndex:station.tileNumber];
		[tile addObject:station];
#endif
		[station release];
	}
	[rs close];
}

- (void)loadRoutesToDisplayFromPlist:(NSString *)fileName
{
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	self.routesToDisplay = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
}

- (void)loadStationListsForRoute:(BTRoute *)route
{
	if (route.stationLists == nil) {
		route.stationLists = [NSMutableArray arrayWithCapacity:2];
	}
	
	NSArray *items = [route.subroutes componentsSeparatedByString:@","];
	for (int i=0; i<[items count]; i++) {
		BTStationList *stationList = [[BTStationList alloc] init];
		stationList.route = route;
		stationList.listId = [items objectAtIndex:i]; // "-", "1", "2", ...
		[route.stationLists addObject:stationList];
		[stationList release];
	}
	
	for (BTStationList *stationList in route.stationLists) {
		FMResultSet *rs = [db executeQuery:@"select * from stages where route_id = ? and subroute = ? order by order_id ASC",
						   route.routeId, stationList.listId];
		NSUInteger counter = 0;
		while ([rs next]) {
			if (counter == 0) {
				stationList.name = [rs stringForColumn:@"bound"];
				stationList.detail = [rs stringForColumn:@"dest"];
			}
			NSString *stationId = [rs stringForColumn:@"station_id"];
			BTStation *station = [self stationWithId:stationId];
			[stationList.stations addObject:station];
			counter++;
		}
		[rs close];
	}
}

- (NSArray *)routeIdsAtStation:(BTStation *)s
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	NSString *stationId = s.stationId;
	FMResultSet *rs = [self.db executeQuery:@"select * from stages where station_id = ? order by route_id ASC",
					   stationId];
	
	NSUInteger counter = 0;
	while ([rs next]) {
		NSString *routeId = [rs stringForColumn:@"route_id"];
		[dict setObject:[NSNumber numberWithInt:counter] forKey:routeId];
		counter++;
	}
	
	return [[dict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)loadScheduleForRoutes
{
	// implement this method in subclass if necessary
}

- (BTRoute *)routeWithId:(NSString *)routeId
{
	return [self.routesDict objectForKey:routeId];
}

- (BTStation *)stationWithId:(NSString *)stationId
{
	return [self.stationsDict objectForKey:stationId];
}

- (void)loadFavoriteStations
{	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSArray *p = [prefs objectForKey:@"favorites"];
    
	if (p != nil) {
		for (NSString *stationId in p) {
			BTStation *station = [self stationWithId:stationId];
			station.favorite = YES;
			[self.favoriteStations addObject:station];
		}
	}
}

- (void)updateNearbyStations
{
	[self.nearbyStations removeAllObjects];
	
	int maxNumberOfNearbyStops;
	if ([[AppSettings maxNumNearbyStops] isEqualToString:@"No Limit"]) {
		maxNumberOfNearbyStops = [self.stations count];
	} else {
		maxNumberOfNearbyStops = [[AppSettings maxNumNearbyStops] intValue];
	}
	
	double radius;
	if ([[AppSettings nearbyRadius] isEqualToString:@"No Limit"]) {
		radius = 50000000;
	} else {
#ifdef METRIC_UNIT
		NSRange rangeOfKm = [[AppSettings nearbyRadius] rangeOfString:@" km"];
		radius = [[[AppSettings nearbyRadius] substringToIndex:rangeOfKm.location] doubleValue]*1000;
#endif

#ifdef ENGLISH_UNIT
		NSRange rangeOfMi = [[AppSettings nearbyRadius] rangeOfString:@" mi"];
		radius = [[[AppSettings nearbyRadius] substringToIndex:rangeOfMi.location] doubleValue]*1609.344;
#endif
	}
	
	int count = 0;
	for (int i=0; i<[self.stations count]; i++) {
		BTStation *station = [self.stations objectAtIndex:i];
		if (station.distance > -1 && station.distance < radius && [self checkStation:station]) {
			[self.nearbyStations addObject:station];
			count++;
			if (count >= maxNumberOfNearbyStops) break;
		}
	}
}

- (void)sortStations:(NSMutableArray *)ss ByDistanceFrom:(CLLocation *)location
{
	BTStation *station;
	CLLocation *stationLocation;
	for (station in ss) {
		stationLocation = [[CLLocation alloc] initWithLatitude:station.latitude longitude:station.longitude];
		station.distance = [stationLocation getDistanceFrom:location]; // in meters
		[stationLocation release];
	}
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	[ss sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
}

- (NSArray *)filterStations:(NSArray *)ss 
{	
	return [[ss retain] autorelease];
}

- (BOOL)checkStation:(BTStation *)s
{
	return YES;
}

- (NSDictionary *)filterRoutes:(NSDictionary *)rs
{
	return [[rs retain] autorelease];
}

- (NSMutableArray *)filterPrediction:(NSMutableArray *)p 
{
	return [[p retain] autorelease];
}

- (void)dealloc
{
	[routes release];
	[routesDict release];
	[routesToDisplay release];
	[stations release];
	[stationsDict release];
	[tiles release];
	[nearbyStations release];
	[favoriteStations release];
	[db close], [db release], db = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


#pragma mark -
#pragma mark Location updates

- (void)didUpdateToLocation:(NSNotification *)notification
{
	CLLocation *newLocation = [[notification userInfo] objectForKey:@"location"];
	[self sortStations:self.stations ByDistanceFrom:newLocation];
	[self updateNearbyStations];
}

@end
