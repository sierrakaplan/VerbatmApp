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

typedef enum PostListType{
    listFeed = 0,
    listChannel = 1,
}PostListType;

@interface POVListScrollViewVC : UIViewController
@property (nonatomic) PostListType listType;//should be set by the VC that creates the PLV

//if it's a feed -- whose feed?
//if it's a channel -- whose channel?
@property (nonatomic) PFUser * listOwner;//also set when POSTLIST is created
@property (nonatomic) Channel * channelForList;//set when postlist created


-(void)reloadCurrentChannel;
-(void)changeCurrentChannelTo:(Channel *) channel;
@end
