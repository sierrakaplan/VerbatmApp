//
//  CreatorAndChannelBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CreatorAndChannelBar.h"
#import "ParseBackendKeys.h"
#import <Parse/PFObject.h>
#import <Parse/PFUser.h>
#import "Styles.h"
/*
 Give a creator and channel name this creates labels for each.
 */

#define LABEL_WALL_OFFSET 10.f
#define TEXT_FONT_TYPE @"Quicksand-Bold"
#define CREATOR_NAME_FONT_SIZE 18.f
#define CREATOR_NAME_TEXT_COLOR whiteColor

#define CHANNEL_NAME_FONT_SIZE 18.f
#define LABEL_TEXT_PADDING 20.f  //Distance between the text and the white border


@interface CreatorAndChannelBar ()
@property (nonatomic) Channel * currentChannel;
@end


@implementation CreatorAndChannelBar

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel{
    self = [super initWithFrame:frame];
    if(self){
        self.currentChannel = channel;
        [self addCreatorName:[(PFUser *)[channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] username] andChannelName:channel.name];
    }
    return self;
}

-(void) addCreatorName: (NSString*) creatorName andChannelName: (NSString*) channelName{
    
    //create username
    CGRect creatorNameFrame = CGRectMake(LABEL_WALL_OFFSET,
                                         LABEL_WALL_OFFSET, self.frame.size.width/2.f,
                                         self.frame.size.height - (2*LABEL_WALL_OFFSET));
    
    UILabel* creatorNameView = [[UILabel alloc] initWithFrame:creatorNameFrame];
    creatorNameView.textAlignment = NSTextAlignmentLeft;
    creatorNameView.text = creatorName;
    UIFont * fontForCreatorName = [UIFont fontWithName:TEXT_FONT_TYPE size:CREATOR_NAME_FONT_SIZE];
    creatorNameView.font = fontForCreatorName;
    creatorNameView.textColor = [UIColor CREATOR_NAME_TEXT_COLOR];
    [creatorNameView setBackgroundColor:[UIColor clearColor]];
    
    
    UIButton* channelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [channelButton setTitle:channelName forState:UIControlStateNormal];
    UIFont * channelNameFont = [UIFont fontWithName:TEXT_FONT_TYPE size:CHANNEL_NAME_FONT_SIZE];
    [channelButton.titleLabel setFont:channelNameFont];
    
    //find size of channel text
    CGSize channelNameSize = [channelButton.titleLabel.text sizeWithAttributes:@{
                                                                        NSFontAttributeName : channelNameFont
                                                                        }];
    
    CGFloat channelNameFrameWidth = LABEL_TEXT_PADDING +  ((channelNameSize.width < self.frame.size.width/2.f) ?
    channelNameSize.width : self.frame.size.width/2.f);
    
    //set the button frame
    CGRect channelNameFrame = CGRectMake(self.frame.size.width -
                                         (channelNameFrameWidth + LABEL_WALL_OFFSET),
                                         LABEL_WALL_OFFSET,
                                         channelNameFrameWidth,
                                         self.frame.size.height - (LABEL_WALL_OFFSET *2));
    channelButton.frame = channelNameFrame;
    
    channelButton.titleLabel.textColor = [UIColor whiteColor];
    channelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    channelButton.layer.borderWidth = 2.f;
    channelButton.layer.cornerRadius = channelButton.frame.size.width/15.f;
    [channelButton setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:creatorNameView];
    [self addSubview:channelButton];
}

-(void)channelButtonPressed{
    [self.delegate channelSelected:self.currentChannel];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
