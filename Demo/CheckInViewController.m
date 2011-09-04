//
//  CheckInViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 5/30/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "CheckInViewController.h"
#import "BTAnnotation.h"
#import "BTLocationManager.h"
#import "BTTransit.h"
#import "BTTransitDelegate.h"
#import "HAHorizontalPickerView.h"


@implementation CheckInViewController

@synthesize currentStation, routeIds;
@synthesize mapView;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Check In";
	[self.navigationController setNavigationBarHidden:YES];
	
	// mapView settings
	[mapView setMapType:MKMapTypeStandard];
	[mapView setUserInteractionEnabled:NO];
	
	BTTransit *transit = (BTTransit *)[AppDelegate transit];
	if (transit.nearbyStations != nil && [transit.nearbyStations count] > 0) {
		self.currentStation = [transit.nearbyStations objectAtIndex:0];
		self.routeIds = [transit routeIdsAtStation:currentStation];
		[self updateMap];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didUpdateToLocation:)
												 name:kDidUpdateToLocationNotification
											   object:nil];
	
	[[BTLocationManager sharedInstance] startUpdatingLocation];
	
	HAHorizontalPickerView *pv = [[HAHorizontalPickerView alloc] initWithFrame:CGRectMake(0, 270, 320, 50)];
	[self.view addSubview:pv];
	
	/*
	// Picker view
	pickerView.backgroundColor = [UIColor darkGrayColor];
	pickerView.selectedTextColor = [UIColor whiteColor];
	pickerView.textColor = [UIColor redColor];
	pickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	pickerView.selectionPoint = CGPointMake(60, 0);
	[pickerView reloadData];
	 */
}

- (void)updateMap
{
	// reset annotation to that of current selected station
	NSArray *annotations = mapView.annotations;
	if (annotations) {
		[mapView removeAnnotations:annotations];
	}
	
	BTAnnotation *annotation = [[BTAnnotation alloc] init];
	annotation.title = currentStation.desc;
	annotation.subtitle = [NSString stringWithFormat:@"Bus stop #%@", currentStation.stationId];
	CLLocationCoordinate2D coordinate = {0,0};
	coordinate.latitude = currentStation.latitude;
	coordinate.longitude = currentStation.longitude;
	annotation.coordinate = coordinate;
	annotation.station = currentStation;
	[mapView addAnnotation:annotation];
	[annotation release];
	
	// set map view region
	MKCoordinateRegion region = {{0.0, 0.0}, {0.0, 0.0}};
	region.center = coordinate;
	region.span.longitudeDelta = 0.003;
	region.span.latitudeDelta = 0.003;
	[mapView setRegion:region animated:NO];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
    [super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.mapView = nil;
}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[currentStation release], currentStation = nil;
	[routeIds release], routeIds = nil;
	[mapView release], mapView = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark -
#pragma mark Location updates

- (void)didUpdateToLocation:(NSNotification *)notification
{
	BTTransit *transit = (BTTransit *)[AppDelegate transit];
	if (transit.nearbyStations != nil && [transit.nearbyStations count] > 0) {
		self.currentStation = [transit.nearbyStations objectAtIndex:0];
		self.routeIds = [transit routeIdsAtStation:currentStation];
		[self updateMap];
		//[pickerView reloadData];
	}
}

/*
#pragma mark -
#pragma mark V8HorizontalPickerView delegate and datasource methods

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
	NSLog(@"count: %d", [routeIds count]);
	return [routeIds count];
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index
{
	NSLog(@"index: %d", index);
	return [routeIds objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
	return 100.0f;
	
	NSString *s = [routeIds objectAtIndex:index];
	CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	CGSize textSize = [s sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]
					constrainedToSize:maxSize
						lineBreakMode:UILineBreakModeWordWrap];
	return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
	NSLog(@"did select index %d", index);
}
 */

@end
