//
//  TwitterViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 11/1/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuth.h"

@interface TwitterViewController : UIViewController <UIWebViewDelegate, OAuthTwitterCallbacks>
{
	NSOperationQueue *queue;
	OAuth *oAuth;
	
	UIWebView *webView;
}

@property (nonatomic, retain) OAuth *oAuth;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)share;
- (void)follow;

@end