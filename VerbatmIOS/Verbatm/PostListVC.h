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

typedef enum PostListType{
    listFeed = 0,
    listChannel = 1,
}PostListType;


@protocol PostListVCProtocol <NSObject>

-(void)hideNavBarIfPresent;
-(void)channelSelected:(Channel *) channel withOwner:(PFUser *) owner;
@end


@interface PostListVC : UICollectionViewController

@property (nonatomic) id <PostListVCProtocol> delegate;

@property (nonatomic) BOOL isHomeProfileOrFeed;
//profile of the current logged in user


@property (nonatomic) PostListType listType;//should be set by the VC that creates the PLV

//if it's a feed -- whose feed?
//if it's a channel -- whose channel?
@property (nonatomic) PFUser * listOwner;//also set when POSTLIST is created
@property (nonatomic) Channel * channelForList;//set when postlist created

//marks all POVs as off screen
-(void) stopAllVideoContent;
//continues POV that's on screen
-(void) continueVideoContent;

-(void)reloadCurrentChannel;
-(void)changeCurrentChannelTo:(Channel *) channel;

//moves the tap/share bar up and down over the tab bar
-(void) footerShowing: (BOOL) showing;
@end
