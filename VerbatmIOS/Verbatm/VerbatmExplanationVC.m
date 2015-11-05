//
//  VerbatmExplanationVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "Styles.h"
#import "VerbatmExplanationVC.h"

@interface VerbatmExplanationVC()

@property (strong, nonatomic) UIButton * exitButton;
@property (strong, nonatomic) UITextView* textView;

#define FONT @"HelveticaNeue-Medium"
#define FONT_SIZE 20.f
#define TEXT_OFFSET 40.f

@end

@implementation VerbatmExplanationVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.view addSubview: self.textView];
	[self createExitButton];
}

-(void)createExitButton{
	self.exitButton = [[UIButton alloc] initWithFrame:
					   CGRectMake(EXIT_CV_BUTTON_WALL_OFFSET, EXIT_CV_BUTTON_WALL_OFFSET,
								  EXIT_CV_BUTTON_WIDTH, EXIT_CV_BUTTON_HEIGHT)];
	[self.exitButton setImage:[UIImage imageNamed:DONE_CHECKMARK] forState:UIControlStateNormal];
	[self.exitButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
	[self.exitButton addTarget:self action:@selector(exitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.exitButton];
	[self.view bringSubviewToFront:self.exitButton];
}

-(void)exitButtonClicked:(UIButton*) sender{
	 [self performSegueWithIdentifier:UNWIND_SEGUE_QUESTION_PAGE sender:self];
}

#pragma mark - Lazy Instantiation -

-(UITextView*) textView {
	if (!_textView) {
		_textView = [[UITextView alloc] initWithFrame: CGRectMake(TEXT_OFFSET, TEXT_OFFSET,
																  self.view.frame.size.width - TEXT_OFFSET*2,
																  self.view.frame.size.height - TEXT_OFFSET*2)];
		_textView.backgroundColor = self.view.backgroundColor;
		_textView.font = [UIFont fontWithName:FONT size:FONT_SIZE];
		_textView.textColor = [UIColor whiteColor];
		_textView.editable = NO;
		_textView.text = VERBATM_EXPLANATION_TEXT;
	}
	return _textView;
}

@end
