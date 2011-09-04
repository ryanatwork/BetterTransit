//
//  BTMapViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BTTransit.h"
#import "BTPredictionViewController.h"

@interface BTMapViewController : UIViewController <MKMapViewDelegate>
{
	BTTransit *transit;
	NSArray *stations;
	
	MKMapView *mapView;
	NSMutableArray *annotations;
	NSMutableArray *lastVisibleTiles;
	
	UIBarButtonItem *locationUpdateButton;
	UIBarButtonItem *activityIndicator;
	UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) NSArray *stations;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) NSMutableArray *lastVisibleTiles;
@property (nonatomic, retain) UIBarButtonItem *locationUpdateButton;
@property (nonatomic, retain) UIBarButtonItem *activityIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

- (void)setCenterLocation:(CLLocation *)location;
- (void)updateAnnotations;
- (void)addAnnotations;
- (void)removeAnnotations;

@end
