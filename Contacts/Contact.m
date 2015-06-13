//
//  Contact.m
//  Contacts
//
//  Created by Brian Donohue on 6/13/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "Contact.h"
@import UIKit;

@implementation Contact

-(id)initWithRecord:(ABRecordRef)ref {
    self = [super init];
    if (self) {
        self.firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        self.lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        self.created = (__bridge NSDate *)ABRecordCopyValue(ref, kABPersonCreationDateProperty);
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
    if ([self.firstName length] && [self.lastName length])
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    else if ([self.firstName length])
        return self.firstName;
    else if (self.lastName)
        return self.lastName;
    else
        return @"";
}

- (NSAttributedString *)attributedFullName {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:self.fullName
                                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    [ret setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]}
                 range:NSMakeRange(0, [self.firstName length])];
    return ret;
}

@end
