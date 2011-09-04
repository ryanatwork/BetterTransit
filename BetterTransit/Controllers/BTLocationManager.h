//
//  BTLocationManager.h
//  BetterTransit
//
//  Created by Yaogang Lian on 2/4/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BTLocationManager : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;
	BOOL isUpdatingLocation;
	BOOL locationFound;
	CLLocation *currentLocation;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isUpdatingLocation;
@property (nonatomic, assign) BOOL locationFound;
@property (nonatomic, retain) CLLocation *currentLocation;

+ (BTLocationManager *)sharedInstance;

// Location
- (void)startUpdatingLocation;

@end
