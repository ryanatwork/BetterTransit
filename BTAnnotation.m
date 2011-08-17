//
//  BTAnnotation.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTAnnotation.h"


@implementation BTAnnotation

@synthesize coordinate, title, subtitle, station;

- (void)dealloc
{
	[title release];
	[subtitle release];
	[station release];
	[super dealloc];
}

@end
