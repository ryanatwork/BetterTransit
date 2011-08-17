//
//  ListViewController.h
//  Showtime
//
//  Created by Yaogang Lian on 1/16/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIViewController.h"

@protocol ListViewControllerDelegate <NSObject>
- (void)setSelectedIndex:(NSUInteger)index forListName:(NSString *)name;
@end


@interface ListViewController : CustomUIViewController
<UITableViewDelegate, UITableViewDelegate>
{
	UITableView *mainTableView;
	NSArray *list;
	NSString *name;
	NSUInteger selectedIndex;
	id<ListViewControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) id<ListViewControllerDelegate> delegate;

- (id)initWithList:(NSArray *)l name:(NSString *)s selectedIndex:(NSUInteger)index delegate:(id)d;

@end
