//
//  SpinnerView.m
//  Contacts
//
//  Created by Brian Donohue on 6/22/15.
//  Copyright (c) 2015 Brian Donohue. All rights reserved.
//

#import "SpinnerView.h"

@implementation SpinnerView

-(id)initWithSize:(CGSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake((size.width - spinner.frame.size.width) / 2,
                                   size.height / 2 - spinner.frame.size.height,
                                   spinner.frame.size.width,
                                   spinner.frame.size.height);
        spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [spinner startAnimating];
        [self addSubview:spinner];
    }
    return self;
}

@end
