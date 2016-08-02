//
//  VerbatmKeyboardToolBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "AdjustTextSizeToolBar.h"
#import "AdjustTextAlignmentToolBar.h"
#import "AdjustTextFontToolBar.h"
#import "AdjustTextAVEBackgroundToolBar.h"
#import "Icons.h"
#import "VerbatmKeyboardToolBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "UtilityFunctions.h"

typedef enum {
    noSelection = 0,
    fontColor = 1,
    fontSize = 2,
    textAlightment = 3,
    fontType = 4,
    background = 5
} ToolBarOptions;

@interface VerbatmKeyboardToolBar()<AdjustTextSizeDelegate, AdjustTextAlignmentToolBarDelegate, AdjustTextFontToolBarDelegate, AdjustTextAVEBackgroundToolBarDelegate>

@property (nonatomic) BOOL textIsBlack;
@property (nonatomic) BOOL toolbardOnTextAve;

@property (strong, nonatomic) UIButton *textColorButton;
@property (strong, nonatomic) UIButton *changeFontSizeButton;
@property (strong, nonatomic) UIButton *changeTextAlignmentButton;
@property (strong, nonatomic) UIButton *changeFontTypeButton;
@property (strong, nonatomic) UIButton *changeTextAveBackgroundButton;

@property (nonatomic) UIView * lowerBarHolder;//holds all the constant icons

@property (nonatomic) AdjustTextSizeToolBar * adjustTextSizeBar;
@property (nonatomic) AdjustTextAlignmentToolBar * adjustTextAlignmentBar;
@property (nonatomic) AdjustTextFontToolBar * adjustTextFontBar;
@property (nonatomic) AdjustTextAVEBackgroundToolBar * adjustBackgroundBar;

@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *keyboardButton;


@property (nonatomic) ToolBarOptions currentSelectedOption;


#define COLOR_BUTTON_X_OFFSET 20.f
#define ICON_GROUP_STANDARD_SPACING 20.f
#define SIZE_BUTTONS_OFFSET 80.f
#define ALIGNMENT_BUTTONS_OFFSET 200.f
#define SPACE 10.f

#define ICON_SEPARATION_SPACE (((self.frame.size.width - (2*TEXT_TOOLBAR_BUTTON_OFFSET)) - (NUM_BASE_BUTTONS * TEXT_TOOLBAR_BUTTON_WIDTH) - TEXT_TOOLBAR_DONE_WIDTH)/(NUM_BASE_BUTTONS - 1.f))

#define NUM_BASE_BUTTONS 5

#define CENTERING_Y ((TEXT_TOOLBAR_HEIGHT/2.f/2.f) - (TEXT_TOOLBAR_BUTTON_WIDTH/2.f))


@end

@implementation VerbatmKeyboardToolBar

-(instancetype)initWithFrame:(CGRect)frame andTextColorBlack:(BOOL)textColorBlack
				 isOnTextAve:(BOOL)onTextAve isOnScreenPermanently:(BOOL)onScreen {
	self = [super initWithFrame:frame];
	if(self) {
        self.backgroundColor = (onScreen) ? [UIColor clearColor] : [UIColor colorWithWhite:0.f alpha:0.1];
		self.textIsBlack = textColorBlack;
        self.toolbardOnTextAve = onTextAve;
        self.currentSelectedOption = noSelection;

        if(onScreen) {
			[self addAllButtons];
		} else {
			[self addSubview:self.textColorButton];
			[self addSubview:self.doneButton];
        }
	}
	return self;
}

-(void) addAllButtons {
	[self.lowerBarHolder addSubview:self.textColorButton];
    [self.lowerBarHolder addSubview:self.changeFontSizeButton];
    [self.lowerBarHolder addSubview:self.changeTextAlignmentButton];
    [self.lowerBarHolder addSubview:self.changeFontTypeButton];
    [self.lowerBarHolder addSubview:self.changeTextAveBackgroundButton];
    [self.lowerBarHolder addSubview:self.keyboardButton];
}


#pragma mark - Change Background Delegate -

-(void)changeImageToImage:(NSString*) imageName {
    [self.delegate changeTextBackgroundToImage:imageName];
}

#pragma mark - Button Actions -

-(void)changeFontTypeButtonPressed{
    [self removeTopHalfBar];
    UIImage *iconImage;
    if(self.currentSelectedOption == fontType){
        self.currentSelectedOption = noSelection;
        iconImage = [UIImage imageNamed: CHANGE_FONT_TYPE_ICON_UNSELECTED ];
    }else{
        self.currentSelectedOption = fontType;
        iconImage = [UIImage imageNamed: CHANGE_FONT_TYPE_ICON_SELECTED ];
    }
    [self.changeFontTypeButton setImage:iconImage forState:UIControlStateNormal];
    [self addTopHalfBar];
}


-(void)changeTextAveBackgroundButtonPressed{
    [self removeTopHalfBar];
    UIImage *iconImage;
    if(self.currentSelectedOption == background){
        self.currentSelectedOption = noSelection;
        iconImage = [UIImage imageNamed:CHANGE_TEXT_VIEW_BACKGROUND_UNSELECTED ];
    }else{
        self.currentSelectedOption = background;
        iconImage = [UIImage imageNamed: CHANGE_TEXT_VIEW_BACKGROUND_SELECTED];
    }
    [self.changeTextAveBackgroundButton setImage:iconImage forState:UIControlStateNormal];
    [self addTopHalfBar];

}

-(void)changeTextAlignmentButtonPressed{
    [self removeTopHalfBar];
    if(self.currentSelectedOption == textAlightment){
        self.currentSelectedOption = noSelection;
    }else{
        self.currentSelectedOption = textAlightment;
    }
    [self addTopHalfBar];
}


#pragma mark - Align Toolbar Delegate -

-(void)alignTextLeft{
    [self.delegate leftAlignButtonPressed];
}

-(void)alignTextRight{
    [self.delegate rightAlignButtonPressed];
}

-(void)alignTextCenter{
    [self.delegate centerAlignButtonPressed];
}

-(void) textColorButtonPressed {
	UIImage *iconImage;
    self.textIsBlack = !self.textIsBlack;
	if (self.textIsBlack) {
		iconImage = [UIImage imageNamed: TEXT_FONT_COLOR_BLACK ];
	} else {
		iconImage = [UIImage imageNamed: TEXT_FONT_COLOR_WHITE];
	}
	[self.textColorButton setImage:iconImage forState:UIControlStateNormal];
	[self.delegate textColorChangedToBlack:self.textIsBlack];
}

-(void)removeTopHalfBar {
    switch (self.currentSelectedOption) {
        case fontSize:
            [self.adjustTextSizeBar removeFromSuperview];
            [self.changeFontSizeButton setImage:[UIImage imageNamed: CHANGE_FONT_SIZE_ICON_UNSELECTED] forState:UIControlStateNormal];
            break;
        case textAlightment:
            [self.adjustTextAlignmentBar removeFromSuperview];
            break;
        case fontType:
            [self.adjustTextFontBar removeFromSuperview];
            [self.changeFontSizeButton setImage:[UIImage imageNamed: CHANGE_FONT_SIZE_ICON_UNSELECTED] forState:UIControlStateNormal];
            break;
        case background:
            [self.adjustBackgroundBar removeFromSuperview];
            [self.changeTextAveBackgroundButton setImage:[UIImage imageNamed: CHANGE_TEXT_VIEW_BACKGROUND_UNSELECTED] forState:UIControlStateNormal];
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
        case textAlightment:
            [self addSubview:self.adjustTextAlignmentBar];
            break;
        case fontType:
            [self addSubview:self.adjustTextFontBar];
            break;
        case background:
            [self addSubview: self.adjustBackgroundBar];
            break;
        default:
            break;
    }
}

-(void) changeFontSizeButtonPressed {
    [self removeTopHalfBar];
    UIImage * iconImage;
     if(self.currentSelectedOption != fontSize){
        self.currentSelectedOption = fontSize;
        iconImage = [UIImage imageNamed: CHANGE_FONT_SIZE_ICON_SELECTED];
    } else {
        self.currentSelectedOption = noSelection;
         iconImage = [UIImage imageNamed: CHANGE_FONT_SIZE_ICON_UNSELECTED];
    }
    
    [self.changeFontSizeButton setImage:iconImage forState:UIControlStateNormal];
    [self addTopHalfBar];
}

#pragma mark - Change Font Type Delegate -

-(void)changeTextFontToFont:(NSString *) fontName{
    [self.delegate changeTextToFont:fontName];
}

#pragma mark - Adjust Text Size Toolbar Delegate -

-(void)increaseTextSizeDelegate {
    [self.delegate textSizeIncreased];
}

-(void)decreaseTextSizeDelegate{
    [self.delegate textSizeDecreased];
}

#pragma mark - Alignment Delegate -

-(void) leftAlignButtonPressed {
	[self.delegate leftAlignButtonPressed];
}

-(void) centerAlignButtonPressed {
	[self.delegate centerAlignButtonPressed];
}

-(void) rightAlignButtonPressed {
	[self.delegate rightAlignButtonPressed];
}

#pragma mark - Done/Keyboard buttons -

-(void) doneButtonPressed {
	[self.delegate doneButtonPressed];
}

-(void)keyboardButtonPressed{
    if([self.delegate respondsToSelector:@selector(keyboardButtonPressed)]){
        [self.delegate keyboardButtonPressed];
    }
}

#pragma mark - Lazy Instantiation -

- (UIButton *) changeFontSizeButton {
    if (!_changeFontSizeButton) {
        CGRect buttonFrame = CGRectMake(self.textColorButton.frame.origin.x +
										self.textColorButton.frame.size.width + ICON_SEPARATION_SPACE,
										CENTERING_Y, TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeFontSizeButton = [UtilityFunctions getButtonWithFrame:buttonFrame
															 andIcon:CHANGE_FONT_SIZE_ICON_UNSELECTED
                                             andSelector:@selector(changeFontSizeButtonPressed) andTarget:self];
    }
    return _changeFontSizeButton;
}

-(UIButton *) doneButton {
	if (!_doneButton) {
        CGFloat height = (self.frame.size.height/2.f) - TEXT_TOOLBAR_BUTTON_OFFSET;
		CGRect doneButtonFrame = CGRectMake(self.frame.size.width  - TEXT_TOOLBAR_DONE_WIDTH - TEXT_TOOLBAR_BUTTON_OFFSET + 5.f, CENTERING_Y, TEXT_TOOLBAR_DONE_WIDTH,height);
		_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_doneButton.frame = doneButtonFrame;
		UIFont* labelFont = [UIFont fontWithName:REGULAR_FONT size:KEYBOARD_TOOLBAR_FONT_SIZE];
		NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"DONE" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName : labelFont}];
		[_doneButton setAttributedTitle:title forState:UIControlStateNormal];
		[_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _doneButton;
}


-(UIButton *) keyboardButton {
    if (!_keyboardButton) {
        CGFloat height = (self.frame.size.height/3.f) - TEXT_TOOLBAR_BUTTON_OFFSET;
        CGFloat centeringY = ((self.frame.size.height/2.f) - height)/2.f;
        
        CGRect keyboardButtonFrame = CGRectMake(self.frame.size.width  - TEXT_TOOLBAR_DONE_WIDTH + 5.f, centeringY,
                                            TEXT_TOOLBAR_DONE_WIDTH/2.f,height);
        _keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _keyboardButton.frame = keyboardButtonFrame;
        [_keyboardButton setImage:[UIImage imageNamed:PRESENT_KEYBOARD_ICON] forState:UIControlStateNormal];
        [_keyboardButton addTarget:self action:@selector(keyboardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _keyboardButton;
}

- (UIButton *) textColorButton {
	if (!_textColorButton) {
		CGRect buttonFrame = CGRectMake(TEXT_TOOLBAR_BUTTON_OFFSET, CENTERING_Y,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _textColorButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:((self.textIsBlack) ? TEXT_FONT_COLOR_BLACK :TEXT_FONT_COLOR_WHITE)
										andSelector:@selector(textColorButtonPressed) andTarget:self];
	}
	return _textColorButton;
}


- (UIButton *) changeTextAlignmentButton {
    if (!_changeTextAlignmentButton) {
        CGRect buttonFrame = CGRectMake(self.changeFontSizeButton.frame.origin.x +
										self.changeFontSizeButton.frame.size.width + ICON_SEPARATION_SPACE, CENTERING_Y, TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeTextAlignmentButton = [UtilityFunctions getButtonWithFrame:buttonFrame
																  andIcon:CHANGE_TEXT_ALIGNMENT_ICON
                                             andSelector:@selector(changeTextAlignmentButtonPressed) andTarget:self];
    }
    return _changeTextAlignmentButton;
}


- (UIButton *) changeFontTypeButton {
    if (!_changeFontTypeButton) {
        CGRect buttonFrame = CGRectMake(self.changeTextAlignmentButton.frame.origin.x + self.changeTextAlignmentButton.frame.size.width + ICON_SEPARATION_SPACE - 10.f, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        
        _changeFontTypeButton = [UtilityFunctions getButtonWithFrame:buttonFrame
															 andIcon:CHANGE_FONT_TYPE_ICON_UNSELECTED
                                                  andSelector:@selector(changeFontTypeButtonPressed) andTarget:self];
        
    }
    
    return _changeFontTypeButton;
}


- (UIButton *) changeTextAveBackgroundButton {
    if (!_changeTextAveBackgroundButton) {
        
        CGRect buttonFrame = CGRectMake(self.changeFontTypeButton.frame.origin.x + self.changeFontTypeButton.frame.size.width + 15.f, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH* 2.f, TEXT_TOOLBAR_BUTTON_WIDTH);
        
        _changeTextAveBackgroundButton = [UtilityFunctions getButtonWithFrame:buttonFrame
																	  andIcon:CHANGE_TEXT_VIEW_BACKGROUND_UNSELECTED
                                             andSelector:@selector(changeTextAveBackgroundButtonPressed) andTarget:self];
        
        [_changeTextAveBackgroundButton setHidden:!self.toolbardOnTextAve];
        
    }
    return _changeTextAveBackgroundButton;
}

-(UIView *)lowerBarHolder {
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

-(AdjustTextAlignmentToolBar *)adjustTextAlignmentBar{
    if (!_adjustTextAlignmentBar) {
        _adjustTextAlignmentBar = [[AdjustTextAlignmentToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height/2.f)];
        _adjustTextAlignmentBar.delegate = self;
    }
    return _adjustTextAlignmentBar;
}

-(AdjustTextFontToolBar *)adjustTextFontBar{
    if (!_adjustTextFontBar) {
        _adjustTextFontBar = [[AdjustTextFontToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height/2.f)];
        _adjustTextFontBar.delegate = self;
    }
    return _adjustTextFontBar;
}

-(AdjustTextAVEBackgroundToolBar *)adjustBackgroundBar{
    if (!_adjustBackgroundBar) {
        _adjustBackgroundBar = [[AdjustTextAVEBackgroundToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height/2.f)];
        _adjustBackgroundBar.toolBarDelegate = self;

    }
    return _adjustBackgroundBar;
}


@end
