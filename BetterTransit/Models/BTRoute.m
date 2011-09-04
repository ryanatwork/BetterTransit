//
//  BTRoute.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTRoute.h"


@implementation BTRoute

@synthesize routeId;
@synthesize style, owner, subroutes, desc;
@synthesize stationLists;
@synthesize schedule;

- (id)init
{
	if (self = [super init]) {
		stationLists = nil;
	}
	return self;
}

- (void)dealloc
{
	[routeId release];
	[style release];
	[subroutes release];
	[desc release];
	[stationLists release];
	[schedule release];
	[super dealloc];
}

@end
