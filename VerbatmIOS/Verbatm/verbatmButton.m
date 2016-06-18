//
//  verbatmButton.m
//  Verbatm
//
//  Created by Iain Usiri on 6/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "verbatmButton.h"

@interface verbatmButton ()

@property (nonatomic) UIImage * selectedImage;
@property (nonatomic) UIImage * unselectedImage;

@end


@implementation verbatmButton


-(void)setButtonInSelectedState:(ButtonSelectionState)buttonInSelectedState {
    if(_buttonInSelectedState != buttonInSelectedState) {
        if(buttonInSelectedState == ButtonSelected){
            [self setBackgroundImage:self.selectedImage forState:UIControlStateNormal];
        }else{
            [self setBackgroundImage:self.unselectedImage forState:UIControlStateNormal];
        }
        _buttonInSelectedState = buttonInSelectedState;
    }
}


-(void)switchState{
    if(self.buttonInSelectedState == ButtonSelected){
        [self setButtonInSelectedState:ButtonNotSelected];
    }else{
        [self setButtonInSelectedState:ButtonSelected];
    }
}

-(void) storeBackgroundImage:(UIImage *) image forState:(ButtonSelectionState) state{
    if(state == ButtonSelected){
        self.selectedImage = image;
    }else{
        self.unselectedImage = image;
    }
    
    if(state == ButtonNotSelected || !self.unselectedImage){
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    
}








/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
