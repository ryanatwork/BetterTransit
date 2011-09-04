//
//  EnhancedDefaultCell.h
//  Showtime
//
//  Created by Yaogang Lian on 1/15/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastScrollingCell.h"

@interface EnhancedDefaultCell : FastScrollingCell
{
	NSString *label;
	UIImage *image;
}

@property (nonatomic, copy) NSString *label;
@property (nonatomic, retain) UIImage *image;

- (void)drawCellView:(CGRect)rect;
+ (CGFloat)rowHeightForText:(NSString *)s;

@end