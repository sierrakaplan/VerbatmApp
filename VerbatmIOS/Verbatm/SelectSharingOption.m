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
#define WALL_OFFSET_Y 20.f

#define IMAGE_TEXT_SPACING 20.f
#define MAX_BAR_NUMBER 3.f //number of bars visible before scrolling
#define BAR_HEIGHT_TOGGLE 25.f //constant that we reduce the bar height by for aesthetics
#define BAR_HEIGHT ((self.frame.size.height/MAX_BAR_NUMBER)-BAR_HEIGHT_TOGGLE)
#define SELECTION_BUTTON_WIDTH 20.f

#define TEXT_LABEL_SIZE 100.f

#define VERBATM_REBLOG_TEXT @"Verbatm (Reblog)"
#define TWITTER_SHARE_TEXT @"Twitter"
#define FACEBOOK_SHARE_TEXT @"Facebook"
#define SMS_SHARE_TEXT @"Sms Link"
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

-(void)presentSelectionOptions {

    //Facebook BAR -- center
    CGRect fb_barFrame = CGRectMake(0.f, self.frame.size.height/2.f -
                                    (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT/2);
    UIView * facebookBar = [self createBarWithFrame:fb_barFrame logo:[UIImage imageNamed:FACEBOOK_LOGO] andTitle:FACEBOOK_SHARE_TEXT];
    [self addSubview:facebookBar];

	//VERBATM BAR -- top
	CGFloat  remainingTopHeight = fb_barFrame.origin.y;
	CGRect barFrame = CGRectMake(0.f, (remainingTopHeight/2.f) -
								 (BAR_HEIGHT/6), self.frame.size.width, BAR_HEIGHT/2);
	UIView * verbatmBar = [self createBarWithFrame:barFrame logo:[UIImage imageNamed:VERBATM_LOGO] andTitle:VERBATM_REBLOG_TEXT];
	[self addSubview:verbatmBar];
    
	//Twitter BAR
    CGRect tw_barFrame = CGRectMake(0.f, facebookBar.frame.origin.y +
                                    facebookBar.frame.size.height +
                                    (remainingTopHeight/2.f) - (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT/2);
    UIView * twitterBar = [self createBarWithFrame:tw_barFrame logo:[UIImage imageNamed:TWITTER_LOGO] andTitle:TWITTER_SHARE_TEXT];
    [self addSubview:twitterBar];
    
    
	//SMS BAR
    CGRect sms_barFrame = CGRectMake(0.f, twitterBar.frame.origin.y +
                                    twitterBar.frame.size.height +
                                    (remainingTopHeight/2.f) - (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT/2);
    UIView * smsBar = [self createBarWithFrame:sms_barFrame logo:[UIImage imageNamed:SMS_ICON] andTitle:SMS_SHARE_TEXT];
    [self addSubview:smsBar];
    
    
	// COPY LINK BAR
    CGRect copyLink_barFrame = CGRectMake(0.f, smsBar.frame.origin.y +
                                    smsBar.frame.size.height +
                                    (remainingTopHeight/2.f) - (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT/2);
    UIView * copyLinkBar = [self createBarWithFrame:copyLink_barFrame logo:[UIImage imageNamed:COPY_LINK_ICON] andTitle:COPY_LINK_TEXT];
    [self addSubview:copyLinkBar];
    
    
    
    self.contentSize = CGSizeMake(0.f, copyLink_barFrame.origin.y +
                                  copyLink_barFrame.size.height + 30.f);
}


-(SelectionView *) createBarWithFrame: (CGRect) frame logo:(UIImage *) logoImage andTitle:(NSString *) title{
    
    SelectionView * ourBar = [[SelectionView alloc] initWithFrame:frame];
    
    CGFloat imageHeight = frame.size.height;
    CGRect viewFrame = CGRectMake(WALL_OFFSET_X, 0.f, imageHeight, imageHeight);
    UIImageView * verbatmView = [[UIImageView alloc] initWithFrame:viewFrame];
    UIImage * logo = logoImage;
    [verbatmView setImage:logo];
    
    CGRect labelFrame = CGRectMake(viewFrame.origin.x + viewFrame.size.width +
                                          IMAGE_TEXT_SPACING, 0.f, imageHeight+ TEXT_LABEL_SIZE, imageHeight);
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [nameLabel setAttributedText:[self getButtonAttributeStringWithText:title]];
    
    CGRect buttonFrame = CGRectMake(frame.size.width - WALL_OFFSET_X *2,
                                    (imageHeight/2.f) - (SELECTION_BUTTON_WIDTH/2.f),
                                    SELECTION_BUTTON_WIDTH, SELECTION_BUTTON_WIDTH);
    
    SelectOptionButton * selectionButton = [[SelectOptionButton alloc] initWithFrame:buttonFrame];
    
    if([title isEqualToString:VERBATM_REBLOG_TEXT]){
        selectionButton.buttonSharingOption = Verbatm;
        
    }else if ([title isEqualToString:FACEBOOK_SHARE_TEXT]){
        selectionButton.buttonSharingOption = Facebook;
    }
    else if ([title isEqualToString:TWITTER_SHARE_TEXT]){
        selectionButton.buttonSharingOption = TwitterShare;
    }
    else if ([title isEqualToString:SMS_SHARE_TEXT]){
        selectionButton.buttonSharingOption = Sms;
    }
    else if ([title isEqualToString:COPY_LINK_TEXT]){
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
    if([selectionButton buttonSelected]){//if it's already selected then remove it
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
