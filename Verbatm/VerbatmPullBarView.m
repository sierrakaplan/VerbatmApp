//
//  customPullBarView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VerbatmPullBarView.h"
#import "VerbatmImageScrollView.h"
#import "UIEffects.h"
#import "Notifications.h"

@interface VerbatmPullBarView ()
@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *undoButton;
@property (strong, nonatomic) UIButton *pullUpButton;
@property (strong, nonatomic) UIImageView *pullDownIcon;

@property (strong, nonatomic) UIImage *undoButtonGrayedOut;
@property (strong, nonatomic) UIImage *previewButtonGrayedOut;
@property (strong, nonatomic) UIImage *undoButtonImage;
@property (strong, nonatomic) UIImage *previewButtonImage;

# pragma mark Spacing
#define CENTER_BUTTON_GAP 20.f
#define XOFFSET 20.f
#define YOFFSET 15.f

# pragma mark Icons
#define UNDO_BUTTON_IMAGE @"undo_button_icon"
#define UNDO_BUTTON_CLICKED @"undo_button_clicked"
#define PREVIEW_BUTTON_IMAGE @"preview_button_icon"
#define PREVIEW_BUTTON_CLICKED @"preview_button_clicked"
#define PULLUP_BUTTON_IMAGE @"pullup_icon"
#define PULLUP_BUTTON_CLICKED @"pullup_icon_clicked"
#define PULLDOWN_ICON_IMAGE @"pulldown_icon"

@end


@implementation VerbatmPullBarView

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

    //load from Nib file..this initializes the background view and all its subviews
    self = [super initWithFrame:frame];
    if(self)
    {
        self.frame = frame;
        [self createButtons];
		[self switchToPullDown];
		[self registerForNotifications];
    }
    return self;
}

//initialize all buttons, for all modes
-(void)createButtons {

	float centerPoint = self.frame.size.width /2.f;
	float buttonSize = PULLBAR_HEIGHT_MENU_MODE - (2.f * YOFFSET);
	float iconHeight = PULLBAR_HEIGHT_PULLDOWN_MODE;
	float iconWidth = iconHeight * 3.f;

	self.undoButtonImage = [UIImage imageNamed:UNDO_BUTTON_IMAGE];
	self.undoButtonGrayedOut = [UIEffects imageOverlayed:self.undoButtonImage withColor:[UIColor darkGrayColor]];
	self.previewButtonImage = [UIImage imageNamed:PREVIEW_BUTTON_IMAGE];
	self.previewButtonGrayedOut = [UIEffects imageOverlayed:self.previewButtonImage withColor:[UIColor darkGrayColor]];

	CGRect pullDownIconFrame = CGRectMake(centerPoint-iconWidth/2.f, 0, iconWidth, iconHeight);
	self.pullDownIcon = [[UIImageView alloc] initWithFrame:pullDownIconFrame];
	[self.pullDownIcon setImage:[UIImage imageNamed:PULLDOWN_ICON_IMAGE]];

	CGRect undoButtonFrame = CGRectMake(XOFFSET, YOFFSET, buttonSize, buttonSize);
	self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.undoButton setFrame:undoButtonFrame];
	[self.undoButton setImage:self.undoButtonGrayedOut forState:UIControlStateNormal];
	[self.undoButton setImage:[UIImage imageNamed:UNDO_BUTTON_CLICKED] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.undoButton addTarget:self action:@selector(undoButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//	[self.undoButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchDown];

	CGRect pullUpButtonFrame = CGRectMake(centerPoint-buttonSize/2.f, YOFFSET, buttonSize, buttonSize);
	self.pullUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.pullUpButton setFrame:pullUpButtonFrame];
	[self.pullUpButton setImage:[UIImage imageNamed:PULLUP_BUTTON_IMAGE] forState:UIControlStateNormal];
	[self.pullUpButton setImage:[UIImage imageNamed:PULLUP_BUTTON_CLICKED] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.pullUpButton addTarget:self action:@selector(pullUpButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//	[self.pullUpButton addTarget:self action:@selector(pullUpButtonPressed:) forControlEvents:UIControlEventTouchDown];

	CGRect previewButtonFrame = CGRectMake(self.frame.size.width - buttonSize - XOFFSET, YOFFSET, buttonSize, buttonSize);
	self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.previewButton setFrame:previewButtonFrame];
	[self.previewButton setImage:self.previewButtonGrayedOut forState:UIControlStateNormal];
	[self.previewButton setImage:[UIImage imageNamed:PREVIEW_BUTTON_CLICKED] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.previewButton addTarget:self action:@selector(previewButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//	[self.previewButton addTarget:self action:@selector(previewButtonPressed:) forControlEvents:UIControlEventTouchDown];
}

-(void) registerForNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(unGrayOutButtons)
												 name:NOTIFICATION_ADDED_MEDIA
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(grayOutButtons)
												 name:NOTIFICATION_REMOVED_ALL_MEDIA
											   object:nil];
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

	[self addSubview:self.undoButton];
	[self addSubview:self.pullUpButton];
	[self addSubview:self.previewButton];
}

-(void)switchToPullDown {
	self.mode = PullBarModePullDown;

	[self.undoButton removeFromSuperview];
	[self.pullUpButton removeFromSuperview];
	[self.previewButton removeFromSuperview];

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

-(void) grayOutButtons {
	[self.undoButton setImage:self.undoButtonGrayedOut forState:UIControlStateNormal];
	[self.previewButton setImage:self.previewButtonGrayedOut forState:UIControlStateNormal];
}

-(void) unGrayOutButtons {
	[self.undoButton setImage:self.undoButtonImage forState:UIControlStateNormal];
	[self.previewButton setImage:self.previewButtonImage forState:UIControlStateNormal];
}


# pragma mark - Button actions on touch up (send message to delegates)

- (IBAction)undoButtonReleased:(UIButton *)sender
{
	[self.delegate undoButtonPressed];
}

- (IBAction)previewButtonReleased:(UIButton *)sender
{
    [self.delegate previewButtonPressed];
    
}

- (IBAction)pullUpButtonReleased:(UIButton *)sender
{
	[self.delegate pullUpButtonPressed];

}

# pragma mark Button actions on touch down -- NOT IN USE --

- (IBAction)undoButtonPressed:(UIButton *)sender {
	[self.undoButton setImage:[UIImage imageNamed:UNDO_BUTTON_CLICKED] forState:UIControlStateNormal];
}


- (IBAction)pullUpButtonPressed:(UIButton *)sender {
	[self.pullUpButton setImage:[UIImage imageNamed:PULLUP_BUTTON_CLICKED] forState:UIControlStateNormal];
}

- (IBAction)previewButtonPressed:(UIButton *)sender {
	[self.previewButton setImage:[UIImage imageNamed:PREVIEW_BUTTON_CLICKED] forState:UIControlStateNormal];
}


@end
