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
    background = 5,
	photoPosition = 6
} ToolBarOptions;

@interface VerbatmKeyboardToolBar()<AdjustTextSizeDelegate, AdjustTextAlignmentToolBarDelegate, AdjustTextFontToolBarDelegate, AdjustTextAVEBackgroundToolBarDelegate>

@property (nonatomic) BOOL textIsBlack;
@property (nonatomic) BOOL onTextAve;

@property (strong, nonatomic) UIButton *textColorButton;
@property (strong, nonatomic) UIButton *changeFontSizeButton;
@property (strong, nonatomic) UIButton *changeTextAlignmentButton;
@property (strong, nonatomic) UIButton *changeFontTypeButton;
@property (strong, nonatomic) UIButton *changeTextAveBackgroundButton;
@property (strong, nonatomic) UIButton *repositionPhotoButton;

@property (nonatomic) UIButton *cancelButton;

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
#define CANCEL_BUTTON_SIZE (2*TEXT_TOOLBAR_BUTTON_OFFSET + TEXT_TOOLBAR_BUTTON_WIDTH)

#define ICON_SEPARATION_SPACE (((self.frame.size.width - (2*TEXT_TOOLBAR_BUTTON_OFFSET)) - (NUM_BASE_BUTTONS * TEXT_TOOLBAR_BUTTON_WIDTH) - TEXT_TOOLBAR_DONE_WIDTH)/(NUM_BASE_BUTTONS - 1))

#define NUM_BASE_BUTTONS 5

#define CENTERING_Y ((TEXT_TOOLBAR_HEIGHT/2.f) - (TEXT_TOOLBAR_BUTTON_WIDTH/2.f))

@end

@implementation VerbatmKeyboardToolBar

-(instancetype)initWithFrame:(CGRect)frame andTextColorBlack:(BOOL)textColorBlack
				 isOnTextAve:(BOOL)onTextAve isOnScreenPermanently:(BOOL)onScreen {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor whiteColor];
		self.textIsBlack = textColorBlack;
        self.onTextAve = onTextAve;
        self.currentSelectedOption = noSelection;

        [self addAllButtons];

		if (onScreen) {
			 [self addSubview:self.keyboardButton];
		} else {
			[self addSubview:self.doneButton];
		}
	}
	return self;
}

-(void) addAllButtons {
	[self addSubview:self.textColorButton];
    [self addSubview:self.changeFontSizeButton];
    [self addSubview:self.changeTextAlignmentButton];
    [self addSubview:self.changeFontTypeButton];
    [self addSubview:self.changeTextAveBackgroundButton];
	[self addSubview:self.repositionPhotoButton];
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


-(void)changeTextAveBackgroundButtonPressed {
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

-(void)changeTextAlignmentButtonPressed {
    [self removeTopHalfBar];
    if(self.currentSelectedOption == textAlightment){
        self.currentSelectedOption = noSelection;
    }else{
        self.currentSelectedOption = textAlightment;
    }
    [self addTopHalfBar];
}

-(void)changePhotoPositionButtonPressed {
	UIImage *iconImage;
	if (self.currentSelectedOption == photoPosition) {
		self.currentSelectedOption = noSelection;
		iconImage = [UIImage imageNamed:REPOSITION_PHOTO_ICON_UNSELECTED];
		[self.delegate repositionPhotoUnSelected];
	} else {
		self.currentSelectedOption = photoPosition;
		iconImage = [UIImage imageNamed: REPOSITION_PHOTO_ICON_SELECTED];
		[self.delegate repositionPhotoSelected];
	}
	[self.repositionPhotoButton setImage:iconImage forState:UIControlStateNormal];
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

-(void) cancelButtonPressed {
	[self removeTopHalfBar];
}

-(void)removeTopHalfBar {
	if (self.cancelButton.superview) {
		[self.cancelButton removeFromSuperview];
	}
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
		case photoPosition:
			[self changePhotoPositionButtonPressed];
			break;
        default:
            break;
    }
	self.currentSelectedOption = noSelection;
}

-(void)addTopHalfBar {
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
	[self addSubview: self.cancelButton];
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
	[self removeTopHalfBar];
	[self.delegate doneButtonPressed];
}

-(void)keyboardButtonPressed {
	[self removeTopHalfBar];
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
        CGFloat height = self.frame.size.height - TEXT_TOOLBAR_BUTTON_OFFSET;
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

- (UIButton *) textColorButton {
	if (!_textColorButton) {
		CGRect buttonFrame = CGRectMake(TEXT_TOOLBAR_BUTTON_OFFSET, CENTERING_Y,
										TEXT_TOOLBAR_BUTTON_WIDTH-5.f, TEXT_TOOLBAR_BUTTON_WIDTH);
        _textColorButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:((self.textIsBlack) ? TEXT_FONT_COLOR_BLACK :TEXT_FONT_COLOR_WHITE)
										andSelector:@selector(textColorButtonPressed) andTarget:self];
	}
	return _textColorButton;
}


- (UIButton *) changeTextAlignmentButton {
    if (!_changeTextAlignmentButton) {
        CGRect buttonFrame = CGRectMake(self.changeFontSizeButton.frame.origin.x +
										self.changeFontSizeButton.frame.size.width + ICON_SEPARATION_SPACE,
										CENTERING_Y, TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        _changeTextAlignmentButton = [UtilityFunctions getButtonWithFrame:buttonFrame
																  andIcon:CHANGE_TEXT_ALIGNMENT_ICON
                                             andSelector:@selector(changeTextAlignmentButtonPressed) andTarget:self];
    }
    return _changeTextAlignmentButton;
}


- (UIButton *) changeFontTypeButton {
    if (!_changeFontTypeButton) {
        CGRect buttonFrame = CGRectMake(self.changeTextAlignmentButton.frame.origin.x + self.changeTextAlignmentButton.frame.size.width +
										ICON_SEPARATION_SPACE - 10.f, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        
        _changeFontTypeButton = [UtilityFunctions getButtonWithFrame:buttonFrame
															 andIcon:CHANGE_FONT_TYPE_ICON_UNSELECTED
                                                  andSelector:@selector(changeFontTypeButtonPressed) andTarget:self];

    }
    
    return _changeFontTypeButton;
}


- (UIButton *) changeTextAveBackgroundButton {
    if (!_changeTextAveBackgroundButton) {
        
        CGRect buttonFrame = CGRectMake(self.changeFontTypeButton.frame.origin.x + self.changeFontTypeButton.frame.size.width +
										ICON_SEPARATION_SPACE, CENTERING_Y,
                                        TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
        
        _changeTextAveBackgroundButton = [UtilityFunctions getButtonWithFrame:buttonFrame
																	  andIcon:CHANGE_TEXT_VIEW_BACKGROUND_UNSELECTED
                                             andSelector:@selector(changeTextAveBackgroundButtonPressed) andTarget:self];

        [_changeTextAveBackgroundButton setHidden:!self.onTextAve];
        
    }
    return _changeTextAveBackgroundButton;
}

-(UIButton *)repositionPhotoButton{
	if (!_repositionPhotoButton) {
		CGRect buttonFrame = CGRectMake(self.changeFontTypeButton.frame.origin.x + self.changeFontTypeButton.frame.size.width +
										ICON_SEPARATION_SPACE, CENTERING_Y,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);

		_repositionPhotoButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:REPOSITION_PHOTO_ICON_UNSELECTED
											  andSelector:@selector(changePhotoPositionButtonPressed) andTarget:self];
		[_repositionPhotoButton setHidden: self.onTextAve];
	}
	return _repositionPhotoButton;
}

-(UIButton *) keyboardButton {
	if (!_keyboardButton) {
		CGRect keyboardButtonFrame = CGRectMake(self.changeTextAveBackgroundButton.frame.origin.x + self.changeTextAveBackgroundButton.frame.size.width +
												ICON_SEPARATION_SPACE, CENTERING_Y,
												TEXT_TOOLBAR_BUTTON_WIDTH*1.2, TEXT_TOOLBAR_BUTTON_WIDTH);
		_keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_keyboardButton.frame = keyboardButtonFrame;
		[_keyboardButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[_keyboardButton setImage:[UIImage imageNamed:PRESENT_KEYBOARD_ICON] forState:UIControlStateNormal];
		[_keyboardButton addTarget:self action:@selector(keyboardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _keyboardButton;
}

- (UIButton *) cancelButton {
	if (!_cancelButton) {
		CGRect buttonFrame = CGRectMake(TEXT_TOOLBAR_BUTTON_OFFSET, CENTERING_Y,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_cancelButton = [UtilityFunctions getButtonWithFrame:buttonFrame andIcon:EXIT_ICON
													andSelector:@selector(cancelButtonPressed) andTarget:self];
	}
	return _cancelButton;
}

-(AdjustTextSizeToolBar *)adjustTextSizeBar{
    if (!_adjustTextSizeBar) {
        _adjustTextSizeBar = [[AdjustTextSizeToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f,
																					self.frame.size.width, self.frame.size.height)];
        _adjustTextSizeBar.delegate = self;
    }
    return _adjustTextSizeBar;
}

-(AdjustTextAlignmentToolBar *)adjustTextAlignmentBar{
    if (!_adjustTextAlignmentBar) {
        _adjustTextAlignmentBar = [[AdjustTextAlignmentToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f,
																							  self.frame.size.width, self.frame.size.height)];
        _adjustTextAlignmentBar.delegate = self;
    }
    return _adjustTextAlignmentBar;
}

-(AdjustTextFontToolBar *)adjustTextFontBar{
    if (!_adjustTextFontBar) {
        _adjustTextFontBar = [[AdjustTextFontToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f,
																					self.frame.size.width, self.frame.size.height)];
        _adjustTextFontBar.delegate = self;
    }
    return _adjustTextFontBar;
}

-(AdjustTextAVEBackgroundToolBar *)adjustBackgroundBar{
    if (!_adjustBackgroundBar) {
        _adjustBackgroundBar = [[AdjustTextAVEBackgroundToolBar alloc]initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width,
																							   self.frame.size.height)];
        _adjustBackgroundBar.toolBarDelegate = self;

    }
    return _adjustBackgroundBar;
}

@end
