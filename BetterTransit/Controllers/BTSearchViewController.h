//
//  BTSearchViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 11/10/09.
//  Copyright 2009 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTransit.h"
#import "BTStationCell.h"
#import "BTPredictionViewController.h"
#import "BTUIViewController.h"


@interface BTSearchViewController : BTUIViewController 
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
	BTTransit *transit;
	NSMutableArray *stations;
	
	UISearchBar *searchBar;
	UITableView *mainTableView;
	
	UIButton *bigCancelButton;
	BOOL bigCancelButtonIsShown;
	
	UILabel *noResultsLabel;
	BOOL noResultsLabelIsShown;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, retain) NSMutableArray *stations;

- (void)handleSearchForTerm:(NSString *)term;
- (void)registerForKeyboardNotifications;
- (void)keyboardDidShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
- (void)cancel:(id)sender;

@end
