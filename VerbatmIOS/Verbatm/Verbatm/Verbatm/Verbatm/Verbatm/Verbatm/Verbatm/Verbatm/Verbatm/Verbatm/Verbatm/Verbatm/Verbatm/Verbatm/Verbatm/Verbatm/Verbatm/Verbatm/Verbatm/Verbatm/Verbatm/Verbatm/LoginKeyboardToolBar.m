//
//  LoginKeyboardToolBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "LoginKeyboardToolBar.h"
#import "Styles.h"

@interface LoginKeyboardToolBar()

@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation LoginKeyboardToolBar

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addSubview: self.nextButton];
	}
	return self;
}

-(void) setNextButtonText:(NSString*)text {
	[self.nextButton setTitle:text forState:UIControlStateNormal];
}

-(void) nextButtonPressed {
	[self.delegate nextButtonPressed];
}

-(UIButton*) nextButton {
	if (!_nextButton) {
		_nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_nextButton.frame = self.bounds;
		_nextButton.backgroundColor = ORANGE_COLOR;
		[_nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _nextButton;
}

@end
