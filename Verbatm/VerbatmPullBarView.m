//
//  customPullBarView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VerbatmPullBarView.h"
#import "EditContentView.h"
#import "UIEffects.h"
#import "Notifications.h"
#import "Icons.h"
#import "SizesAndPositions.h"

@interface VerbatmPullBarView ()
@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *undoButton;
@property (strong, nonatomic) UIButton *pullUpButton;
@property (strong, nonatomic) UIImageView *pullDownIcon;

@property (strong, nonatomic) UIImage *undoButtonGrayedOut;
@property (strong, nonatomic) UIImage *previewButtonGrayedOut;
@property (strong, nonatomic) UIImage *undoButtonImage;
@property (strong, nonatomic) UIImage *previewButtonImage;

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
	float buttonSize = PULLBAR_HEIGHT_MENU_MODE - (2.f * PULLBAR_BUTTON_YOFFSET);
	float previewButtonWidth = buttonSize*1.5;

	self.undoButtonImage = [UIImage imageNamed:UNDO_BUTTON_IMAGE];
	self.undoButtonGrayedOut = [UIEffects imageOverlayed:self.undoButtonImage withColor:[UIColor darkGrayColor]];
	self.previewButtonImage = [UIImage imageNamed:PREVIEW_BUTTON_IMAGE];
	self.previewButtonGrayedOut = [UIEffects imageOverlayed:self.previewButtonImage withColor:[UIColor darkGrayColor]];

	CGRect pullDownIconFrame = CGRectMake(centerPoint-PULLBAR_PULLDOWN_ICON_WIDTH/2.f, 0, PULLBAR_PULLDOWN_ICON_WIDTH, PULLBAR_HEIGHT_PULLDOWN_MODE);
	self.pullDownIcon = [[UIImageView alloc] initWithFrame:pullDownIconFrame];
	[self.pullDownIcon setImage:[UIImage imageNamed:PULLDOWN_ICON_IMAGE]];

	CGRect undoButtonFrame = CGRectMake(PULLBAR_BUTTON_XOFFSET, PULLBAR_BUTTON_YOFFSET, buttonSize, buttonSize);
	self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.undoButton setFrame:undoButtonFrame];
	[self.undoButton setImage:self.undoButtonGrayedOut forState:UIControlStateNormal];
	[self.undoButton setImage:[UIImage imageNamed:UNDO_BUTTON_CLICKED] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.undoButton addTarget:self action:@selector(undoButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//	[self.undoButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchDown];

	CGRect pullUpButtonFrame = CGRectMake(centerPoint-buttonSize/2.f, PULLBAR_BUTTON_YOFFSET, buttonSize, buttonSize);
	self.pullUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.pullUpButton setFrame:pullUpButtonFrame];
	[self.pullUpButton setImage:[UIImage imageNamed:PULLUP_BUTTON_IMAGE] forState:UIControlStateNormal];
	[self.pullUpButton setImage:[UIImage imageNamed:PULLUP_BUTTON_CLICKED] forState:UIControlStateHighlighted | UIControlStateSelected];
	[self.pullUpButton addTarget:self action:@selector(pullUpButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//	[self.pullUpButton addTarget:self action:@selector(pullUpButtonPressed:) forControlEvents:UIControlEventTouchDown];

	CGRect previewButtonFrame = CGRectMake(self.frame.size.width - previewButtonWidth - PULLBAR_BUTTON_XOFFSET, PULLBAR_BUTTON_YOFFSET, previewButtonWidth, buttonSize);
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
