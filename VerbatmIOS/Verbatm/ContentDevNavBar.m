//
//  ContentDevNavBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "ContentDevNavBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface ContentDevNavBar()

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *previewButton;
@property (nonatomic) BOOL previewEnabledInMenuMode;

#define BUTTON_HEIGHT 15.f

@end

@implementation ContentDevNavBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if(self) {
		[self setBackgroundColor: [UIColor clearColor]];
		[self createButtons];
	}
	return self;
}

//initialize all buttons, for all modes
-(void)createButtons {

	UIImage* backIcon = [UIImage imageNamed:BACK_ICON];
	self.backButton = [self getButtonWithIcon: backIcon];
	CGFloat backWidth = (backIcon.size.width / backIcon.size.height) * BUTTON_HEIGHT;
	CGRect backButtonFrame = CGRectMake(CONTENT_DEV_NAV_BAR_OFFSET, CONTENT_DEV_NAV_BAR_OFFSET,
										backWidth, BUTTON_HEIGHT);
	self.backButton.frame = backButtonFrame;
	[self.backButton addTarget:self action:@selector(backButtonReleased:) forControlEvents:UIControlEventTouchUpInside];


	UIImage* previewIcon = [UIImage imageNamed:PREVIEW_ICON];
	self.previewButton = [self getButtonWithIcon: previewIcon];
	CGFloat previewWidth = (previewIcon.size.width / previewIcon.size.height) * BUTTON_HEIGHT;
	CGRect previewButtonFrame = CGRectMake(self.frame.size.width - previewWidth - CONTENT_DEV_NAV_BAR_OFFSET,
										   CONTENT_DEV_NAV_BAR_OFFSET,
										   previewWidth, BUTTON_HEIGHT);
	self.previewButton.frame = previewButtonFrame;
	[self.previewButton addTarget:self action:@selector(previewButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
	[self enablePreviewButton: NO];
}

-(UIButton*) getButtonWithIcon: (UIImage*) icon {
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button.imageView setContentMode: UIViewContentModeScaleAspectFit];
	[button setImage:icon forState:UIControlStateNormal];
	[self addSubview: button];
	return button;
}

# pragma mark - Enable and unEnable Buttons -

-(void) enablePreviewButton: (BOOL) enable {
	[self.previewButton setEnabled: enable];
}

# pragma mark - Button actions on touch up (send message to delegates)

-(void) backButtonReleased:(UIButton*) sender {
	if (!self.delegate) {
//		NSLog(@"No content dev pull bar delegate set.");
	}
	[self.delegate backButtonPressed];
}

- (void) previewButtonReleased:(UIButton *)sender {
	if (!self.delegate) {
//		NSLog(@"No content dev nav bar delegate set.");
	}
    [self.delegate previewButtonPressed];
}

@end
