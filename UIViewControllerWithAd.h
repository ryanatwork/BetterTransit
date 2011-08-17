//
//  UIViewControllerWithAd.h
//  Showtime
//
//  Created by yaogang@enflick on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIViewController.h"
#import "AdWhirlManager.h"

@interface UIViewControllerWithAd : CustomUIViewController <AdWhirlManagerDelegate>
{
	CGFloat adOffset;
	UIView *adBanner;
	AdWhirlView *awView;
	AdWhirlManager *awManager;
}

@property (nonatomic, retain) UIView *adBanner;
@property (nonatomic, assign) CGFloat adOffset;

- (void)createAd;
- (void)setAdPosition:(BOOL)animated;
- (void)setAdPositionAnimated;

// subclass must overwrite the following methods
- (NSUInteger)adZone;
- (void)updateUI;

@end
