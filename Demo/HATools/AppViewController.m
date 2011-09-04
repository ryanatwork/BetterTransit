//
//  AppViewController.m
//  BetterTransit
//
//  Created by Yaogang Lian on 11/3/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "AppViewController.h"
#import "LoadingView.h"

@implementation AppViewController

@synthesize contentScrollView, bgView;
@synthesize appNameLabel, companyNameLabel, appIconView;
@synthesize descriptionLabel, imageScrollView, clipView;
@synthesize baseURLString, appDict, infoDict, imageDict;
@synthesize screenshots;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Info";
	self.baseURLString = [appDict objectForKey:@"base_url"];
	self.appNameLabel.text = [appDict objectForKey:@"app_name"];
	
	self.infoDict = nil;
	self.imageDict = [NSMutableDictionary dictionaryWithCapacity:6];
	self.screenshots = [NSMutableArray arrayWithCapacity:5];
	
	[LoadingView show];
	
	// Download app detailed info
	networkQueue = [[ASINetworkQueue alloc] init];
	[networkQueue setDelegate:self];
	[networkQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(requestDidFail:)];
	
	NSString *infoURLString = [self.baseURLString stringByAppendingString:@"info.xml"];
	NSURL *infoURL = [NSURL URLWithString:infoURLString];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:infoURL];
	[request setTimeOutSeconds:20];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
							  [NSNumber numberWithInt:REQUEST_TYPE_GET_XML] forKey:@"request_type"];
	[request setUserInfo:userInfo];
	[networkQueue addOperation:request];
	[networkQueue go];
	
	// Download app icon
	UIImage *iconImage = [imageDict objectForKey:@"app_icon.png"];
	if (iconImage == nil) {
		NSString *s = [self.baseURLString stringByAppendingString:@"icon90.png"];
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:s]];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_TYPE_GET_ICON], @"request_type",
								  @"app_icon.png", @"image_name", nil];
		[request setUserInfo:userInfo];
		[networkQueue addOperation:request];
	} else {
		[self.appIconView setImage:iconImage];
	}
	
	clipView.clipsToBounds = YES;
	clipView.backgroundColor = [UIColor clearColor];
	
	imageScrollView.clipsToBounds = NO;
	imageScrollView.pagingEnabled = YES;
	imageScrollView.showsHorizontalScrollIndicator = NO;
	
	//contentScrollView.canCancelContentTouches = YES;
	//contentScrollView.delaysContentTouches = YES;
}

- (void)layoutScreenshots
{	
	// Download screenshots and layout them in the scroll view
	NSArray *imageNames = [infoDict objectForKey:@"screenshots"];
	int numberOfImages = [imageNames count];
	
	for (int i=0; i<numberOfImages; i++) {
		NSString *name = [imageNames objectAtIndex:i];
		UIImage *image = [imageDict objectForKey:name];
		
		if (image == nil) {
			NSString *s = [self.baseURLString stringByAppendingString:name];
			ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:s]];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_TYPE_GET_ICON], @"request_type",
									  name, @"image_name", nil];
			[request setUserInfo:userInfo];
			[networkQueue addOperation:request];
		}
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.contentMode = UIViewContentModeCenter;
		[screenshots addObject:imageView];
		[imageView setFrame:CGRectMake((i*260)+10, 10, 240, 320)];
		[imageScrollView addSubview:imageView];
		[imageView release];
	}
	
	[imageScrollView setContentSize:CGSizeMake(numberOfImages*260, 340)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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
	[contentScrollView release], contentScrollView = nil;
	[bgView release], bgView = nil;
	[appNameLabel release], appNameLabel = nil;
	[companyNameLabel release], companyNameLabel = nil;
	[appIconView release], appIconView = nil;
	[descriptionLabel release], descriptionLabel = nil;
	[imageScrollView release], imageScrollView = nil;
	[clipView release], clipView = nil;
	[baseURLString release], baseURLString = nil;
	[appDict release], appDict = nil;
	[infoDict release], infoDict = nil;
	[imageDict release], imageDict = nil;
	[screenshots release], screenshots = nil;
	[networkQueue setDelegate:nil];
	[networkQueue release], networkQueue = nil;
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
		
		[LoadingView dismiss];
		
		NSString *err = nil;
		infoDict = [[NSPropertyListSerialization propertyListFromData:[request responseData]
													 mutabilityOption:NSPropertyListMutableContainersAndLeaves
															   format:NULL
													 errorDescription:&err] retain];
		
		NSString *s = [infoDict objectForKey:@"description"];
		CGRect rect = self.descriptionLabel.frame;
		CGSize size = [s sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(rect.size.width, CGFLOAT_MAX)
						lineBreakMode:UILineBreakModeWordWrap];
		
		self.companyNameLabel.text = [infoDict objectForKey:@"company"];
		self.descriptionLabel.text = s;
		self.descriptionLabel.numberOfLines = 0;
		[self.descriptionLabel setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, size.height)];
		
		self.contentScrollView.contentSize = CGSizeMake(320, size.height + 456);
		self.clipView.frame = CGRectMake(0, size.height+100, 320, 340);
		self.imageScrollView.frame = CGRectMake(30, 0, 260, 340);
		
		[self layoutScreenshots];
		
	} else if (requestType == REQUEST_TYPE_GET_ICON) {
		UIImage *image = [UIImage imageWithData:[request responseData]];
		if (image != nil)
			[imageDict setObject:image forKey:[[request userInfo] objectForKey:@"image_name"]];
		
		NSString *name = [[request userInfo] objectForKey:@"image_name"];
		if ([name isEqualToString:@"app_icon.png"]) {
			UIImage *iconImage = [imageDict objectForKey:@"app_icon.png"];
			[self.appIconView setImage:iconImage];
			[self.appIconView setFrame:CGRectMake(10, 16, 60, 60)];
		} else {
			NSArray *imageNames = [infoDict objectForKey:@"screenshots"];
			int i = [imageNames indexOfObject:name];
			[[screenshots objectAtIndex:i] setImage:[imageDict objectForKey:name]];
		}
	}
}

- (void)requestDidFail:(ASIHTTPRequest *)request
{
	NSLog(@"request did fail with error: %@", [request error]);
}


#pragma mark -
#pragma mark Action

- (IBAction)downloadApp:(id)sender
{
	NSLog(@"download app");
	NSString *s = [appDict objectForKey:@"itunes_url"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:s]];
}

@end
