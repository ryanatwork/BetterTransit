//
//  Utility.m
//  BetterTransit
//
//  Created by Yaogang Lian on 8/15/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
#include <sys/sysctl.h>

@implementation Utility


+ (NSString *)appVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)appName
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (NSString *)deviceType
{
	return [Utility getSysInfoByName:"hw.machine"];
}

+ (NSString *)diagnosticInfo
{
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"App: %@\n", [Utility appName]];
	[s appendFormat:@"Version: %@\n", [Utility appVersion]];
	[s appendFormat:@"System: %@ %@\n", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
	[s appendFormat:@"Device: %@ (%@)", [[UIDevice currentDevice] model], [Utility deviceType]];
	return s;
}

+ (BOOL)OSVersionGreaterOrEqualTo:(NSString*)reqSysVer
{
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	return ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
}

+ (void)showDialog:(NSString *)s
{
	[self performSelectorOnMainThread:@selector(showDialogOnMainThread:) withObject:s waitUntilDone:NO];
}

+ (void)showDialogOnMainThread:(NSString *)s
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
													message:s 
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

+ (void)showErrorDialog:(NSString *)s
{
	[self performSelectorOnMainThread:@selector(showErrorDialogOnMainThread:) withObject:s waitUntilDone:NO];
}

+ (void)showErrorDialogOnMainThread:(NSString *)s
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:s 
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

+ (NSString *)formattedStringForDistance:(double)distance
{
#ifdef METRIC_UNIT
	if (distance < 500) {
		return [NSString stringWithFormat:@"%0.0f m", distance];
	} else {
		return [NSString stringWithFormat:@"%0.1f km", distance/1000];
	}
#endif
	
#ifdef ENGLISH_UNIT
	return [NSString stringWithFormat:@"%0.1f mi", distance / 1609.344];
#endif
}

@end
