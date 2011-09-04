//
//  FAQItemViewController.m
//  Showtime
//
//  Created by yaogang@enflick on 5/26/11.
//  Copyright 2011 HappenApps. All rights reserved.
//

#import "FAQItemViewController.h"


@implementation FAQItemViewController

@synthesize question, answer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
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
    [question release], question = nil;
    [answer release], answer = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"FAQ", @"");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    
    CGSize maxSize = {270, 300};
    
    CGSize size1 = [question sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, size1.width, size1.height)];
    [questionLabel setText:question];
    [questionLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [questionLabel setNumberOfLines:0];
    [questionLabel setLineBreakMode:UILineBreakModeWordWrap];
    questionLabel.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:questionLabel];
    [questionLabel release];
    
    CGSize size2 = [answer sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 20+size1.height, size2.width, size2.height)];
    [answerLabel setText:answer];
    [answerLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [answerLabel setNumberOfLines:0];
    [answerLabel setLineBreakMode:UILineBreakModeWordWrap];
    answerLabel.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:answerLabel];
    [answerLabel release];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize maxSize = {270, 300};
    CGSize size1 = [question sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    CGSize size2 = [answer sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    return size1.height + size2.height + 30.0f;
}


#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
