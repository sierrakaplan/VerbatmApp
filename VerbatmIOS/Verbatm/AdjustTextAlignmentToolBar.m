//
//  AdjustTextAlignmentToolBar.m
//  Verbatm
//
//  Created by Iain Usiri on 7/25/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "AdjustTextAlignmentToolBar.h"
#import "UtilityFunctions.h"
#import "Icons.h"
#import "Styles.h"
#import "SizesAndPositions.h"
@interface AdjustTextAlignmentToolBar ()
    @property (strong, nonatomic) UIButton *leftAlignButton;
    @property (strong, nonatomic) UIButton *centerAlignButton;
    @property (strong, nonatomic) UIButton *rightAlignButton;
@end

#define SPACE 30.f
#define CENTERING_Y ((self.frame.size.height - ICON_SIZE)/2.f)

#define ICON_SIZE (self.frame.size.height - 10.f)


@implementation AdjustTextAlignmentToolBar

-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.leftAlignButton];
        [self addSubview:self.centerAlignButton];
        [self addSubview:self.rightAlignButton];
    }
    return self;
}

-(void)leftAlignButtonPressed{
    [self.delegate alignTextLeft];
}

-(void)centerAlignButtonPressed{
    [self.delegate alignTextCenter];
}

-(void)rightAlignButtonPressed {
    [self.delegate alignTextRight];
}


- (UIButton *) leftAlignButton {
    if (!_leftAlignButton) {
        CGRect buttonFrame = CGRectMake(self.centerAlignButton.frame.origin.x - SPACE - ICON_SIZE , CENTERING_Y,
                                        ICON_SIZE, ICON_SIZE);
        _leftAlignButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:LEFT_ALIGN_ICON andSelector:@selector(leftAlignButtonPressed) andTarget:self];
    }
    return _leftAlignButton;
}

- (UIButton *) centerAlignButton {
    if (!_centerAlignButton) {
        CGRect buttonFrame = CGRectMake((self.frame.size.width - ICON_SIZE )/2.f, CENTERING_Y,
                                        ICON_SIZE, ICON_SIZE);
        _centerAlignButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:CENTER_ALIGN_ICON andSelector:@selector(centerAlignButtonPressed) andTarget:self];
  
        
    }
    return _centerAlignButton;
}

- (UIButton *) rightAlignButton {
    if (!_rightAlignButton) {
        CGRect buttonFrame = CGRectMake(self.centerAlignButton.frame.origin.x + self.centerAlignButton.frame.size.width + SPACE, CENTERING_Y,
                                        ICON_SIZE, ICON_SIZE);
        _rightAlignButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:RIGHT_ALIGN_ICON andSelector:@selector(rightAlignButtonPressed) andTarget:self];
    }
    return _rightAlignButton;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
