//
//  PostListVC.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <UIKit/UIKit.h>
#import <Parse/PFUser.h>
#import "PostsQueryManager.h"


@protocol PostListVCProtocol <NSObject>

-(void)noPostFound;
-(void)postsFound;
-(void)cellSelectedAtPostIndex:(NSIndexPath *) cellPath;

-(void)hideNavBarIfPresent;
-(void)channelSelected:(Channel *) channel;
@end

typedef enum PostListType {
	listFeed = 0,
	listChannel = 1,
} PostListType;

@interface PostListVC : UICollectionViewController

@property (strong, nonatomic) PostsQueryManager *postsQueryManager;

@property (nonatomic) BOOL isInitiated;

@property (nonatomic, weak) id <PostListVCProtocol> postListDelegate;

@property (nonatomic) BOOL inSmallMode;

@property (nonatomic, readonly) NSMutableArray * parsePostObjects;
@property (nonatomic) BOOL currentlyPublishing;


-(void) display:(Channel*)channelForList asPostListType:(PostListType)listType
  withListOwner:(PFUser*)listOwner isCurrentUserProfile:(BOOL)isCurrentUserProfile
andStartingDate:(NSDate*)date;


//used when a cell view is tapped and we need to create a new postlist VC from an older one
-(void) loadPostListFromOlPostListWithDisplay:(Channel*)channelForList postListType:(PostListType)listType
                                    listOwner:(PFUser*)listOwner isCurrentUserProfile:(BOOL)isCurrentUserProfile startingDate:(NSDate*)date andParseObjects:(NSMutableArray *)newParseObjects;
-(void) clearViews;

//marks all posts as off screen
-(void) offScreen;

-(void) refreshPosts;

-(void) loadMorePosts;

//moves the tap/share bar up and down over the tab bar
-(void) footerShowing: (BOOL) showing;

@end
