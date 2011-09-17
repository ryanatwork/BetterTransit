//
//  BTSettingsViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/17/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTransit.h"
#import "HAListViewController.h"

@interface BTSettingsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, HAListViewControllerDelegate> 
{
	BTTransit *transit;
}

@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, retain) NSArray *startupScreenOptions;
@property (nonatomic, retain) NSArray *nearbyRadiusOptions;
@property (nonatomic, retain) NSArray *maxNumNearbyStopsOptions;

@end
