//
//  BTTransitDelegate.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTTransitDelegate.h"
#import "BTLocationManager.h"
#import "Utility.h"

#ifdef FLURRY_KEY
#import "FlurryAPI.h"
void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}
#endif

@implementation BTTransitDelegate

@synthesize window, tabBarController;
@synthesize transit, feedLoader;


#pragma mark -
#pragma mark Customizable controllers

- (BTPredictionViewController *)createPredictionViewController
{
	return [[BTPredictionViewController alloc] init];
}

- (BTScheduleViewController *)createScheduleViewController
{
	return nil;
}

- (BTRailViewController *)createRailViewController
{
	return [[BTRailViewController alloc] init];
}	

- (BTRouteCell *)createRouteCellWithIdentifier:(NSString *)CellIdentifier
{
	return [[BTRouteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
}


#pragma mark -
#pragma mark Application life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Add the tab bar controller's current view as a subview of the window
    [self.window addSubview:tabBarController.view];
	[self.window makeKeyAndVisible];
    
    UINavigationController *nc;
	for (nc in tabBarController.viewControllers) {
		nc.navigationBar.tintColor = COLOR_NAV_BAR_BG;
    }
	
/* TODO fix me
	// Show startup tab
	NSString *tabTitle = [AppSettings startupScreen];
	if ([tabTitle isEqualToString:@"Nearby"] || [tabTitle isEqualToString:@"Favorites"]) {
		tabTitle = @"Stops";
	}
	
	UINavigationController *nc;
	for (nc in tabBarController.viewControllers) {
		nc.navigationBar.tintColor = COLOR_NAV_BAR_BG;
		if ([nc.title isEqualToString:tabTitle]) {
			[tabBarController setSelectedViewController:nc];
		}
	}
*/
    
#ifdef FLURRY_KEY
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSession:FLURRY_KEY];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"TRACKING_NEW_USERS"]) {
        // Log Flurry event to track the number of new users
        NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[UIDevice currentDevice] model], @"device_model",
                                    [Utility deviceType], @"device_type", nil];
        [FlurryAPI logEvent:@"TRACKING_NEW_USERS" withParameters:flurryDict];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TRACKING_NEW_USERS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
#endif
	
	return YES;
}

- (void)fadeSplashScreen
{
	UIImage* backImage = [UIImage imageNamed:@"Default.png"];
	UIView* backView = [[UIImageView alloc] initWithImage:backImage];
	backView.frame = window.bounds;
	[window addSubview:backView];
	
	[UIView beginAnimations:@"CWFadeIn" context:(void*)backView];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.4f];
	backView.alpha = 0;
	backView.transform = CGAffineTransformMakeScale(5.0, 5.0);
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
	UIView* backView = (UIView*)context;
	[backView removeFromSuperview];
	[backView release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application
{	
	// Turn off timer and reset feed loader's delegate if predicition view is visisble
	UINavigationController *nc = (UINavigationController *)[tabBarController selectedViewController];
	UIViewController *vc = [nc visibleViewController];
	
	if ( [vc isKindOfClass:[BTPredictionViewController class]] ) {
		[self.feedLoader setDelegate:nil];
		[((BTPredictionViewController *)vc).timer invalidate];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Update current location
	[[BTLocationManager sharedInstance] startUpdatingLocation];
	
	UINavigationController *nc = (UINavigationController *)[tabBarController selectedViewController];
	UIViewController *vc = [nc visibleViewController];
	
	if ( [vc isKindOfClass:[BTPredictionViewController class]] ) {
		BTPredictionViewController *c = (BTPredictionViewController *)vc;
		[c checkBusArrival];
		[c startTimer];
	}
}

- (void)dealloc
{
	[window release], window = nil;
    [tabBarController release], tabBarController = nil;
	
	[transit release], transit = nil;
	[feedLoader release], feedLoader = nil;
    [super dealloc];
}
	
@end
