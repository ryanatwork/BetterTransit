//
//  BTPredictionEntry.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTRoute.h"
#import "BTStation.h"

@interface BTPredictionEntry : NSObject
{
	BTRoute *route;
	BTStation *station;
	
	NSString *routeId;
	NSString *subrouteId;
	NSString *destination;
	NSString *eta; // estimated time for arrival
	
	BOOL shouldDownloadData; // download data for this route
	BOOL isUpdating; // is downloading data
	NSString *info; // extra information
}

@property (nonatomic, retain) BTRoute *route;
@property (nonatomic, retain) BTStation *station;
@property (nonatomic, copy) NSString *routeId;
@property (nonatomic, copy) NSString *subrouteId;
@property (nonatomic, copy) NSString *destination;
@property (nonatomic, copy) NSString *eta;
@property (assign) BOOL shouldDownloadData;
@property (assign) BOOL isUpdating;
@property (nonatomic, copy) NSString *info;

@end
