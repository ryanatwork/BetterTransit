//
//  BTFeedLoader.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTFeedLoader.h"
#import "Reachability.h"

@implementation BTFeedLoader

@synthesize prediction, delegate, currentStation;


#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super init]) {
		prediction = [[NSMutableArray alloc] init];
		
		networkQueue = [[ASINetworkQueue alloc] init];
		[networkQueue setDelegate:self];
		[networkQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
		[networkQueue setRequestDidFailSelector:@selector(requestDidFail:)];
	}
	return self;
}

// Subclasses should overwrite this
- (NSString *)dataSourceForStation:(BTStation *)station
{
	return @"";
}

// Subclasses should overwrite this
- (void)getPredictionForStation:(BTStation *)station
{
	// Check Internet connection
	if (![[Reachability reachabilityForInternetConnection] isReachable]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[delegate updatePrediction:@"No Internet connection"];
		return;
	}
	
	// Cancel previous requests
	[networkQueue cancelAllOperations];
	
	self.currentStation = station;
	
	NSURL *url = [NSURL URLWithString:[self dataSourceForStation:station]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0"];
	[request setAllowCompressedResponse:YES];
	[request setTimeOutSeconds:TIMEOUT_INTERVAL];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
							  [NSNumber numberWithInt:REQUEST_TYPE_GET_FEED] forKey:@"request_type"];
	[request setUserInfo:userInfo];
	[networkQueue addOperation:request];
	[networkQueue go];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)getFeedForEntry:(BTPredictionEntry *)entry
{
	// subclass should overwrite this method
}

- (void)dealloc
{
	[prediction release], prediction = nil;
	[currentStation release], currentStation = nil;
	
	[networkQueue cancelAllOperations];
	[networkQueue setDelegate:nil];
	[networkQueue release], networkQueue = nil;
	
	delegate = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark ASIHTTPRequest delegate methods

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[delegate updatePrediction:self.prediction];
}

- (void)requestDidFail:(ASIHTTPRequest *)request
{
	//NSLog(@"request did fail with error: %@", [request error]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[delegate updatePrediction:nil];
}

@end
