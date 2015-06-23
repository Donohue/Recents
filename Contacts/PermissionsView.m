//
//  PermissionsView.m
//  Contacts
//
//  Created by Brian Donohue on 6/22/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "PermissionsView.h"

@implementation PermissionsView

#define kContainerPadding 50
#define kButtonTopPadding 25

-(id)initWithSize:(CGSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        NSString *infoText = NSLocalizedString(@"Recents needs access to your contacts!", nil);
        UIFont *infoFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        CGSize infoSize = [infoText boundingRectWithSize:CGSizeMake(size.width - kContainerPadding * 2, size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: infoFont}
                                                 context:NULL].size;
        
        UIFont *permissionButtonFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0f];
        NSString *permissionButtonText = NSLocalizedString(@"Grant Access", nil);
        CGSize permissionStringSize = [permissionButtonText boundingRectWithSize:CGSizeMake(size.width - kContainerPadding * 2, size.height)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName: permissionButtonFont}
                                                               context:NULL].size;
        CGSize buttonSize = CGSizeMake(permissionStringSize.width + 20, permissionStringSize.height + 10);
        
        CGFloat containerWidth = self.frame.size.width - kContainerPadding * 2;
        CGFloat containerHeight = infoSize.height + kButtonTopPadding + buttonSize.height;
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(kContainerPadding,
                                                                     size.height / 2 - containerHeight,
                                                                     containerWidth,
                                                                     containerHeight)];
        container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;        
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, infoSize.width, infoSize.height)];
        infoLabel.numberOfLines = 0;
        infoLabel.text = infoText;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.font = infoFont;
        [container addSubview:infoLabel];
        
        self.permissionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.permissionsButton.titleLabel.font = permissionButtonFont;
        [self.permissionsButton setTitle:permissionButtonText forState:UIControlStateNormal];
        self.permissionsButton.frame = CGRectMake((containerWidth - buttonSize.width) / 2,
                                                  infoSize.height + kButtonTopPadding,
                                                  buttonSize.width, buttonSize.height);
        self.permissionsButton.layer.borderColor = self.permissionsButton.titleLabel.textColor.CGColor;
        self.permissionsButton.layer.borderWidth = 0.5f;
        self.permissionsButton.layer.cornerRadius = 5.0f;
        [self.permissionsButton addTarget:self
                                   action:@selector(permissionsButtonClicked:)
                         forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:self.permissionsButton];
        
        [self addSubview:container];
    }
    return self;
}

-(void)permissionsButtonClicked:(id)sender {
    if (self.permissionsBlock) {
        self.permissionsBlock();
    }
}

@end
