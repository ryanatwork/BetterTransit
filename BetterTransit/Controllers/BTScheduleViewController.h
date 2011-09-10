//
//  BTScheduleViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/19/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTUIViewController.h"
#import "BTRoute.h"


@interface BTScheduleViewController : BTUIViewController 
{
	BTRoute *route;
	NSString *subrouteId;
}

@property (nonatomic, retain) BTRoute *route;
@property (nonatomic, copy) NSString *subrouteId;

@end
