//
//  ViewController.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ViewController.h"
#import "ContactsManager.h"
#import "Contact.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ViewController

@dynamic refreshControl;

- (void)setupContacts {
    __weak typeof(self) weakSelf = self;
    [[ContactsManager sharedInstance] authorizeAndLoadContacts:^(BOOL granted, NSArray *ret) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.contacts = ret;
            [strongSelf.tableView reloadData];
            if ([strongSelf.refreshControl isRefreshing]) {
                [strongSelf.refreshControl endRefreshing];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Contacts", nil);
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                       action:@selector(setupContacts)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self setupContacts];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = self.contacts[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.attributedText = [contact attributedFullName];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

@end
