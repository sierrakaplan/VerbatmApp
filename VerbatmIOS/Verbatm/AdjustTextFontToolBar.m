//
//  AdjustTextFontToolBar.m
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "AdjustTextFontToolBar.h"
#import "UtilityFunctions.h"
#import "Icons.h"
#import "Styles.h"
#import "SizesAndPositions.h"

@interface AdjustTextFontToolBar ()

@property (strong, nonatomic) UIButton *firstFontButton;
@property (strong, nonatomic) UIButton *secondFontButton;
@property (strong, nonatomic) UIButton *lastFontButton;

@end

#define SPACE 10.f
#define CENTERING_Y ((self.frame.size.height - ICON_HEIGHT)/2.f)

#define ICON_HEIGHT (self.frame.size.height - 10.f)
#define ICON_WIDTH (ICON_HEIGHT * 2.f)
#define TEXT_COLOR whiteColor

@implementation AdjustTextFontToolBar


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:TOP_TOOLBAR_BACKGROUND_COLOR];
        [self addSubview:self.firstFontButton];
        [self addSubview:self.secondFontButton];
        [self addSubview:self.lastFontButton];
    }
    return self;
}


-(void)firstFontButtonSelected{
    [self.delegate changeTextFontToFont:TEXT_FONT_TYPE_1];
}

-(void)secondFontButtonSelected{
    [self.delegate changeTextFontToFont:TEXT_FONT_TYPE_2];
}


-(void)lastFontButtonSelected{
    [self.delegate changeTextFontToFont:TEXT_FONT_TYPE_3];
}

- (UIButton *) firstFontButton {
    if (!_firstFontButton) {
        CGRect buttonFrame = CGRectMake(self.secondFontButton.frame.origin.x - SPACE - ICON_WIDTH , CENTERING_Y,
                                        ICON_WIDTH, ICON_HEIGHT);
        _firstFontButton = [AdjustTextFontToolBar getButtonWithFrame:buttonFrame title:@"Font 1" andSelector:@selector(firstFontButtonSelected) andTarget:self];
    }
    return _firstFontButton;
}

- (UIButton *) secondFontButton {
    if (!_secondFontButton) {
        CGRect buttonFrame = CGRectMake((self.frame.size.width - ICON_WIDTH )/2.f, CENTERING_Y,
                                        ICON_WIDTH, ICON_HEIGHT);
        _secondFontButton = [AdjustTextFontToolBar getButtonWithFrame:buttonFrame title:@"Font 2" andSelector:@selector(secondFontButtonSelected) andTarget:self];
    
    }
    return _secondFontButton;
}

- (UIButton *) lastFontButton {
    if (!_lastFontButton) {
        CGRect buttonFrame = CGRectMake(self.secondFontButton.frame.origin.x + self.secondFontButton.frame.size.width + SPACE, CENTERING_Y,
                                        ICON_WIDTH, ICON_HEIGHT);
        _lastFontButton = [AdjustTextFontToolBar getButtonWithFrame:buttonFrame title:@"Font 3" andSelector:@selector(lastFontButtonSelected) andTarget:self];
    }
    return _lastFontButton;
}


+(UIButton *) getButtonWithFrame:(CGRect)frame title:(NSString*)title andSelector:(SEL)action andTarget:(id) target {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor TEXT_COLOR] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
