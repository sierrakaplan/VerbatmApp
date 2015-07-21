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
#import "SizesAndPositions.h"

@interface MediaSelectTile ()
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
        [self addButtonsAsSubviews];
        [self setBackgroundColor:[UIColor clearColor]];

		UIImage *textButtonImage = [UIImage imageNamed:TEXT_BUTTON];
		UIImage *photoButtonImage = [UIImage imageNamed:PHOTO_BUTTON];
		UIImage *grayedOutIconText = [UIEffects imageOverlayed:textButtonImage withColor:[UIColor lightGrayColor]];
		UIImage *grayedOutIconImage = [UIEffects imageOverlayed:photoButtonImage withColor:[UIColor lightGrayColor]];

		[self.selectMedia setImage:grayedOutIconImage forState: UIControlStateNormal];
		[self.selectText setImage:grayedOutIconText forState: UIControlStateNormal];

        [self.selectText setImage:textButtonImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.selectMedia setImage:photoButtonImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    return self;
    self.optionSelected = NO;
}

-(void) createFramesForButtonsWithFrame: (CGRect) frame
{
    self.selectMedia.frame = CGRectMake(ADD_MEDIA_BUTTON_OFFSET, ADD_MEDIA_BUTTON_OFFSET, frame.size.width/2, frame.size.height-ADD_MEDIA_BUTTON_OFFSET*2);
    self.selectText.frame = CGRectMake(frame.size.width/2, ADD_MEDIA_BUTTON_OFFSET, frame.size.width/2-ADD_MEDIA_BUTTON_OFFSET, frame.size.height-ADD_MEDIA_BUTTON_OFFSET*2);
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
