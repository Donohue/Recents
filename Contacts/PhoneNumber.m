//
//  PhoneNumber.m
//  Contacts
//
//  Created by Brian Donohue on 6/21/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "PhoneNumber.h"

@implementation PhoneNumber

-(NSString *)unformattedNumber {
    NSString *unformatted = [self.number stringByReplacingOccurrencesOfString:@" " withString:@""];
    unformatted = [unformatted stringByReplacingOccurrencesOfString:@"(" withString:@""];
    unformatted = [unformatted stringByReplacingOccurrencesOfString:@")" withString:@""];
    unformatted = [unformatted stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return unformatted;
}

-(NSURL *)smsURL {
    NSString *str = [NSString stringWithFormat:@"sms:%@", [self unformattedNumber]];
    return [NSURL URLWithString:str];
}

-(NSURL *)phoneURL {
    NSString *str = [NSString stringWithFormat:@"tel:%@", [self unformattedNumber]];
    return [NSURL URLWithString:str];
}

@end
