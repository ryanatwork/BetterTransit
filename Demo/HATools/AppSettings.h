//
//  AppSettings.h
//  BetterTransit
//
//  Created by Yaogang Lian on 1/21/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppSettings : NSObject {

}

+ (NSString *)startupScreen;
+ (NSString *)nearbyRadius;
+ (NSString *)maxNumNearbyStops;

// General
+ (void)loadAppSettings;
+ (void)setAppSettings:(NSDictionary *)dict;

+ (NSDictionary *)videoAdDict;
+ (int)updateExpiryDateInterval;
+ (int)updateAppSettingsInterval;

+ (NSString *)videoAdFilePath;
+ (BOOL)videoAdExists;
+ (NSString *)videoAdBgFilePath;
+ (BOOL)videoAdBgExists;
+ (int)playCountForVideoAd;
+ (void)setPlayCountForVideoAd:(int)i;
+ (NSDate *)videoAdPlayDate;
+ (void)setVideoAdPlayDate;
+ (NSUInteger)campaignDuration;
+ (BOOL)staticVideoAd;

+ (BOOL)supportAds;
+ (BOOL)supportRemoveAds;
+ (BOOL)adFree;
+ (BOOL)lifetimeAdsFree;
+ (NSString *)expiryDateString;
+ (NSDate *)expiryDate;
+ (void)setExpiryDate:(NSDate *)date;

+ (NSDate *)lastTimeExpiryDateUpdated;
+ (void)setLastTimeExpiryDateUpdated:(NSDate *)date;

+ (NSDate *)lastTimeAppSettingsUpdated;
+ (void)setLastTimeAppSettingsUpdated:(NSDate *)date;

+ (NSString *)deviceId;

@end
