//
//  BTSettingsViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/17/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTSettingsViewController.h"
#import "BTTransitDelegate.h"
#import "ListViewController.h"
#import "Utility.h"
#import "AppSettings.h"

#ifdef FLURRY_KEY
#import "FlurryAPI.h"
#endif

@implementation BTSettingsViewController

@synthesize mainTableView;
@synthesize startupScreenOptions, nearbyRadiusOptions, maxNumNearbyStopsOptions;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Settings", @"");
	
	transit = [AppDelegate transit];
	
	mainTableView.backgroundColor = [UIColor clearColor];
	
	self.startupScreenOptions = [NSArray arrayWithObjects:@"Nearby", @"Favorites", @"Map", @"Routes", @"Search", nil];
	self.maxNumNearbyStopsOptions = [NSArray arrayWithObjects:@"10", @"20", @"30", @"50", @"100", @"No Limit", nil];
#ifdef METRIC_UNIT
	self.nearbyRadiusOptions = [NSArray arrayWithObjects:@"0.2 km", @"0.5 km", @"1 km", @"2 km", @"5 km", @"No Limit", nil];
#else
	self.nearbyRadiusOptions = [NSArray arrayWithObjects:@"0.2 mi", @"0.5 mi", @"1 mi", @"2 mi", @"5 mi", @"No Limit", nil];
#endif
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
}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[mainTableView release], mainTableView = nil;
	
	[startupScreenOptions release], startupScreenOptions = nil;
	[nearbyRadiusOptions release], nearbyRadiusOptions = nil;
	[maxNumNearbyStopsOptions release], maxNumNearbyStopsOptions = nil;
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *CellIdentifier1 = @"SettingsCell1";
	
	UITableViewCell *cell;
	if (indexPath.section == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1] autorelease];
		}
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Startup Screen";
				cell.detailTextLabel.text = [AppSettings startupScreen];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			case 1:
				cell.textLabel.text = @"Nearby Radius";
				cell.detailTextLabel.text = [AppSettings nearbyRadius];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			case 2:
				cell.textLabel.text = @"Max No. of Nearby Stops";
				cell.detailTextLabel.text = [AppSettings maxNumNearbyStops];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			default:
				break;
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0)
	{
		ListViewController *controller = [[ListViewController alloc] init];
		switch (indexPath.row) {
			case 0:
				controller.list = self.startupScreenOptions;
				controller.selectedIndex = [self.startupScreenOptions indexOfObject:[AppSettings startupScreen]];
				controller.title = @"Startup Screen";
				controller.name = LIST_STARTUP_SCREEN;
				break;
			case 1:
				controller.list = self.nearbyRadiusOptions;
				controller.selectedIndex = [self.nearbyRadiusOptions indexOfObject:[AppSettings nearbyRadius]];
				controller.title = @"Nearby Radius";
				controller.name = LIST_NEARBY_RADIUS;
				break;
			case 2:
				controller.list = self.maxNumNearbyStopsOptions;
				controller.selectedIndex = [self.maxNumNearbyStopsOptions indexOfObject:[AppSettings maxNumNearbyStops]];
				controller.title = @"Max Number of Stops";
				controller.name = LIST_MAX_NUM_NEARBY_STOPS;
				break;
			default:
				break;
		}
		controller.delegate = self;
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}


#pragma mark -
#pragma mark ListViewControllerDelegate methods

- (void)setSelectedIndex:(NSUInteger)index forListName:(NSString *)name
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([name isEqualToString:LIST_STARTUP_SCREEN]) {
		NSString *s = [self.startupScreenOptions objectAtIndex:index];
		[prefs setObject:s forKey:KEY_STARTUP_SCREEN];
	} else if ([name isEqualToString:LIST_NEARBY_RADIUS]) {
		NSString *s = [self.nearbyRadiusOptions objectAtIndex:index];
		[prefs setObject:s forKey:KEY_NEARBY_RADIUS];
	} else if ([name isEqualToString:LIST_MAX_NUM_NEARBY_STOPS]) {
		NSString *s = [self.maxNumNearbyStopsOptions objectAtIndex:index];
		[prefs setObject:s forKey:KEY_MAX_NUM_NEARBY_STOPS];
	}
	[prefs synchronize];
}	

@end
