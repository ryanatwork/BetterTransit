//
//  VideoAdViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 1/21/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VideoAdViewController : UIViewController
{
	UIView *blackView;
	UIImageView *bgView;
	BOOL firstTimeShown;
	BOOL noVideo;
}

@property (nonatomic, retain) UIView *blackView;
@property (nonatomic, retain) IBOutlet UIImageView *bgView;

- (void)playVideoAd;

- (IBAction)cancel;
- (IBAction)followLink;

@end
