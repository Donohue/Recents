//
//  ContactAccessoryView.m
//  Contacts
//
//  Created by Brian Donohue on 6/21/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ContactAccessoryView.h"

@implementation ContactAccessoryView

#define kImageSize 25
#define kImagePadding 20

-(id)init {
    self = [super initWithFrame:CGRectMake(0, 0, kImageSize * 2 + kImagePadding, kImageSize)];
    if (self) {
        self.phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.phoneButton.frame = CGRectMake(0, 0, kImageSize, kImageSize);
        [self.phoneButton setImage:[UIImage imageNamed:@"phone"]
                          forState:UIControlStateNormal];
        [self.phoneButton addTarget:self
                             action:@selector(phoneButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
        
        self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.messageButton.frame = CGRectMake(kImageSize + kImagePadding, 0, kImageSize, kImageSize);
        [self.messageButton setImage:[UIImage imageNamed:@"message"]
                            forState:UIControlStateNormal];
        [self.messageButton addTarget:self
                               action:@selector(messageButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.phoneButton];
        [self addSubview:self.messageButton];
    }
    return self;
}

- (void)phoneButtonTapped:(id)sender {
    if (self.phoneBlock) {
        self.phoneBlock();
    }
}

- (void)messageButtonTapped:(id)sender {
    if (self.messageBlock) {
        self.messageBlock();
    }
}

@end
