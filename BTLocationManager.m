//
//  BTLocationManager.m
//  BetterTransit
//
//  Created by Yaogang Lian on 2/4/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "BTLocationManager.h"
#import "FlurryAPI.h"


@implementation BTLocationManager

@synthesize locationManager, isUpdatingLocation, locationFound, currentLocation;


static BTLocationManager *sharedInstance = nil;
+ (BTLocationManager *)sharedInstance
{
	if (sharedInstance == nil) {
		sharedInstance = [[BTLocationManager alloc] init];
	}
	return sharedInstance;
}


#pragma mark -
#pragma mark Object life cycle

- (id)init
{
	if (self = [super init]) {
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self]; // send location update to self
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		isUpdatingLocation = NO;
		locationFound = NO;
		currentLocation = nil;
	}
	return self;
}

- (void)dealloc
{
	locationManager.delegate = nil;
	[locationManager release], locationManager = nil;
	[currentLocation release], currentLocation = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Location management

- (void)startUpdatingLocation 
{
	if (isUpdatingLocation) return;
	
	isUpdatingLocation = YES;
  	[locationManager startUpdatingLocation];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kStartUpdatingLocationNotification
														object:self
													  userInfo:nil];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation 
{
	[locationManager stopUpdatingLocation];
	isUpdatingLocation = NO;
	locationFound = YES;

#ifdef PRODUCTION_READY
	CLLocation *loc = newLocation;
#else
	CLLocation *loc = [[[CLLocation alloc] initWithLatitude:FAKE_LOCATION_LATITUDE longitude:FAKE_LOCATION_LONGITUDE] autorelease];
#endif
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:loc forKey:@"location"];
	
	// If the user's location didn't change much, don't bother sending out notifications
	if (self.currentLocation != nil && fabs([loc getDistanceFrom:self.currentLocation]) < 100) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLocationDidNotChangeNotification
															object:self
														  userInfo:userInfo];
	} else {
		self.currentLocation = loc;
		[FlurryAPI setLatitude:loc.coordinate.latitude
					 longitude:loc.coordinate.longitude
			horizontalAccuracy:loc.horizontalAccuracy
			  verticalAccuracy:loc.verticalAccuracy];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdateToLocationNotification
															object:self
														  userInfo:userInfo];
	}
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	[manager stopUpdatingLocation];
	isUpdatingLocation = NO;
	locationFound = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kDidFailToUpdateLocationNotification 
														object:self
													  userInfo:nil];
	
	// NSLog(@"location manager failed");
	/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:@"Your location could not be determined."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	 */
}

@end
