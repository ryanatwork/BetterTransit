//
//  FAQViewController.m
//  Showtime
//
//  Created by yaogang@enflick on 5/26/11.
//  Copyright 2011 HappenApps. All rights reserved.
//

#import "FAQViewController.h"
#import "FAQItemViewController.h"


@implementation FAQViewController


@synthesize faqArray;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        faqArray = nil;
    }
    return self;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [faqArray release], faqArray = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"FAQ", @"");
    
    if (faqArray == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"Loading...";
        HUD.delegate = self;
        
        // Show the HUD while the provided method executes in the background
        [HUD showWhileExecuting:@selector(loadFAQ) onTarget:self withObject:nil animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Actions

- (void)loadFAQ
{
    self.faqArray = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:URL_FAQ]];
    [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
}

- (void)reloadTable
{
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (faqArray == nil) {
        return 0;
    } else {
        return [faqArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    
    NSDictionary *dict = [faqArray objectAtIndex:indexPath.row];
    NSString *question = [dict objectForKey:@"question"];
    
    CGSize maxSize = {266, 300};
    CGSize size = [question sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, size.width, size.height)];
    [titleLabel setText:question];
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
    [titleLabel setNumberOfLines:0];
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [faqArray objectAtIndex:indexPath.row];
    NSString *question = [dict objectForKey:@"question"];
    CGSize maxSize = {266, 300};
    CGSize size = [question sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    return size.height + 20.0f;
}


#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [faqArray objectAtIndex:indexPath.row];
    NSString *question = [dict objectForKey:@"question"];
    NSString *answer = [dict objectForKey:@"answer"];
    
    FAQItemViewController *controller = [[FAQItemViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [controller setQuestion:question];
    [controller setAnswer:answer];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


#pragma mark -
#pragma mark MBProgressHUD delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
    [HUD release];
}

@end
