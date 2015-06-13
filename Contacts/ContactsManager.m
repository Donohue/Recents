//
//  ContactsManager.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ContactsManager.h"
#import "Contact.h"
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
    NSMutableArray *unsortedContacts = [NSMutableArray array];
    for (id entry in entries) {
        [unsortedContacts addObject:[[Contact alloc] initWithRecord:(__bridge ABRecordRef)entry]];
    }
    
    return [unsortedContacts sortedArrayUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {
        return [obj2.created compare:obj1.created];
    }];
}

- (void)authorizeAndLoadContacts:(void(^)(BOOL, NSArray *))completionHandler {
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf)
                return;
        
            NSArray *arr = granted? [strongSelf loadContacts:ab]: nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(granted, arr);
            });
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self loadContacts:ab];
        completionHandler(YES, [self loadContacts:ab]);
    }
    else {
        completionHandler(NO, nil);
    }
}

@end
