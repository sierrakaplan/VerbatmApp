//
//  verbatmUITextView.m
//  Verbatm
//
//  Created by Iain Usiri on 9/9/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmUITextView.h"
#import "UIEffects.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "Notifications.h"


@interface VerbatmUITextView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIView* toolBar;
@property (strong, nonatomic) UIButton* doneButton;
@end



@implementation VerbatmUITextView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
//		[UIEffects addDashedBorderToView:self.textView];
		[self addToolBarToView];
	}
	return self;
}


//creates a toolbar to add onto the keyboard
-(void)addToolBarToView {
	CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	self.toolBar = [[UIView alloc] initWithFrame:toolBarFrame];
	[self.toolBar setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];

	CGRect doneButtonFrame = CGRectMake(self.frame.size.width - TEXT_TOOLBAR_BUTTON_SIZE - TEXT_TOOLBAR_BUTTON_OFFSET, TEXT_TOOLBAR_BUTTON_OFFSET, TEXT_TOOLBAR_BUTTON_SIZE, self.frame.size.height - TEXT_TOOLBAR_BUTTON_OFFSET*2);
	self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.doneButton.layer.cornerRadius = 10;
	[self.doneButton setFrame:doneButtonFrame];
	[self.doneButton setBackgroundColor:[UIColor DONE_BUTTON_COLOR]];

	UIColor *labelColor = [UIColor whiteColor];
	UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:PUBLISH_BUTTON_LABEL_FONT_SIZE];
	NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Done" attributes:@{NSForegroundColorAttributeName: labelColor, NSFontAttributeName : labelFont}];
	[self.doneButton setAttributedTitle:title forState:UIControlStateNormal];

	[self.doneButton addTarget:self action:@selector(exitTextView) forControlEvents:UIControlEventTouchUpInside];
	[self.toolBar addSubview:self.doneButton];

	[self addSubview:self.toolBar];
}

-(void)adjustToolBarFrame {
	self.toolBar.frame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
}

-(void) exitTextView {
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EXIT_EDIT_CONTENT_VIEW object:nil userInfo:nil];
}

@end
