//
//  POVListScrollViewVC.h
//  Verbatm
//
//  Created by Iain Usiri on 2/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>

typedef enum PostListType{
    listFeed = 0,
    listChannel = 1,
}PostListType;


@protocol POVListViewProtocol <NSObject>
-(void) shareOptionSelectedForParsePostObject: (PFObject* ) pov;
@end


@interface POVListScrollViewVC : UIViewController
@property (nonatomic) PostListType listType;//should be set by the VC that creates the PLV

@property (nonatomic) id<POVListViewProtocol> delegate;

//if it's a feed -- whose feed?
//if it's a channel -- whose channel?
@property (nonatomic) PFUser * listOwner;//also set when POSTLIST is created
@property (nonatomic) Channel * channelForList;//set when postlist created


@property (nonatomic) BOOL isHomeProfileOrFeed;//profile of the current logged in user




-(void) stopAllVideoContent;//marks all POVs as off screen
-(void) continueVideoContent;//continues POV that's on screen

-(void)reloadCurrentChannel;
-(void)changeCurrentChannelTo:(Channel *) channel;
//moves the tap/share bar up and down over the tab bar
-(void) footerShowing: (BOOL) showing;





@end
