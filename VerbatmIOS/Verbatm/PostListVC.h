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
-(void)channelSelected:(Channel *) channel withOwner:(PFUser *) owner;
@end

typedef enum PostListType {
	listFeed = 0,
	listChannel = 1,
} PostListType;

@interface PostListVC : UICollectionViewController

@property (nonatomic) id <PostListVCProtocol> delegate;

@property (nonatomic) BOOL isHomeProfileOrFeed;

@property (nonatomic) PostListType listType;

@property (nonatomic) PFUser * listOwner;
@property (nonatomic) Channel * channelForList;

//marks all posts as off screen
-(void) stopAllVideoContent;

//continues post that's on screen
-(void) continueVideoContent;

-(void)reloadCurrentChannel;
-(void)changeCurrentChannelTo:(Channel *) channel;

//moves the tap/share bar up and down over the tab bar
-(void) footerShowing: (BOOL) showing;
@end
