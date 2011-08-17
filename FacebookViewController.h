//
//  FacebookViewController.h
//  BetterTransit
//
//  Created by Yaogang Lian on 10/31/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface FacebookViewController : UIViewController 
<FBSessionDelegate, FBRequestDelegate, FBDialogDelegate, 
UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
	UITableView *tableView;
	UITableViewCell *loginCell;
	
	FBSession* facebookSession;
	FBPermissionDialog* pDialog;
	FBLoginDialog *lDialog;
}

- (void)writeToWall;

@end
