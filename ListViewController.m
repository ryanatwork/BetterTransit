//
//  ListViewController.m
//  Showtime
//
//  Created by Yaogang Lian on 1/16/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "ListViewController.h"


@implementation ListViewController

@synthesize mainTableView, list, name, selectedIndex, delegate;


#pragma mark -
#pragma mark Initialization

- (id)init
{
	self = [super initWithNibName:@"ListViewController" bundle:[NSBundle mainBundle]];
	if (self) {
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (id)initWithList:(NSArray *)l name:(NSString *)s selectedIndex:(NSUInteger)index delegate:(id)d
{
	if (self = [super initWithNibName:@"ListViewController" bundle:[NSBundle mainBundle]]) {
		self.hidesBottomBarWhenPushed = YES;
		self.list = l;
		self.name = s;
		self.selectedIndex = index;
		self.delegate = d;
	}
	return self;
}


#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	mainTableView.backgroundColor = [UIColor clearColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
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
	[list release], list = nil;
	[name release], name = nil;
	delegate = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [self.list objectAtIndex:indexPath.row];
	
	if (selectedIndex == indexPath.row) {
		cell.textLabel.textColor = [UIColor colorWithRed:0.20 green:0.31 blue:0.52 alpha:1.0];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	self.selectedIndex = indexPath.row;
	[delegate setSelectedIndex:indexPath.row forListName:self.name];
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
