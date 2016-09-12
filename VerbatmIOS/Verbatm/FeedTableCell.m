//
//  FeedTableCell.m
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTableCell.h"
#import "UtilityFunctions.h"

@interface FeedTableCell () <ProfileVCDelegate>

@end


@implementation FeedTableCell

-(void)clearProfile {
	if(_currentProfile){
		[_currentProfile clearOurViews];
		_currentProfile = nil;
	}
}

-(void)setProfileAlreadyLoaded:(ProfileVC *) newProfile{

	ProfileVC * oldProfile = self.currentProfile;
	self.currentProfile = newProfile;
	self.currentProfile.delegate = self;
	self.currentProfile.verbatmNavigationController = self.navigationController;
	self.currentProfile.verbatmTabBarController = self.tabBarController;
	[self addSubview:self.currentProfile.view];
	self.clipsToBounds = YES;

	if(oldProfile && oldProfile != newProfile){
		[oldProfile clearOurViews];
	}
}

-(void)presentProfileForChannel:(Channel *) channel{

	ProfileVC * oldProfile = self.currentProfile;

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		self.currentProfile = [[ProfileVC alloc] init];
		self.currentProfile.verbatmNavigationController = self.navigationController;
		self.currentProfile.verbatmTabBarController = self.tabBarController;
		self.currentProfile.profileInFeed = YES;
		self.currentProfile.delegate = self;
		self.currentProfile.ownerOfProfile = channel.channelCreator;
		self.currentProfile.channel = channel;

		dispatch_async(dispatch_get_main_queue(), ^{
			[self addSubview:self.currentProfile.view];
			if(oldProfile){
				[oldProfile clearOurViews];
			}
		});
	});
}
-(void)updateDateOfLastPostSeen{
    if(self.currentProfile){
        [self.currentProfile updateDateOfLastPostSeen];
    }
}

-(void)reloadProfile{
	[self.currentProfile refreshProfile];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	// Initialization code
}

-(void) lockFeedScrollView:(BOOL)shouldLock{
    [self.delegate lockFeedScrollView:shouldLock];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

#pragma mark - Profile Delegate -

-(void) pushViewController:(UIViewController *)viewController {
	[self.delegate pushViewController: viewController];
}


@end
