//
//  BTSearchViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 11/10/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTSearchViewController.h"
#import "Utility.h"
#import "BTTransitDelegate.h"
#import "FlurryAPI.h"

@implementation BTSearchViewController

@synthesize stations;
@synthesize searchBar, mainTableView;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Search", @"");
	
	transit = [AppDelegate transit];
	
	self.backdrop.frame = CGRectMake(0, 44, 320, 367);
	
	mainTableView.backgroundColor = [UIColor clearColor];
	mainTableView.separatorColor = COLOR_TABLE_VIEW_SEPARATOR;
	mainTableView.rowHeight = 60;
	
	self.stations = [NSMutableArray array];
	
	CGRect rect = CGRectMake(0, 44, 320, 199);
	bigCancelButton = [[UIButton alloc] initWithFrame:rect];
	[bigCancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchDown];
	bigCancelButton.alpha = 1.0;
	bigCancelButtonIsShown = NO;
	
	noResultsLabel = [[UILabel alloc] initWithFrame:rect];
	noResultsLabel.font = [UIFont boldSystemFontOfSize:19];
	noResultsLabel.text = @"No Results";
	noResultsLabel.textColor = [UIColor darkGrayColor];
	noResultsLabel.backgroundColor = [UIColor clearColor];
	noResultsLabel.textAlignment = UITextAlignmentCenter;
	noResultsLabelIsShown = NO;
	
	// change label text on search keyboard to "Done"
	for (UIView *searchBarSubview in [searchBar subviews]) {
		if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
			@try {
				[(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
			}
			@catch (NSException * e) {
				// ignore exception
			}
		}
	}
	
	[self registerForKeyboardNotifications];
	[searchBar becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
	[FlurryAPI logEvent:@"DID_SHOW_SEARCH_VIEW"];
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
	self.searchBar = nil;
}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[searchBar release], searchBar = nil;
	[mainTableView release], mainTableView = nil;
	[stations release], stations = nil;
	[bigCancelButton release], bigCancelButton = nil;
	[noResultsLabel release], noResultsLabel = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark TableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.stations count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BTStationSearchCellID";
    
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[searchBar resignFirstResponder];
	return indexPath;
}


#pragma mark -
#pragma mark UISearchBarDelegate Methods 

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText
{
	[self handleSearchForTerm:searchText];
	[mainTableView reloadData];
	
	// Show "No Results" if search text is not empty but station list is empty after search
	if ([searchText length] > 0 && [self.stations count] == 0) {
		if (!noResultsLabelIsShown) {
			[self.view addSubview:noResultsLabel];
			noResultsLabelIsShown = YES;
		}
	} else {
		if (noResultsLabelIsShown) {
			[noResultsLabel removeFromSuperview];
			noResultsLabelIsShown = NO;
		}
	}
	
	// Show the invisible big cancel button as long as station list is empty and keyboard is on
	if ([self.stations count] == 0  && !bigCancelButtonIsShown) {
		[self.view addSubview:bigCancelButton];
		bigCancelButtonIsShown = YES;
	} else if ([self.stations count] > 0 && bigCancelButtonIsShown) {
		[bigCancelButton removeFromSuperview];
		bigCancelButtonIsShown = NO;
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb
{
	NSString *searchText = [sb text];
	[self handleSearchForTerm:searchText];
	[mainTableView reloadData];
	[sb resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb
{
	sb.text = @"";
	self.stations = nil;
	[mainTableView reloadData];
	[sb resignFirstResponder];
}

- (void)handleSearchForTerm:(NSString *)term
{
	if ([term length] > 0) {
		NSMutableArray *foundStations = [NSMutableArray array];
		for (BTStation *station in transit.stations) {
			NSRange range1 = [station.desc rangeOfString:term options:NSCaseInsensitiveSearch];
			NSRange range2 = [station.stationId rangeOfString:term options:NSCaseInsensitiveSearch];
			if (range1.location != NSNotFound || range2.location != NSNotFound) {
				[foundStations addObject:station];
			}
		}
		self.stations = foundStations;
	} else {
		self.stations = nil;
	}
}

#pragma mark -
#pragma mark Hide/Show keyboard

- (void)registerForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardDidShow:) 
												 name:UIKeyboardDidShowNotification 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
	// Show the invisible big cancel button as long as station list is empty and keyboard is on
	if ([self.stations count] == 0 && !bigCancelButtonIsShown) {
		[self.view addSubview:bigCancelButton];
		bigCancelButtonIsShown = YES;
	}
	mainTableView.frame = CGRectMake(0, 44, 320, 199);
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	// Remove the invisible big cancel button when keyboard hides
	if (bigCancelButtonIsShown) {
		[bigCancelButton removeFromSuperview];
		bigCancelButtonIsShown = NO;
	}
	mainTableView.frame = CGRectMake(0, 44, 320, 367);
}

- (void)cancel:(id)sender
{
	[searchBar resignFirstResponder];
}

@end
