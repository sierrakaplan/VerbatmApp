//
//  Followers.m
//  Verbatm
//
//  Created by Damas on 4/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Followers.h"
#import "Channel_BackendObject.h"
#import "Channel.h"
#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import "User_BackendObject.h"
#import "ProfileVC.h"
#import <Parse/PFQuery.h>

#define FOLLOWER_LABEL_HEIGHT 30.f
#define SCROLL_BUFFER 10.f

@interface Followers ()
@property (nonatomic) NSMutableArray *blogFollowers;
@property (nonatomic) Channel *currentBlog;
@property (nonatomic) CGFloat y;
@end

@implementation Followers
-(instancetype) initWithFrame:(CGRect)frame forChannel:(Channel *)blog{
    self = [super initWithFrame:frame];
    if(self){
        self.currentBlog = blog;
        self.y = 0.f;
        [self formatView];
 //                       [self setContentSize];
        [self currentBlogFollowers];
    }
    return self;
}

-(void)formatView{
    self.scrollEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.showsVerticalScrollIndicator = YES;
    self.userInteractionEnabled = YES;
    [self scrollRectToVisible:self.frame animated:YES];
}

-(void) currentBlogFollowers {
    
    [Follow_BackendManager usersFollowingChannel:self.currentBlog withCompletionBlock:^(NSArray *blogFollowers){
        for(PFObject *obj in blogFollowers){
            __block PFUser *user = [obj valueForKey:FOLLOW_USER_KEY];
            __block NSString *name = nil;
            
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error){
                user = (PFUser *) object;
                [self.blogFollowers addObject:user];
                name = [user valueForKey:VERBATM_USER_NAME_KEY];
                [self createFollowersLabels:name];
            }];

        }
        

    }];
}

-(void) createFollowersLabels:(NSString *) name{


        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.frame.size.width, FOLLOWER_LABEL_HEIGHT)];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(v.frame.size.width * 0.125, v.frame.size.height * 0.125, v.frame.size.width * 0.75, v.frame.size.height)];
        [l setText:name];
        [l setTextColor:[UIColor blackColor]];
        [l setTextAlignment:NSTextAlignmentCenter];
        [l setCenter:v.center];
        
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userSelected:)];
    [v addGestureRecognizer:tap];
        [v addSubview:l];
        [self addSubview:v];
        
        self.y += FOLLOWER_LABEL_HEIGHT;
}

-(void) userSelected:(UITapGestureRecognizer *) gesture {
    PFUser *selectedUser = self.blogFollowers[0];
    [selectedUser fetchIfNeededInBackgroundWithBlock:^
     (PFObject * _Nullable object, NSError * _Nullable error) {
         if(object){
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self goToUserProfile:(PFUser *)object];
             });
         }
     }];
}



-(void) goToUserProfile:(PFUser *) user {
    [self removeFromSuperview];
    ProfileVC *  userProfile = [[ProfileVC alloc] init];
    userProfile.isCurrentUserProfile = NO;
    userProfile.isProfileTab = NO;
    userProfile.userOfProfile = user;
    
    UIViewController *top = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (top.presentedViewController){
        top = top.presentedViewController;
    }
    top = top;
    
    [top presentViewController:userProfile animated:YES completion:^{
    }];
}

-(void) setContentSize {
    self.contentSize = CGSizeMake(0, self.frame.size.height+100);
}

-(NSMutableArray *) blogFollowers{
    if(!_blogFollowers){
        _blogFollowers = [[NSMutableArray alloc] init];
    }
    
    return _blogFollowers;
}

@end
