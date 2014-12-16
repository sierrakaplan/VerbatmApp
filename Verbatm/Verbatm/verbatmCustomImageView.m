//
//  verbatmCustomImageView.m
//  Verbatm
//
//  Created by Iain Usiri on 11/25/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomImageView.h"

@implementation verbatmCustomImageView

-(void)layoutSubviews
{
    if(self.isVideo){
        ((AVPlayerLayer*)[self.layer.sublayers firstObject]).frame = self.bounds;
    }
}
@end
