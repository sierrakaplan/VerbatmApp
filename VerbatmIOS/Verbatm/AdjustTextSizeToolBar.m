//
//  AdjustTextSizeToolBar.m
//  Verbatm
//
//  Created by Iain Usiri on 7/25/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "AdjustTextSizeToolBar.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UtilityFunctions.h"

@interface AdjustTextSizeToolBar ()
@property (strong, nonatomic) UIButton *textSizeIncreaseButton;
@property (strong, nonatomic) UIButton *textSizeDecreaseButton;
@end

#define SPACE 30.f
#define CENTERING_Y ((self.frame.size.height - TEXT_TOOLBAR_BUTTON_WIDTH)/2.f)

#define ICON_SIZE (self.frame.size.height - 10.f)

@implementation AdjustTextSizeToolBar



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:TOP_TOOLBAR_BACKGROUND_COLOR];
        [self addSubview:self.textSizeIncreaseButton];
        [self addSubview:self.textSizeDecreaseButton];
        
        
    }
    return self;
}



-(void)textSizeIncreaseButtonPressed{
    [self.delegate increaseTextSizeDelegate];
}

-(void)textSizeDecreaseButtonPressed{
    [self.delegate decreaseTextSizeDelegate];
}


- (UIButton *) textSizeIncreaseButton {
    if (!_textSizeIncreaseButton) {
        CGRect buttonFrame = CGRectMake(self.frame.size.width/2.f  - ICON_SIZE, CENTERING_Y,
                                        ICON_SIZE, ICON_SIZE);
        _textSizeIncreaseButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:INCREASE_FONT_SIZE_ICON andSelector:@selector(textSizeIncreaseButtonPressed) andTarget:self];
    }
    return _textSizeIncreaseButton;
}

- (UIButton *) textSizeDecreaseButton {
    if (!_textSizeDecreaseButton) {
        CGRect buttonFrame = CGRectMake(self.frame.size.width/2.f + ICON_SIZE, CENTERING_Y,
                                        ICON_SIZE, ICON_SIZE);
        _textSizeDecreaseButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:DECREASE_FONT_SIZE_ICON andSelector:@selector(textSizeDecreaseButtonPressed) andTarget:self];
        
    }
    return _textSizeDecreaseButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
