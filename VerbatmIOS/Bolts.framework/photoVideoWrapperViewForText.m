//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "photoVideoWrapperViewForText.h"

@implementation photoVideoWrapperViewForText

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


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
