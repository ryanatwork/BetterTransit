//
//  HAHorizontalPickerView.h
//  BetterTransit
//
//  Created by Yaogang Lian on 6/4/11.
//  Copyright 2011 Happen Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAHorizontalPickerView : UIView
{
    UIScrollView *_scrollView;
	UIImageView *_overlay;
}

- (void)layoutCells;

@end