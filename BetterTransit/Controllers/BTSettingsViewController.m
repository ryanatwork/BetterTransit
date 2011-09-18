//
//  BTSettingsViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/17/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTSettingsViewController.h"
#import "BTTransitDelegate.h"
#import "HAListViewController.h"
#import "Utility.h"
#import "BTAppSettings.h"

#ifdef FLURRY_KEY
#import "FlurryAPI.h"
#endif

@implementation BTSettingsViewController

@synthesize startupScreenOptions, nearbyRadiusOptions, maxNumNearbyStopsOptions;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Settings", @"");
    
    self.sectionOffset = 1;
	
	transit = [AppDelegate transit];
	
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
	[startupScreenOptions release], startupScreenOptions = nil;
	[nearbyRadiusOptions release], nearbyRadiusOptions = nil;
	[maxNumNearbyStopsOptions release], maxNumNearbyStopsOptions = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *BTSettingsCellIdentifier = @"BTSettingsCell";
	
	UITableViewCell *cell;
	if (indexPath.section == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:BTSettingsCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BTSettingsCellIdentifier] autorelease];
		}
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Startup Screen";
				cell.detailTextLabel.text = [BTAppSettings startupScreen];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			case 1:
				cell.textLabel.text = @"Nearby Radius";
				cell.detailTextLabel.text = [BTAppSettings nearbyRadius];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			case 2:
				cell.textLabel.text = @"Max No. of Nearby Stops";
				cell.detailTextLabel.text = [BTAppSettings maxNumNearbyStops];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			default:
				break;
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0)
	{
		HAListViewController *controller = [[HAListViewController alloc] init];
		switch (indexPath.row) {
			case 0:
				controller.list = self.startupScreenOptions;
				controller.selectedIndex = [self.startupScreenOptions indexOfObject:[BTAppSettings startupScreen]];
				controller.title = @"Startup Screen";
				controller.tag = TAG_LIST_STARTUP_SCREEN;
				break;
			case 1:
				controller.list = self.nearbyRadiusOptions;
				controller.selectedIndex = [self.nearbyRadiusOptions indexOfObject:[BTAppSettings nearbyRadius]];
				controller.title = @"Nearby Radius";
				controller.tag = TAG_LIST_NEARBY_RADIUS;
				break;
			case 2:
				controller.list = self.maxNumNearbyStopsOptions;
				controller.selectedIndex = [self.maxNumNearbyStopsOptions indexOfObject:[BTAppSettings maxNumNearbyStops]];
				controller.title = @"Max Number of Stops";
				controller.tag = TAG_LIST_MAX_NUM_NEARBY_STOPS;
				break;
			default:
				break;
		}
		controller.delegate = self;
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
    else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark -
#pragma mark ListViewControllerDelegate methods

- (void)setSelectedIndex:(NSUInteger)index inList:(NSInteger)tag
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch (tag) {
        case TAG_LIST_STARTUP_SCREEN:
        {
            NSString *s = [self.startupScreenOptions objectAtIndex:index];
            [prefs setObject:s forKey:KEY_STARTUP_SCREEN];
        }
            break;
            
        case TAG_LIST_NEARBY_RADIUS:
        {
            NSString *s = [self.nearbyRadiusOptions objectAtIndex:index];
            [prefs setObject:s forKey:KEY_NEARBY_RADIUS];
        }
            break;
            
        case TAG_LIST_MAX_NUM_NEARBY_STOPS:
        {
            NSString *s = [self.maxNumNearbyStopsOptions objectAtIndex:index];
            [prefs setObject:s forKey:KEY_MAX_NUM_NEARBY_STOPS];
        }
            break;
            
        default:
            break;
    }
	[prefs synchronize];
}

@end
