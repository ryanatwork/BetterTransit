//
//  AdWhirlManager.m
//  AdWhirlDemo
//
//  Created by yaogang@enflick on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdWhirlManager.h"
#import "Constants.h"
#import "AdWhirlView.h"

@implementation AdWhirlManager

@synthesize awView, adZone, delegate;

/*
static BOOL adFree = FALSE;
+ (BOOL)testAdFree
{
	if (!adFree) {
		[[AdWhirlManager class] performSelector:@selector(changeAdFree) withObject:nil afterDelay:10.0f];
	}
	return adFree;
}

+ (void)changeAdFree
{
	adFree = TRUE;
}
*/

#pragma mark -
#pragma mark awManagers

static NSMutableDictionary *awManagers = nil;

+ (AdWhirlManager *)awManagerForZone:(NSUInteger)zone
{
	if (awManagers == nil) {
		awManagers = [[NSMutableDictionary alloc] initWithCapacity:3];
	}
	
	AdWhirlManager *manager = [awManagers objectForKey:[NSNumber numberWithInt:zone]];
	if (manager == nil) {
		manager = [[AdWhirlManager alloc] init];
		manager.adZone = zone;
		manager.delegate = nil;
		[awManagers setObject:manager forKey:[NSNumber numberWithInt:zone]];
		[manager release];
	}
	return manager;
}

+ (void)removeDelegateForAdZone:(NSUInteger)zone
{
	AdWhirlManager *manager = [awManagers objectForKey:[NSNumber numberWithInt:zone]];
	[manager setDelegate:nil];
}

+ (void)preloadAds
{
	[AdWhirlManager awManagerForZone:AD_ZONE_1];
	[AdWhirlManager awManagerForZone:AD_ZONE_2];
	//[AdWhirlManager awManagerForZone:AD_ZONE_3];
}


#pragma mark -
#pragma mark Object life cycle

- (id)init
{
	if (self = [super init]) {
		self.awView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
		awView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		// when awView is created, we turn off timer and new ad requests since we want to refresh ads only when the view
		// becomes visisble (and stop refreshing ads when the view disappears).
		[awView ignoreAutoRefreshTimer];
	}
	return self;
}

- (void)dealloc
{
	[awView ignoreNewAdRequests];
	[awView ignoreAutoRefreshTimer];
	[awView setDelegate:nil];
	[awView release], awView = nil;
	
	delegate = nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark AdWhirlDelegate methods

- (NSString *)adWhirlApplicationKey
{
	return ADWHIRL_API_KEY;
}

- (BOOL)adWhirlTestMode
{
	return NO;
}

- (UIViewController *)viewControllerForPresentingModalView
{
	if (delegate != nil && [delegate respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
		return [delegate viewControllerForPresentingModalView];
	} else {
		// return a dummy UIViewController so that ads can be retrieved during preloading
		return [[[UIViewController alloc] init] autorelease];
	}
}

- (void)adWhirlDidReceiveConfig:(AdWhirlView *)adWhirlView
{
	//NSLog(@"adWhirl did receive config");
	//[adWhirlView requestFreshAd];
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView	
{
	//NSLog(@"adWhirl did receive ad");
	if (delegate != nil) {
		if ([delegate respondsToSelector:@selector(setAdPositionAnimated)]) {
			[delegate performSelectorOnMainThread:@selector(setAdPositionAnimated) withObject:nil waitUntilDone:NO];
		}
	}
}

- (void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo
{
	//NSLog(@"adWhirl did fail to receive ad");
	// No need to adjust since the old ad is still shown
	/*
	 // This delegate method is called quite often, thus 
	if (delegate != nil) {
		if ([delegate respondsToSelector:@selector(setAdPositionAnimated)]) {
			[delegate performSelectorOnMainThread:@selector(setAdPositionAnimated) withObject:nil waitUntilDone:NO];
		}
	}
	 */
}

- (void)adWhirlWillPresentFullScreenModal
{
	//NSLog(@"adWhirl will present fullscreen modal");
	//It's recommended to invoke whatever you're using as a "Pause Menu" so your
    //game won't keep running while the user is "playing" with the Ad (for example, iAds)
	if ([delegate respondsToSelector:@selector(adWhirlWillPresentFullScreenModal)]) {
		[delegate performSelectorOnMainThread:@selector(adWhirlWillPresentFullScreenModal) withObject:nil waitUntilDone:YES];
	}
}

- (void)adWhirlDidDismissFullScreenModal
{
	//NSLog(@"adWhirl did dismiss fullscreen modal");
	//Once the user closes the Ad he'll want to return to the game and continue where
    //he left it
	if ([delegate respondsToSelector:@selector(adWhirlDidDismissFullScreenModal)]) {
		[delegate performSelectorOnMainThread:@selector(adWhirlDidDismissFullScreenModal) withObject:nil waitUntilDone:YES];
	}
}

/*
#pragma mark AdWhirl UI customization

- (UIColor *)adWhirlAdBackgroundColor
{
	return [UIColor whiteColor];
}

- (UIColor *)adWhirlTextColor
{
	return [UIColor blackColor];
}

- (UIColor *)adWhirlSecondaryTextColor
{
	return [UIColor blackColor];
}
*/


#pragma mark -
#pragma mark AdMob

- (NSString *)admobPublisherID
{
	return ADMOB_APP_ID;
}


#pragma mark -
#pragma mark InMobi

- (NSString *)inMobiAppID
{
	return INMOBI_APP_ID;
}

@end
