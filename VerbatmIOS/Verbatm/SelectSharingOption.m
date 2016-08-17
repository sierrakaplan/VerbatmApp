//
//  SelectSharingOption.m
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "SelectionView.h"
#import "Styles.h"
#import "SelectSharingOption.h"
#import "SelectOptionButton.h"
#import "SizesAndPositions.h"

#define WALL_OFFSET_X 30.f
#define OPTIONS_OFFSET 20.f

#define BAR_HEIGHT 50.f
#define SELECTION_BUTTON_WIDTH 20.f
#define IMAGE_TEXT_SPACING 20.f
#define TEXT_LABEL_SIZE 100.f

#define VERBATM_REBLOG_TEXT @"Reblog to Verbatm"
#define SMS_SHARE_TEXT @"Send Via Text"
#define FACEBOOK_SHARE_TEXT @"Facebook"
#define TWITTER_SHARE_TEXT @"Twitter"
#define COPY_LINK_TEXT @"Copy Link"

@interface SelectSharingOption ()

@property (nonatomic) SelectOptionButton * selectedButton;

@end

@implementation SelectSharingOption


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self presentSelectionOptions];
    }
    return self;
}

/*
 1. Reblog to Verbatm
 2. Send via text
 3. Facebook
 4. Twitter
 5. Copy link
 */
-(void)presentSelectionOptions {

	CGRect verbatmFrame = CGRectMake(0.f, OPTIONS_OFFSET, self.frame.size.width, BAR_HEIGHT);
	UIView *verbatmBar = [self createBarWithFrame:verbatmFrame logo:[UIImage imageNamed:VERBATM_LOGO]
										 andTitle:VERBATM_REBLOG_TEXT];
	[self addSubview: verbatmBar];

	//SMS BAR
	CGRect smsFrame = CGRectMake(0.f, verbatmFrame.origin.y + verbatmFrame.size.height + OPTIONS_OFFSET,
								 self.frame.size.width, BAR_HEIGHT);
	UIView *smsBar = [self createBarWithFrame:smsFrame logo:[UIImage imageNamed:SMS_ICON] andTitle:SMS_SHARE_TEXT];
	[self addSubview:smsBar];

    //Facebook BAR
    CGRect fbFrame = CGRectMake(0.f, smsFrame.origin.y + smsFrame.size.height + OPTIONS_OFFSET,
								self.frame.size.width, BAR_HEIGHT);
    UIView *facebookBar = [self createBarWithFrame:fbFrame logo:[UIImage imageNamed:FACEBOOK_LOGO]
										  andTitle:FACEBOOK_SHARE_TEXT];
    [self addSubview:facebookBar];

	//Twitter BAR
	CGRect twitterFrame = CGRectMake(0.f, fbFrame.origin.y + fbFrame.size.height + OPTIONS_OFFSET,
									 self.frame.size.width, BAR_HEIGHT);
    UIView *twitterBar = [self createBarWithFrame:twitterFrame logo:[UIImage imageNamed:TWITTER_LOGO]
										 andTitle:TWITTER_SHARE_TEXT];
    [self addSubview:twitterBar];
    
	// COPY LINK BAR
	CGRect copyLinkFrame = CGRectMake(0.f, twitterFrame.origin.y + twitterFrame.size.height + OPTIONS_OFFSET,
									  self.frame.size.width, BAR_HEIGHT);
    UIView *copyLinkBar = [self createBarWithFrame:copyLinkFrame logo:[UIImage imageNamed:COPY_LINK_ICON]
										  andTitle:COPY_LINK_TEXT];
    [self addSubview:copyLinkBar];
    
    self.contentSize = CGSizeMake(0.f, copyLinkFrame.origin.y +
                                  copyLinkFrame.size.height + OPTIONS_OFFSET);
}


-(SelectionView *) createBarWithFrame: (CGRect) frame logo:(UIImage *) logoImage andTitle:(NSString *) title{
    
    SelectionView * ourBar = [[SelectionView alloc] initWithFrame:frame];
    
    CGFloat imageHeight = frame.size.height;
    CGRect viewFrame = CGRectMake(WALL_OFFSET_X, 0.f, imageHeight, imageHeight);
    UIImageView * verbatmView = [[UIImageView alloc] initWithFrame:viewFrame];
    UIImage * logo = logoImage;
    [verbatmView setImage:logo];
    
    CGRect labelFrame = CGRectMake(viewFrame.origin.x + viewFrame.size.width +
                                          IMAGE_TEXT_SPACING, 0.f, imageHeight + TEXT_LABEL_SIZE, imageHeight);
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [nameLabel setAttributedText:[self getButtonAttributeStringWithText:title]];
    
    CGRect buttonFrame = CGRectMake(frame.size.width - WALL_OFFSET_X *2,
                                    (imageHeight/2.f) - (SELECTION_BUTTON_WIDTH/2.f),
                                    SELECTION_BUTTON_WIDTH, SELECTION_BUTTON_WIDTH);
    
    SelectOptionButton * selectionButton = [[SelectOptionButton alloc] initWithFrame:buttonFrame];
    
    if([title isEqualToString:VERBATM_REBLOG_TEXT]){
        selectionButton.buttonSharingOption = Verbatm;
    } else if ([title isEqualToString:SMS_SHARE_TEXT]){
		selectionButton.buttonSharingOption = Sms;
	} else if ([title isEqualToString:FACEBOOK_SHARE_TEXT]){
        selectionButton.buttonSharingOption = Facebook;
	} else if ([title isEqualToString:TWITTER_SHARE_TEXT]){
        selectionButton.buttonSharingOption = TwitterShare;
    } else if ([title isEqualToString:COPY_LINK_TEXT]){
        selectionButton.buttonSharingOption = CopyLink;
    }

    [selectionButton addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    ourBar.shareOptionButton = selectionButton;
    
    [ourBar addSubview:verbatmView];
    [ourBar addSubview:nameLabel];
    [ourBar addSubview:selectionButton];
    [self addTapGestureToView:ourBar];
    
    return ourBar;
}

-(NSAttributedString *)getButtonAttributeStringWithText:(NSString *)text{
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
																		NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:REPOST_BUTTON_TEXT_FONT_SIZE]}];
}

-(void)unselectAllOptions{
    [self.selectedButton setButtonSelected:NO];
}

-(void)addTapGestureToView:(UIView *) tapView{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionSelectionMade:)];
    [tapView addGestureRecognizer:tap];
}


-(void)optionSelectionMade:(UITapGestureRecognizer *) gesture {
    SelectionView * selectedView = (SelectionView *) gesture.view;
    [self optionSelected:selectedView.shareOptionButton];
}

-(void) optionSelected:(UIButton *)sender {
    SelectOptionButton * selectionButton = (SelectOptionButton *)sender;
    if([selectionButton buttonSelected]) {
        [selectionButton setButtonSelected:NO];
        [self.sharingDelegate shareOptionDeselected:selectionButton.buttonSharingOption];
        self.selectedButton = nil;
    } else {
		[selectionButton setButtonSelected:YES];
        [self.sharingDelegate shareOptionSelected:selectionButton.buttonSharingOption];
        
        self.selectedButton = selectionButton;
    }
}

@end
