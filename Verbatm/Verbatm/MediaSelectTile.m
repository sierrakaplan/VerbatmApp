//
//  verbatmCustomMediaSelectTile.m
//  Verbatm
//
//  Created by Iain Usiri on 9/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "MediaSelectTile.h"
#import "DashLineView.h"
#import "UIEffects.h"
#import "Notifications.h"
#import "Icons.h"
#import "Styles.h"
#import "Durations.h"
#import "SizesAndPositions.h"
#import "ContentDevVC.h"

@interface MediaSelectTile () <ContentDevElementDelegate>
    @property(nonatomic ,strong) UIButton * selectMedia;
    @property (nonatomic ,strong) UIButton * selectText;
    @property (nonatomic, strong) CAShapeLayer * border;
@property (readwrite, nonatomic) BOOL optionSelected;

@end

@implementation MediaSelectTile

#pragma mark - initialize view
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createFramesForButtonsWithFrame: frame];
		[self createImagesForButtons];
        [self addButtonsAsSubviews];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
    self.optionSelected = NO;
}

-(void) createFramesForButtonsWithFrame: (CGRect) frame {
	float buttonOffset = frame.size.height/10.f;
	float size = frame.size.height-buttonOffset*2;
	float xDifference = frame.size.width/4.f - size/2.f;
    self.selectMedia.frame = CGRectMake(buttonOffset + xDifference, buttonOffset, size, size);
    self.selectText.frame = CGRectMake(frame.size.width/2.f + xDifference, buttonOffset, size, size);
	self.selectMedia.layer.cornerRadius = self.selectMedia.frame.size.width/2;
	self.selectText.layer.cornerRadius = self.selectText.frame.size.width/2;
	self.selectMedia.layer.shadowRadius = buttonOffset;
	self.selectText.layer.shadowRadius = buttonOffset;
}

-(void) createImagesForButtons {
	UIImage *textButtonImage = [UIImage imageNamed:INSERT_TEXT_BUTTON];
	UIImage *photoButtonImage = [UIImage imageNamed:INSERT_MEDIA_BUTTON];
	UIImage *grayedOutIconText = [UIEffects imageOverlayed:textButtonImage withColor:[UIColor lightGrayColor]];
	UIImage *grayedOutIconImage = [UIEffects imageOverlayed:photoButtonImage withColor:[UIColor lightGrayColor]];

	[self.selectText setImage:grayedOutIconText forState:UIControlStateSelected | UIControlStateHighlighted];
	[self.selectMedia setImage:grayedOutIconImage forState:UIControlStateSelected | UIControlStateHighlighted];

	[self.selectMedia setImage:photoButtonImage forState: UIControlStateNormal];
	[self.selectText setImage:textButtonImage forState: UIControlStateNormal];
}

-(void) formatButtons {
	[self.selectText.layer setBackgroundColor:[UIColor clearColor].CGColor];
	[self.selectMedia.layer setBackgroundColor:[UIColor clearColor].CGColor];

	UIColor* buttonBackgroundColor = [UIColor darkGrayColor];

	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{
		self.selectMedia.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.selectText.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.selectMedia.layer.shadowOpacity = 1;
		self.selectText.layer.shadowOpacity = 1;
		[self.selectText.layer setBackgroundColor:buttonBackgroundColor.CGColor];
		[self.selectMedia.layer setBackgroundColor:buttonBackgroundColor.CGColor];
	} completion:^(BOOL finished) {
	}];
}

-(void)addButtonsAsSubviews
{
	[self addSubview:self.selectMedia];
    [self addSubview:self.selectText];
}

-(void) addText {
    self.optionSelected =YES;
	[self.delegate textButtonPressedOnTile:self];
}

-(void) addMedia {
    self.optionSelected = YES;
	[self.delegate multiMediaButtonPressedOnTile:self];
}

-(void) buttonHighlight: (UIButton*) button
{
    [button setBackgroundColor:[UIColor whiteColor]];
}

-(void)markAsSelected: (BOOL) selected {
	if (selected) {
		self.layer.borderColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
		self.layer.borderWidth = 2.0f;
	} else {
		self.layer.borderWidth = 0.f;
	}
}

-(void)markAsDeleting: (BOOL) deleting {
	if (deleting) {
		self.layer.borderColor = [UIColor DELETING_ITEM_COLOR].CGColor;
		self.layer.borderWidth = 2.0f;
	} else {
		self.layer.borderWidth = 0.f;
	}
}


#pragma mark - *Lazy Instantiation
-(UIButton *) selectMedia
{
    if(!_selectMedia)
    {
        _selectMedia = [[UIButton alloc]init];
        [_selectMedia addTarget:self action:@selector(addMedia) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectMedia;
}


-(UIButton *) selectText
{

    if(!_selectText) _selectText = [[UIButton alloc]init];
    [_selectText addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];

    return _selectText;
}



@end
