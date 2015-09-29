//
//  HomeNavPullBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/4/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "HomeNavPullBar.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UIEffects.h"

@interface HomeNavPullBar()

@property (strong, nonatomic) UIButton *profileNavButton;
@property (strong, nonatomic) UIButton *adkNavButton;

@end

@implementation HomeNavPullBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

	//load from Nib file..this initializes the background view and all its subviews
	self = [super initWithFrame:frame];
	if(self) {
		[self formatSelf];
		[self createButtons];
	}
	return self;
}

-(void) formatSelf {
//	[UIEffects createLessBlurViewOnView:self withStyle:UIBlurEffectStyleLight];
	[self setBackgroundColor:[UIColor NAV_BAR_COLOR]];
}

//position the nav views in appropriate places and set frames
-(void) createButtons {
	self.profileNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.adkNavButton = [UIButton buttonWithType:UIButtonTypeCustom];

	float navIconSize = NAV_BAR_HEIGHT - NAV_ICON_OFFSET*2;
	self.profileNavButton.frame = CGRectMake(NAV_ICON_OFFSET, NAV_ICON_OFFSET,
											 navIconSize, navIconSize);
	self.adkNavButton.frame = CGRectMake(self.frame.size.width - navIconSize - NAV_ICON_OFFSET,
										 NAV_ICON_OFFSET,
										 navIconSize, navIconSize);

	[self.profileNavButton setImage:[UIImage imageNamed:PROFILE_NAV_ICON] forState:UIControlStateNormal];
	[self.adkNavButton setImage:[UIImage imageNamed:ADK_NAV_ICON] forState:UIControlStateNormal];

	[self.profileNavButton addTarget:self action:@selector(profileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.adkNavButton addTarget:self action:@selector(adkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

	//[self addSubview:self.profileNavButton];
	[self addSubview:self.adkNavButton];
}

-(void) profileButtonPressed:(UIButton*) sender {
	//[self.delegate profileButtonPressed];
}

-(void) adkButtonPressed:(UIButton*) sender {
	[self.delegate adkButtonPressed];
}

@end
