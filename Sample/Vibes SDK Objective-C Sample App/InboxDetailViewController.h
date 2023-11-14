//
//  InboxDetailViewController.h
//  Vibes SDK Objective-C Sample App
//
//  Created by Moin' Victor on 25/11/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

#import <UIKit/UIKit.h>
@import VibesPush;

NS_ASSUME_NONNULL_BEGIN

@interface InboxDetailViewController : UIViewController
    @property (nonatomic, weak) IBOutlet UILabel *contentLabel;
    @property (nonatomic, weak) IBOutlet UILabel *subjectLabel;
    @property (nonatomic, weak) IBOutlet UILabel *dateLabel;
    @property (nonatomic, weak) IBOutlet UIImageView *imageIcon;
    @property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
    @property InboxMessage *inboxMessage;
@end

NS_ASSUME_NONNULL_END
