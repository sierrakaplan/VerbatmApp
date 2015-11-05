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
#import "Styles.h"
#import "VerbatmExplanationVC.h"

@interface VerbatmExplanationVC()

@property (strong, nonatomic) UIButton * exitButton;
@property (strong, nonatomic) UITextView* textView;

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
		_textView = [[UITextView alloc] initWithFrame: self.view.bounds];
		_textView.font = [UIFont fontWithName:DEFAULT_FONT size:16.f];
		_textView.textColor = [UIColor blackColor];
		_textView.text = @"We're currently testing stories that comply with the following pattern: \n \
			1. Photos, Videos, or Text (PVT) that introduces you and the event you're going to. Talk a little about how you feel about the event (excited, interested, etc.) \n \
			2. PVT that gives the viewer a sense of the event--cool moments and your reaction to them. \n \
			3. PVT that summarizes what you want people to know about the event, and what your main takeaway has been from attending. \
		";
	}
	return _textView;
}

@end
