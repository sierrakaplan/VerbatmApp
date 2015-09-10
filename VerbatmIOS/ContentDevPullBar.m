//
//  customPullBarView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ContentDevPullBar.h"
#import "EditContentView.h"
#import "UIEffects.h"
#import "Notifications.h"
#import "Icons.h"
#import "SizesAndPositions.h"

@interface ContentDevPullBar ()
@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *galleryButton;

@property (strong, nonatomic) UIImageView *pullDownIcon;

@property (strong, nonatomic) UIImage *previewButtonGrayedOut;
@property (strong, nonatomic) UIImage *previewButtonImage;

@end


@implementation ContentDevPullBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

    //load from Nib file..this initializes the background view and all its subviews
    self = [super initWithFrame:frame];
    if(self) {
        [self createButtons];
		[self switchToPullDown];
    }
    return self;
}

//initialize all buttons, for all modes
-(void)createButtons {

	float centerPoint = self.frame.size.width /2.f;
	float buttonSize = PULLBAR_HEIGHT_MENU_MODE - (2.f * PULLBAR_BUTTON_YOFFSET);
	float previewButtonWidth = buttonSize*1.5;

	self.previewButtonImage = [UIImage imageNamed:PREVIEW_BUTTON_IMAGE];
	self.previewButtonGrayedOut = [UIEffects imageOverlayed:self.previewButtonImage withColor:[UIColor darkGrayColor]];

	CGRect pullDownIconFrame = CGRectMake(centerPoint-PULLBAR_PULLDOWN_ICON_WIDTH/2.f, 0, PULLBAR_PULLDOWN_ICON_WIDTH, PULLBAR_HEIGHT_PULLDOWN_MODE);
	self.pullDownIcon = [[UIImageView alloc] initWithFrame:pullDownIconFrame];
	[self.pullDownIcon setImage:[UIImage imageNamed:PULLDOWN_ICON_IMAGE]];

	CGRect previewButtonFrame = CGRectMake(PULLBAR_BUTTON_XOFFSET, PULLBAR_BUTTON_YOFFSET, buttonSize, buttonSize);
	self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.previewButton setFrame:previewButtonFrame];
	[self grayOutPreview];
	[self.previewButton setImage:[UIImage imageNamed:PREVIEW_BUTTON_CLICKED] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.previewButton addTarget:self action:@selector(previewButtonReleased:) forControlEvents:UIControlEventTouchUpInside];

	CGRect cameraButtonFrame = CGRectMake(centerPoint-buttonSize/2.f, PULLBAR_BUTTON_YOFFSET, buttonSize, buttonSize);
	self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.cameraButton setFrame: cameraButtonFrame];
	[self.cameraButton setImage:[UIImage imageNamed:CAMERA_BUTTON_IMAGE] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.cameraButton addTarget:self action:@selector(cameraButtonReleased:) forControlEvents:UIControlEventTouchUpInside];

	CGRect galleryButtonFrame = CGRectMake(self.frame.size.width - previewButtonWidth - PULLBAR_BUTTON_XOFFSET, PULLBAR_BUTTON_YOFFSET, previewButtonWidth, buttonSize);
	self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.galleryButton setFrame:galleryButtonFrame];
	//TODO: changet this to gallery icon
	[self.galleryButton setImage:[UIImage imageNamed:PULLUP_BUTTON_IMAGE] forState:UIControlStateNormal];
	[self.galleryButton addTarget:self action:@selector(galleryButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
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

	[self.pullDownIcon removeFromSuperview];

	[self addSubview:self.previewButton];
	[self addSubview:self.cameraButton];
	[self addSubview:self.galleryButton];
}

-(void)switchToPullDown {
	self.mode = PullBarModePullDown;

	[self.previewButton removeFromSuperview];
	[self.cameraButton removeFromSuperview];
	[self.galleryButton removeFromSuperview];

	[self addSubview:self.pullDownIcon];
}


# pragma mark - GestureRecognizer delegate methods

// ignore pan gesture if touching buttons
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([touch.view isKindOfClass:[UIControl class]]) {
		// we touched our control surface
		return NO; // ignore the touch
	}
	return YES; // handle the touch
}

# pragma mark - Un and gray out buttons

-(void) grayOutPreview {
	[self.previewButton setEnabled:NO];
	[self.previewButton setImage:self.previewButtonGrayedOut forState:UIControlStateNormal];
}

-(void) unGrayOutPreview {
	[self.previewButton setEnabled:YES];
	[self.previewButton setImage:self.previewButtonImage forState:UIControlStateNormal];
}


# pragma mark - Button actions on touch up (send message to delegates)


- (void) previewButtonReleased:(UIButton *)sender {
	if (self.delegate) {
    	[self.delegate previewButtonPressed];
	}

}

- (void) cameraButtonReleased:(UIButton *)sender {
	if (self.delegate) {
		[self.delegate cameraButtonPressed];
	}
}

-(void) galleryButtonReleased:(UIButton*) sender {
	if (self.delegate) {
		[self.delegate galleryButtonPressed];
	}
}


@end
