//
//  WelcomeVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChooseLoginVC.h"
#import "WelcomeVC.h"
#import "SegueIDs.h"
#import "Styles.h"

@interface WelcomeVC()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditonsLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

#define TEXT_HEIGHT 50.f
#define VERTICAL_OFFSET 30.f

@end

@implementation WelcomeVC

-(void) viewDidLoad {
	self.backgroundImageView.frame = self.view.bounds;
	self.welcomeLabel.frame = CGRectMake(0.f, VERTICAL_OFFSET, self.view.frame.size.width, TEXT_HEIGHT);
	self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
	self.welcomeLabel.font = [UIFont fontWithName:BOLD_FONT size: 30.f];

	CGFloat subtitleYPos = self.welcomeLabel.frame.origin.y + self.welcomeLabel.frame.size.height;
	self.subtitleLabel.frame = CGRectMake(0.f, subtitleYPos, self.view.frame.size.width, TEXT_HEIGHT);
	self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
	self.subtitleLabel.font = [UIFont fontWithName:REGULAR_FONT size:20.f];

	self.agreementLabel.frame = CGRectMake(0.f, self.view.frame.size.height - TEXT_HEIGHT - VERTICAL_OFFSET,
										   self.view.frame.size.width, 20.f);
	self.agreementLabel.textAlignment = NSTextAlignmentCenter;
	self.agreementLabel.font = [UIFont fontWithName:REGULAR_FONT size:14.f];
	self.agreementLabel.adjustsFontSizeToFitWidth = YES;

	self.termsAndConditonsLabel.frame = CGRectMake(0.f, self.agreementLabel.frame.origin.y +
												   self.agreementLabel.frame.size.height,
												   self.view.frame.size.width, 30.f);
	self.termsAndConditonsLabel.font = [UIFont fontWithName:REGULAR_FONT size:14.f];
	self.termsAndConditonsLabel.adjustsFontSizeToFitWidth = YES;
	self.termsAndConditonsLabel.textAlignment = NSTextAlignmentCenter;

	self.continueButton.frame = CGRectMake(0.f, self.agreementLabel.frame.origin.y - TEXT_HEIGHT,
										   self.view.frame.size.width,
										   TEXT_HEIGHT);
	self.continueButton.titleLabel.font = [UIFont fontWithName:BOLD_FONT size:30.f];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(termsAndConditionsPressed)];
	[self.termsAndConditonsLabel addGestureRecognizer: tapGesture];
	self.termsAndConditonsLabel.userInteractionEnabled = YES;
}

-(void) termsAndConditionsPressed {
	[self performSegueWithIdentifier:SEGUE_TERMS_AND_CONDITIONS sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:SEGUE_CREATE_ACCOUNT]) {
		// Get reference to the destination view controller
		ChooseLoginVC *chooseLoginVC = [segue destinationViewController];
		chooseLoginVC.creatingAccount = YES;
	}
}

@end
