//
//  BTMapViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTMapViewController.h"
#import "BTAnnotation.h"
#import "BTTransitDelegate.h"
#import "BTLocationManager.h"
#import "FlurryAPI.h"

@implementation BTMapViewController

@synthesize stations;
@synthesize mapView, annotations, lastVisibleTiles;
@synthesize locationUpdateButton, activityIndicator, activityIndicatorView;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Map", @"");
	
	transit = [AppDelegate transit];
	
	self.stations = transit.stations;
	self.annotations = nil;
	self.lastVisibleTiles = nil;
	
	UIButton *locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	locateButton.frame = CGRectMake(0, 0, 34, 28);
	[locateButton setImage:[UIImage imageNamed:@"locate.png"] forState:UIControlStateNormal];
	[locateButton addTarget:self action:@selector(updateLocation:) forControlEvents:UIControlEventTouchUpInside];
	locationUpdateButton = [[UIBarButtonItem alloc] initWithCustomView:locateButton];
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.hidesWhenStopped = YES;
	activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
	
	self.navigationItem.rightBarButtonItem = locationUpdateButton;
	
	// mapView settings
	[mapView setMapType:MKMapTypeStandard];
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:YES];
	[mapView setShowsUserLocation:YES];
	[mapView setDelegate:self]; // set delegate for annotations
	
	// When the region is changed, mapView:regionDidChangeAnimated: will be called, in which we update annotations
	[self setCenterLocation:[[BTLocationManager sharedInstance] currentLocation]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[FlurryAPI logEvent:@"DID_SHOW_MAP_VIEW"];
	
	// Observe notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(startUpdatingLocation:)
												 name:kStartUpdatingLocationNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didUpdateToLocation:)
												 name:kDidUpdateToLocationNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didFailToUpdateLocation:)
												 name:kDidFailToUpdateLocationNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(locationDidNotChange:)
												 name:kLocationDidNotChangeNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidUnload
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mapView removeAnnotations:mapView.annotations];
	self.mapView = nil;
	self.annotations = nil;
}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[stations release];
	[mapView release];
	[annotations release];
	[lastVisibleTiles release];
	[locationUpdateButton release];
	[activityIndicator release];
	[activityIndicatorView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark -
#pragma mark Manage annotations

#if NUM_TILES > 1
- (NSArray *)visibleTiles
{
	NSMutableArray *visibleTiles = [NSMutableArray arrayWithCapacity:2];
	
	MKCoordinateRegion region = mapView.region;
	double minLong = region.center.longitude - region.span.longitudeDelta/2.0;
	double maxLong = region.center.longitude + region.span.longitudeDelta/2.0;
	double minLat = region.center.latitude - region.span.latitudeDelta/2.0;
	double maxLat = region.center.latitude + region.span.latitudeDelta/2.0;
	
	int i1 = floor( (minLat - MIN_LATITUDE)/DELTA_LATITUDE );
	int j1 = floor( (minLong - MIN_LONGITUDE)/DELTA_LONGITUDE );
	
	int i2 = floor( (maxLat - MIN_LATITUDE)/DELTA_LATITUDE );
	int j2 = floor( (maxLong - MIN_LONGITUDE)/DELTA_LONGITUDE );
	
	if (i1 < 0 || i1 > i2 || j1 < 0 || j1 > j2) return nil;
	
	for (int i=i1; i<=i2; i++) {
		for (int j=j1; j<=j2; j++) {
			// Fixed an out-of-bounds crash
			int index = i*NUM_TILES_IN_X+j;
			if (transit.tiles != nil && index >= 0 && index < [transit.tiles count]) {
				NSMutableArray *tile = [transit.tiles objectAtIndex:index];
				[visibleTiles addObject:tile];
			}
		}
	}
	return visibleTiles;
}

- (NSArray *)annotationsInTile:(NSArray *)tile
{
	NSMutableArray *anns = [NSMutableArray arrayWithCapacity:20];
	for (BTStation *station in tile) {
		BTAnnotation *annotation = [[BTAnnotation alloc] init];
		annotation.title = station.desc;
		annotation.subtitle = [NSString stringWithFormat:@"Bus stop #%@", station.stationId];
		CLLocationCoordinate2D coordinate = {0,0};
		coordinate.latitude = station.latitude;
		coordinate.longitude = station.longitude;
		annotation.coordinate = coordinate;
		annotation.station = station;
		[anns addObject:annotation];
		[annotation release];
	}
	return anns;
}
#endif

- (void)updateAnnotations
{
	if (![[BTLocationManager sharedInstance] locationFound]) return;
	
	// filter stations to the current visible region
	MKCoordinateRegion region = mapView.region;
	if (region.span.longitudeDelta > 0.015) {
		[self removeAnnotations];
		self.lastVisibleTiles = nil;
		return;
	}
	
#if NUM_TILES > 1
	NSArray *visibleTiles = [self visibleTiles];
	for (NSArray *tile in visibleTiles) {
		if ( lastVisibleTiles == nil || ![lastVisibleTiles containsObject:tile] ) {
			[mapView addAnnotations:[self annotationsInTile:tile]];
		} else {
			[lastVisibleTiles removeObject:tile];
		}
	}
			 
	for (NSArray *tile in lastVisibleTiles) {
		[mapView removeAnnotations:[self annotationsInTile:tile]];
	}
	
	self.lastVisibleTiles = [visibleTiles mutableCopy];
	[lastVisibleTiles release];
	
#else
	BOOL shouldAddAnnotations = TRUE;
	for (id annotation in mapView.annotations) {
		if (annotation != mapView.userLocation) {
			shouldAddAnnotations = FALSE;
			break;
		}
	}
	
	if (shouldAddAnnotations) {
		[self addAnnotations];
	}
#endif
}

- (void)addAnnotations
{
	if (self.annotations == nil) {
		self.annotations = [NSMutableArray arrayWithCapacity:NUM_STOPS];
		for (BTStation *station in self.stations) {
			BTAnnotation *annotation = [[BTAnnotation alloc] init];
			annotation.title = station.desc;
			annotation.subtitle = [NSString stringWithFormat:@"Bus stop #%@", station.stationId];
			CLLocationCoordinate2D coordinate = {0,0};
			coordinate.latitude = station.latitude;
			coordinate.longitude = station.longitude;
			annotation.coordinate = coordinate;
			annotation.station = station;
			[self.annotations addObject:annotation];
			[annotation release];
		}
	}
	[mapView addAnnotations:self.annotations];
}

- (void)removeAnnotations
{
#if NUM_TILES > 1
	NSArray *annotationsCopy = [mapView.annotations copy];
	for (id annotation in annotationsCopy) {
		if (annotation != mapView.userLocation) {
			[mapView removeAnnotation:annotation];
		}
	}
	[annotationsCopy release];
#else
	[mapView removeAnnotations:self.annotations];
#endif
}


#pragma mark -
#pragma mark UIButton actions

- (IBAction)updateLocation:(id)sender
{
	[[BTLocationManager sharedInstance] startUpdatingLocation];
}

- (void)setCenterLocation:(CLLocation *)location
{
	MKCoordinateRegion region = {{0.0, 0.0}, {0.0, 0.0}};
	region.center = location.coordinate;
	region.span.longitudeDelta = 0.002;
	region.span.latitudeDelta = 0.002;
	[mapView setRegion:region animated:YES];
}


#pragma mark -
#pragma mark MapView delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id)annotation
{
    MKAnnotationView *annotationView = nil;
    if (annotation != mv.userLocation) {
        static NSString *defaultID = @"AnnotationViewID";
		annotationView = (MKAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:defaultID];
		if (annotationView == nil) {
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultID] autorelease];
		}
		
		annotationView.canShowCallout = YES;
		BTAnnotation *ann = (BTAnnotation *)annotation;
		NSString *imageName = [NSString stringWithFormat:@"station_sign_%d.png", ann.station.owner];
		UIImage *img = [UIImage imageNamed:imageName];
		if (img == nil) {
			img = [UIImage imageNamed:@"default_station_sign.png"];
		}
		[annotationView setImage:img];
		//pinView.leftCalloutAccessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		CGPoint offsetPixels;
		offsetPixels.x = 0;
		offsetPixels.y = -2;
		annotationView.centerOffset = offsetPixels;
		
	 } else
        [mv.userLocation setTitle:@"I Am Here"];
    return annotationView;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)av calloutAccessoryControlTapped:(UIControl *)control
{
	BTAnnotation *annotation = [av annotation];
	
	BTPredictionViewController *controller = [AppDelegate createPredictionViewController];
	controller.station = annotation.station;
	controller.prediction = nil;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateAnnotations];
}


#pragma mark -
#pragma mark Location updates

- (void)startUpdatingLocation:(NSNotification *)notification
{
	self.navigationItem.rightBarButtonItem = activityIndicator;
	[self.activityIndicatorView startAnimating];
}

- (void)didUpdateToLocation:(NSNotification *)notification
{
	CLLocation *newLocation = [[notification userInfo] objectForKey:@"location"];
	[self setCenterLocation:newLocation];
	[self.activityIndicatorView stopAnimating];
	self.navigationItem.rightBarButtonItem = locationUpdateButton;
}

- (void)didFailToUpdateLocation:(NSNotification *)notification
{
	[self.activityIndicatorView stopAnimating];
	self.navigationItem.rightBarButtonItem = locationUpdateButton;
}

- (void)locationDidNotChange:(NSNotification *)notification
{
	[self.activityIndicatorView stopAnimating];
	self.navigationItem.rightBarButtonItem = locationUpdateButton;
	[self setCenterLocation:[[BTLocationManager sharedInstance] currentLocation]];
}	

@end
