
//
//  SelectChannel.m
//  Verbatm
//
//  Created by Iain Usiri on 1/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "Channel.h"
#import "Channel_BackendObject.h"
#import <Parse/PFUser.h>
#import "SelectChannel.h"
#import "SelectOptionButton.h"
#import "SelectionView.h"
#import "Styles.h"
#import "UserInfoCache.h"
#import "Icons.h"

#define CHANNEL_LABEL_HEIGHT 70
#define WALL_OFFSET_X 30.f
#define WALL_OFFSET_Y 20.f

#define IMAGE_TEXT_SPACING 20.f
#define SELECTION_BUTTON_WIDTH 20.f

#define SCROLL_BUFFER 10.f //small buffer added to content size so there's room at the bottom

@interface SelectChannel ()

@property (nonatomic) NSMutableArray * selectedChannels;

@property (nonatomic) SelectOptionButton * selectedButton;
@property (nonatomic) BOOL canSelectMultipleChannels;
@property (nonatomic) BOOL facebookSelected;
@property (nonatomic) BOOL source;


@end

@implementation SelectChannel
-(instancetype) initWithFrame:(CGRect)frame canSelectMultiple:(BOOL) selectMultiple{
    
    self = [super initWithFrame:frame];
    self.facebookSelected = NO;
    self.source = NO;
    
    if(self){
        self.canSelectMultipleChannels = selectMultiple;
//        [self createChannelLabels:[[UserInfoCache sharedInstance] getUserChannels]];

    }
    
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame canSelectMultiple:(BOOL) selectMultiple source:(BOOL) source {
    
    self = [super initWithFrame:frame];
    self.facebookSelected = NO;
    self.source = source;
    if(self){
        self.canSelectMultipleChannels = selectMultiple;
        [self createChannelLabel:[[UserInfoCache sharedInstance] getUserChannel]];
        
    }
    
    return self;
}


-(void)formatView{
    self.scrollEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
}

//todo: get rid of this sharing option
- (void) createChannelLabel:(Channel *) channel {
    [self createFacebookLabel];
    
    CGFloat startingYCord =CHANNEL_LABEL_HEIGHT;
	CGRect labelFrame = CGRectMake(0.f, startingYCord, self.frame.size.width, CHANNEL_LABEL_HEIGHT);
	UIView  * channelLabel = [self getChannelLabelWithFrame:labelFrame andChannel:channel];
	[self addSubview:channelLabel];
	startingYCord += CHANNEL_LABEL_HEIGHT;

    CGSize newContentSize = CGSizeMake(0, startingYCord + CHANNEL_LABEL_HEIGHT + SCROLL_BUFFER);
    self.contentSize = newContentSize;
}

-(void) createFacebookLabel {
    CGRect labelFrame = CGRectMake(0.f, 0.f, self.frame.size.width, CHANNEL_LABEL_HEIGHT);
    
    SelectionView * selectionBar = [[SelectionView alloc] initWithFrame:labelFrame];
    
    CGFloat xCord = labelFrame.size.width - WALL_OFFSET_X - SELECTION_BUTTON_WIDTH;
    CGFloat yCord =(labelFrame.size.height/2.f) - (SELECTION_BUTTON_WIDTH/2.f);
    
    CGRect buttonFrame = CGRectMake( xCord, yCord,
                                    SELECTION_BUTTON_WIDTH, SELECTION_BUTTON_WIDTH);
    
    SelectOptionButton * selectOption = [[SelectOptionButton alloc] initWithFrame:buttonFrame];
    

    [selectOption addTarget:self action:@selector(facebookSelected:) forControlEvents:UIControlEventTouchUpInside];
 
    CGFloat imageHeight = CHANNEL_LABEL_HEIGHT * 0.5;
    CGRect viewFrame = CGRectMake(WALL_OFFSET_X, 15.f, imageHeight, imageHeight);
    UIImageView * facebookView = [[UIImageView alloc] initWithFrame:viewFrame];
    UIImage * logo = [UIImage imageNamed:FACEBOOK_LOGO];
    [facebookView setImage:logo];
    
    CGRect fbLabelFrame = CGRectMake(WALL_OFFSET_X + imageHeight + 10.f, 0.f, xCord , labelFrame.size.height);
    UILabel * newLabel = [[UILabel alloc] initWithFrame:fbLabelFrame];
    [newLabel setAttributedText:[self getButtonAttributeStringWithText:@""]];
    
    selectionBar.shareOptionButton = selectOption;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookBarSelected:)];
    [selectionBar addGestureRecognizer:tap];
    
    [selectionBar addSubview:selectOption];
    [selectionBar addSubview:newLabel];
    [selectionBar addSubview:facebookView];
    [self addSubview:selectionBar];

}

-(void) facebookSelected:(UIButton *) button{
     SelectOptionButton * selectionButton = (SelectOptionButton *)button;
    if([selectionButton buttonSelected]){
        [selectionButton setButtonSelected:NO];
        self.facebookSelected = NO;
    }else{
        [selectionButton setButtonSelected:YES];
        self.facebookSelected = YES;
    }
    
    [self.selectChannelDelegate facebookSelected:self.facebookSelected];
}

-(void)facebookBarSelected:(UITapGestureRecognizer *) gesture {
    SelectionView * selectedView = (SelectionView *) gesture.view;
    [self facebookSelected:selectedView.shareOptionButton];
    
}


-(UIView *) getChannelLabelWithFrame:(CGRect) frame andChannel:(Channel *) channel{
    
    SelectionView * selectionBar = [[SelectionView alloc] initWithFrame:frame];
    
    CGFloat xCord = frame.size.width - WALL_OFFSET_X - SELECTION_BUTTON_WIDTH;
    CGFloat yCord =(frame.size.height/2.f) - (SELECTION_BUTTON_WIDTH/2.f);
    
    CGRect buttonFrame = CGRectMake( xCord, yCord,
                                    SELECTION_BUTTON_WIDTH, SELECTION_BUTTON_WIDTH);
    
    SelectOptionButton * selectOption = [[SelectOptionButton alloc] initWithFrame:buttonFrame];
    selectOption.associatedObject = channel;
    [selectOption addTarget:self action:@selector(channelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSString * channelName = channel.name;
    CGRect labelFrame = CGRectMake(WALL_OFFSET_X, 0.f, xCord , frame.size.height);
    UILabel * newLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [newLabel setAttributedText:[self getButtonAttributeStringWithText:channelName]];
    
    selectionBar.shareOptionButton = selectOption;

    [selectionBar addSubview:selectOption];
    [selectionBar addSubview:newLabel];
    
    [self addTapGestureToView:selectionBar];
    
    return selectionBar;
}
-(NSAttributedString *)getButtonAttributeStringWithText:(NSString *)text{
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:REPOST_BUTTON_TEXT_FONT_SIZE]}];
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
    [self channelButtonSelected:selectedView.shareOptionButton];
}

-(void)channelButtonSelected:(UIButton *) button {
    SelectOptionButton * selectionButton = (SelectOptionButton *)button;
    if(self.canSelectMultipleChannels) {
        if([selectionButton buttonSelected]){//if it's already selected then remove it
            [selectionButton setButtonSelected:NO];
            [self.selectedChannels removeObject:selectionButton.associatedObject];
            if([selectionButton.associatedObject isKindOfClass:[Channel class]] &&
               self.selectedChannels.count) {
                [self.selectChannelDelegate channelsSelected:self.selectedChannels];
            }
        }else{
            
            [self.selectedChannels addObject:selectionButton.associatedObject];
            [selectionButton setButtonSelected:YES];
            if([selectionButton.associatedObject isKindOfClass:[Channel class]]) {
                [self.selectChannelDelegate channelsSelected:self.selectedChannels];
            }
        }
    }else {
        if([selectionButton buttonSelected]){//if it's already selected then remove it
            [selectionButton setButtonSelected:NO];
        }else{
            if(self.selectedButton){//only one button can be selected at once
                [self.selectedButton setButtonSelected:NO];
            }
            self.selectedButton = selectionButton;
            [selectionButton setButtonSelected:YES];
            
            if([selectionButton.associatedObject isKindOfClass:[Channel class]]){
              [self.selectChannelDelegate channelsSelected:self.selectedChannels];
            }
        }
    }
}



-(NSMutableArray *) selectedChannels{
    if(!_selectedChannels){
        _selectedChannels = [[NSMutableArray alloc] init];
    }
    return _selectedChannels;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
