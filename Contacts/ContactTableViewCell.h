//
//  ContactTableViewCell.h
//  Contacts
//
//  Created by Brian Donohue on 6/21/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactAccessoryView.h"

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic, strong) ContactAccessoryView *contactAccessoryView;

@end
