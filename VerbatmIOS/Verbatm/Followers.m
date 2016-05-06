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
#import <PromiseKit/PromiseKit.h>

#define FOLLOWER_LABEL_HEIGHT 50.f
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
            
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error){
                user = (PFUser *) object;
                [self.blogFollowers addObject:user];
                [self createFollowersLabels:user];
            }];

        }
    }];
}

-(void) createFollowersLabels:(PFUser *) user{

        NSString *name = [user valueForKey:VERBATM_USER_NAME_KEY];
        UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.y, self.frame.size.width, FOLLOWER_LABEL_HEIGHT)];
        [userNameLabel setText:name];
        [userNameLabel setTextColor:[UIColor blackColor]];
        [userNameLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userSelected:)];
        [userNameLabel addGestureRecognizer:tap];
        userNameLabel.userInteractionEnabled = YES;
        [self addSubview:userNameLabel];
        self.y += FOLLOWER_LABEL_HEIGHT;
    
    CGSize newContentSize = CGSizeMake(0, self.y + FOLLOWER_LABEL_HEIGHT + SCROLL_BUFFER);
    self.contentSize = newContentSize;

}

-(void) userSelected:(UITapGestureRecognizer *) gesture {
    CGPoint touchPoint=[gesture locationInView:self];
    int index = (int)(touchPoint.y/ FOLLOWER_LABEL_HEIGHT);
    PFUser *selectedUser = self.blogFollowers[index];
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
    [self.superview removeFromSuperview];
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
