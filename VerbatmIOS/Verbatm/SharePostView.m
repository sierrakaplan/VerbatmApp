//
//  SharePostView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "SharePostView.h"
#import "SelectSharingOption.h"
#import "SelectChannel.h"
#import "Styles.h"
#import "UIImage+ImageEffectsAndTransforms.h"
#define SHARE_BUTTON_HEIGHT CANCEL_BUTTON_HEIGHT - 10.f
#define CANCEL_BUTTON_HEIGHT 40.f

#define BUTTON_WALL_OFFSET_X  10.f
#define ANIMATION_DURATION 0.5

@interface SharePostView () <SelectSharingOptionProtocol, UITextFieldDelegate>

@property (nonatomic) SelectSharingOption *sharingOption;
@property (nonatomic) UIButton * shareButton;
@property (nonatomic) UIButton * cancelButton;

@property (nonatomic) BOOL facebookSelected;
@property (nonatomic) BOOL verbatmSelected;

@end


@implementation SharePostView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self formatView];
		self.facebookSelected = NO;
        self.verbatmSelected = NO;
		[self createSelections];
	}
	return self;
}

-(void)formatView{
	self.backgroundColor = REPOST_VIEW_BACKGROUND_COLOR;
}

-(void)createSelections{

	self.sharingOption = [[SelectSharingOption alloc] initWithFrame: CGRectMake(0.f, SHARE_BUTTON_HEIGHT,
																				self.frame.size.width, self.frame.size.height- (SHARE_BUTTON_HEIGHT * 2.f))];
	[self addSubview:self.sharingOption];
	self.sharingOption.sharingDelegate = self;

	[self createShareButton];
	[self createCancelButton];
}

-(void)createShareButton {

	//create share button
	CGRect shareButtonFrame = CGRectMake(BUTTON_WALL_OFFSET_X, SHARE_BUTTON_HEIGHT + self.frame.size.height - (SHARE_BUTTON_HEIGHT * 2.f),
										 self.frame.size.width - (BUTTON_WALL_OFFSET_X * 2),SHARE_BUTTON_HEIGHT );

	self.shareButton =  [[UIButton alloc] initWithFrame:shareButtonFrame];
	[self.shareButton setAttributedTitle:[self getButtonAttributeStringWithText:@"REBLOG" andColor:[UIColor whiteColor]] forState:UIControlStateNormal];
	[self.shareButton setAttributedTitle:[self getButtonAttributeStringWithText:@"REBLOG" andColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
	[self.shareButton setBackgroundImage:[UIImage makeImageWithColorAndSize:[UIColor whiteColor] andSize:shareButtonFrame.size]
								forState:UIControlStateHighlighted];

	self.shareButton.layer.cornerRadius = 4.f;
	self.shareButton.clipsToBounds = YES;
	self.shareButton.layer.borderWidth = 1.f;
	self.shareButton.layer.borderColor = [UIColor whiteColor].CGColor;

	[self.shareButton addTarget:self action:@selector(shareButtonSelected) forControlEvents:UIControlEventTouchDown];
	[self addSubview:self.shareButton];
    [self bringSubviewToFront:self.shareButton];

}

-(NSAttributedString *)getButtonAttributeStringWithText:(NSString *)text andColor:(UIColor *)color{
	return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:REPOST_BUTTON_TEXT_FONT_SIZE]}];
}

-(void) createCancelButton {
	CGRect cancelButtonFrame = CGRectMake(0.f, 0.f, self.frame.size.width, SHARE_BUTTON_HEIGHT);
	self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
	[self.cancelButton  setAttributedTitle:[self getButtonAttributeStringWithText:@"CANCEL" andColor:[UIColor whiteColor]] forState:UIControlStateNormal];
	[self.cancelButton  setAttributedTitle:[self getButtonAttributeStringWithText:@"CANCEL" andColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
	[self.cancelButton setBackgroundImage:[UIImage makeImageWithColorAndSize:[UIColor whiteColor] andSize:cancelButtonFrame.size]
								forState:UIControlStateHighlighted];
	self.cancelButton.backgroundColor = [UIColor clearColor];

	self.cancelButton.layer.cornerRadius = 1.f;
	self.cancelButton.clipsToBounds = YES;
	self.cancelButton.layer.borderWidth = 1.f;
	self.cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
	[self.cancelButton addTarget:self action:@selector(cancelButtonSelected) forControlEvents:UIControlEventTouchDown];
	[self addSubview:self.cancelButton];
}

-(void) cancelButtonSelected {
    [self.delegate cancelButtonSelected];
}

-(void)shareButtonSelected {
	[self.delegate reblogToVerbatm:self.verbatmSelected andFacebook:self.facebookSelected];
}

#pragma mark Share options protocol

-(void)shareOptionSelected:(ShareOptions) shareOption{
	if(shareOption == Verbatm){
		self.verbatmSelected = YES;
	}
    if (shareOption == Facebook){
		self.facebookSelected = YES;
	}
}

-(void) shareOptionDeselected:(ShareOptions)shareOption {
	if(shareOption == Verbatm){
		self.verbatmSelected = NO;
	}
	if (shareOption == Facebook){
		self.facebookSelected = NO;
	}
}

@end
