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
#import "Styles.h"

@interface ContentDevPullBar ()


@property (strong, nonatomic) UIButton *backButton;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UILabel *previewLabel;
@property (nonatomic) BOOL previewEnabledInMenuMode;

// This button switches modes (can be the camera or the pull down)
@property (strong, nonatomic) UIButton *switchModeButton;
@property (strong, nonatomic) UIImage* cameraImage;
@property (strong, nonatomic) UIImage* pullDownImage;

@property (strong, nonatomic) UIButton *galleryButton;
@property (strong, nonatomic) UIImage* galleryImage;
@property (strong, nonatomic) UIImage* galleryImageGrayedOut;


@end


@implementation ContentDevPullBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

    //load from Nib file..this initializes the background view and all its subviews
    self = [super initWithFrame:frame];
    if(self) {
		[self setBackgroundColor: [UIColor NAV_BAR_COLOR]];
        [self createButtons];
		[self switchToPullDown];
    }
    return self;
}

//initialize all buttons, for all modes
-(void)createButtons {

	float navIconSize = NAV_BAR_HEIGHT - NAV_ICON_OFFSET*2;
	float middleButtonWidth = (self.frame.size.width - ((navIconSize+NAV_ICON_OFFSET)*2.f))/2.f;

	CGRect backButtonFrame = CGRectMake(NAV_ICON_OFFSET,  NAV_ICON_OFFSET, navIconSize, navIconSize);
	self.backButton = [self getButtonWithFrame: backButtonFrame];
	[self.backButton setImage:[UIImage imageNamed:BACK_ARROW_LEFT] forState:UIControlStateNormal];
	[self.backButton addTarget:self action:@selector(backButtonReleased:) forControlEvents:UIControlEventTouchUpInside];


	CGRect previewButtonFrame = CGRectMake(backButtonFrame.origin.x + backButtonFrame.size.width,
										   NAV_ICON_OFFSET, middleButtonWidth, navIconSize);
	self.previewLabel = [self getLabelWithParentFrame:previewButtonFrame andText:@"PREVIEW"];
	self.previewButton = [self getButtonWithFrame: previewButtonFrame];
	[self.previewButton addTarget:self action:@selector(previewButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
	[self.previewButton addSubview:self.previewLabel];
	[self enablePreviewInMenuMode: NO];

	CGRect switchModeButtonFrame = CGRectMake(previewButtonFrame.origin.x + previewButtonFrame.size.width,
											  NAV_ICON_OFFSET, middleButtonWidth, navIconSize);
	self.switchModeButton = [self getButtonWithFrame: switchModeButtonFrame];
	[self.switchModeButton addTarget:self action:@selector(switchModeButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
	self.pullDownImage = [UIImage imageNamed: PULLDOWN_ICON];
	self.cameraImage = [UIImage imageNamed: CAMERA_BUTTON_ICON];

	CGRect galleryButtonFrame = CGRectMake(self.frame.size.width - navIconSize - NAV_ICON_OFFSET,
										 NAV_ICON_OFFSET, navIconSize, navIconSize);
	self.galleryButton = [self getButtonWithFrame:galleryButtonFrame];
	[self.galleryButton addTarget:self action:@selector(galleryButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
	self.galleryImage = [UIImage imageNamed:GALLERY_BUTTON_ICON];
	self.galleryImageGrayedOut = [UIEffects imageOverlayed:self.galleryImage withColor:[UIColor lightGrayColor]];
}


-(UILabel*) getLabelWithParentFrame: (CGRect) parentFrame andText:(NSString*) text {
	UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(0.f, 0.f,
																parentFrame.size.width, parentFrame.size.height)];
	label.text = text;
	label.font = [UIFont fontWithName:PREVIEW_BUTTON_FONT size:PREVIEW_BUTTON_FONT_SIZE];
	label.textAlignment = NSTextAlignmentCenter;
	return label;
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
	[self enableGallery: YES];
	if (self.previewEnabledInMenuMode) {
		[self enablePreview: YES];
	}
}

-(void)switchToPullDown {
	self.mode = PullBarModePullDown;
	[self.switchModeButton setImage:self.pullDownImage forState: UIControlStateNormal];
	[self enableGallery: NO];
	[self enablePreview: NO];
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

# pragma mark - Enable and unEnable Buttons

// (Preview is always unenabled in pull down mode)

-(void) enablePreviewInMenuMode: (BOOL) enable {
	self.previewEnabledInMenuMode = enable;
	if (self.mode == PullBarModeMenu) {
		[self enablePreview: enable];
	}
}

-(void) enablePreview: (BOOL) enable {
	if (enable) {
		[self.previewLabel setTextColor: [UIColor blackColor]];
	} else {
		[self.previewLabel setTextColor: [UIColor lightGrayColor]];
	}
	[self.previewButton setEnabled: enable];
}

-(void) enableGallery: (BOOL) enable {
	if (enable) {
		[self.galleryButton setImage:self.galleryImage forState: UIControlStateNormal];
	} else {
		[self.galleryButton setImage:self.galleryImageGrayedOut forState: UIControlStateNormal];
	}
	[self.galleryButton setEnabled: enable];
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

- (void) switchModeButtonReleased:(UIButton *)sender {
	if (!self.delegate) {
		NSLog(@"No content dev pull bar delegate set.");
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

-(void) galleryButtonReleased:(UIButton*) sender {
	if (!self.delegate) {
		NSLog(@"No content dev pull bar delegate set.");
	}
	[self.delegate galleryButtonPressed];
}


@end
