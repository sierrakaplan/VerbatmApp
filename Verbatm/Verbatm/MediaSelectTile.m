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

@interface MediaSelectTile ()
    @property(nonatomic ,strong) UIButton * selectMedia;
    @property (nonatomic ,strong) UIButton * selectText;
@property (nonatomic, strong) DashLineView * dashedView;
    @property (nonatomic, strong) CAShapeLayer * border;
@property (readwrite, nonatomic) BOOL optionSelected;

#define BUTTON_OFFSET 5
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
        [self.selectText setImage:textButtonImage forState: UIControlStateNormal];
        [self.selectMedia setImage:photoButtonImage forState: UIControlStateNormal];
        
        UIImage *highlightedIconText = [UIEffects imageOverlayed:textButtonImage withColor:[UIColor whiteColor]];
        UIImage *highlightedIconImage = [UIEffects imageOverlayed:photoButtonImage withColor:[UIColor whiteColor]];
        [self.selectText setImage:highlightedIconText forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.selectMedia setImage:highlightedIconImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    return self;
    self.optionSelected = NO;
}

//Iain
-(void) createFramesForButtonsWithFrame: (CGRect) frame
{
    self.selectText.frame = CGRectMake(BUTTON_OFFSET, BUTTON_OFFSET, frame.size.width/2, frame.size.height-BUTTON_OFFSET*2);
    self.selectMedia.frame = CGRectMake(frame.size.width/2, BUTTON_OFFSET, frame.size.width/2-BUTTON_OFFSET, frame.size.height-BUTTON_OFFSET*2);
}
//Iain
-(void)addButtonsAsSubviews
{
    [self addSubview:self.selectText];
    [self addSubview:self.selectMedia];
}

-(void) addText {
    self.optionSelected =YES;
    [self.delegate addTextViewButtonPressedAsBaseView:self.baseSelector];
//	[self sendAddedMediaNotification];
}

-(void) addMedia {
    self.optionSelected = YES;
    [self addDashedBorder];
    [self.delegate addMultiMediaButtonPressedAsBaseView:self.baseSelector fromView: self];
//	[self sendAddedMediaNotification];
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
        [_selectMedia addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectMedia;
}


-(UIButton *) selectText
{

    if(!_selectText) _selectText = [[UIButton alloc]init];
    [_selectText addTarget:self action:@selector(addMedia) forControlEvents:UIControlEventTouchUpInside];
//    [_selectText addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];

    return _selectText;
}

-(void)addDashedBorder
{
    self.dashed = YES;
    self.dashedView = [[DashLineView alloc]initWithFrame:self.bounds];
    [self.selectText removeFromSuperview];
    [self.selectMedia removeFromSuperview];
    [self.dashedView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.dashedView];
    
}

//get rid of the dashed lines and return the options
-(void) returnToButtonView
{
    [self.dashedView removeFromSuperview];
    [self addSubview:self.selectMedia];
    [self addSubview:self.selectText];
    self.dashed = NO;
    
}



@end
