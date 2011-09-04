//
//  AppSettings.m
//  BetterTransit
//
//  Created by Yaogang Lian on 1/21/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "AppSettings.h"


@implementation AppSettings


+ (NSString *)startupScreen
{
	NSString *s = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STARTUP_SCREEN];
	if (s == nil) {
		s = @"Nearby";
	}
	return s;
}
	
+ (NSString *)nearbyRadius
{
	NSString *s = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_NEARBY_RADIUS];
	if (s == nil) {
#ifdef METRIC_UNIT
		s = @"5 km";
#else
		s = @"5 mi";
#endif
	}
	return s;
}
	
+ (NSString *)maxNumNearbyStops
{
	NSString *s = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_MAX_NUM_NEARBY_STOPS];
	if (s == nil) {
		s = @"10";
	}
	return s;
}


#pragma mark -
#pragma mark App settings

NSDictionary *appSettings = nil;

+ (void)loadAppSettings
{
	[self performSelectorInBackground:@selector(loadAppSettingsInBackground) withObject:nil];
}


+ (void)loadAppSettingsInBackground
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (appSettings != nil) {
		[appSettings release];
	}
	
	appSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appSettings"] retain];
	[pool release];
}

+ (void)setAppSettings:(NSDictionary *)dict
{
	if (appSettings != nil) {
		[appSettings release];
	}
	appSettings = [dict retain];
	
	[[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"appSettings"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)videoAdDict
{
	if (appSettings == nil) return nil;
	
	return [appSettings objectForKey:@"video_ad"];
}

+ (int)updateExpiryDateInterval
{
	// the time interval between checking expiry date, in seconds
	int interval = 2*60;
	if (appSettings != nil) {
		id s = [appSettings objectForKey:@"check_expiry_interval"];
		if (s != nil) {
			interval = [s intValue];
		}
	}
	return interval;
}

+ (int)updateAppSettingsInterval
{
	// the time interval betwee checking app settings, in seconds
	int interval = 24*60*60;
	if (appSettings != nil) {
		id s = [appSettings objectForKey:@"check_app_settings_interval"];
		if (s != nil) {
			interval = [s intValue];
		}
	}
	return interval;
}

+ (NSString *)videoAdFilePath
{
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [docsPath stringByAppendingPathComponent:@"video_ad.mov"];
}

+ (BOOL)videoAdExists
{
	NSString *filePath = [AppSettings videoAdFilePath];
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (NSString *)videoAdBgFilePath
{
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [docsPath stringByAppendingPathComponent:@"video_ad_bg.png"];
}

+ (BOOL)videoAdBgExists
{
	NSString *filePath = [AppSettings videoAdBgFilePath];
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (int)playCountForVideoAd
{
	NSDictionary *dict = [AppSettings videoAdDict];
	if (dict == nil) return -1;
	
	NSString *key = [NSString stringWithFormat:@"play_count_%@", [dict objectForKey:@"id"]];
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void)setPlayCountForVideoAd:(int)i
{
	NSDictionary *dict = [AppSettings videoAdDict];
	NSString *key = [NSString stringWithFormat:@"play_count_%@", [dict objectForKey:@"id"]];
	[[NSUserDefaults standardUserDefaults] setInteger:i forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)videoAdPlayDate
{
	NSDictionary *dict = [AppSettings videoAdDict];
	if (dict == nil) return nil;
	
	NSString *key = [NSString stringWithFormat:@"play_date_%@", [dict objectForKey:@"id"]];
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setVideoAdPlayDate
{
	NSDictionary *dict = [AppSettings videoAdDict];
	if (dict == nil) return;
	
	NSDate *playDate;
	
	NSUInteger duration = [AppSettings campaignDuration];
	if (duration == 0) {
		playDate = [NSDate date];
	} else {
		NSUInteger n = arc4random()%duration;
		playDate = [[NSDate date] dateByAddingTimeInterval:n*24*60*60];
	}
	
	NSString *key = [NSString stringWithFormat:@"play_date_%@", [dict objectForKey:@"id"]];
	[[NSUserDefaults standardUserDefaults] setObject:playDate forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)campaignDuration
{
	NSDictionary *dict = [AppSettings videoAdDict];
	if (dict == nil) return 0;
	
	return [[dict objectForKey:@"duration"] integerValue];
}

+ (BOOL)staticVideoAd
{
	NSDictionary *dict = [AppSettings videoAdDict];
	if (dict == nil) return YES;
	
	return [[dict objectForKey:@"static"] boolValue];
}
	

#pragma mark -
#pragma mark Ads

+ (BOOL)supportAds
{
	BOOL b = FALSE;
	if (appSettings != nil) {
		id s = [appSettings objectForKey:@"support_ads"];
		if (s != nil) {
			b = [s boolValue];
		}
	}
	return b;
}

+ (BOOL)supportRemoveAds
{
	BOOL b = FALSE;
	if (appSettings != nil) {
		id s = [appSettings objectForKey:@"support_remove_ads"];
		if (s != nil) {
			b = [s boolValue];
		}
	}
	return b;
}

+ (BOOL)adFree
{
	if (![AppSettings supportAds]) return TRUE;
	
	if ([AppSettings lifetimeAdsFree]) return TRUE;
	
	NSDate *date = [AppSettings expiryDate];
	if (date == nil) {
		return NO;
	} else {
		return ([[AppSettings expiryDate] timeIntervalSinceNow] > 0);
	}
}

+ (BOOL)lifetimeAdsFree
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_LIFETIME_ADS_FREE];
}	

+ (NSString *)expiryDateString
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];
	
	NSString *s = [df stringFromDate:[AppSettings expiryDate]];
	[df release];
	
	return s;
}

+ (NSDate *)expiryDate
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"expiryDate"];
}	
	
+ (void)setExpiryDate:(NSDate *)date
{
	[AppSettings setLastTimeExpiryDateUpdated:[NSDate date]];
	
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"expiryDate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)lastTimeExpiryDateUpdated
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTimeExpiryDateUpdated"];
}

+ (void)setLastTimeExpiryDateUpdated:(NSDate *)date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastTimeExpiryDateUpdated"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark App settings

+ (NSDate *)lastTimeAppSettingsUpdated
{	
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTimeAppSettingsUpdated"];
}

+ (void)setLastTimeAppSettingsUpdated:(NSDate *)date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastTimeAppSettingsUpdated"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark Misc.

+ (NSString *)deviceId
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}

@end
