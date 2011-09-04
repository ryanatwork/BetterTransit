//
//  TitleViewLabel.m
//  bettertransit
//
//  Created by Yaogang Lian on 6/18/11.
//  Copyright 2011 Happen Apps. All rights reserved.
//

#import "TitleViewLabel.h"


@implementation TitleViewLabel

@synthesize text;

- (id)initWithText:(NSString *)s
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 36)];
    if (self) {
        self.text = s;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *textColor = [UIColor whiteColor];
    [textColor set];
    
    UIFont *normalTextFont = [UIFont boldSystemFontOfSize:18.0f];
    UIFont *smallTextFont = [UIFont boldSystemFontOfSize:14.0f];
    
    CGSize size = [self.text sizeWithFont:smallTextFont];
    if (size.width > 200.0f) {
        [self.text drawInRect:CGRectMake(0, 0, 200, 36)
                     withFont:smallTextFont
                lineBreakMode:UILineBreakModeWordWrap
                    alignment:UITextAlignmentCenter];
    } else {
        CGFloat actualFontSize;
        [self.text sizeWithFont:normalTextFont
                    minFontSize:14.0f
                 actualFontSize:&actualFontSize
                       forWidth:200.0f
                  lineBreakMode:UILineBreakModeWordWrap];
        
        [self.text drawInRect:CGRectMake(0, 8, 200, 24)
                     withFont:[UIFont boldSystemFontOfSize:actualFontSize]
                lineBreakMode:UILineBreakModeWordWrap
                    alignment:UITextAlignmentCenter];
    }
}

@end
