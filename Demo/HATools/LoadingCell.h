//
//  LoadingCell.h
//  Showtime
//
//  Created by Yaogang Lian on 1/10/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingCell : UITableViewCell
{
	UIActivityIndicatorView *spinner;
	UILabel *label;
}

- (void)setText:(NSString *)s;

@end
