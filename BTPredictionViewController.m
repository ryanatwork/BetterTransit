//
//  BTPredictionViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTPredictionViewController.h"
#import "BTAnnotation.h"
#import "BTPredictionEntry.h"
#import "BTTransitDelegate.h"
#import "Utility.h"
#import "FlurryAPI.h"
#import "TitleViewLabel.h"
#import "LoadingCell.h"
#import "EnhancedDefaultCell.h"


@implementation BTPredictionViewController

@synthesize station, prediction, filteredPrediction;
@synthesize mainTableView, stationInfoView, _refreshHeaderView, mapView;
@synthesize stationDescLabel, stationIdLabel, stationDistanceLabel, favButton;
@synthesize timer;
@synthesize errorMessage;


#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super initWithNibName:@"BTPredictionViewController" bundle:[NSBundle mainBundle]];
	if (self) {
        downloadStatus = DOWNLOAD_STATUS_INIT;
        self.errorMessage = nil;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	transit = [AppDelegate transit];
	
	mainTableView.backgroundColor = [UIColor clearColor];
	mainTableView.separatorColor = COLOR_TABLE_VIEW_SEPARATOR;
	mainTableView.rowHeight = 72;
	
    // Setup title view
    TitleViewLabel *label = [[TitleViewLabel alloc] initWithText:station.desc];
    self.navigationItem.titleView = label;
    [label release];
    
	// mapView settings
	[mapView setMapType:MKMapTypeStandard];
	[mapView setUserInteractionEnabled:NO];
    
    // Pull to refresh header
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *v = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - mainTableView.bounds.size.height, self.view.frame.size.width, mainTableView.bounds.size.height)];
		v.delegate = self;
		[v refreshLastUpdatedDate];
		[self.mainTableView addSubview:v];
		self._refreshHeaderView = v;
		[v release];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	// Make sure navigation bar will be shown
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    self.view.frame = CGRectMake(0, 0, 320, 416);
    [super viewWillAppear:animated];
	
	stationDescLabel.text = station.desc;
	stationIdLabel.text = [NSString stringWithFormat:@"Bus stop #%@", station.stationId];
	if (station.distance > -1.0) {
		stationDistanceLabel.text = [Utility formattedStringForDistance:station.distance];
	} else { // don't display distance if user location is not found
		stationDistanceLabel.text = @"";
	}
	
	if (station.favorite) {
        [self.favButton setImage:[UIImage imageNamed:@"favorite_icon.png"] forState:UIControlStateNormal];
        [self.favButton setImage:[UIImage imageNamed:@"favorite_icon.png"] forState:UIControlStateHighlighted];
	} else {
        [self.favButton setImage:[UIImage imageNamed:@"favorite_icon_gray.png"] forState:UIControlStateNormal];
        [self.favButton setImage:[UIImage imageNamed:@"favorite_icon_gray.png"] forState:UIControlStateHighlighted];
	}
	
	// reset annotation to that of current selected station
	NSArray *annotations = mapView.annotations;
	if (annotations) {
		[mapView removeAnnotations:annotations];
	}
	BTAnnotation *annotation = [[BTAnnotation alloc] init];
	annotation.title = station.desc;
	annotation.subtitle = [NSString stringWithFormat:@"Bus stop #%@", station.stationId];
	CLLocationCoordinate2D coordinate = {0,0};
	coordinate.latitude = station.latitude;
	coordinate.longitude = station.longitude;
	annotation.coordinate = coordinate;
	annotation.station = station;
	[mapView addAnnotation:annotation];
	[annotation release];
	
	// set map view region
	MKCoordinateRegion region = {{0.0, 0.0}, {0.0, 0.0}};
	region.center = coordinate;
	region.span.longitudeDelta = 0.003;
	region.span.latitudeDelta = 0.003;
	[mapView setRegion:region animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
    [self checkBusArrival];
	[self startTimer];
	
	NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:station.stationId, @"stopID", nil];
	[FlurryAPI logEvent:@"DID_SHOW_PREDICTION_VIEW" withParameters:flurryDict];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.timer invalidate];
	[[AppDelegate feedLoader] setDelegate:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[super viewDidUnload];
	
	self.mainTableView = nil;
    [_refreshHeaderView setDelegate:nil];
    self._refreshHeaderView = nil;
	self.mapView = nil;
	self.stationDescLabel = nil;
	self.stationIdLabel = nil;
	self.stationDistanceLabel = nil;
	self.favButton = nil;

}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[station release], station = nil;
	[prediction release], prediction = nil;
	[filteredPrediction release], filteredPrediction = nil;
	[mainTableView release], mainTableView = nil;
    [_refreshHeaderView setDelegate:nil];
    [_refreshHeaderView release], _refreshHeaderView = nil;
	[mapView release], mapView = nil;
	[stationDescLabel release], stationDescLabel = nil;
	[stationIdLabel release], stationIdLabel = nil;
	[stationDistanceLabel release], stationDistanceLabel = nil;
	[favButton release], favButton = nil;
	[timer release], timer = nil;
    [errorMessage release], errorMessage = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Ad support

- (NSUInteger)adZone
{
	return AD_ZONE_1;
}

- (void)updateUI
{
	CGRect contentFrame = self.view.bounds;
	contentFrame.size.height -= adOffset;
	mainTableView.frame = contentFrame;
	backdrop.frame = contentFrame;
}


#pragma mark -
#pragma mark UI methods

- (IBAction)setFav:(id)sender
{
	station.favorite = !station.favorite;
	
	if (station.favorite) {
		[self.favButton setImage:[UIImage imageNamed:@"favorite_icon.png"] forState:UIControlStateNormal];
		[self.favButton setImage:[UIImage imageNamed:@"favorite_icon.png"] forState:UIControlStateHighlighted];
		[transit.favoriteStations addObject:self.station];
	} else {
		[self.favButton setImage:[UIImage imageNamed:@"favorite_icon_gray.png"] forState:UIControlStateNormal];
		[self.favButton setImage:[UIImage imageNamed:@"favorite_icon_gray.png"] forState:UIControlStateHighlighted];
		[transit.favoriteStations removeObject:self.station];
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSMutableArray *favs = [NSMutableArray array];
	for (BTStation *s in transit.favoriteStations) {
		[favs addObject:s.stationId];
	}
	[prefs setObject:favs forKey:@"favorites"];
	[prefs synchronize];
}

- (void)checkBusArrival
{
    if (_reloading) return;
    _reloading = YES;
    
	[[AppDelegate feedLoader] setDelegate:self];
	[[AppDelegate feedLoader] getPredictionForStation:self.station];
}

- (void)moveFavsToTop
{
	// subclass will override
}

- (void)startTimer
{
	// refresh time table every 20 seconds as long as this page stays open
	self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL target:self selector:@selector(checkBusArrival) userInfo:nil repeats:YES];
}


#pragma mark -
#pragma mark BTFeedLoaderDelegate methods

- (void)updatePrediction:(id)info
{
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mainTableView];
	
	if (info != nil && [info isKindOfClass:[NSArray class]]) {
		self.prediction = (NSMutableArray *)info;
		self.filteredPrediction = [transit filterPrediction:self.prediction];
		[self moveFavsToTop];
        
		if ([self.filteredPrediction count] > 0) {
            downloadStatus = DOWNLOAD_STATUS_SUCCEEDED;
            self.errorMessage = nil;
		} else {
            downloadStatus = DOWNLOAD_STATUS_FAILED;
            self.errorMessage = @"No bus is coming in the next 30 mins.";
		}
		
	} else {
        downloadStatus = DOWNLOAD_STATUS_FAILED;
        self.errorMessage = (info ? info : @"Failed to download data");
	}
    
    [self.mainTableView reloadData];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (downloadStatus == DOWNLOAD_STATUS_INIT || downloadStatus == DOWNLOAD_STATUS_FAILED) {
        return 2;
    } else {
        return [self.filteredPrediction count] + 1;
    }
}

- (BTPredictionCell *)createNewCell
{
	BTPredictionCell *newCell = nil;
	NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"BTPredictionCell"
													  owner:self options:nil];
	for (NSObject *nibItem in nibItems) {
		if ([nibItem isKindOfClass:[BTPredictionCell class]]) {
			newCell = (BTPredictionCell *)nibItem;
			break;
		}
	}
	return newCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StationInfoCellIdentifier = @"StationInfoCellIdentifier";
    static NSString *PredictionCellIdentifier = @"PredictionCellIdentifier";
    static NSString *LoadingCellIdentifier = @"LoadingCellIdentifier";
    static NSString *DefaultCellIdentifier = @"DefaultCellIdentifier";
    
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StationInfoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StationInfoCellIdentifier] autorelease];
            [cell.contentView addSubview:stationInfoView];
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fiber_paper.png"]];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if (downloadStatus == DOWNLOAD_STATUS_INIT && indexPath.row == 1)
    {
        LoadingCell *cell = (LoadingCell *)[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        if (cell == nil) {
            cell = [[[LoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingCellIdentifier] autorelease];
        }
        
        [cell setText:@"Loading bus arrival times..."];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    if (downloadStatus == DOWNLOAD_STATUS_FAILED && indexPath.row == 1)
    {
        EnhancedDefaultCell *cell = (EnhancedDefaultCell *)[tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
		if (cell == nil) {
			cell = [[[EnhancedDefaultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier] autorelease];
		}
        cell.label = self.errorMessage;
		cell.image = [UIImage imageNamed:@"icn_warning.png"];
        cell.backgroundColor = [UIColor clearColor];
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    BTPredictionCell *cell = (BTPredictionCell *)[tableView dequeueReusableCellWithIdentifier:PredictionCellIdentifier];
    if (cell == nil) {
		cell = [self createNewCell];
		// turn off selection use
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    cell.backgroundColor = [UIColor clearColor];
    
	BTPredictionEntry *entry = [self.filteredPrediction objectAtIndex:indexPath.row-1];
	BTRoute *route = [transit routeWithId:entry.routeId];
	cell.routeLabel.text = route.desc;
	cell.destinationLabel.text = [self modifyDestination:entry.destination withStyle:route.style];
	cell.estimateLabel.text = entry.eta;
	
	NSString *imageName = [NSString stringWithFormat:@"%@.png", route.routeId];
	UIImage *routeImage = [[UIImage imageNamed:imageName] retain];
	if (routeImage) {
		[cell.imageView setImage:routeImage];
	} else {
		cell.idLabel.hidden = NO;
		cell.idLabel.text = route.routeId;
	}
	[routeImage release];
	
    return cell;
}

- (NSString *)modifyDestination:(NSString *)dest withStyle:(NSString *)style
{
	NSString *result = [[dest retain] autorelease];
	
	if ([style isEqualToString:@"to"]) {
		result = [NSString stringWithFormat:@"To %@", dest];
	} else if ([style isEqualToString:@"remove"]) {
		NSRange range = [dest rangeOfString:@"via"];
		if (range.location == NSNotFound) {
			result = @"";
		} else {
			result = [NSString stringWithFormat:@"v%@", [dest substringFromIndex:range.location+1]];
		}
	}
	return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return 130.0f;
    else return 72.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)v
{
    downloadStatus = DOWNLOAD_STATUS_INIT;
    [self checkBusArrival];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)v
{	
	return _reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)v
{
    return [NSDate date];
}

@end
