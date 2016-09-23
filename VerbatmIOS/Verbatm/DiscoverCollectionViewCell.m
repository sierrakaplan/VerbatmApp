//
//  DiscoverCollectionViewCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "DiscoverCollectionViewCell.h"
#import "Icons.h"
#import "Follow_BackendManager.h"
#import "Notifications.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "SizesAndPositions.h"
#import "UserInfoCache.h"

@interface DiscoverCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFollowersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (nonatomic) BOOL isFollowed;
@property (nonatomic, strong) NSNumber *numFollowers;
@property (weak, readwrite) Channel *channelBeingPresented;

#define MAIN_VIEW_OFFSET 10.f
#define X_OFFSET 10.f
#define Y_OFFSET 5.f
#define NUM_FOLLOWERS_WIDTH 50.f

@end

@implementation DiscoverCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	self.backgroundColor  = [UIColor blackColor];
	[self registerForFollowNotification];
	[self clearViews];
	[self.followButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
	[self.followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchDown];
    // Initialization code
}

-(void)registerForFollowNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userFollowStatusChanged:)
												 name:NOTIFICATION_NOW_FOLLOWING_USER
											   object:nil];
}

-(void) clearViews {
	[self.coverPhotoImageView setImage:[UIImage imageNamed: NO_COVER_PHOTO_IMAGE]];
}

-(void) layoutSubviews {
	self.coverPhotoImageView.frame = self.bounds;
	CGFloat yOffset = self.frame.size.height - DISCOVER_USERNAME_AND_FOLLOW_HEIGHT - Y_OFFSET;
	self.followButton.frame = CGRectMake(self.frame.size.width - DISCOVER_USERNAME_AND_FOLLOW_HEIGHT - X_OFFSET,
										 yOffset, DISCOVER_USERNAME_AND_FOLLOW_HEIGHT,
										 DISCOVER_USERNAME_AND_FOLLOW_HEIGHT);
	self.numFollowersLabel.frame = CGRectMake(self.followButton.frame.origin.x - NUM_FOLLOWERS_WIDTH - X_OFFSET,
											  yOffset, NUM_FOLLOWERS_WIDTH,
											  DISCOVER_USERNAME_AND_FOLLOW_HEIGHT);

	self.userNameLabel.frame = CGRectMake(X_OFFSET, Y_OFFSET,
										  self.frame.size.width - (X_OFFSET*2),
										  DISCOVER_CHANNEL_NAME_HEIGHT);
}

-(void)userFollowStatusChanged:(NSNotification *) notification {

	NSDictionary * userInfo = [notification userInfo];
	if(userInfo){
		NSString * userId = userInfo[USER_FOLLOWING_NOTIFICATION_USERINFO_KEY];
		NSNumber * isFollowingAction = userInfo[USER_FOLLOWING_NOTIFICATION_ISFOLLOWING_KEY];
		//only update the follow icon if this is the correct user and also if the action was
		//no registered on this view
		if([userId isEqualToString:[self.channelBeingPresented.channelCreator objectId]]&&
		   ([isFollowingAction boolValue] != self.isFollowed)) {
			self.isFollowed = [isFollowingAction boolValue];
			[self updateFollowIcon];
		}
	}
}

-(void) presentChannel:(Channel *)channel {
	self.isFollowed = [[UserInfoCache sharedInstance] checkUserFollowsChannel: channel];
	[self updateFollowIcon];
	self.channelBeingPresented = channel;

	[self.userNameLabel setText: channel.userName];
	self.numFollowers = self.channelBeingPresented.parseChannelObject[CHANNEL_NUM_FOLLOWS];
	[self changeNumFollowersLabel];

	[self.channelBeingPresented loadCoverPhotoWithCompletionBlock:^(UIImage *coverPhoto, NSData *coverPhotoData) {
		if (coverPhoto) {
			self.coverPhotoImageView.image = coverPhoto;
		} else {
			self.coverPhotoImageView.image = [UIImage imageNamed:NO_COVER_PHOTO_IMAGE];
		}
		[self layoutSubviews];
	}];
}

-(void) followButtonPressed {
	self.isFollowed = !self.isFollowed;
	if (self.isFollowed) {
		self.numFollowers = [NSNumber numberWithInteger:[self.numFollowers integerValue]+1];
		[Follow_BackendManager currentUserFollowChannel: self.channelBeingPresented];
	} else {
		self.numFollowers = [NSNumber numberWithInteger:[self.numFollowers integerValue]-1];
		[Follow_BackendManager currentUserStopFollowingChannel: self.channelBeingPresented];
	}
	[self updateFollowIcon];
}

-(void) updateFollowIcon {
	if (self.isFollowed) {
		[self.followButton setImage: [UIImage imageNamed:CHECK_MARK] forState:UIControlStateNormal];
		self.followButton.enabled = NO;
		//        [self changeFollowButtonTitle:@"Following" toColor:[UIColor blackColor]];
		//        self.followButton.backgroundColor = [UIColor whiteColor];
	} else {
		[self.followButton setImage: [UIImage imageNamed:FOLLOW_ICON] forState:UIControlStateNormal];
		self.followButton.enabled = YES;
		//        [self changeFollowButtonTitle:@"Follow" toColor:[UIColor whiteColor]];
		//        self.followButton.backgroundColor = [UIColor clearColor];
	}
	[self changeNumFollowersLabel];
}

-(void) changeNumFollowersLabel {
	[self.numFollowersLabel setText:[self.numFollowers stringValue]];
}

@end
