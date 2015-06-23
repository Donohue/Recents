//
//  PermissionsView.h
//  Contacts
//
//  Created by Brian Donohue on 6/22/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PermissionsView : UIView

-(id)initWithSize:(CGSize)size;

@property (nonatomic, strong) UIButton *permissionsButton;
@property (nonatomic, strong) void (^permissionsBlock)();

@end
