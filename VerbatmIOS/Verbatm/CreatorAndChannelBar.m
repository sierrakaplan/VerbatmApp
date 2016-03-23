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
#import "Styles.h"
#import "Follow_BackendManager.h"
#import "ProfileVC.h"
#import "Follow_BackendManager.h"
/*
 Give a creator and channel name this creates labels for each.
 */

#define LABEL_WALL_OFFSET 5.f
#define TEXT_FONT_TYPE @"Quicksand"
#define CREATOR_NAME_FONT_SIZE 15.f
#define CREATOR_NAME_TEXT_COLOR whiteColor

#define CHANNEL_NAME_FONT_SIZE CREATOR_NAME_FONT_SIZE
#define LABEL_TEXT_PADDING 20.f  //Distance between the text and the white border


@interface CreatorAndChannelBar ()
@property (nonatomic) Channel * currentChannel;
@property (nonatomic) PFUser * channelOwner;
@property (nonatomic) UIImageView * followImage;
@property (nonatomic) BOOL isFollowingChannel;
@end


@implementation CreatorAndChannelBar

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel{
    self = [super initWithFrame:frame];
    if(self){
        self.currentChannel = channel;
        self.channelOwner =(PFUser *)[channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
        [self createBackground];
        [self addCreatorName:[self.channelOwner valueForKey:USER_USER_NAME_KEY] andChannelName:channel.name];
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
    
    [self addPresentChannelGestureToView:creatorNameView];
    creatorNameView.userInteractionEnabled = YES;
    
    // find size of channel text
    UIFont * fontForChannelName = [UIFont fontWithName:TEXT_FONT_TYPE size:CREATOR_NAME_FONT_SIZE];
    
    CGSize channelNameSize = [channelName sizeWithAttributes:@{NSFontAttributeName : fontForChannelName}];
    
    CGFloat channelNameFrameWidth = LABEL_TEXT_PADDING +  ((channelNameSize.width < self.frame.size.width/2.f) ?
        channelNameSize.width : self.frame.size.width/2.f);
    
    //create channel name view
    
    CGFloat labelHeights = self.frame.size.height - (2*LABEL_WALL_OFFSET);
    
    CGRect followImageFrame = CGRectMake(0.f,0.f,labelHeights,
                                                   labelHeights);
    CGFloat channelNameHolderFrameWidth = (channelNameFrameWidth + followImageFrame.size.width + LABEL_WALL_OFFSET);
    
    CGRect channelNameHolderViewFrame = CGRectMake(self.frame.size.width -
                                         (channelNameHolderFrameWidth + LABEL_WALL_OFFSET),
                                         LABEL_WALL_OFFSET, channelNameHolderFrameWidth,
                                         labelHeights);
    CGRect channelNameFrame = CGRectMake(followImageFrame.size.width,0.f, channelNameFrameWidth,labelHeights);
    
    
    //create and format channel name holder view
    UIView * channelNameHolderView = [[UIView alloc] initWithFrame:channelNameHolderViewFrame];
    [self addFollowChannelGestureToView: channelNameHolderView];
    channelNameHolderView.backgroundColor = [UIColor clearColor];
    channelNameHolderView.layer.borderColor = [UIColor whiteColor].CGColor;
    channelNameHolderView.layer.borderWidth = 1.f;
    channelNameHolderView.layer.cornerRadius = channelNameHolderView.frame.size.width/15.f;
    
    
    //create follow image
    self.followImage = [[UIImageView alloc] initWithFrame:followImageFrame];
    self.followImage.backgroundColor = [UIColor clearColor];

    
    UILabel* channelNameView = [[UILabel alloc] initWithFrame:channelNameFrame];
    channelNameView.textAlignment = NSTextAlignmentCenter;
    channelNameView.text = channelName;
    
    channelNameView.font = fontForChannelName;
    channelNameView.textColor = [UIColor CREATOR_NAME_TEXT_COLOR];
    [channelNameView setBackgroundColor:[UIColor clearColor]];
    
    
    [channelNameHolderView addSubview:self.followImage];
    [channelNameHolderView addSubview:channelNameView];
    [self addSubview:creatorNameView];
    [self addSubview:channelNameHolderView];
    [self createFollowIcon];
}


-(void)setFollowImageIsFollowing:(BOOL) isFollowing{
    UIImage * image = [UIImage imageNamed:((isFollowing) ? FOLLOW_ICON_IMAGE_SELECTED :FOLLOW_ICON_IMAGE_UNSELECTED)];
    
    self.followImage.image = image;
}



-(void) createBackground {

    
    self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3];
    //    UIImage * background = [UIImage imageNamed:@"Rectangle_Background_2"];
//    UIImageView * view = [[UIImageView alloc] initWithImage:background];
//    view.frame = self.bounds;
//    [self addSubview:view];
}


-(void)createFollowIcon{
    [Follow_BackendManager currentUserFollowsChannel:self.currentChannel withCompletionBlock:^
        (bool isFollowing) {
         dispatch_async(dispatch_get_main_queue(), ^{
             self.isFollowingChannel = isFollowing;
             [self setFollowImageIsFollowing:isFollowing];
         });
     }];
}


-(void)addFollowChannelGestureToView:(UIView *) view{
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followChannel)];
    singleTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTap];
}

-(void) followChannel {
    if(self.isFollowingChannel){
        [self setFollowImageIsFollowing:NO];
        self.isFollowingChannel = NO;
        [Follow_BackendManager currentUserStopFollowingChannel:self.currentChannel];
    }else{
        [self setFollowImageIsFollowing:YES];
        self.isFollowingChannel = YES;
        [Follow_BackendManager currentUserFollowChannel:self.currentChannel];
    }
}


-(void)addPresentChannelGestureToView:(UIView *) view{
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentChannel)];
    singleTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTap];
}

-(void)presentChannel{
    [self.delegate channelSelected:self.currentChannel withOwner:self.channelOwner];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
