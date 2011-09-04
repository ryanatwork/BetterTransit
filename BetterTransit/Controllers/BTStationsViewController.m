//
//  BTStationsViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTStationsViewController.h"
#import "BTTransitDelegate.h"
#import "BTLocationManager.h"
#import "Utility.h"
#import "AppSettings.h"

#ifdef FLURRY_KEY
#import "FlurryAPI.h"
#endif

@implementation BTStationsViewController
 
@synthesize stations;
@synthesize mainTableView, addToFavsView, noNearbyStopsView, segmentedControl;
@synthesize locationUpdateButton, spinnerBarItem, spinner;
@synthesize isEditing, editButton, doneButton;
@synthesize viewIsShown;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Stops", @"");
	
	transit = [AppDelegate transit];
	
	mainTableView.backgroundColor = [UIColor clearColor];
	mainTableView.separatorColor = COLOR_TABLE_VIEW_SEPARATOR;
	mainTableView.rowHeight = 60;
	
	self.viewIsShown = NO;
	self.stations = [NSArray array];
	self.isEditing = NO;
	
	// Setup segmented control
	NSArray *items = [NSArray arrayWithObjects:NSLocalizedString(@"Nearby", @""),
					  NSLocalizedString(@"Favorites", @""), nil];
	self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 166, 30);
	
	NSString *s = [AppSettings startupScreen];
	if ([s isEqualToString:@"Favorites"]) {
		[segmentedControl setSelectedSegmentIndex:1];
	} else {
		[segmentedControl setSelectedSegmentIndex:0];
	}
	
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = segmentedControl;
	
	// Setup locate button
	UIButton *locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	locateButton.frame = CGRectMake(0, 0, 34, 28);
	[locateButton setImage:[UIImage imageNamed:@"locate.png"] forState:UIControlStateNormal];
	[locateButton addTarget:self action:@selector(updateLocation:) forControlEvents:UIControlEventTouchUpInside];
	locationUpdateButton = [[UIBarButtonItem alloc] initWithCustomView:locateButton];
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.hidesWhenStopped = YES;
	
	spinnerBarItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
	self.navigationItem.rightBarButtonItem = locationUpdateButton;
	
	self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
																	target:self 
																	action:@selector(editFavs:)];
	[editButton release];
	
	self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																	target:self
																	action:@selector(editFavs:)];
	[doneButton release];
	
	// an illustration showing how to add a bus stop to favorites
	self.addToFavsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ADD_TO_FAVS_PNG]];
	[addToFavsView release];
	addToFavsView.hidden = YES;
	[self.view addSubview:self.addToFavsView];
	
	// an illustration showing that no nearby stops are found.
	self.noNearbyStopsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNearbyStops.png"]];
	[noNearbyStopsView release];
	noNearbyStopsView.hidden = YES;
	[self.view addSubview:self.noNearbyStopsView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self refreshView];
	self.viewIsShown = YES;

#ifdef FLURRY_KEY
	[FlurryAPI logEvent:@"DID_SHOW_STATION_VIEW"];
#endif
	
	// Observe notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(startUpdatingLocation:)
												 name:kStartUpdatingLocationNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didUpdateToLocation:)
												 name:kDidUpdateToLocationNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didFailToUpdateLocation:)
												 name:kDidFailToUpdateLocationNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(locationDidNotChange:)
												 name:kLocationDidNotChangeNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.viewIsShown = NO;
	if (isEditing)
	{
		[mainTableView setEditing:NO animated:NO];
		isEditing = NO;
		[self saveFavs];
	}
}
 
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.mainTableView = nil;
	self.addToFavsView = nil;
	self.noNearbyStopsView = nil;
	self.segmentedControl = nil;
}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[stations release];
	[mainTableView release];
	[addToFavsView release];
	[noNearbyStopsView release];
	[segmentedControl release];
	[locationUpdateButton release];
	[spinnerBarItem release];
	[spinner release];
	[editButton release], editButton = nil;
	[doneButton release], doneButton = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark -
#pragma mark UI methods

- (void)segmentAction:(id)sender
{
	if (isEditing) {
		[mainTableView setEditing:NO animated:NO];
		isEditing = NO;
		[self saveFavs];
	}
	
	[self refreshView];
	[mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)refreshView
{
	switch ([segmentedControl selectedSegmentIndex]) {
		case 0:
			if ([[BTLocationManager sharedInstance] locationFound]) {
				[transit updateNearbyStations];
				self.stations = transit.nearbyStations; // already filtered
				if ([self.stations count] == 0) {
					noNearbyStopsView.hidden = NO;
					[self.view bringSubviewToFront:noNearbyStopsView];
				} else {
					noNearbyStopsView.hidden = YES;
				}
			} else {
				noNearbyStopsView.hidden = YES;
			}
			addToFavsView.hidden = YES;
			[self.navigationItem setRightBarButtonItem:locationUpdateButton animated:NO];

#ifdef FLURRY_KEY
			[FlurryAPI logEvent:@"CLICKED_NEARBY"];
#endif
			break;
		case 1:
			self.stations = [transit filterStations:transit.favoriteStations];
			if ([self.stations count] == 0) {
				addToFavsView.hidden = NO;
				[self.view bringSubviewToFront:addToFavsView];
				addToFavsView.alpha = 0.0;
				
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.3];
				addToFavsView.alpha = 1.0;
				[UIView commitAnimations];
				
				[self.navigationItem setRightBarButtonItem:nil animated:YES];
			} else {
				addToFavsView.hidden = YES;
				[self.navigationItem setRightBarButtonItem:editButton animated:NO];
			}
			noNearbyStopsView.hidden = YES;

#ifdef FLURRY_KEY
			[FlurryAPI logEvent:@"CLICKED_FAVS"];
#endif
			break;
		default:
			break;
	}
	[mainTableView reloadData];
}

- (void)editFavs:(id)sender
{
	if (isEditing) { // Done button pressed
		[mainTableView setEditing:NO animated:YES];
		isEditing = NO;
		[self.navigationItem setRightBarButtonItem:editButton animated:NO];
		[self saveFavs];
		
	} else { // Edit button pressed
		[mainTableView setEditing:YES animated:YES];
		isEditing = YES;
		[self.navigationItem setRightBarButtonItem:doneButton animated:NO];
	}
}

- (void)saveFavs
{
	// Save the favorites
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSMutableArray *favs = [NSMutableArray array];
	for (BTStation *s in transit.favoriteStations) {
		[favs addObject:s.stationId];
	}
	[prefs setObject:favs forKey:@"favorites"];
	[prefs synchronize];
}

- (void)checkNumberOfNearbyStops
{
	if (self.viewIsShown && segmentedControl.selectedSegmentIndex == 0 
		&& [transit.nearbyStations count] == 0) {
		noNearbyStopsView.hidden = NO;
		[self.view bringSubviewToFront:noNearbyStopsView];
	} else {
		noNearbyStopsView.hidden = YES;
	}
}

- (IBAction)updateLocation:(id)sender
{
	[[BTLocationManager sharedInstance] startUpdatingLocation];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.stations count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BTStationCellID";
	
	BTStationCell *cell = (BTStationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[BTStationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	BTStation *station = [self.stations objectAtIndex:indexPath.row];
	cell.station = station;
	
	NSString *imageName = [NSString stringWithFormat:@"station_%d.png", station.owner];
	UIImage *stationImage = [[UIImage imageNamed:imageName] retain];
	if (stationImage != nil) {
		cell.iconImage = stationImage;
		[stationImage release];
	} else {
		cell.iconImage = [UIImage imageNamed:@"default_station.png"];
	}
	
	[cell setNeedsDisplay];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	BTStation *selectedStation = [self.stations objectAtIndex:indexPath.row];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	BTPredictionViewController *controller = [AppDelegate createPredictionViewController];
	controller.station = selectedStation;
	controller.prediction = nil;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellEditingStyle style;
	if (segmentedControl.selectedSegmentIndex == 0) {
		style = UITableViewCellEditingStyleNone;
	} else {
		style = UITableViewCellEditingStyleDelete;
	}
	return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		BTStation *station = [stations objectAtIndex:indexPath.row];
		station.favorite = NO;
		[transit.favoriteStations removeObject:station];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		
		if ([transit.favoriteStations count] == 0) {
			[mainTableView setEditing:NO animated:YES];
			isEditing = NO;
			[self saveFavs];
			[self refreshView];
		}
	}
}

// The following two methods are required for reordering rows
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	BTStation *station = [[stations objectAtIndex:fromIndexPath.row] retain];
	[transit.favoriteStations removeObject:station];
	[transit.favoriteStations insertObject:station atIndex:toIndexPath.row];
	[station release];
}


#pragma mark -
#pragma mark Location updates

- (void)startUpdatingLocation:(NSNotification *)notification
{
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.navigationItem.rightBarButtonItem = spinnerBarItem;
	}
	[self.spinner startAnimating];
}

- (void)didUpdateToLocation:(NSNotification *)notification
{
	[self checkNumberOfNearbyStops];
	[self refreshView];
	[self.spinner stopAnimating];
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.navigationItem.rightBarButtonItem = locationUpdateButton;
	}
}

- (void)didFailToUpdateLocation:(NSNotification *)notification
{
	[self.spinner stopAnimating];
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.navigationItem.rightBarButtonItem = locationUpdateButton;
	}
}

- (void)locationDidNotChange:(NSNotification *)notification
{
	[self.spinner stopAnimating];
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.navigationItem.rightBarButtonItem = locationUpdateButton;
	}
}	

@end
