//
//  BTStation.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTRoute;

@interface BTStation : NSObject
{
	NSString *stationId;
	int owner;
	NSString *desc;
	double latitude;
	double longitude;
	NSUInteger tileNumber;
	double distance;
	BOOL favorite;
	BTRoute *selectedRoute; // station has a selected route when invoked from RailView
}

@property (nonatomic, copy) NSString *stationId;
@property (nonatomic, assign) int owner;
@property (nonatomic, copy) NSString *desc;
@property double latitude;
@property double longitude;
@property (nonatomic, assign) NSUInteger tileNumber;
@property double distance;
@property BOOL favorite;
@property (nonatomic, retain) BTRoute *selectedRoute;

@end
