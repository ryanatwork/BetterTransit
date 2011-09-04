//
//  CheckInViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 5/30/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BTStation.h"

@interface CheckInViewController : UIViewController
{
	BTStation *currentStation;
	NSArray *routeIds; // route Ids at the current station
	
	MKMapView *mapView;
}

@property (nonatomic, retain) BTStation *currentStation;
@property (nonatomic, retain) NSArray *routeIds;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)updateMap;

@end
