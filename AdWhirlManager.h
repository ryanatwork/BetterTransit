//
//  AdWhirlManager.h
//  AdWhirlDemo
//
//  Created by yaogang@enflick on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"


@protocol AdWhirlManagerDelegate <NSObject>
- (UIViewController *)viewControllerForPresentingModalView;
- (void)setAdPositionAnimated;
@end


@interface AdWhirlManager : NSObject <AdWhirlDelegate>
{
	AdWhirlView *awView;
	NSUInteger adZone;
	NSObject<AdWhirlManagerDelegate> *delegate;
}

@property (nonatomic, retain) AdWhirlView *awView;
@property (nonatomic, assign) NSUInteger adZone;
@property (nonatomic, assign) id<AdWhirlManagerDelegate> delegate;

+ (AdWhirlManager *)awManagerForZone:(NSUInteger)zone;
+ (void)removeDelegateForAdZone:(NSUInteger)zone;
+ (void)preloadAds;

@end