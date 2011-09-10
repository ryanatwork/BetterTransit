//
//  BTStationsViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTransit.h"
#import "BTStationCell.h"
#import "BTPredictionViewController.h"
#import "BTUIViewController.h"

@interface BTStationsViewController : BTUIViewController
<UITableViewDelegate, UITableViewDataSource>
{
	BTTransit *transit;
	NSArray *stations;
	
	UITableView *mainTableView;
	UIImageView *addToFavsView;
	UIImageView *noNearbyStopsView;
	UISegmentedControl *segmentedControl;
	UIBarButtonItem *locationUpdateButton;
	UIBarButtonItem *spinnerBarItem;
	UIActivityIndicatorView *spinner;
	
	BOOL isEditing;
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	
	BOOL viewIsShown;
}

@property (nonatomic, retain) NSArray *stations;
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, retain) UIImageView *addToFavsView;
@property (nonatomic, retain) UIImageView *noNearbyStopsView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UIBarButtonItem *locationUpdateButton;
@property (nonatomic, retain) UIBarButtonItem *spinnerBarItem;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, assign) BOOL viewIsShown;

- (IBAction)updateLocation:(id)sender;
- (void)segmentAction:(id)sender;
- (void)refreshView;
- (void)editFavs:(id)sender;
- (void)saveFavs;
- (void)checkNumberOfNearbyStops;

@end
