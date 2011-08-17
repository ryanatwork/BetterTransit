//
//  LoadingView.m
//  BetterTransit
//
//  Created by Yaogang Lian on 11/2/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView


static LoadingView *sharedInstance = nil;
+ (LoadingView *)sharedInstance
{
	if (sharedInstance == nil) {
		NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:nil options:nil];
		sharedInstance = [[nibViews objectAtIndex:0] retain];
		sharedInstance.frame = CGRectMake(0, 0, 320, 480);
	}
	return sharedInstance;
}

+ (void)showWithText:(NSString *)text
{
	LoadingView *loadingView = [LoadingView sharedInstance];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	if (text != nil) {
		[loadingView setText:text];
	} else {
		[loadingView setText:@"Loading..."];
	}
	
	UIWindow *w = [[UIApplication sharedApplication] keyWindow];
	[w addSubview:loadingView];
}

+ (void)showWithText:(NSString *)text inView:(UIView *)v
{
	LoadingView *loadingView = [LoadingView sharedInstance];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	if (text != nil) {
		[loadingView setText:text];
	} else {
		[loadingView setText:@"Loading..."];
	}
	[v addSubview:loadingView];
}	

+ (void)show
{
	[LoadingView showWithText:@"Loading..."];
}

+ (void)dismiss
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[[LoadingView sharedInstance] removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
	[backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
	[loadingLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin)];
	[activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin)];
}

- (void)setText:(NSString*)text
{
	[loadingLabel setText:text];
}

- (void)dealloc {
    [super dealloc];
}


@end
