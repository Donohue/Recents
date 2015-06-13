//
//  ContactsSection.h
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsSection : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *contacts;

- (id)initWithTitle:(NSString *)title andContacts:(NSArray *)contacts;

@end
