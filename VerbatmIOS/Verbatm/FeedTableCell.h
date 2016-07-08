//
//  FeedTableCell.h
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "ProfileVC.h"


@protocol FeedCellDelegate <NSObject>

-(void)shouldHideTabBar:(BOOL) shouldHide;

@end


@interface FeedTableCell : UITableViewCell
-(void)presentProfileForChannel:(Channel *) channel;
@property (nonatomic, weak) id<FeedCellDelegate> delegate;
-(void)setProfileAlreadyLoaded:(ProfileVC *) newProfile;
-(void)reloadProfile;
-(void)clearProfile;
@end
