//
//  ContactsManager.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ContactsManager.h"
#import "ContactsSection.h"
#import <AddressBook/AddressBook.h>

@implementation ContactsManager

+ (id)sharedInstance {
    static dispatch_once_t predicate;
    static ContactsManager *obj;
    dispatch_once(&predicate, ^{
        obj = [[ContactsManager alloc] init];
    });
    return obj;
}

- (NSArray *)loadContacts:(ABAddressBookRef)ab {
    NSArray *entries = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(ab);
    NSMutableDictionary *unsortedSections = [NSMutableDictionary dictionary];
    for (id entry in entries) {
        Contact *contact = [[Contact alloc] initWithRecord:(__bridge ABRecordRef)entry];
        NSString *key = contact.yearAndMonthCreated;
        NSMutableArray *arr = unsortedSections[key];
        if (!arr)
            unsortedSections[key] = [NSMutableArray arrayWithObject:contact];
        else
            [arr addObject:contact];
    }
    
    NSArray *sortedKeys = [[unsortedSections allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
        return [key2 compare:key1];
    }];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sortedKeys.count];
    for (NSString *key in sortedKeys) {
        NSArray *sorted = [unsortedSections[key] sortedArrayUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {
            return [obj2.created compare:obj1.created];
        }];
        
        Contact *contact = sorted[0];
        ContactsSection *section = [[ContactsSection alloc] initWithTitle:contact.monthAndYearCreated
                                                              andContacts:sorted];
        [sections addObject:section];
    }
    
    return sections;
}

- (void)authorizeAndLoadContacts:(void(^)(BOOL, NSArray *))completionHandler {
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf)
                return;
        
            NSArray *arr = granted? [self loadContacts:ab]: nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(granted, arr);
            });
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        completionHandler(YES, [self loadContacts:ab]);
    }
    else {
        completionHandler(NO, nil);
    }
}

- (void)deleteContact:(Contact *)contact {
    CFErrorRef error = NULL;
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    BOOL success = ABAddressBookRemoveRecord(ab, contact.addressBookReference, &error);
    NSLog(@"SUCCESS: %d %@", success, error);
}

@end
