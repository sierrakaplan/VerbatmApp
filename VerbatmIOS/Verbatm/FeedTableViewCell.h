//
//  FeedTableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 6/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileVC.h"
#import "Channel.h"


@protocol FeedCellDelegate <NSObject>

-(void)shouldHideTabBar:(BOOL) shouldHide;

@end

@interface FeedTableViewCell : UITableViewCell
@property (nonatomic) id<FeedCellDelegate> delegate;

-(void)presentProfileForChannel:(Channel *) channel;
-(void)setProfileAlreadyLoaded:(ProfileVC *) newProfile;
-(void)reloadProfile;

@end
