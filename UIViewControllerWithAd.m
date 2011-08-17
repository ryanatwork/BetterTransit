//
//  UIViewControllerWithAd.m
//  Showtime
//
//  Created by yaogang@enflick on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerWithAd.h"
#import "AppSettings.h"


@implementation UIViewControllerWithAd

@synthesize adBanner, adOffset;


// Subclass should overwrite with proper ad zone
- (NSUInteger)adZone
{
	return AD_ZONE_1;
}

- (void)updateUI
{
	// subclass should overwrite this
	/*
	 CGRect contentFrame = self.view.bounds;
	 contentFrame.size.height -= adOffset;
	 mainTableView.frame = contentFrame;
	 */
}


#pragma mark -
#pragma mark View life cycles

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (AD_FREE) {
		if (adBanner != nil) {
			[adBanner removeFromSuperview];
			self.adBanner = nil;
			awView = nil;
			awManager = nil;
		}
		self.adOffset = 0.0f;
		[self updateUI];
		
	} else {
		[self createAd]; //recreate the ad banner but keep in mind we cache awView in AdWhirlManager so this is fast
		[awView doNotIgnoreNewAdRequests];
		[awView doNotIgnoreAutoRefreshTimer];
		[self setAdPosition:NO]; // will call updateUI inside
		
		// We should refresh ads after setAdPostion, otherwise old ads won't show.
		// Also we delay the refresh by 0.5s to make the user experience smoother.
		if (arc4random()%2 == 0) {
			[awView performSelector:@selector(requestFreshAd) withObject:nil afterDelay:0.5f];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (!AD_FREE) {
		if (awView != nil) {
			[awView ignoreNewAdRequests];
			[awView ignoreAutoRefreshTimer];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (AD_FREE) {
		self.adOffset = 0.0f;
		[self updateUI];
	} else {
		[self setAdPosition:YES]; // will call update UI inside
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	[AdWhirlManager removeDelegateForAdZone:[self adZone]];
	awView = nil;
	awManager = nil;
	self.adBanner = nil;
}


- (void)dealloc
{
	[AdWhirlManager removeDelegateForAdZone:[self adZone]];
	awView = nil;
	awManager = nil;
	[adBanner release], adBanner = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark AdWhirl

- (void)createAd
{	
	awManager = [AdWhirlManager awManagerForZone:[self adZone]];
	awManager.delegate = self;
	awView = awManager.awView;
	
	CGFloat bannerHeight = 0.0f;
	CGRect frame;
	if ([awView adExists]) {
		// Show the awView immediately if it's already loaded
		bannerHeight = [awView actualAdSize].height;
		frame.origin = CGPointMake(0.0f, 0.0f);
		frame.size = CGSizeMake(self.view.bounds.size.width, bannerHeight);
	} else {
		// Place the awView offscreen until it loads successfully
		frame.origin = CGPointMake(0.0f, -50.0f);
		frame.size = CGSizeMake(self.view.bounds.size.width, 50.0f);
	}
	
	if (adBanner == nil) {
		self.adBanner = [[[UIView alloc] initWithFrame:frame] autorelease];
		adBanner.backgroundColor = [UIColor clearColor];
		[self.view addSubview:adBanner];
	}
	
	CGSize actualAdSize = [awView actualAdSize];
	awView.frame = CGRectMake((frame.size.width-actualAdSize.width)/2.0, 0, actualAdSize.width, actualAdSize.height);
	[adBanner addSubview:awView];
}

- (void)setAdPosition:(BOOL)animated
{
	CGFloat animationDuration = animated ? 0.2f : 0.0f;
	CGRect contentFrame = self.view.bounds;
	
	[awView rotateToOrientation:self.interfaceOrientation];
	CGSize actualAdSize = [awView actualAdSize];
	
	if ([awView adExists]) {
		self.adOffset = actualAdSize.height;
	} else {
		self.adOffset = 0.0f;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	[self updateUI];
	adBanner.frame = CGRectMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame)-adOffset, contentFrame.size.width, actualAdSize.height);
	awView.frame = CGRectMake((contentFrame.size.width-actualAdSize.width)/2.0, 0, actualAdSize.width, actualAdSize.height);
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark AdWhirlManagerDelegate methods

- (UIViewController *)viewControllerForPresentingModalView
{
	return self.navigationController;
}

- (void)setAdPositionAnimated
{
	[self setAdPosition:YES];
}

@end
