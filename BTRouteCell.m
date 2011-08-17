//
//  BTRouteCell.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTRouteCell.h"

#define MAIN_FONT_SIZE 14
#define SECONDARY_FONT_SIZE 13

@implementation BTRouteCell

@synthesize route, iconImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		cellView.backgroundColor = [UIColor clearColor];
		self.route = nil;
		self.iconImage = nil;
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return self;
}

- (void)drawCellView:(CGRect)rect
{
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
	} else {
		mainTextColor = [UIColor blackColor];
	}
	
	// Set the color for the main text items.
	[mainTextColor set];
	
	[route.desc drawInRect:CGRectMake(38, 12, 240, 20)
					withFont:mainFont
			   lineBreakMode:UILineBreakModeTailTruncation
				   alignment:UITextAlignmentLeft];
	
	
	// Show route number if the route icon doesn't exist
	if (self.iconImage == nil) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		UIColor *bgColor = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1.0];
		[bgColor set];
		CGContextFillRect(context, CGRectMake(0, 0, 32, 44));
		
		[[UIColor whiteColor] set];
		[route.routeId drawInRect:CGRectMake(0, 12, 32, 20)
						 withFont:[UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE]
					lineBreakMode:UILineBreakModeClip
						alignment:UITextAlignmentCenter];
	} else {
		[iconImage drawInRect:CGRectMake(6, 10, 24, 24)];
	}
}

- (void)dealloc
{
	[route release], route = nil;
	[iconImage release], iconImage = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Accessibility

- (NSString *)accessibilityLabel
{
	return [NSString stringWithFormat:@"%@", route.desc];
}

@end
