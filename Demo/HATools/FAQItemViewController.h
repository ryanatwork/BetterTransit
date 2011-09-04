//
//  FAQItemViewController.h
//  Showtime
//
//  Created by yaogang@enflick on 5/26/11.
//  Copyright 2011 HappenApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FAQItemViewController : UITableViewController
{
    NSString *question;
    NSString *answer;
}

@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *answer;

@end
