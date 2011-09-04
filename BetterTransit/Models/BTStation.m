//
//  BTStation.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTStation.h"


@implementation BTStation

@synthesize stationId, owner, desc;
@synthesize latitude, longitude, tileNumber, distance, favorite;
@synthesize selectedRoute;

- (id)init
{
	if (self = [super init]) {
		favorite = NO;
		tileNumber = 0;
		distance = -2.0;
		selectedRoute = nil;
	}
	return self;
}

- (void)dealloc
{
	[stationId release];
	[desc release];
	[selectedRoute release];
	[super dealloc];
}

@end
