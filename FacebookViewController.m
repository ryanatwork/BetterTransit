//
//  FacebookViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/31/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "FacebookViewController.h"
#import "Utility.h"
#import "LoadingView.h"
#import "FlurryAPI.h"

#define KEY_FB_PERMISSION_GRANTED @"KEY_FB_PERMISSION_GRANTED"
#define KEY_LAST_TIME_SHARING_DIALOG_SHOWN @"KEY_LAST_TIME_SHARING_DIALOG_SHOWN"


@implementation FacebookViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStyleGrouped];
	[tableView setDataSource:self];
	[tableView setDelegate:self];
	[self.view addSubview:tableView];
	
	loginCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
	CGRect contentRect;
	contentRect = CGRectMake(10.0, 2.0, 275, 38);
	
	UILabel *textView = [[UILabel alloc] initWithFrame:contentRect];
	textView.text = @"Share on Facebook";
	loginCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	textView.numberOfLines = 1;
	textView.textColor = [UIColor blackColor];
	textView.highlightedTextColor = [UIColor whiteColor];
	textView.font = [UIFont boldSystemFontOfSize:16];
	textView.textAlignment = UITextAlignmentLeft; // default
	
	[loginCell.contentView addSubview:textView];
	[textView release];
	
	[self setTitle:@"Facebook Connect"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[tableView reloadData];
	
	facebookSession = [[FBSession sessionForApplication:FB_API_KEY secret:FB_API_SECRET delegate:self] retain];
	
	if (facebookSession.isConnected) {
		[LoadingView showWithText:@"Sharing..."];
		[self writeToWall];
	} else {
		lDialog = [[FBLoginDialog alloc] initWithSession:facebookSession];
		[lDialog setDelegate:self];
		[lDialog show];
		[lDialog release];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[facebookSession release], facebookSession = nil;
	[tableView release], tableView = nil;
	[loginCell release], loginCell = nil;	
    [super dealloc];
}


#pragma mark -
#pragma mark UITableViewDelegate & DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return loginCell;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (facebookSession.isConnected) {
		[LoadingView showWithText:@"Sharing..."];
		[self writeToWall];
		
	} else {
		lDialog = [[FBLoginDialog alloc] initWithSession:facebookSession];
		[lDialog setDelegate:self];
		[lDialog show];
		[lDialog release];
	}
	
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section
{
	return [NSString stringWithFormat:@"Connect with Facebook to share \n%@ with your friends", APP_NAME];
}


#pragma mark -
#pragma mark Action methods

- (void)request:(FBRequest*)request didLoad:(id)result 
{
	if ([request.method isEqualToString:@"facebook.stream.publish"]) {
		
		//NSLog(@"Message successfully posted");
		[LoadingView dismiss];
		
		// Avoid showing the same dialog twice in a row
		NSDate *lastTimeShown = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LAST_TIME_SHARING_DIALOG_SHOWN];
		if (lastTimeShown == nil || [[NSDate date] timeIntervalSinceDate:lastTimeShown] > 1.0f) {
			
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks for sharing!" 
															message:nil
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];		
			[alert show];
			[alert release];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KEY_LAST_TIME_SHARING_DIALOG_SHOWN];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	[LoadingView dismiss];
	NSLog(@"%@",error);
	//[self.navigationController popViewControllerAnimated:YES];
}

- (void)dialogDidSucceed:(FBDialog*)dialog
{
	if (dialog == pDialog) {
		//NSLog(@"FB permission granted");
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:KEY_FB_PERMISSION_GRANTED];
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_FB_PERMISSION_GRANTED]) {
		[LoadingView showWithText:@"Sharing..."];
		[self writeToWall];
	}
}

- (void)writeToWall
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							FB_SHARE_MESSAGE, @"message",
							FB_SHARE_ATTACHMENT, @"attachment",
							nil];
	[[FBRequest requestWithDelegate:self] call:@"facebook.stream.publish" params:params];
	
	[FlurryAPI logEvent:@"SHARE_ON_FACEBOOK"];
}

#pragma mark -
#pragma mark FBSession delegate methods

- (void)showPDialog
{
	pDialog = [[[FBPermissionDialog alloc] init] autorelease];
	pDialog.delegate = self;
	pDialog.permission = @"status_update";
	[pDialog show];	
}

- (void)session:(FBSession*)session didLogin:(FBUID)uid
{
	if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_FB_PERMISSION_GRANTED]) {
		[self showPDialog];
	} 
}

@end
