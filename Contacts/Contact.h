//
//  Contact.h
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface Contact : NSObject

@property (nonatomic, strong) NSString *compositeName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) id record;

-(id)initWithRecord:(ABRecordRef)ref;
- (NSString *)fullName;
- (NSAttributedString *)attributedFullName;
- (NSString *)monthAndYearCreated;
- (NSString *)yearAndMonthCreated;
- (ABRecordRef)addressBookReference;

@end
