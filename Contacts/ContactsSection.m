//
//  ContactsSection.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ContactsSection.h"

@implementation ContactsSection

- (id)initWithTitle:(NSString *)title andContacts:(NSArray *)contacts {
    self = [super init];
    if (self) {
        self.title = title;
        self.contacts = [NSMutableArray arrayWithArray:contacts];
    }
    return self;
}

@end
