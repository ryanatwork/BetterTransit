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
#import "FacebookViewController.h"
#import "TwitterViewController.h"
#import "AppViewController.h"
#import "InAppPurchaseManager.h"
#import "Utility.h"
#import "LoadingView.h"
#import "AppSettings.h"
#import "FlurryAPI.h"
#import "FAQViewController.h"
#import "WebViewController.h"


@implementation BTSettingsViewController

@synthesize mainTableView, purchaseAdsFreeCell;
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
	
	networkQueue = [[ASINetworkQueue alloc] init];
	[networkQueue setDelegate:self];
	[networkQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(requestDidFail:)];
	
	NSString *appURLString = APP_LIST_XML;
	NSURL *appURL = [NSURL URLWithString:appURLString];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:appURL];
	[request setTimeOutSeconds:20];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
							  [NSNumber numberWithInt:REQUEST_TYPE_GET_XML] forKey:@"request_type"];
	[request setUserInfo:userInfo];
	[networkQueue addOperation:request];
	[networkQueue go];
	
	appArray = nil;
	iconDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	// Restore pending transactions if the user closed the app during purchase
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pending_transaction"])
	{
		[[InAppPurchaseManager sharedInstance] restorePendingTransactions];
	}
	
	[mainTableView reloadData];
	[Utility dismissToolTip];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(removeAds)
												 name:kRemoveAdsNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.mainTableView = nil;
	self.purchaseAdsFreeCell = nil;
}

- (void)dealloc
{
	DLog(@">>> %s <<<", __PRETTY_FUNCTION__);
	[mainTableView release], mainTableView = nil;
	[purchaseAdsFreeCell release], purchaseAdsFreeCell = nil;
	
	[startupScreenOptions release], startupScreenOptions = nil;
	[nearbyRadiusOptions release], nearbyRadiusOptions = nil;
	[maxNumNearbyStopsOptions release], maxNumNearbyStopsOptions = nil;
	
	[networkQueue release], networkQueue = nil;
	[appArray release], appArray = nil;
	[iconDictionary release], iconDictionary = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark -
#pragma mark ASIHTTPRequest

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
	if ([request error]) {
		NSLog(@"Error in requestDidFinish");
		return;
	}
	
	int requestType = [[[request userInfo] objectForKey:@"request_type"] intValue];
	if (requestType == REQUEST_TYPE_GET_XML) {
		NSString *err = nil;
		appArray = [[NSPropertyListSerialization propertyListFromData:[request responseData]
													 mutabilityOption:NSPropertyListMutableContainersAndLeaves
															   format:NULL
													 errorDescription:&err] retain];
	} else if (requestType == REQUEST_TYPE_GET_ICON) {
		UIImage *image = [UIImage imageWithData:[request responseData]];
		[iconDictionary setObject:image forKey:[[request userInfo] objectForKey:@"app_name"]];
	}
	[self.mainTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)requestDidFail:(ASIHTTPRequest *)request
{
	NSLog(@"request did fail with error: %@", [request error]);
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	sectionOffset = ([AppSettings supportRemoveAds] && ![AppSettings lifetimeAdsFree]) ? 0 : 1;
	return 4 - sectionOffset;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int numberOfRows;
	
	switch (section + sectionOffset) {
		case 0:
			numberOfRows = 1;
			break;
		case 1:
			numberOfRows = 3;
			break;
		case 2:
			numberOfRows = 3;
			break;
		case 3:
			if (appArray == nil) {
				numberOfRows = 0;
			} else {
				numberOfRows = [appArray count];
			}
			break;
		default:
			break;
	}
	
	return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int newSection = indexPath.section + sectionOffset;
	if (newSection == 0) {
		if (indexPath.row == 0) {
			return 50;
		} else if (indexPath.row == 1) {
			if (AD_FREE) {
				return 44;
			} else {
				return 60;
			}
		}
	}
	
	if (newSection == 3)
		return 50;
	
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	NSString *s = nil;
	switch (section + sectionOffset) {
		case 1:
			s = @"Application Settings";
			break;
		case 2:
			s = @"Support";
			break;
		case 3:
			if (appArray != nil) {
				s = @"Our Apps";
			}
			break;
		default:
			break;
	}
	return s;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *CellIdentifier1 = @"SettingsCell1";
	static NSString *CellIdentifier2 = @"SettingsCell2";
	static NSString *CellIdentifier3 = @"SettingsCell3";
	
	UITableViewCell *cell;
	int newSection = indexPath.section + sectionOffset;
	
	if (newSection == 0)
	{
		if (indexPath.row == 0) {
			cell = purchaseAdsFreeCell;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = COLOR_AD_REMOVAL;
		}
	}
	else if (newSection == 1)
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
	else if (newSection == 2)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		}
		
		[cell.imageView setImage:nil];
		if (indexPath.row == 0) {
			cell.textLabel.text = @"FAQ";
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"HappenApps Blog";
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Send us feedback";
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if (newSection == 3)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3] autorelease];
		}
		
		for (UIView *v in cell.contentView.subviews) {
			[v removeFromSuperview];
		}
		
		NSDictionary *dict = [appArray objectAtIndex:indexPath.row];
		
		UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_icon_placeholder.png"]];
		[iconImageView setFrame:CGRectMake(6, 4, 40, 40)];
		[cell.contentView addSubview:iconImageView];
		[iconImageView release];
		
		UIImage *iconImage = [iconDictionary objectForKey:[dict objectForKey:@"app_name"]];
		if (iconImage == nil) {
			NSString *appURLString = [[dict objectForKey:@"base_url"] stringByAppendingString:@"icon40.png"];
			NSURL *appURL = [NSURL URLWithString:appURLString];
			
			ASIHTTPRequest *request;
			request = [ASIHTTPRequest requestWithURL:appURL];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_TYPE_GET_ICON], @"request_type",
									  [dict objectForKey:@"app_name"], @"app_name", nil];
			[request setUserInfo:userInfo];
			[networkQueue addOperation:request];
			[networkQueue go];
		} else {
			[iconImageView setImage:iconImage];
		}
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 5, 200, 22)];
		[titleLabel setText:[dict objectForKey:@"app_name"]];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
		
		[cell.contentView addSubview:titleLabel];
		[titleLabel release];
		
		UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 27, 235, 15)];
		[descriptionLabel setText:[dict objectForKey:@"description"]];
		[descriptionLabel setFont:[UIFont systemFontOfSize:12]];
		descriptionLabel.textColor = [UIColor grayColor];
		descriptionLabel.highlightedTextColor = [UIColor whiteColor];
		
		[cell.contentView addSubview:descriptionLabel];
		[descriptionLabel release];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	int newSection = indexPath.section + sectionOffset;
	if (newSection == 1)
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
	else if (newSection == 2)
	{
		if (indexPath.row == 0) {
			[self showFAQ];
		} else if (indexPath.row == 1) {
			[self showBlog];
		} else if (indexPath.row == 2) {
			[self sendFeedback];
		}
	}
	else if (newSection == 3)
	{
		NSDictionary *appDict = [appArray objectAtIndex:indexPath.row];
		NSString *platform = [appDict objectForKey:@"platform"];
		NSString *model = [[UIDevice currentDevice] model];
		
		if ([platform isEqualToString:@"iPad"] && ![model isEqualToString:@"iPad"]) {
			AppViewController *controller = [[AppViewController alloc] init];
			controller.appDict = appDict;
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
		} else {
			NSString *urlString = [appDict objectForKey:@"itunes_url"];
			NSURL *itunesURL = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:itunesURL];
		}
		
		NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:[appDict objectForKey:@"app_name"], @"appName", nil];
		[FlurryAPI logEvent:@"CLICKED_CROSS_PROMOTION" withParameters:flurryDict];
	}
}


#pragma mark -
#pragma mark Mail

- (void)showFAQ
{
    FAQViewController *controller = [[FAQViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)showBlog
{
	WebViewController *controller = [[WebViewController alloc] initWithURL:[NSURL URLWithString:URL_BLOG]];
	controller.mode = MODE_PUSHED;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)sendFeedback
{
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setToRecipients:[NSArray arrayWithObject:@"support@happenapps.com"]];
		NSString *subject = [NSString stringWithFormat:@"Feedback for %@", [Utility appName]];
		[picker setSubject:subject];
		
		NSString *body = [NSString stringWithFormat:@"\n\n%@", [Utility diagnosticInfo]];
		[picker setMessageBody:body isHTML:FALSE];
		
		[self.navigationController presentModalViewController:picker animated:YES];
		[picker release];
	} else {
		[self launchMailAppOnDevice];
	}
}

- (void)composeEmail
{
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposeSheet];
	} else {
		[self launchMailAppOnDevice];
	}
}

- (void)displayComposeSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:STRING_EMAIL_SUBJECT];
	[picker setMessageBody:STRING_EMAIL_BODY isHTML:FALSE];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

// Launches the Mail application on the device.
- (void)launchMailAppOnDevice
{
	NSString *email = [NSString stringWithFormat: @"mailto:%@?subject=%@&body=%@", @"", STRING_EMAIL_SUBJECT, STRING_EMAIL_BODY];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error 
{
	[self dismissModalViewControllerAnimated:YES];
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



#pragma mark -
#pragma mark In-app purchase to remove ads

- (IBAction)buyAdsFreeVersion:(id)sender
{
	NSString *msg = @"Are you sure you want to purchase the lifetime ads-free version for $0.99? (If you have made this purchase before, you won't be charged again.)";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Ads Permanently"
													message:msg
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Confirm", nil];
	alert.tag = TAG_BUY_ADS_FREE_VERSION;
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == TAG_BUY_ADS_FREE_VERSION && buttonIndex == 1) {
		[[InAppPurchaseManager sharedInstance] purchaseAdsFreeVersion];
	}
}

- (void)removeAds
{
	[self performSelectorOnMainThread:@selector(removeAdsOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)removeAdsOnMainThread
{
	[mainTableView reloadData];
}

@end
