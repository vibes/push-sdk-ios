//
//  InboxViewController.h
//  Vibes SDK Objective-C Sample App
//
//  Created by Moin' Victor on 24/11/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface InboxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
    @property (nonatomic) IBOutlet UIRefreshControl *refreshControl;
    @property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
