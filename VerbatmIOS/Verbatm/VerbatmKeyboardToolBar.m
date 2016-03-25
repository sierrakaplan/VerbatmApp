//
//  VerbatmKeyboardToolBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VerbatmKeyboardToolBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"

@implementation VerbatmKeyboardToolBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {
	//load from Nib file..this initializes the background view and all its subviews
	self = [super initWithFrame:frame];
	if(self) {
		self.frame = frame;
		[self createButtons];
        self.backgroundColor = [UIColor whiteWith];
	}
	return self;
}

-(void) createButtons {
	CGRect doneButtonFrame = CGRectMake(self.frame.size.width - TEXT_TOOLBAR_BUTTON_WIDTH, 0.f, TEXT_TOOLBAR_BUTTON_WIDTH, self.frame.size.height - TEXT_TOOLBAR_BUTTON_OFFSET);
	UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.layer.cornerRadius = 10;
	[doneButton setFrame:doneButtonFrame];
	[doneButton setBackgroundColor:[UIColor DONE_BUTTON_COLOR]];

	UIColor *labelColor = [UIColor whiteColor];
	UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:KEYBOARD_TOOLBAR_FONT_SIZE];
	NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Done" attributes:@{NSForegroundColorAttributeName: labelColor, NSFontAttributeName : labelFont}];
	[doneButton setAttributedTitle:title forState:UIControlStateNormal];

	[doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:doneButton];

}

-(void) doneButtonPressed {
	if (self.delegate) {
		[self.delegate doneButtonPressed];
	}
}

@end
