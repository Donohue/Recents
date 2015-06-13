//
//  ViewController.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ViewController.h"
#import "ContactsManager.h"
#import "ContactsSection.h"
#import "Contact.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ViewController

@dynamic refreshControl;

- (void)setupContacts {
    __weak typeof(self) weakSelf = self;
    [[ContactsManager sharedInstance] authorizeAndLoadContacts:^(BOOL granted, NSArray *ret) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.sections = ret;
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
    ContactsSection *section = self.sections[indexPath.section];
    Contact *contact = section.contacts[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"cell"];
    cell.textLabel.attributedText = [contact attributedFullName];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)s {
    ContactsSection *section = self.sections[s];
    return [section.contacts count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)s {
    ContactsSection *section = self.sections[s];
    return section.title;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ContactsSection *section = self.sections[indexPath.section];
        [section.contacts removeObjectAtIndex:indexPath.row];
        [[ContactsManager sharedInstance] deleteContact:section.contacts[indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
