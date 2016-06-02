//
//  FollowingView.m
//  Verbatm
//
//  Created by Damas on 5/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FollowingView.h"
#import "Follow_BackendManager.h"
#import "Channel_BackendObject.h"
#import "ParseBackendKeys.h"
#import "Styles.h"
#import <Parse/PFUser.h>

#define FOLLOWING_VIEW_HEIGHT 30.f
#define SCROLL_BUFFER 10.f
#define SHARE_BUTTON_HEIGHT 40.f

@interface FollowingView()
@property (nonatomic) NSMutableArray *blogsFollowing;
@property (nonatomic) UIScrollView *sv;
@property (nonatomic) UIView *header;
@property (nonatomic) CGFloat y;
@end

@implementation FollowingView

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.y = 0.f;
        [self setHeader];
        [self formatView];
        [self currentFollowingBlogs];
    }
    
    return self;
}

-(void) createScrollView{
    self.sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.header.frame.size.height + 10, self.frame.size.width, (self.frame.size.height - (self.header.frame.size.height + 10)))];
    [self.sv setClipsToBounds:YES];
    [self addSubview:self.sv];
}

-(void) setHeader{
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/16)];
    [self.header setBackgroundColor:[UIColor orangeColor]];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/16)];
    [headerLabel setText:@"Following"];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    
    CGRect topBackButtonFrame = CGRectMake(0, self.header.frame.size.height * 0.125, self.header.frame.size.width/10, self.header.frame.size.height * 0.75);
    UIButton *backButton = [[UIButton alloc] initWithFrame:topBackButtonFrame];
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self.header addSubview:headerLabel];
    [self.header addSubview:backButton];
    [self addSubview:self.header];
    
    [self createScrollView];
}

-(void) backButtonSelected {
    [self removeFromSuperview];
}

-(void) currentFollowingBlogs{
    [Follow_BackendManager channelsUserFollowing:[PFUser currentUser] withCompletionBlock:^(NSArray *followingChannels){
        for(PFObject *obj in followingChannels){
                PFObject *channel = [obj valueForKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
                [channel fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error){
                    NSString *blogName = [object valueForKey:CHANNEL_NAME_KEY];
//                    PFUser *creator = [object valueForKey:CHANNEL_CREATOR_KEY];
//                    __block NSString *name = nil;
//                    [creator fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error){
//                        PFUser *user = (PFUser *) object;
//                        name = [user valueForKey:VERBATM_USER_NAME_KEY];
//
//                    }];
                    
                    [self createFollowingViewsWithUser:@"User Name" andBlog:blogName];
                }];
        }
    }];
}

-(void) formatView{
    self.backgroundColor = REPOST_VIEW_BACKGROUND_COLOR;
    
    self.sv.scrollEnabled = YES;
    self.sv.showsVerticalScrollIndicator = YES;
    self.sv.userInteractionEnabled = YES;
    [self.sv scrollRectToVisible:self.sv.frame animated:YES];
}

-(void) createFollowingViewsWithUser:(NSString *)blogCreatorName andBlog:(NSString *)blogName {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.sv.frame.size.width, FOLLOWING_VIEW_HEIGHT)];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, self.y, self.sv.frame.size.width/2, FOLLOWING_VIEW_HEIGHT)];
    UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(self.sv.frame.size.width * 0.6, self.y, self.sv.frame.size.width * 0.35, FOLLOWING_VIEW_HEIGHT)];
    b .layer .borderWidth = 2.0;
    b .layer .borderColor = [UIColor whiteColor].CGColor;
    b .layer .cornerRadius = 4.0;
    
    
    [l setText:blogCreatorName];
    [b setTitle:blogName forState:UIControlStateNormal];
    b.titleLabel.adjustsFontSizeToFitWidth = true;
    b.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
    
    [l setTextColor:[UIColor whiteColor]];
    [v addSubview:l];
    [v addSubview:b];
    [self.sv addSubview:v];
    self.y += FOLLOWING_VIEW_HEIGHT;
    
    CGSize newContentSize = CGSizeMake(self.sv.frame.size.width, (self.y * 2 + FOLLOWING_VIEW_HEIGHT + SCROLL_BUFFER));
    self.sv.contentSize = newContentSize;
}


-(void) channelButtonPressed {
    
}

@end
