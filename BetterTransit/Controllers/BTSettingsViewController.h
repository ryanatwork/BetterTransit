//
//  BTSettingsViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/17/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTransit.h"
#import "ListViewController.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import <MessageUI/MessageUI.h>


@interface BTSettingsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,
MFMailComposeViewControllerDelegate, ListViewControllerDelegate> 
{
	BTTransit *transit;
	UITableView *mainTableView;
	UITableViewCell *purchaseAdsFreeCell;
	int sectionOffset;
	
	NSArray *startupScreenOptions;
	NSArray *nearbyRadiusOptions;
	NSArray *maxNumNearbyStopsOptions;
	
	ASINetworkQueue *networkQueue;
	NSArray *appArray;
	NSMutableDictionary *iconDictionary;
}

@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *purchaseAdsFreeCell;
@property (nonatomic, retain) NSArray *startupScreenOptions;
@property (nonatomic, retain) NSArray *nearbyRadiusOptions;
@property (nonatomic, retain) NSArray *maxNumNearbyStopsOptions;

// Lists
- (void)setSelectedIndex:(NSUInteger)index forListName:(NSString *)name;

// Email
- (void)showFAQ;
- (void)showBlog;
- (void)sendFeedback;

- (void)composeEmail;
- (void)displayComposeSheet;
- (void)launchMailAppOnDevice;

// In-app purchase
- (IBAction)buyAdsFreeVersion:(id)sender;
- (void)removeAds;

@end
