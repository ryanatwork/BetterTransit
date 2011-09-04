//
//  LoadingView.h
//  BetterTransit
//
//  Created by Yaogang Lian on 11/2/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView
{
	IBOutlet UILabel *loadingLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *backgroundView;
}

+ (void)show;
+ (void)showWithText:(NSString *)text;
+ (void)showWithText:(NSString *)text inView:(UIView *)v;
+ (void)dismiss;

- (void)setText:(NSString*)text;

@end
