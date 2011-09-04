//
//  WebViewController.h
//  Showtime
//
//  Created by Yaogang Lian on 3/20/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController
<UIWebViewDelegate, UIActionSheetDelegate>
{
	NSURL *currentURL;
	
	NSInteger mode; // MODE_MODAL, MODE_PUSHED
	UIWebView *webView;
	UIToolbar* toolbar;
	UIActivityIndicatorView *activityIndicator;
	
	UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *actionButton;
}

@property (nonatomic, retain) NSURL *currentURL;
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;

- (id)initWithURL:(NSURL*)url;
- (IBAction)actionPressed:(id)sender;
- (void)dismissWebView;

@end
