//
//  InboxViewController.m
//  Vibes SDK Objective-C Sample App
//
//  Created by Moin' Victor on 24/11/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

#import "InboxViewController.h"
#import "InboxMessageTableViewCell.h"
#import "InboxDetailViewController.h"
@import VibesPush;

@interface InboxViewController ()

@end

@implementation InboxViewController
    NSArray<InboxMessage *> *inboxMessages;
    NSInteger selectedIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    inboxMessages = [[NSMutableArray alloc] init];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents: UIControlEventValueChanged];

    if (@available(iOS 10.0, *)) {
        self.tableView.refreshControl = self.refreshControl;
    } else {
        [self.tableView addSubview: self.refreshControl];
    }
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchMessages];
}

- (void)refreshTable {
    //TODO: refresh your data
    [self fetchMessages];
}

- (void) fetchMessages {
    [self.refreshControl beginRefreshing];
    [[Vibes shared] fetchInboxMessages:^(NSArray<InboxMessage *> * _Nonnull messages, NSError * _Nullable error) {
        NSLog(@"fetchInboxMessages: Result -----===>>>>>>> %@", messages);
        NSLog(@"fetchInboxMessages: Error -----===>>>>>>> %@", error ? error : @"[None]");
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.refreshControl endRefreshing];
            // Run UI Updates
            if (error == nil) {
                inboxMessages = messages;
                [self.tableView reloadData];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Inbox Error" message: error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction: cancel];
                [self presentViewController: alert animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section
{
    return [inboxMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";

    InboxMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellId];
    if (cell == nil) {
        cell = [[InboxMessageTableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: cellId];
    }
    InboxMessage *message = [inboxMessages objectAtIndex: indexPath.row];

    [cell.contentLabel setText: message.content];
    [cell.subjectLabel setText: message.subject];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd 'at' HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate: message.createdAt];
    [cell.dateLabel setText:dateString];

    [self downloadImageFromURL:message.detail intoImageView:cell.imageIcon withActivityIndicator:cell.activityIndicator];
    return cell;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (inboxMessages == nil || inboxMessages.count == 0) {
        UILabel *noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, tableView.bounds.size.height)];
        [noDataLabel setText:@"No inbox messages. Pull to fetch messages... "];
        [noDataLabel setTextColor: [UIColor grayColor]];
        [noDataLabel setTextAlignment: NSTextAlignmentCenter];
        tableView.backgroundView = noDataLabel;
        [tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        return 0;
    }
    self.tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    return 1;
}

#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    InboxMessageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Row:%d selected and its data is %@", indexPath.row, cell.subjectLabel.text);
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"inbox_detail" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"inbox_detail"]) {
        InboxDetailViewController *detailCont = segue.destinationViewController;
        detailCont.inboxMessage = [inboxMessages objectAtIndex:selectedIndex];
    }
}

/// Download the image into image view
/// @param url Image URL
/// @param imageView The image view
/// @param activityIndicator The activity indicator to show progress
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
