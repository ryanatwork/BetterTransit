//
//  BTRoute.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BTRoute : NSObject
{
	NSString *routeId;
	NSString *style;
	int owner;
	NSString *subroutes;
	NSString *desc;
	NSMutableArray *stationLists;
	NSString *schedule;
}

@property (nonatomic, copy) NSString *routeId;
@property (nonatomic, copy) NSString *style;
@property (nonatomic, assign) int owner;
@property (nonatomic, copy) NSString *subroutes;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, retain) NSMutableArray *stationLists;
@property (nonatomic, copy) NSString *schedule;

@end
