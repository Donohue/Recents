//
//  ContactAccessoryView.h
//  Contacts
//
//  Created by Brian Donohue on 6/21/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@protocol ContactAccessoryViewDelegate <NSObject>

-(void)contactAccessoryViewPhone:(Contact *)contact;
-(void)contactAccessoryViewMessage:(Contact *)contact;

@end

@interface ContactAccessoryView : UIView

@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) void (^phoneBlock)();
@property (nonatomic, strong) void (^messageBlock)();

@end
