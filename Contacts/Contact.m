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
    }
    return self;
}

- (NSString *)fullName {
    if ([self.firstName length] && [self.lastName length])
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    else if ([self.firstName length])
        return self.firstName;
    else
        return self.lastName;
}

- (NSAttributedString *)attributedFullName {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:self.fullName
                                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    [ret setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]}
                 range:NSMakeRange(0, [self.firstName length])];
    return ret;
}

@end
