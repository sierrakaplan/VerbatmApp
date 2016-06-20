//
//  FollowingView.m
//  Verbatm
//
//  Created by Damas on 5/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FollowingView.h"
#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>

#define FOLLOWING_VIEW_HEIGHT 30.f
#define SCROLL_BUFFER 10.f

@interface FollowingView()
@property (nonatomic) NSMutableArray *blogsFollowing;
@property (nonatomic) CGFloat y;
@end

@implementation FollowingView

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.y = 0.f;
        [self formatView];
        [self currentFollowingBlogs];
    }
    
    return self;
}

-(void) setHeader{
    
}

-(void) currentFollowingBlogs{
    [Follow_BackendManager channelsUserFollowing:[PFUser currentUser] withCompletionBlock:^(NSArray *followingChannels){
        for(PFObject *obj in followingChannels){
            [obj fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error){
                Channel *c = (Channel *) object;
  //              Channel *c = [object valueForKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
  //              [self.blogsFollowing addObject:object];
 //               NSString *blogName = [c valueForKey:CHANNEL_NAME_KEY];
                NSString *blogCreatorName = [c valueForKey:CHANNEL_CREATOR_KEY];
                NSLog(@"%@", c.name);
                [self createFollowingViewsWithUser:blogCreatorName andBlog:@"Hi"];
            }];
            
        }
    }];
}

-(void) formatView{
    self.alpha = 0.5;
    self.scrollEnabled = YES;
    self.backgroundColor = [UIColor grayColor];
    [self scrollRectToVisible:self.frame animated:YES];
}

-(void) createFollowingViewsWithUser:(NSString *)blogCreatorName andBlog:(NSString *)blogName {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.frame.size.width, FOLLOWING_VIEW_HEIGHT)];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, self.y, self.frame.size.width/2, FOLLOWING_VIEW_HEIGHT)];
    UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2, self.y, self.frame.size.width/2, FOLLOWING_VIEW_HEIGHT)];
    
    [l setText:blogCreatorName];
    [b setTitle:blogName forState:UIControlStateNormal];
    
    [v addSubview:l];
    [v addSubview:b];
    [self addSubview:v];
    self.y += FOLLOWING_VIEW_HEIGHT;
    
    CGSize newContentSize = CGSizeMake(0, self.y + FOLLOWING_VIEW_HEIGHT + SCROLL_BUFFER);
    self.contentSize = newContentSize;
    
}

@end
