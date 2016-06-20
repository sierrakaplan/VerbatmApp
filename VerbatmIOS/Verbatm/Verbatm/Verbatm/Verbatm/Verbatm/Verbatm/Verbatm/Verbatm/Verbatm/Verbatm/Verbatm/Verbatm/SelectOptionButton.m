
//
//  SelectOptionButton.m
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "SelectOptionButton.h"

@interface SelectOptionButton ()


#define UNSELECTED_BACKGROUND_COLOR clearColor
#define SELECTED_BACKGROUND_COLOR whiteColor
@end

@implementation SelectOptionButton

-(instancetype) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        [self formatButton];
    }
    return  self;
}


-(void)formatButton{
    self.backgroundColor = [UIColor UNSELECTED_BACKGROUND_COLOR];
    self.layer.cornerRadius = self.frame.size.height/2.f;
    self.layer.borderWidth = 2.f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.clipsToBounds = YES;
}

-(void)setButtonSelected:(BOOL)buttonSelected{
    if(buttonSelected){
        self.backgroundColor = [UIColor SELECTED_BACKGROUND_COLOR];
    }else{
        self.backgroundColor = [UIColor UNSELECTED_BACKGROUND_COLOR];
    }
    _buttonSelected = buttonSelected;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end



