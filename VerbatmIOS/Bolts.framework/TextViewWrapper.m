//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "TextViewWrapper.h"

@implementation TextViewWrapper

-(void)showText{
    if(self.textView){
        [self addSubview:self.textView];
        [self bringSubviewToFront:self.textView];
    }
    
}
-(void)hideText{
    if(self.textView){
        [self.textView removeFromSuperview];
    }
}

@end
