//
//  TwitterViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/31/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "TwitterViewController.h"
#import "OAuth+UserDefaults.h"
#import "ASIFormDataRequest.h"
#import "Utility.h"
#import "NSString+Trim.h"
#import "LoadingView.h"
#import "FlurryAPI.h"


@implementation TwitterViewController

@synthesize oAuth, webView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Twitter";
	
	queue = [[NSOperationQueue alloc] init];
	
	oAuth = [[OAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY andConsumerSecret:OAUTH_CONSUMER_SECRET];
	[oAuth loadOAuthTwitterContextFromUserDefaults];
	oAuth.delegate = self;
	
	// setup web view
	webView.dataDetectorTypes = UIDataDetectorTypeNone;
	webView.scalesPageToFit = YES;
	webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (oAuth.user_id == nil) {
		// new user
		NSInvocationOperation *operation = [[NSInvocationOperation alloc]
											initWithTarget:oAuth
											selector:@selector(synchronousRequestTwitterToken)
											object:nil];
		[queue addOperation:operation];
		[operation release];
		
		[LoadingView show];
		
	} else {
		// returning user
		[LoadingView showWithText:@"Sharing..."];
		[self performSelector:@selector(share) withObject:nil afterDelay:0.0f];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[queue release], queue = nil;
	[oAuth release], oAuth = nil;
	[webView release], webView = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark OAuthTwitterCallbacks protocol

- (void)requestTwitterTokenDidSucceed:(OAuth *)_oAuth
{
	NSURL *myURL = [NSURL URLWithString:[NSString
										 stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@",
										 _oAuth.oauth_token]];
	[webView loadRequest:[NSURLRequest requestWithURL:myURL]];
}

- (void)requestTwitterTokenDidFail:(OAuth *)oAuth
{
	NSLog(@"request Twitter token did fail.");
	[LoadingView dismiss];
}

- (void)authorizeTwitterTokenDidSucceed:(OAuth *)_oAuth
{
	NSLog(@"authorize Twitter token did succeed");
    [oAuth saveOAuthTwitterContextToUserDefaults];
	[self share];
}

- (void)authorizeTwitterTokenDidFail:(OAuth *)_oAuth 
{
	NSLog(@"authorize Twitter token did fail");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)share
{
    // We assume that the user is authenticated by this point and we have a valid OAuth context,
    // thus no need to do context checking.
    NSString *postUrl = @"https://api.twitter.com/1/statuses/update.json";
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]
                                   initWithURL:[NSURL URLWithString:postUrl]];
    
    NSMutableDictionary *postInfo = [NSMutableDictionary
                                     dictionaryWithObject:TWITTER_SHARE_MESSAGE
                                     forKey:@"status"];
	
	for (NSString *key in [postInfo allKeys]) {
        [request setPostValue:[postInfo objectForKey:key] forKey:key];
    }
    
    [request addRequestHeader:@"Authorization"
                        value:[oAuth oAuthHeaderForMethod:@"POST"
                                                   andUrl:postUrl
                                                andParams:postInfo]];
    
    [request startSynchronous];
    
    //NSLog(@"Status posted. HTTP result code: %d", request.responseStatusCode);
	
	[request release];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks for sharing!" 
													message:@"Would you also like to follow us on Twitter?"
												   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];		
	[alert show];
	[alert release];
	
	[LoadingView dismiss];
	
	[FlurryAPI logEvent:@"SHARED_ON_TWITTER"];
}

- (void)follow
{
	NSString *postUrl = @"http://api.twitter.com/1/friendships/create.json";
	
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc]
                                   initWithURL:[NSURL URLWithString:postUrl]];
	
	NSMutableDictionary *postInfo = [NSMutableDictionary
                                     dictionaryWithObject:@"HappenApps"
                                     forKey:@"screen_name"];
	
	for (NSString *key in [postInfo allKeys]) {
        [request setPostValue:[postInfo objectForKey:key] forKey:key];
    }
	
	[request addRequestHeader:@"Authorization"
                        value:[oAuth oAuthHeaderForMethod:@"POST"
                                                   andUrl:postUrl
                                                andParams:postInfo]];
	
	[request startSynchronous];
    
    //NSLog(@"Status posted. HTTP result code: %d", request.responseStatusCode);
	
	[request release];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks for following @HappenApps" 
													message:@"We will keep you updated on Twitter."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[LoadingView dismiss];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[LoadingView showWithText:@"Following..."];
		[self performSelector:@selector(follow) withObject:nil afterDelay:0.0f];
	}
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	[LoadingView show];
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)wv 
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
	[LoadingView dismiss];
	
	// Scrape the webpage to find the PIN
	NSString *html = [wv stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	//NSLog(@"HTML: %@", html);
	
	NSString *PIN = nil;
	NSRange range1 = [html rangeOfString:@"id=\"oauth_pin\">"];
	if (range1.location != NSNotFound) {
		NSString *s = [html substringFromIndex:(range1.location + range1.length)];
		NSRange range2 = [s rangeOfString:@"</div>"];
		if (range2.location != NSNotFound) {
			PIN = [[s substringToIndex:range2.location] trim];
			NSLog(@"PIN: %@", PIN);
		}
	}
	
	// Then use the PIN to authorize the token
	if (PIN != nil && [PIN length] > 0) {
		NSInvocationOperation *operation = [[NSInvocationOperation alloc]
											initWithTarget:oAuth
											selector:@selector(synchronousAuthorizeTwitterTokenWithVerifier:)
											object:PIN];
		[queue addOperation:operation];
		[operation release];
		
		[LoadingView showWithText:@"Sharing..."];
	}
}

@end