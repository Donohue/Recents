//
//  ContactTableViewCell.m
//  Contacts
//
//  Created by Brian Donohue on 6/21/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

#define kImageSize 25
#define kImagePadding 20

- (void)awakeFromNib {
    self.contactAccessoryView = [[ContactAccessoryView alloc] init];
    self.accessoryView = self.contactAccessoryView;
    self.editingAccessoryView = self.contactAccessoryView;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

@end
