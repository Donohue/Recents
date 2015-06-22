//
//  ViewController.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ViewController.h"
#import "SpinnerView.h"
#import "ContactTableViewCell.h"
#import "ContactAccessoryView.h"
#import "ContactsManager.h"
#import "ContactsSection.h"
#import "Contact.h"
@import MessageUI;

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
            strongSelf.tableView.tableFooterView = [[UIView alloc] init];
            strongSelf.tableView.scrollEnabled = YES;
            if ([strongSelf.refreshControl isRefreshing]) {
                [strongSelf.refreshControl endRefreshing];
            }
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Recents", nil);
    self.tableView.tableFooterView = [[SpinnerView alloc] initWithSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height - 64)];
    self.tableView.scrollEnabled = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                       action:@selector(setupContacts)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self setupContacts];

}

- (Contact *)contactAtIndexPath:(NSIndexPath *)indexPath {
    ContactsSection *section = self.sections[indexPath.section];
    return section.contacts[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = [self contactAtIndexPath:indexPath];
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.attributedText = [contact attributedFullName];
    cell.contactAccessoryView.phoneBlock = ^{
        [[UIApplication sharedApplication] openURL:[contact.phoneNumbers[0] phoneURL]];
    };
    cell.contactAccessoryView.messageBlock = ^{
        [[UIApplication sharedApplication] openURL:[contact.phoneNumbers[0] smsURL]];
    };
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
        __weak typeof(self) weakSelf = self;
        Contact *contact = [self contactAtIndexPath:indexPath];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction *action) {
                                                            typeof(self) strongSelf = weakSelf;
                                                            if (!strongSelf)
                                                                return;
                                                            
                                                            ContactsSection *section = strongSelf.sections[indexPath.section];
                                                            [section.contacts removeObjectAtIndex:indexPath.row];
                                                            [[ContactsManager sharedInstance] deleteContact:contact];
                                                            [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {}];
        NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@ from your contacts?", contact.fullName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Contact", nil)
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:confirm];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
