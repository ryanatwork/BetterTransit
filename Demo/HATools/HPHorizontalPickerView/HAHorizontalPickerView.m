//
//  HAHorizontalPickerView.m
//  BetterTransit
//
//  Created by Yaogang Lian on 6/4/11.
//  Copyright 2011 Happen Apps. All rights reserved.
//

#import "HAHorizontalPickerView.h"

#define CELL_WIDTH 100
#define CELL_HEIGHT 50


@implementation HAHorizontalPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0.929 green:0.929 blue:0.929 alpha:1.0];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.backgroundColor = [UIColor clearColor];
		
        [self addSubview:_scrollView];
        [self layoutCells];
		
		_overlay = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
		[_overlay setImage:[UIImage imageNamed:@"horz_picker_overlay.png"]];
		[self addSubview:_overlay];
    }
    return self;
}

- (void)layoutCells
{
    int numberOfCells = 7;
    NSArray *datasource = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
    
    for (int i=0; i<numberOfCells; i++) {
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(i*CELL_WIDTH+10, 0, CELL_WIDTH, CELL_HEIGHT)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, 50)];
        titleLabel.text = [datasource objectAtIndex:i];
		titleLabel.backgroundColor = [UIColor clearColor];
        [cellView addSubview:titleLabel];
        [titleLabel release];
        
        cellView.contentMode = UIViewContentModeCenter;
        [_scrollView addSubview:cellView];
        [cellView release];
    }
    
    [_scrollView setContentSize:CGSizeMake(numberOfCells*CELL_WIDTH, CELL_HEIGHT)];
	[self bringSubviewToFront:_overlay];
}

- (void)dealloc
{
	[_scrollView release], _scrollView = nil;
	[_overlay release], _overlay = nil;
    [super dealloc];
}

- (UIView *)hitTest:(CGPoint) point withEvent:(UIEvent *)event
{
	if ([self pointInside:point withEvent:event]) {
		return _scrollView;
	}
	return nil;
}

@end