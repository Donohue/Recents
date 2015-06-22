//
//  PhoneNumber.h
//  Contacts
//
//  Created by Brian Donohue on 6/21/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNumber : NSObject

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *number;

- (NSURL *)phoneURL;
- (NSURL *)smsURL;

@end
