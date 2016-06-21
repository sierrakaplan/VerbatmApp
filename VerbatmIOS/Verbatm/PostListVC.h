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


@protocol PostListVCProtocol <NSObject>

-(void)hideNavBarIfPresent;
-(void)channelSelected:(Channel *) channel;
@end

typedef enum PostListType {
	listFeed = 0,
	listChannel = 1,
    listSmallSizedList = 2 //a list, in a blog, that is minimized in size
} PostListType;

@interface PostListVC : UICollectionViewController

@property (nonatomic, weak) id <PostListVCProtocol> postListDelegate;

-(void) display:(Channel*)channelForList asPostListType:(PostListType)listType
  withListOwner:(PFUser*)listOwner isCurrentUserProfile:(BOOL)isCurrentUserProfile
andStartingDate:(NSDate*)date;

-(void) clearViews;

//marks all posts as off screen
-(void) offScreen;

-(void) refreshPosts;

-(void) loadMorePosts;

//moves the tap/share bar up and down over the tab bar
-(void) footerShowing: (BOOL) showing;
-(void)changePostViewsToSize:(CGSize) newSize;
@end
