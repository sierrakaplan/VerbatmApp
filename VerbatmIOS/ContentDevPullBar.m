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

#define PULSE_DURATION 0.9
#define PULSE_DISTANCE 15

@end

@implementation ContentDevPullBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if(self) {
		[self setBackgroundColor: [UIColor clearColor]];
        [self createButtons];
		[self switchToPullDown];
	}
	return self;
}

//initialize all buttons, for all modes
-(void)createButtons {

	self.switchModeButtonFrame = CGRectMake(0, NAV_ICON_OFFSET, self.frame.size.width, NAV_ICON_SIZE);
	self.switchModeButton = [self getButtonWithFrame: self.switchModeButtonFrame];
	[self.switchModeButton addTarget:self action:@selector(switchModeButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
	self.pullDownBackgroundSquare = [[UIView alloc] initWithFrame:CGRectMake(self.switchModeButtonFrame.origin.x +
																			 self.switchModeButtonFrame.size.width/2.f - NAV_BAR_HEIGHT/2.f,
																			 0, NAV_BAR_HEIGHT, NAV_BAR_HEIGHT)];
	self.pullDownBackgroundSquare.backgroundColor = [UIColor blackColor];
	self.pullDownImage = [UIImage imageNamed: PULLDOWN_ICON];
	self.cameraImage = [UIImage imageNamed: CAMERA_BUTTON_ICON];
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

- (void) switchModeButtonReleased:(UIButton *)sender {
    
	if (!self.delegate) {
//		NSLog(@"No content dev pull bar delegate set.");
	}
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

@end
