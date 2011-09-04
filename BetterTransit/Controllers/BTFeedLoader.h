//
//  BTFeedLoader.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "BTStation.h"
#import	"BTPredictionEntry.h"

@protocol BTFeedLoaderDelegate <NSObject>

- (void)updatePrediction:(id)info;

@end

@interface BTFeedLoader : NSObject
{
	NSMutableArray *prediction; // includes prediction for all available routes
	NSObject<BTFeedLoaderDelegate> *delegate;
	BTStation *currentStation;
	
	ASINetworkQueue *networkQueue;
}

@property (nonatomic, retain) NSMutableArray *prediction;
@property (assign) id<BTFeedLoaderDelegate> delegate;
@property (nonatomic, retain) BTStation *currentStation;

- (NSString *)dataSourceForStation:(BTStation *)station;
- (void)getPredictionForStation:(BTStation *)station;
- (void)getFeedForEntry:(BTPredictionEntry *)entry;

@end
