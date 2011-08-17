//
//  BTTransitDelegate.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTTransitDelegate.h"
#import "BTLocationManager.h"
#import "Appirater.h"
#import "Utility.h"
#import "LoadingView.h"
#import "AppSettings.h"
#import "FlurryAPI.h"
#import "VideoAdViewController.h"

@implementation BTTransitDelegate

@synthesize window, tabBarController;
@synthesize transit, feedLoader;


void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}


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
	// Load app settings
	[AppSettings loadAppSettings];
	
	// Add the tab bar controller's current view as a subview of the window
    [self.window addSubview:tabBarController.view];
	[self.window makeKeyAndVisible];
	
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
	
	[Appirater appLaunched];
	
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
	
	[self performSelectorInBackground:@selector(updateAppSettings) withObject:nil];
	[self performSelectorInBackground:@selector(updateExpiryDate) withObject:nil];
	
	NSDate *playDate = [AppSettings videoAdPlayDate];
	if (playDate == nil) {
		[self performSelectorInBackground:@selector(downloadVideoAd) withObject:nil];
	} else if ([playDate timeIntervalSinceNow] < 0 && [AppSettings playCountForVideoAd] == 0) {
		[self playVideoAd];
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


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	[LoadingView dismiss];
}


#pragma mark -
#pragma mark App Settings

- (void)updateAppSettings
{
	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Don't update app settings more than once a day
		if ([[NSDate date] timeIntervalSinceDate:[AppSettings lastTimeAppSettingsUpdated]] < [AppSettings updateAppSettingsInterval])
			goto done_update_app_settings;
		
		NSURL *settingsURL;
		if ([Utility OSVersionGreaterOrEqualTo:@"4.0"]) {
			settingsURL = [NSURL URLWithString:APP_SETTINGS_XML];
		} else {
			settingsURL = [NSURL URLWithString:APP_SETTINGS_OS3_XML];
		}
		
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfURL:settingsURL];
		if (settingsDict == nil)
			goto done_update_app_settings;
		
		[AppSettings setAppSettings:settingsDict];
		[AppSettings setLastTimeAppSettingsUpdated:[NSDate date]];

	done_update_app_settings:
		[pool release];
	}
}

- (void)updateExpiryDate
{
	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Don't update expiry date too often
		if ([[NSDate date] timeIntervalSinceDate:[AppSettings lastTimeExpiryDateUpdated]] < [AppSettings updateExpiryDateInterval])
			goto done_get_expiry_date;
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"MMMM dd, yyyy"];
		
		NSString *s = [NSString stringWithFormat:@"%@/expiry_date?udid=%@", API_BASE_URL, [AppSettings deviceId]];
		NSError *error = nil;
		NSString *dateString = [NSString stringWithContentsOfURL:[NSURL URLWithString:s] encoding:NSUTF8StringEncoding error:&error];
		
		if (dateString != nil && [dateString length] > 0) {
			NSDate *expiryDate = [df dateFromString:dateString];
			[AppSettings setExpiryDate:expiryDate];
		}
		
		[df release];

	done_get_expiry_date:
		[pool release];
	}
}

- (void)downloadVideoAd
{
	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSDictionary *dict = [AppSettings videoAdDict];
		if (dict == nil)
			goto done_download_video_ad;
		
		// download the video file
		NSString *s = [dict objectForKey:@"video_url"];
		NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:s]];
		[videoData writeToFile:[AppSettings videoAdFilePath] atomically:YES];
		
		// download the background image file
		s = [dict objectForKey:@"bg_url"];
		NSData *bgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:s]];
		[bgData writeToFile:[AppSettings videoAdBgFilePath] atomically:YES];
		
		[AppSettings setVideoAdPlayDate];
		
	done_download_video_ad:
		[pool release];
	}
}

- (void)playVideoAd
{
	[AppSettings setPlayCountForVideoAd:1];
	VideoAdViewController *controller = [[VideoAdViewController alloc] init];
	[tabBarController presentModalViewController:controller animated:YES];
	[controller release];
	
	[FlurryAPI logEvent:@"playVideoAd"];
}
	
@end
