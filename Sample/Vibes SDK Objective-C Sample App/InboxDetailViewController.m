//
//  InboxDetailViewController.m
//  Vibes SDK Objective-C Sample App
//
//  Created by Moin' Victor on 25/11/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

#import "InboxDetailViewController.h"

@interface InboxDetailViewController ()

@end

@implementation InboxDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentLabel setText: _inboxMessage.content];
    [self.subjectLabel setText: _inboxMessage.subject];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd 'at' HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate: _inboxMessage.createdAt];
    [self.dateLabel setText:dateString];

    [self downloadImageFromURL:_inboxMessage.detail intoImageView:self.imageIcon withActivityIndicator:self.activityIndicator];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) downloadImageFromURL: (NSString*) url intoImageView: (UIImageView*) imageView
        withActivityIndicator: (UIActivityIndicatorView*) activityIndicator
{
    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
        if ( data == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
                [activityIndicator setHidden:YES];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            imageView.image = [UIImage imageWithData: data];
            [activityIndicator stopAnimating];
            [activityIndicator setHidden:YES];
        });
    });
}
@end
