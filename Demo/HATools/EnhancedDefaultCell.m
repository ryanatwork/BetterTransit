//
//  EnhancedDefaultCell.m
//  Showtime
//
//  Created by Yaogang Lian on 1/15/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "EnhancedDefaultCell.h"

#define MAIN_FONT_SIZE 16
#define MAX_TEXT_WIDTH 240
#define Y_PADDING 16

@implementation EnhancedDefaultCell

@synthesize label, image;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		cellView.backgroundColor = [UIColor clearColor];
		self.label = nil;
		self.image = nil;
    }
    return self;
}

- (void)drawCellView:(CGRect)rect
{
	// Color and font for the label
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
	} else {
		mainTextColor = [UIColor blackColor];
	}
	
	// Set the color for the main text items.
	[mainTextColor set];
	
	// Show label
	CGSize size = [label sizeWithFont:mainFont constrainedToSize:CGSizeMake(MAX_TEXT_WIDTH, CGFLOAT_MAX)
						lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat rowHeight = size.height + Y_PADDING;
	if (rowHeight < 72.0f) rowHeight = 72.0f;
	
	CGRect r = CGRectMake(56, (rowHeight-size.height)/2.0, MAX_TEXT_WIDTH, size.height);
	[self.label drawInRect:r
				  withFont:mainFont
			 lineBreakMode:UILineBreakModeWordWrap
				 alignment:UITextAlignmentLeft];
	
	// Draw image
	[image drawInRect:CGRectMake(22, (rowHeight-24)/2.0, 24, 24)];
}	

- (void)dealloc
{
	[label release], label = nil;
	[image release], image = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Misc.

+ (CGFloat)rowHeightForText:(NSString *)s
{
	CGFloat rowHeight;
	if (s == nil) {
		rowHeight = 44.0f;
	} else {
		UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
		CGSize size = [s sizeWithFont:mainFont constrainedToSize:CGSizeMake(MAX_TEXT_WIDTH, CGFLOAT_MAX)
						lineBreakMode:UILineBreakModeWordWrap];
		rowHeight = size.height + Y_PADDING;
		if (rowHeight < 44.0f) rowHeight = 44.0f;
	}
	return rowHeight;
}


#pragma mark -
#pragma mark Accessibility

- (NSString *)accessibilityLabel
{
	return [NSString stringWithFormat:@"%@", label];
}

@end
