//
//  Utility.h
//  BetterTransit
//
//  Created by Yaogang Lian on 8/15/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utility : NSObject {

}

+ (NSString *)appVersion;
+ (NSString *)appName;
+ (NSString *)getSysInfoByName:(char *)typeSpecifier;
+ (NSString *)deviceType;
+ (NSString *)diagnosticInfo;
+ (BOOL)OSVersionGreaterOrEqualTo:(NSString*)reqSysVer;
+ (void)showDialog:(NSString *)s;
+ (void)showErrorDialog:(NSString *)s;
+ (NSString *)formattedStringForDistance:(double)distance;
+ (void)showToolTip;
+ (void)dismissToolTip;

@end
