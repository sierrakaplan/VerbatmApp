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

@class VerbatmNavigationController;
@class MasterNavigationVC;

@protocol FeedCellDelegate <NSObject>

-(void) showNavBar:(BOOL) show;
-(void) pushViewController:(UIViewController*)viewController;

@end


@interface FeedTableCell : UITableViewCell

@property (nonatomic, weak) id<FeedCellDelegate> delegate;
@property (nonatomic) VerbatmNavigationController *navigationController;
@property (nonatomic) MasterNavigationVC *tabBarController;
@property (nonatomic) ProfileVC * currentProfile;

-(void)presentProfileForChannel:(Channel *) channel;

-(void)setProfileAlreadyLoaded:(ProfileVC *) newProfile;
-(void)reloadProfile;
-(void)clearProfile;
-(void)updateDateOfLastPostSeen;

@end
