//
//  BTStationList.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/18/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTStationList.h"


@implementation BTStationList

@synthesize route, listId, name, detail, stations;

- (id)init
{
	if (self = [super init]) {
		listId = @"";
		name = @"";
		detail = @"";
		stations = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[route release];
	[listId release];
	[name release];
	[detail release];
	[stations release];
	[super dealloc];
}

@end
