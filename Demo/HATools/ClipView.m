//
//  ClipView.m
//  BetterTransit
//
//  Created by Yaogang Lian on 11/4/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "ClipView.h"


@implementation ClipView

- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
	if ([self pointInside:point withEvent:event]) {
		return scrollView;
	}
	return nil;
}


@end
