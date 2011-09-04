//
//  BTPredictionViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BTTransit.h"
#import "BTStation.h"
#import "BTPredictionCell.h"
#import "BTFeedLoader.h"
#import "EGORefreshTableHeaderView.h"


@interface BTPredictionViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, 
BTFeedLoaderDelegate, EGORefreshTableHeaderDelegate>
{
	BTTransit *transit;
	BTStation *station;
	NSMutableArray *prediction;
	NSMutableArray *filteredPrediction;
	
	UITableView *mainTableView;
    UIView *stationInfoView;
	MKMapView *mapView;
	UILabel *stationDescLabel;
	UILabel *stationIdLabel;
	UILabel *stationDistanceLabel;
	UIButton *favButton;
	
	NSTimer *timer;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    NSUInteger downloadStatus;
    NSString *errorMessage;
}

@property (nonatomic, retain) BTStation *station;
@property (nonatomic, retain) NSMutableArray *prediction;
@property (nonatomic, retain) NSMutableArray *filteredPrediction;
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, retain) IBOutlet UIView *stationInfoView;
@property (nonatomic, retain) EGORefreshTableHeaderView *_refreshHeaderView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UILabel *stationDescLabel;
@property (nonatomic, retain) IBOutlet UILabel *stationIdLabel;
@property (nonatomic, retain) IBOutlet UILabel *stationDistanceLabel;
@property (nonatomic, retain) IBOutlet UIButton *favButton;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSString *errorMessage;

- (IBAction)setFav:(id)sender;

- (NSString *)modifyDestination:(NSString *)dest withStyle:(NSString *)style;
- (void)checkBusArrival;
- (void)moveFavsToTop;
- (void)startTimer;

- (BTPredictionCell *)createNewCell;

@end
