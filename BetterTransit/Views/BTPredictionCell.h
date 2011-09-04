//
//  BTPredictionCell.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BTPredictionCell : UITableViewCell
{
	UIImageView *imageView;
	UILabel *routeLabel;
	UILabel *destinationLabel;
	UILabel *estimateLabel;
	UILabel *idLabel; // show route ID when route icons are not available
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *routeLabel;
@property (nonatomic, retain) IBOutlet UILabel *destinationLabel;
@property (nonatomic, retain) IBOutlet UILabel *estimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *idLabel;

@end
