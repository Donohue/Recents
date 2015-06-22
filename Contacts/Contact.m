//
//  Contact.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "Contact.h"
#import "PhoneNumber.h"
@import UIKit;

@implementation Contact

- (NSArray *)phoneNumbersWithRecord:(ABRecordRef)ref {
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(phoneNumbers)];
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
        NSString *locLabel = nil;
        if (label) {
            locLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(label);
            CFRelease(label);
        }
        
        PhoneNumber *phoneNumber = [[PhoneNumber alloc] init];
        phoneNumber.number = number;
        phoneNumber.label = locLabel;
        [numbers addObject:phoneNumber];
    }
    return numbers;
}

-(id)initWithRecord:(ABRecordRef)ref {
    self = [super init];
    if (self) {
        self.compositeName = (__bridge NSString *)ABRecordCopyCompositeName(ref);
        self.firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        self.lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        self.created = (__bridge NSDate *)ABRecordCopyValue(ref, kABPersonCreationDateProperty);
        self.emailAddress = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonEmailProperty);
        self.phoneNumbers = [self phoneNumbersWithRecord:ref];
        self.record = (__bridge id)ref;
    }
    return self;
}

- (ABRecordRef)addressBookReference {
    return (__bridge ABRecordRef)self.record;
}

- (NSString *)monthAndYearCreated {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"MMM yyyy"];
    return [dateFormatter stringFromDate:self.created];
}

- (NSString *)yearAndMonthCreated {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    return [dateFormatter stringFromDate:self.created];
}

- (NSString *)fullName {
    return [self.compositeName length]? self.compositeName: @"";
}

- (NSAttributedString *)attributedFullName {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:self.fullName
                                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    [ret setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]}
                 range:NSMakeRange(0, [self.firstName length])];
    return ret;
}

@end
