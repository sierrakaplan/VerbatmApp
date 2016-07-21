//
//  FeedTableCell.m
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTableCell.h"
#import "UtilityFunctions.h"

@interface FeedTableCell ()<ProfileVCDelegate>

@property (nonatomic) ProfileVC * currentProfile;

@end


@implementation FeedTableCell

-(void)clearProfile {
	if(_currentProfile){
		[_currentProfile clearOurViews];
		_currentProfile = nil;
	}
}

-(void)setProfileAlreadyLoaded:(ProfileVC *) newProfile{

	ProfileVC * __block oldProfile = self.currentProfile;
	self.currentProfile = newProfile;
	self.currentProfile.delegate = self;
	[self addSubview:self.currentProfile.view];
	self.clipsToBounds = YES;

	if(oldProfile && oldProfile != newProfile){
		[oldProfile clearOurViews];
		oldProfile = nil;
	}
}

-(void)presentProfileForChannel:(Channel *) channel{

	ProfileVC * __block oldProfile = self.currentProfile;

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		self.currentProfile = [[ProfileVC alloc] init];
		self.currentProfile.isCurrentUserProfile = NO;
		self.currentProfile.profileInFeed = YES;
		self.currentProfile.isProfileTab = NO;
		self.currentProfile.delegate = self;
		self.currentProfile.ownerOfProfile = channel.channelCreator;
		self.currentProfile.channel = channel;

		dispatch_async(dispatch_get_main_queue(), ^{
			[self addSubview:self.currentProfile.view];
			if(oldProfile){
				[oldProfile clearOurViews];
				oldProfile = nil;
			}
		});
	});
}


-(void)reloadProfile{
	[self.currentProfile refreshProfile];
}

-(void) showTabBar:(BOOL) show{
	[self.delegate shouldHideTabBar:!show];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	// Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

@end
