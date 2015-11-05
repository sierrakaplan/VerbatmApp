//
//  customPullBarView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ContentDevPullBar.h"
#import "EditContentView.h"
#import "Notifications.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface ContentDevPullBar ()

// This button switches modes (can be the camera or the pull down)
@property (strong, nonatomic) UIButton *switchModeButton;
@property (nonatomic) CGRect switchModeButtonFrame;
@property (nonatomic) BOOL pullDownPulsing;
@property (strong, nonatomic) UIView* pullDownBackgroundSquare;
@property (strong, nonatomic) UIImage* cameraImage;
@property (strong, nonatomic) UIImage* pullDownImage;

@property (strong, nonatomic) UIButton *questionMarkButton;

#define PULSE_DURATION 0.9
#define PULSE_DISTANCE 15

@end

@implementation ContentDevPullBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if(self) {
		[self setBackgroundColor: [UIColor whiteColor]];
        [self createButtons];
		[self switchToPullDown];
	}
	return self;
}

//initialize all buttons, for all modes
-(void)createButtons {
	self.switchModeButtonFrame = CGRectMake(self.frame.size.width/2.f - NAV_ICON_SIZE/2.f,
											NAV_ICON_OFFSET, NAV_ICON_SIZE, NAV_ICON_SIZE);
	self.switchModeButton = [self getButtonWithFrame: self.switchModeButtonFrame];
	[self.switchModeButton addTarget:self action:@selector(switchModeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.pullDownBackgroundSquare = [[UIView alloc] initWithFrame:CGRectMake(self.switchModeButtonFrame.origin.x +
																			 self.switchModeButtonFrame.size.width/2.f - NAV_BAR_HEIGHT/2.f,
																			 0, NAV_BAR_HEIGHT, NAV_BAR_HEIGHT)];
	self.pullDownBackgroundSquare.backgroundColor = [UIColor blackColor];
	self.pullDownImage = [UIImage imageNamed: PULLDOWN_ICON];
	self.cameraImage = [UIImage imageNamed: CAMERA_BUTTON_ICON];

	CGRect questionButtonFrame = CGRectMake(NAV_ICON_OFFSET, NAV_ICON_OFFSET, NAV_ICON_SIZE, NAV_ICON_SIZE);
	self.questionMarkButton = [self getButtonWithFrame: questionButtonFrame];
	[self.questionMarkButton setImage:[UIImage imageNamed:INFO_ICON] forState:UIControlStateNormal];
	[self.questionMarkButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(UIButton*) getButtonWithFrame: (CGRect)frame  {
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame: frame];
	[button.imageView setContentMode: UIViewContentModeScaleAspectFit];
	[self addSubview: button];
	return button;
}

#pragma mark - Pulsing pull down -

-(void) pulsePullDown {
	[UIView animateWithDuration:PULSE_DURATION
						  delay:0.0f
						options:UIViewAnimationCurveLinear |
	 UIViewAnimationOptionRepeat |
	 UIViewAnimationOptionAutoreverse
					 animations:^{
						 self.switchModeButton.frame = CGRectOffset(self.switchModeButton.frame, 0, PULSE_DISTANCE);
					 }
					 completion:^(BOOL finished) {
					 }];
	self.pullDownPulsing = YES;
}

# pragma mark - Switch PullBar mode

-(void)switchToMode: (PullBarMode) mode {
	if (mode == PullBarModeMenu) {
		[self switchToMenu];
	} else if (mode == PullBarModePullDown) {
		[self switchToPullDown];
	}
}

-(void)switchToMenu {
	self.mode = PullBarModeMenu;
	[self.switchModeButton setImage:self.cameraImage forState: UIControlStateNormal];
	if (self.pullDownPulsing) {
		[self.switchModeButton.layer removeAllAnimations];
		self.switchModeButton.frame = self.switchModeButtonFrame;
	}
}

-(void)switchToPullDown {
	self.mode = PullBarModePullDown;
	[self.switchModeButton setImage:self.pullDownImage forState: UIControlStateNormal];
}

# pragma mark - Button actions on touch up (send message to delegates)

- (void) switchModeButtonPressed:(UIButton *)sender {
	switch(self.mode) {
		case PullBarModeMenu: {
			[self.delegate cameraButtonPressed];
			break;
		}
		case PullBarModePullDown: {
			[self.delegate pullDownButtonPressed];
			break;
		}
	}
}

-(void) questionButtonPressed: (UIButton*) sender{
	[self.delegate questionButtonPressed];
}

@end
