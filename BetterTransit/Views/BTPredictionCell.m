//
//  BTPredictionCell.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTPredictionCell.h"


@implementation BTPredictionCell

@synthesize imageView, routeLabel, destinationLabel, estimateLabel, idLabel;

/*
 - (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
 if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
 // Initialization code
 }
 return self;
 }
 */


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc
{
	[imageView release];
	[routeLabel release];
	[destinationLabel release];
	[estimateLabel release];
	[idLabel release];
    [super dealloc];
}

@end
