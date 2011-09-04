//
//  LoadingCell.m
//  Showtime
//
//  Created by Yaogang Lian on 1/10/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "LoadingCell.h"


@implementation LoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.frame = CGRectMake(20, 26, 20, 20);
		[self.contentView addSubview:spinner];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(56, 25, 244, 21)];
        label.font = [UIFont systemFontOfSize:16.0f];
		label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:label];
    }
    return self;
}

- (void)setText:(NSString *)s
{
	label.text = s;
	[spinner startAnimating];
}

- (void)dealloc
{
	[spinner release], spinner = nil;
	[label release], label = nil;
	
    [super dealloc];
}


@end
