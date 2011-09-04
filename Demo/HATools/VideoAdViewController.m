//
//  VideoAdViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 1/21/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "VideoAdViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppSettings.h"
#import "Utility.h"
#import "FlurryAPI.h"


@implementation VideoAdViewController

@synthesize blackView, bgView;


#pragma mark -
#pragma mark Initialize

- (id)init
{
	if (self = [super initWithNibName:@"VideoAdViewController" bundle:[NSBundle mainBundle]]) {
		self.wantsFullScreenLayout = YES;
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		firstTimeShown = YES;
		noVideo = [AppSettings staticVideoAd];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSData *imageData = [NSData dataWithContentsOfFile:[AppSettings videoAdBgFilePath]];
	bgView.image = [UIImage imageWithData:imageData];
	
	if (!noVideo) {
		self.blackView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
		blackView.backgroundColor = [UIColor blackColor];
		blackView.opaque = YES;
		[self.view addSubview:blackView];
		[self.view bringSubviewToFront:blackView];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	if (firstTimeShown && !noVideo) {
		[self playVideoAd];
		firstTimeShown = NO;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.blackView = nil;
	self.bgView = nil;
}

- (void)dealloc
{
	[blackView release], blackView = nil;
	[bgView release], bgView = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UI response methods

- (IBAction)cancel
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)followLink
{
	[self dismissModalViewControllerAnimated:YES];
	
	NSString *s = [[AppSettings videoAdDict] objectForKey:@"click_url"];
	if (s != nil && [s length] > 0) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:s]];
	}
	
	[FlurryAPI logEvent:@"followLinkAfterVideoAd"];
}


#pragma mark -
#pragma mark Download and play video ad

- (void)playVideoAd
{
	NSString *filePath = [AppSettings videoAdFilePath];
	
	if ([Utility OSVersionGreaterOrEqualTo:@"4.0"]) {
		MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
		moviePlayer.view.frame = self.view.bounds;
		[self.view addSubview:moviePlayer.view];
			
		moviePlayer.movieSourceType = MPMovieSourceTypeFile;
		moviePlayer.controlStyle = MPMovieControlStyleNone;
		
		// Register for the playback finished notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:moviePlayer];
		[moviePlayer play];
		
	} else {
		// iPhone SDK 3.1 only supports playing movie in fullscreen mode
		MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
		moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
		moviePlayer.movieControlMode = MPMovieControlModeHidden;
		
		// Register for the playback finished notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:moviePlayer];
		// Movie playback is asynchronous, so this method returns immediately.
		[moviePlayer play];
	}
}

- (void)movieFinishedCallback:(NSNotification *)notification
{
	[blackView removeFromSuperview];
	MPMoviePlayerController *moviePlayer = [notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayer];
	if ([Utility OSVersionGreaterOrEqualTo:@"4.0"]) {
		[moviePlayer.view removeFromSuperview];
	} else {
		// Release the movie instance created during view loading
		[moviePlayer release];
	}
}

@end
