//
//  CustomUITabBarController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 9/5/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "CustomUITabBarController.h"


@implementation CustomUITabBarController

- (void)viewDidLoad
{
	[super viewDidLoad];
	/*
	CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 48);
	UIView *v = [[UIView alloc] initWithFrame:frame];
	[v setBackgroundColor:COLOR_TAB_BAR_BG];
	[self.tabBar insertSubview:v atIndex:0];
	[v release];
     */
	
	if (SUPPORT_CHECKIN) {
		[self addCenterButtonWithImage:[UIImage imageNamed:@"icn_checkin.png"] highlightImage:nil];
	}
}

// Create a custom UIButton and add it to the center of our tab bar
- (void)addCenterButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(showCheckInView:) forControlEvents:UIControlEventTouchUpInside];
	
	CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
	if (heightDifference < 0) {
		button.center = CGPointMake(self.tabBar.frame.size.width/2.0, self.tabBar.frame.size.height/2.0);
	} else {
		CGPoint center = CGPointMake(self.tabBar.frame.size.width/2.0, self.tabBar.frame.size.height/2.0);
		center.y = center.y - heightDifference/2.0;
		button.center = center;
	}
	
	[self.tabBar addSubview:button];
}

- (void)showCheckInView:(id)sender
{
	self.selectedIndex = 2;
}

@end
