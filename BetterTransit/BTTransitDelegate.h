//
//  BTTransitDelegate.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTransit.h"
#import "BTFeedLoader.h"
#import "BTScheduleViewController.h"
#import "BTPredictionViewController.h"
#import "BTRailViewController.h"
#import "BTRouteCell.h"

@interface BTTransitDelegate : NSObject <UIApplicationDelegate,
										 UIAlertViewDelegate,
										 UITabBarControllerDelegate>
{
	UIWindow *window;
	UITabBarController *tabBarController;
	
	BTTransit *transit;
	BTFeedLoader *feedLoader;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (retain) IBOutlet BTTransit *transit;
@property (retain) IBOutlet BTFeedLoader *feedLoader;

// Create view controllers
- (BTPredictionViewController *)createPredictionViewController;
- (BTScheduleViewController *)createScheduleViewController;
- (BTRailViewController *)createRailViewController;
- (BTRouteCell *)createRouteCellWithIdentifier:(NSString *)CellIdentifier;

// App settings
- (void)updateAppSettings;
- (void)updateExpiryDate;
- (void)downloadVideoAd;
- (void)playVideoAd;

@end
