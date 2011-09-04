//
//  BTTransit.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BTRoute.h"
#import "BTStation.h"
#import "FMDatabase.h"

@interface BTTransit : NSObject
{
	NSMutableArray *routes;
	NSMutableDictionary *routesDict; // a dictionary for fast lookup of routes
	NSDictionary *routesToDisplay; // for RoutesView tab, organized in sections
	NSMutableArray *stations;
	NSMutableDictionary *stationsDict; // a dictionary for fast lookup of stations
	NSMutableArray *tiles; // use tiles to quickly load annotations onto the map
	NSMutableArray *nearbyStations;
	NSMutableArray *favoriteStations;
	
	// Database
	FMDatabase *db;
}

@property (nonatomic, retain) NSMutableArray *routes;
@property (nonatomic, retain) NSMutableDictionary *routesDict;
@property (nonatomic, retain) NSDictionary *routesToDisplay;
@property (nonatomic, retain) NSMutableArray *stations;
@property (nonatomic, retain) NSMutableDictionary *stationsDict;
@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, retain) NSMutableArray *nearbyStations;
@property (nonatomic, retain) NSMutableArray *favoriteStations;
@property (nonatomic, retain) FMDatabase *db;

- (void)loadData;
- (void)loadRoutesFromDB;
- (void)loadStationsFromDB;
- (void)loadRoutesToDisplayFromPlist:(NSString *)fileName;
- (void)loadStationListsForRoute:(BTRoute *)route;
- (NSArray *)routeIdsAtStation:(BTStation *)s;
- (void)loadFavoriteStations;
- (void)updateNearbyStations;
- (void)loadScheduleForRoutes;
- (BTStation *)stationWithId:(NSString *)stationId;
- (BTRoute *)routeWithId:(NSString *)routeId;
- (void)sortStations:(NSMutableArray *)ss ByDistanceFrom:(CLLocation *)location;
- (NSArray *)filterStations:(NSArray *)ss;
- (BOOL)checkStation:(BTStation *)s;
- (NSDictionary *)filterRoutes:(NSDictionary *)rs;
- (NSMutableArray *)filterPrediction:(NSMutableArray *)p;

@end
