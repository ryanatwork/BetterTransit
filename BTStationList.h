//
//  BTStationList.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/18/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTRoute;

@interface BTStationList : NSObject
{
	BTRoute *route;
	NSString *listId;
	NSString *name;
	NSString *detail;
	NSMutableArray *stations;
}

@property (nonatomic, retain) BTRoute *route;
@property (nonatomic, copy) NSString *listId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, retain) NSMutableArray *stations;

@end
