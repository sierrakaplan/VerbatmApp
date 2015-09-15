//
//  RefreshTableViewCell.m
//  Verbatm
//
//  Created by Iain Usiri on 9/14/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "RefreshTableViewCell.h"
@interface RefreshTableViewCell ()
//for when this is a placeholder cell and the content is being pushed to the cloud
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation RefreshTableViewCell


-(void)layoutSubviews{
    [self setBackgroundColor:[UIColor clearColor]];
    [self startActivityIndicator];
}
-(void)startActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.alpha = 1.0;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.center = self.center;
    [self addSubview:self.activityIndicator];
    [self bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
    if(!self.activityIndicator.isAnimating) return;
    [self.activityIndicator stopAnimating];
}
@end
