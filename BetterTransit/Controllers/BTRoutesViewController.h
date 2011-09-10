//
//  BTRoutesViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTransit.h"
#import "BTUIViewController.h"


@interface BTRoutesViewController : BTUIViewController
<UITableViewDelegate, UITableViewDataSource>
{
	BTTransit *transit;
	NSDictionary *routesToDisplay;
	NSArray *sectionNames;
	UITableView *mainTableView;
}

@property (nonatomic, retain) NSDictionary *routesToDisplay;
@property (nonatomic, retain) NSArray *sectionNames;
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;

@end
