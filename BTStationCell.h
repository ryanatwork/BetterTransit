//
//  BTStationCell.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastScrollingCell.h"
#import "BTStation.h"

@interface BTStationCell : FastScrollingCell
{
	BTStation *station;
	UIImage *iconImage;
}

@property (nonatomic, retain) BTStation *station;
@property (nonatomic, retain) UIImage *iconImage;

- (void)drawCellView:(CGRect)rect;

@end
