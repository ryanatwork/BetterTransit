//
//  BTRoutesViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/16/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import "BTRoutesViewController.h"
#import "BTRailViewController.h"
#import "BTTransitDelegate.h"
#import "BTRouteCell.h"
#import "FlurryAPI.h"

@implementation BTRoutesViewController

@synthesize mainTableView;
@synthesize routesToDisplay, sectionNames;


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Routes", @"");
	
	transit = [AppDelegate transit];
	
	mainTableView.backgroundColor = [UIColor clearColor];
	mainTableView.separatorColor = COLOR_TABLE_VIEW_SEPARATOR;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	self.routesToDisplay= [transit filterRoutes:transit.routesToDisplay];
	self.sectionNames = [self.routesToDisplay objectForKey:@"SectionNames"];
	[mainTableView reloadData];
	
	[FlurryAPI logEvent:@"DID_SHOW_ROUTES_VIEW"];
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
	[routesToDisplay release];
	[sectionNames release];
	[mainTableView release];
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sectionNames count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [self.sectionNames objectAtIndex:section];
	NSArray *routesInSection = [self.routesToDisplay objectForKey:key];
	return [routesInSection count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RouteCellID";
	
	BTRouteCell *cell = (BTRouteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[AppDelegate createRouteCellWithIdentifier:CellIdentifier] autorelease];
	}
	
	NSString *key = [self.sectionNames objectAtIndex:indexPath.section];
	NSArray *routesInSection = [self.routesToDisplay objectForKey:key];
	NSString *routeId = [routesInSection objectAtIndex:indexPath.row];
	BTRoute *route = [transit routeWithId:routeId];
	cell.route = route;
	
	cell.iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", route.routeId]];
	[cell setNeedsDisplay];
    
    // Hide the disclosure button if the index titles are shown
    if ([self.sectionNames count] >= 8) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([self.sectionNames count] > 1) {
		return [self.sectionNames objectAtIndex:section];
	} else {
		return nil;
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if ([self.sectionNames count] >= 8) {
		return self.sectionNames;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *key = [self.sectionNames objectAtIndex:indexPath.section];
	NSArray *routesInSection = [self.routesToDisplay objectForKey:key];
	NSString *selectedRouteId = [routesInSection objectAtIndex:indexPath.row];
	BTRoute *selectedRoute = [transit routeWithId:selectedRouteId];
	if (selectedRoute.stationLists == nil) {
		[transit loadStationListsForRoute:selectedRoute];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	BTRailViewController *controller = [AppDelegate createRailViewController];
	controller.route = selectedRoute;
	controller.stationLists = selectedRoute.stationLists;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

@end
