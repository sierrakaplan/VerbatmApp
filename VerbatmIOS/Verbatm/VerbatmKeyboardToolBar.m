//
//  VerbatmKeyboardToolBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "AdjustTextSizeToolBar.h"
#import "Icons.h"
#import "VerbatmKeyboardToolBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"



typedef enum {
    noSelection = 0,
    fontColor = 1,
    fontSize = 2,
    textAlightment = 3,
    fontType = 4,
    background = 5
}ToolBarOptions;


@interface VerbatmKeyboardToolBar()<AdjustTextSizeDelegate>

@property (nonatomic) BOOL optionSelected;


@property (strong, nonatomic) UIButton *textColorButton;
@property (strong, nonatomic) UIButton *changeFontSizeButton;
@property (strong, nonatomic) UIButton *changeTextAlignmentButton;
@property (strong, nonatomic) UIButton *changeFontTypeButton;
@property (strong, nonatomic) UIButton *changeTextAveBackgroundButton;


@property (nonatomic) UIView * lowerBarHolder;//holds all the constant icons

@property (nonatomic) AdjustTextSizeToolBar * adjustTextSizeBar;


@property (strong, nonatomic) UIButton *leftAlignButton;
@property (strong, nonatomic) UIButton *centerAlignButton;
@property (strong, nonatomic) UIButton *rightAlignButton;
@property (strong, nonatomic) UIButton *doneButton;


@property (nonatomic) ToolBarOptions currentSelectedOption;


#define COLOR_BUTTON_X_OFFSET 20.f

#define ICON_GROUP_STANDARD_SPACING 20.f

#define SIZE_BUTTONS_OFFSET 80.f
#define ALIGNMENT_BUTTONS_OFFSET 200.f
#define SPACE 10.f

#define ICON_SEPERATION_SPACE (((self.frame.size.width - (2*TEXT_TOOLBAR_BUTTON_OFFSET)) - (NUM_BASE_BUTTONS * TEXT_TOOLBAR_BUTTON_WIDTH) - TEXT_TOOLBAR_DONE_WIDTH)/(NUM_BASE_BUTTONS - 1.f))


#define NUM_BASE_BUTTONS 5.f //number of buttons on the toolbar

#define CENTERING_Y (((self.frame.size.height/2.f) - TEXT_TOOLBAR_BUTTON_WIDTH)/2.f)




@end

@implementation VerbatmKeyboardToolBar

-(instancetype)initWithFrame:(CGRect)frame andTextColorBlack:(BOOL)textColorBlack{
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor redColor];
		self.optionSelected = textColorBlack;
		[self addButtons];
	}
	return self;
}

-(void) addButtons {
	[self.lowerBarHolder addSubview:self.textColorButton];
    [self.lowerBarHolder addSubview:self.changeFontSizeButton];
    [self.lowerBarHolder addSubview:self.changeTextAlignmentButton];
    [self.lowerBarHolder addSubview:self.changeFontTypeButton];
    [self.lowerBarHolder addSubview:self.changeTextAveBackgroundButton];
    [self.lowerBarHolder addSubview:self.doneButton];

    
    
//	[self addSubview:self.textSizeIncreaseButton];
//	[self addSubview:self.textSizeDecreaseButton];
//	[self addSubview:self.leftAlignButton];
//	[self addSubview:self.centerAlignButton];
//	[self addSubview:self.rightAlignButton];
    
}

#pragma mark - Button Actions -


-(void)changeFontTypeButtonPressed{
     self.optionSelected = !self.optionSelected;
    
}
-(void)changeTextAveBackgroundButtonPressed{
     self.optionSelected = !self.optionSelected;
    
}
-(void)changeTextAlignmentButtonPressed{
     self.optionSelected = !self.optionSelected;
}
-(void) textColorButtonPressed {
	self.optionSelected = !self.optionSelected;
	UIImage *iconImage;
	if (self.optionSelected) {
		iconImage = [UIImage imageNamed: SELECT_FONT_ICON_SELECTED ];
	} else {
		iconImage = [UIImage imageNamed: SELECT_FONT_ICON_UNSELECTED];
	}
	[self.textColorButton setImage:iconImage forState:UIControlStateNormal];
	[self.delegate textColorChangedToBlack:self.optionSelected];
}

-(void)removeTopHalfBar{
    switch (self.currentSelectedOption) {
        case fontSize:
            if(self.adjustTextSizeBar)[self.adjustTextSizeBar removeFromSuperview];
            break;
            
        default:
            break;
    }
}

-(void)addTopHalfBar{
    switch (self.currentSelectedOption) {
        case fontSize:
            [self addSubview:self.adjustTextSizeBar];
            break;
            
        default:
            break;
    }
}

-(void) changeFontSizeButtonPressed {
    [self removeTopHalfBar];
    self.optionSelected = !self.optionSelected;
    UIImage *iconImage;
    if (self.optionSelected) {
        self.currentSelectedOption = fontSize;
        iconImage = [UIImage imageNamed: CHANGE_FONT_SIZE_ICON_SELECTED];
    } else {
        self.currentSelectedOption = noSelection;
         iconImage = [UIImage imageNamed: CHANGE_FONT_SIZE_ICON_UNSELECTED];
        
    }
    [self.changeFontSizeButton setImage:iconImage forState:UIControlStateNormal];
    [self addTopHalfBar];
}



#pragma mark -Adjust Text Size Toolbar Delegate-
-(void)increaseTextSizeDelegate{
    [self.delegate textSizeIncreased];
}
-(void)decreaseTextSizeDelegate{
    [self.delegate textSizeDecreased];
}


-(void) leftAlignButtonPressed {
	[self.delegate leftAlignButtonPressed];
}

-(void) centerAlignButtonPressed {
	[self.delegate centerAlignButtonPressed];
}

-(void) rightAlignButtonPressed {
	[self.delegate rightAlignButtonPressed];
}

-(void) doneButtonPressed {
	[self.delegate doneButtonPressed];
}

#pragma mark - Lazy Instantiation -
- (UIButton *) changeFontSizeButton {
    if (!_changeFontSizeButton) {
        CGRect buttonFrame = CGRectMake(self.textColorButton.frame.origin.x + self.textColorButton.frame.size.width + ICON_SEPERATION_SPACE, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeFontSizeButton = [self getButtonWithFrame:buttonFrame andIcon:CHANGE_FONT_SIZE_ICON_UNSELECTED
                                             andSelector:@selector(changeFontSizeButtonPressed)];
    }
    return _changeFontSizeButton;
}







-(UIButton *) doneButton {
	if (!_doneButton) {
		CGRect doneButtonFrame = CGRectMake(self.frame.size.width  - TEXT_TOOLBAR_DONE_WIDTH - TEXT_TOOLBAR_BUTTON_OFFSET, 0.f,
											TEXT_TOOLBAR_DONE_WIDTH, (self.frame.size.height/2.f) - TEXT_TOOLBAR_BUTTON_OFFSET);
		_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_doneButton.frame = doneButtonFrame;
		UIFont* labelFont = [UIFont fontWithName:REGULAR_FONT size:KEYBOARD_TOOLBAR_FONT_SIZE];
		NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"DONE" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName : labelFont}];
		[_doneButton setAttributedTitle:title forState:UIControlStateNormal];
		[_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _doneButton;
}

- (UIButton *) textColorButton {
	if (!_textColorButton) {
		CGRect buttonFrame = CGRectMake(TEXT_TOOLBAR_BUTTON_OFFSET, CENTERING_Y,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_textColorButton = [self getButtonWithFrame:buttonFrame andIcon:SELECT_FONT_ICON_UNSELECTED
										andSelector:@selector(textColorButtonPressed)];
	}
	return _textColorButton;
}


- (UIButton *) changeTextAlignmentButton {
    if (!_changeTextAlignmentButton) {
        CGRect buttonFrame = CGRectMake(self.changeFontSizeButton.frame.origin.x + self.changeFontSizeButton.frame.size.width + ICON_SEPERATION_SPACE, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeTextAlignmentButton = [self getButtonWithFrame:buttonFrame andIcon:CHANGE_TEXT_ALIGNMENT_ICON
                                             andSelector:@selector(changeTextAlignmentButtonPressed)];
    }
    return _changeTextAlignmentButton;
}


- (UIButton *) changeFontTypeButton {
    if (!_changeFontTypeButton) {
        CGRect buttonFrame = CGRectMake(self.changeTextAlignmentButton.frame.origin.x + self.changeTextAlignmentButton.frame.size.width + ICON_SEPERATION_SPACE, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeFontTypeButton = [self getButtonWithFrame:buttonFrame andIcon:CHANGE_FONT_TYPE_ICON_UNSELECTED
                                                  andSelector:@selector(changeFontTypeButtonPressed)];
    }
    return _changeFontTypeButton;
}


- (UIButton *) changeTextAveBackgroundButton {
    if (!_changeTextAveBackgroundButton) {
        CGRect buttonFrame = CGRectMake(self.changeFontTypeButton.frame.origin.x + self.changeFontTypeButton.frame.size.width + ICON_SEPERATION_SPACE, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeTextAveBackgroundButton = [self getButtonWithFrame:buttonFrame andIcon:CHANGE_TEXT_VIEW_BACKGROUND
                                             andSelector:@selector(changeTextAveBackgroundButtonPressed)];
    }
    return _changeTextAveBackgroundButton;
}







-(UIView *)lowerBarHolder{
    if (!_lowerBarHolder) {
        _lowerBarHolder = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height/2.f, self.frame.size.width, self.frame.size.height/2.f)];
        [_lowerBarHolder setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_lowerBarHolder];
    }
    return _lowerBarHolder;
}


-(AdjustTextSizeToolBar *)adjustTextSizeBar{
    if (!_adjustTextSizeBar) {
        _adjustTextSizeBar = [[AdjustTextSizeToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height/2.f)];
        _adjustTextSizeBar.delegate = self;
    }
    return _adjustTextSizeBar;
}


//- (UIButton *) leftAlignButton {
//	if (!_leftAlignButton) {
//		CGRect buttonFrame = CGRectMake(self.textSizeDecreaseButton.frame.origin.x + self.textSizeDecreaseButton.frame.size.width + ICON_GROUP_STANDARD_SPACING , BUTTON_Y_OFFSET,
//										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
//		_leftAlignButton = [self getButtonWithFrame:buttonFrame andIcon:LEFT_ALIGN_ICON
//										andSelector:@selector(leftAlignButtonPressed)];
//	}
//	return _leftAlignButton;
//}
//
//- (UIButton *) centerAlignButton {
//	if (!_centerAlignButton) {
//		CGRect buttonFrame = CGRectMake(self.leftAlignButton.frame.origin.x + self.leftAlignButton.frame.size.width + SPACE , BUTTON_Y_OFFSET,
//										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
//		_centerAlignButton = [self getButtonWithFrame:buttonFrame andIcon:CENTER_ALIGN_ICON
//											 andSelector:@selector(centerAlignButtonPressed)];
//
//	}
//	return _centerAlignButton;
//}
//
//- (UIButton *) rightAlignButton {
//	if (!_rightAlignButton) {
//		CGRect buttonFrame = CGRectMake(self.centerAlignButton.frame.origin.x + self.centerAlignButton.frame.size.width + SPACE, BUTTON_Y_OFFSET,
//										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
//		_rightAlignButton = [self getButtonWithFrame:buttonFrame andIcon:RIGHT_ALIGN_ICON
//										 andSelector:@selector(rightAlignButtonPressed)];
//
//	}
//	return _rightAlignButton;
//}

-(UIButton *) getButtonWithFrame:(CGRect)frame andIcon:(NSString*)iconName andSelector:(SEL)action {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	[button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}


@end
