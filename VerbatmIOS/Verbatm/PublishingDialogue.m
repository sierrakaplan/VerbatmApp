//
//  PublishingDialogue.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 2/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "PublishingDialogue.h"

@interface PublishingDialogue ()

@property (nonatomic) UIView* publishingOptions;
@property (strong, nonatomic) UIButton* exitButton;

@property (nonatomic) BOOL facebookOption;
@property (nonatomic) BOOL twitterOption;

#define EXIT_BUTTON_HEIGHT 10.f
#define NUM_SOCIAL_MEDIA_CHOICES 3
#define SOCIAL_MEDIA_CHOICE_HEIGHT 150.f
#define SHARE_BUTTON_HEIGHT 100.f
#define PUBLISHING_OPTIONS_HEIGHT (NUM_SOCIAL_MEDIA_CHOICES * SOCIAL_MEDIA_CHOICE_HEIGHT + SHARE_BUTTON_HEIGHT)

@end

@implementation PublishingDialogue


-(instancetype) initWithFrame:(CGRect)frame andChannel: (NSString*) channel {
	self = [super initWithFrame:frame];
	if (self) {
		//NOT IN USE
//		[self setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.5f]];
//		[self addSubview: self.publishingOptions];
//		[self.publishingOptions addSubview:self.exitButton];
//		NSString* verbatmName = [@"VERBATM (Channel \"" stringByAppendingString:<#(nonnull NSString *)#> + channel + "\")";
//		[self.publishingOptions addSubview: [self createSocialMediaChoiceWithName: andOffset:<#(CGFloat)#> andImage:<#(NSString *)#> andAction:<#(SEL)#>]]
//		[self.publishingOptions addSubview: [self createSocialMediaChoiceWithName:@"FACEBOOK"
//																		andOffset:EXIT_BUTTON_HEIGHT
//																		 andImage:FACEBOOK_ICON
//																		andAction:@selector(facebookOptionPressed)]]

	}
	return self;
}

-(UIView*) createSocialMediaChoiceWithName: (NSString*) name andOffset: (CGFloat) yOffset
							   andImage: (NSString*) imageName andAction: (SEL) buttonAction {
	CGFloat spacing = 10.f;
	CGFloat iconWidth = 10.f;
	CGFloat buttonWidth = 10.f;
	UIView* base = [[UIView alloc] initWithFrame:CGRectMake(0.f, yOffset, self.frame.size.width, SOCIAL_MEDIA_CHOICE_HEIGHT)];
	UIImageView* iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	[iconView setFrame:CGRectMake(spacing, 0.f, iconWidth, iconWidth)];
	[base addSubview: iconView];

	UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(spacing*2 + iconWidth, 0.f,
															   self.frame.size.width - spacing*4 - iconWidth - buttonWidth,
															   SOCIAL_MEDIA_CHOICE_HEIGHT)];
	[label setText:name];
	[base addSubview:label];

	UIButton* toggle = [UIButton buttonWithType:UIButtonTypeCustom];
	[toggle setFrame:CGRectMake(spacing*3, 0.f, buttonWidth, buttonWidth)];
	[toggle setImage:[UIImage imageNamed:CHECKBOX_UNSELECTED] forState:UIControlStateNormal];
	[toggle addTarget:self action:buttonAction forControlEvents:UIControlEventTouchUpInside];
	[base addSubview:toggle];

	return base;
}

-(void) toggleButton: (UIButton*) button toState:(BOOL) selected {
	if (selected) {
		[button setImage:[UIImage imageNamed:CHECKBOX_SELECTED] forState:UIControlStateNormal];
	} else {
		[button setImage:[UIImage imageNamed:CHECKBOX_UNSELECTED] forState:UIControlStateNormal];
	}
}

-(void) exitButtonPressed {
	[self.delegate exitButtonPressed];
}

#pragma mark - Lazy Instantiation -

-(UIView*) publishingOptions {
	if (!_publishingOptions) {
		CGRect publishingOptionsFrame = CGRectMake(0.f, PUBLISHING_OPTIONS_HEIGHT, self.frame.size.width,
												   self.frame.size.height - PUBLISHING_OPTIONS_HEIGHT);
		_publishingOptions = [[UIView alloc] initWithFrame:publishingOptionsFrame];
		[_publishingOptions setBackgroundColor:[UIColor whiteColor]];

	}
	return _publishingOptions;
}

-(UIButton*) exitButton {
	if (!_exitButton) {
		_exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_exitButton setFrame:CGRectMake(0.f, 0.f, EXIT_BUTTON_HEIGHT, EXIT_BUTTON_HEIGHT)];
		[_exitButton setImage:[UIImage imageNamed:EXIT_BUTTON_IMAGE] forState:UIControlStateNormal];
		[_exitButton addTarget:self action:@selector(exitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _exitButton;
}


@end
