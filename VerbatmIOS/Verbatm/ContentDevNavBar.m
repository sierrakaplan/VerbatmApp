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
@property (strong, nonatomic) UILabel *previewLabel;
@property (nonatomic) BOOL previewEnabledInMenuMode;

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
//
//	float middleButtonWidth = (self.frame.size.width - ((NAV_ICON_SIZE+NAV_ICON_OFFSET)*2.f))/2.f;
//
//	CGRect backButtonFrame = CGRectMake(NAV_ICON_OFFSET,  NAV_ICON_OFFSET, NAV_ICON_SIZE, NAV_ICON_SIZE);
//	self.backButton = [self getButtonWithFrame: backButtonFrame];
//	[self.backButton setImage:[UIImage imageNamed:BACK_ARROW_LEFT] forState:UIControlStateNormal];
//	[self.backButton addTarget:self action:@selector(backButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//
//	[panGesture requireGestureRecognizerToFail:self.backButton.gestureRecognizers.firstObject];
//
//	CGRect previewButtonFrame = CGRectMake(backButtonFrame.origin.x + backButtonFrame.size.width + 10,
//										   NAV_ICON_OFFSET, middleButtonWidth, NAV_ICON_SIZE);
//	self.previewLabel = [self getLabelWithParentFrame:previewButtonFrame andText:@"PREVIEW"];
//	self.previewButton = [self getButtonWithFrame: previewButtonFrame];
//	[self.previewLabel setTextColor:[UIColor PREVIEW_PUBLISH_COLOR]];
//	[self.previewButton addTarget:self action:@selector(previewButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//	[self.previewButton addSubview:self.previewLabel];
//	[self enablePreviewInMenuMode: NO];
}

# pragma mark - Button actions on touch up (send message to delegates)

-(void) backButtonReleased:(UIButton*) sender {
	if (!self.delegate) {
		NSLog(@"No content dev pull bar delegate set.");
	}
	[self.delegate backButtonPressed];
}

- (void) previewButtonReleased:(UIButton *)sender {

	if (!self.delegate) {
		NSLog(@"No content dev pull bar delegate set.");
	}
    [self.delegate previewButtonPressed];
}

@end
