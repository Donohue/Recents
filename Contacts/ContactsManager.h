//
//  ContactsManager.h
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface ContactsManager : NSObject

+ (id)sharedInstance;
- (void)authorizeAndLoadContacts:(void(^)(BOOL, NSArray *))completionHandler;
- (void)deleteContact:(Contact *)contact;

@end
