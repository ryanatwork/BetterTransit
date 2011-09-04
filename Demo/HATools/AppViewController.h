//
//  AppViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 11/3/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ClipView.h"

@interface AppViewController : UIViewController
{
	UIScrollView *contentScrollView;
	UIImageView *bgView;
	
	UILabel *appNameLabel;
	UILabel *companyNameLabel;
	UIImageView *appIconView;
	
	UILabel *descriptionLabel;
	UIScrollView *imageScrollView;
	ClipView *clipView;
	
	ASINetworkQueue *networkQueue;
	NSString *baseURLString;
	NSDictionary *appDict;
	NSDictionary *infoDict;
	NSMutableDictionary *imageDict;
	NSMutableArray *screenshots;
}

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *bgView;
@property (nonatomic, retain) IBOutlet UILabel *appNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *companyNameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *appIconView;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, retain) IBOutlet ClipView *clipView;
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, retain) NSDictionary *appDict;
@property (nonatomic, retain) NSDictionary *infoDict;
@property (nonatomic, retain) NSMutableDictionary *imageDict;
@property (nonatomic, retain) NSMutableArray *screenshots;


- (void)layoutScreenshots;
- (IBAction)downloadApp:(id)sender;


@end
