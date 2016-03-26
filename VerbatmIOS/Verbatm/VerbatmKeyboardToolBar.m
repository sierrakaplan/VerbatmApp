//
//  VerbatmKeyboardToolBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "VerbatmKeyboardToolBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"

@interface VerbatmKeyboardToolBar()

@property (nonatomic) BOOL textColorBlack;
@property (strong, nonatomic) UIButton *textColorButton;
@property (strong, nonatomic) UIButton *textSizeIncreaseButton;
@property (strong, nonatomic) UIButton *textSizeDecreaseButton;
@property (strong, nonatomic) UIButton *leftAlignButton;
@property (strong, nonatomic) UIButton *centerAlignButton;
@property (strong, nonatomic) UIButton *rightAlignButton;
@property (strong, nonatomic) UIButton *doneButton;

#define BUTTON_Y_OFFSET ((TEXT_TOOLBAR_HEIGHT - TEXT_TOOLBAR_BUTTON_WIDTH)/2.f)
#define COLOR_BUTTON_X_OFFSET 20.f
#define SIZE_BUTTONS_OFFSET 100.f
#define ALIGNMENT_BUTTONS_OFFSET 200.f
#define SPACE 10.f

@end

@implementation VerbatmKeyboardToolBar

-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.frame = frame;
		self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8];
		self.textColorBlack = YES;
		[self addButtons];
	}
	return self;
}

-(void) addButtons {
	[self addSubview:self.textColorButton];
	[self addSubview:self.textSizeIncreaseButton];
	[self addSubview:self.textSizeDecreaseButton];
	[self addSubview:self.leftAlignButton];
	[self addSubview:self.centerAlignButton];
	[self addSubview:self.rightAlignButton];
	[self addSubview:self.doneButton];
}

#pragma mark - Button Actions -

-(void) textColorButtonPressed {
	self.textColorBlack = !self.textColorBlack;
	UIImage *iconImage;
	if (self.textColorBlack) {
		iconImage = [UIImage imageNamed: WHITE_FONT_ICON];
	} else {
		iconImage = [UIImage imageNamed: BLACK_FONT_ICON];
	}
	[self.textColorButton setImage:iconImage forState:UIControlStateNormal];
	[self.delegate textColorChangedToBlack:self.textColorBlack];
}

-(void) textSizeIncreaseButtonPressed {
	[self.delegate textSizeIncreased];
}

-(void) textSizeDecreaseButtonPressed {
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

-(UIButton *) doneButton {
	if (!_doneButton) {
		CGRect doneButtonFrame = CGRectMake(self.frame.size.width - TEXT_TOOLBAR_DONE_WIDTH, BUTTON_Y_OFFSET,
											TEXT_TOOLBAR_DONE_WIDTH, self.frame.size.height - TEXT_TOOLBAR_BUTTON_OFFSET);
		_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_doneButton.frame = doneButtonFrame;
		UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:KEYBOARD_TOOLBAR_FONT_SIZE];
		NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"DONE" attributes:@{NSForegroundColorAttributeName: VERBATM_GOLD_COLOR, NSFontAttributeName : labelFont}];
		[_doneButton setAttributedTitle:title forState:UIControlStateNormal];
		[_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _doneButton;
}

- (UIButton *) textColorButton {
	if (!_textColorButton) {
		CGRect buttonFrame = CGRectMake(TEXT_TOOLBAR_BUTTON_OFFSET, BUTTON_Y_OFFSET,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_textColorButton = [self getButtonWithFrame:buttonFrame andIcon:WHITE_FONT_ICON
										andSelector:@selector(textColorButtonPressed)];
	}
	return _textColorButton;
}

- (UIButton *) textSizeIncreaseButton {
	if (!_textSizeIncreaseButton) {
		CGRect buttonFrame = CGRectMake(SIZE_BUTTONS_OFFSET, BUTTON_Y_OFFSET,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_textSizeIncreaseButton = [self getButtonWithFrame:buttonFrame andIcon:INCREASE_FONT_SIZE_ICON
											 andSelector:@selector(textSizeIncreaseButtonPressed)];

	}
	return _textSizeIncreaseButton;
}

- (UIButton *) textSizeDecreaseButton {
	if (!_textSizeDecreaseButton) {
		CGRect buttonFrame = CGRectMake(SIZE_BUTTONS_OFFSET + SPACE + TEXT_TOOLBAR_BUTTON_WIDTH, BUTTON_Y_OFFSET,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_textSizeDecreaseButton = [self getButtonWithFrame:buttonFrame andIcon:DECREASE_FONT_SIZE_ICON
											   andSelector:@selector(textSizeDecreaseButtonPressed)];

	}
	return _textSizeDecreaseButton;
}

- (UIButton *) leftAlignButton {
	if (!_leftAlignButton) {
		CGRect buttonFrame = CGRectMake(ALIGNMENT_BUTTONS_OFFSET, BUTTON_Y_OFFSET,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_leftAlignButton = [self getButtonWithFrame:buttonFrame andIcon:LEFT_ALIGN_ICON
										andSelector:@selector(leftAlignButtonPressed)];

	}
	return _leftAlignButton;
}

- (UIButton *) centerAlignButton {
	if (!_centerAlignButton) {
		CGRect buttonFrame = CGRectMake(ALIGNMENT_BUTTONS_OFFSET + SPACE + TEXT_TOOLBAR_BUTTON_WIDTH, BUTTON_Y_OFFSET,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_centerAlignButton = [self getButtonWithFrame:buttonFrame andIcon:CENTER_ALIGN_ICON
											 andSelector:@selector(centerAlignButtonPressed)];

	}
	return _centerAlignButton;
}

- (UIButton *) rightAlignButton {
	if (!_rightAlignButton) {
		CGRect buttonFrame = CGRectMake(ALIGNMENT_BUTTONS_OFFSET + (SPACE + TEXT_TOOLBAR_BUTTON_WIDTH)*2, BUTTON_Y_OFFSET,
										TEXT_TOOLBAR_BUTTON_WIDTH, TEXT_TOOLBAR_BUTTON_WIDTH);
		_rightAlignButton = [self getButtonWithFrame:buttonFrame andIcon:RIGHT_ALIGN_ICON
										 andSelector:@selector(rightAlignButtonPressed)];

	}
	return _rightAlignButton;
}

-(UIButton *) getButtonWithFrame:(CGRect)frame andIcon:(NSString*)iconName andSelector:(SEL)action {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	[button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}


@end
