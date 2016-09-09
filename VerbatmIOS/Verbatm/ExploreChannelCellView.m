//
//  ExploreChannelCellView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ExploreChannelCellView.h"
#import "Icons.h"
#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import "Page_BackendObject.h"
#import "Post_BackendObject.h"
#import "PostsQueryManager.h"
#import "PostView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Notifications.h"
#import <Parse/PFUser.h>
#import "UserInfoCache.h"

@interface ExploreChannelCellView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UILabel *numFollowersLabel;
@property (nonatomic, strong) UIImageView *coverPhotoImage;

@property (nonatomic) BOOL isFollowed;
@property (nonatomic, strong) NSNumber *numFollowers;
@property (weak, readwrite) Channel *channelBeingPresented;


#define MAIN_VIEW_OFFSET 10.f
#define POST_VIEW_WIDTH 150.f
#define OFFSET 5.f
#define NUM_FOLLOWERS_WIDTH 40.f

@end

@implementation ExploreChannelCellView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame: frame];
	if (self) {
		self.backgroundColor = [UIColor blackColor];
        [self registerForFollowNotification];
	}
	return self;
}

-(void)registerForFollowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFollowStatusChanged:)
                                                 name:NOTIFICATION_NOW_FOLLOWING_USER
                                               object:nil];
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

-(void) layoutSubviews {
	self.coverPhotoImage.frame = self.bounds;
	CGFloat yOffset = self.frame.size.height - DISCOVER_USERNAME_AND_FOLLOW_HEIGHT - OFFSET;
	self.followButton.frame = CGRectMake(self.frame.size.width - FOLLOW_BUTTON_WIDTH - OFFSET,
										 yOffset, FOLLOW_BUTTON_WIDTH,
										 DISCOVER_USERNAME_AND_FOLLOW_HEIGHT);
	self.numFollowersLabel.frame = CGRectMake(self.followButton.frame.origin.x - FOLLOW_BUTTON_WIDTH - OFFSET,
											  yOffset, NUM_FOLLOWERS_WIDTH,
											  DISCOVER_USERNAME_AND_FOLLOW_HEIGHT);

    self.userNameLabel.frame = CGRectMake(OFFSET, OFFSET,
                                          self.frame.size.width - (OFFSET*2),
                                          DISCOVER_CHANNEL_NAME_HEIGHT);
}

-(void) presentChannel:(Channel *)channel {
    self.isFollowed = [[UserInfoCache sharedInstance] checkUserFollowsChannel: channel];
	self.channelBeingPresented = channel;

	[self.userNameLabel setText: channel.userName];
	[self.channelBeingPresented loadCoverPhotoWithCompletionBlock:^(UIImage *coverPhoto, NSData *coverPhotoData) {
		if (coverPhoto) {
			self.coverPhotoImage.image = coverPhoto;
		}
	}];

	[self addSubview: self.coverPhotoImage];

	self.numFollowers = self.channelBeingPresented.parseChannelObject[CHANNEL_NUM_FOLLOWS];
	[self changeNumFollowersLabel];
     BOOL isCurrentUserChannel = [[channel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
    if(!isCurrentUserChannel){
        [self updateFollowIcon];
        [self addSubview:self.followButton];
    }
	
	[self addSubview:self.userNameLabel];
	[self addSubview:self.numFollowersLabel];
}

-(void) clearViews {

	self.channelBeingPresented = nil;

	[self.userNameLabel removeFromSuperview];
	[self.followButton removeFromSuperview];
	self.userNameLabel = nil;
	self.followButton = nil;
	self.coverPhotoImage = nil;
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
        [self changeFollowButtonTitle:@"Following" toColor:[UIColor blackColor]];
        self.followButton.backgroundColor = [UIColor whiteColor];
    } else {
        [self changeFollowButtonTitle:@"Follow" toColor:[UIColor whiteColor]];
        self.followButton.backgroundColor = [UIColor clearColor];
    }
    [self changeNumFollowersLabel];
}

-(void) changeFollowButtonTitle:(NSString*)title toColor:(UIColor*) color{
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
                                      NSFontAttributeName: [UIFont fontWithName:BOLD_FONT size:FOLLOW_TEXT_FONT_SIZE]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
    [self.followButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

-(void) changeNumFollowersLabel {
	[self.numFollowersLabel setText:[self.numFollowers stringValue]];
}


-(UIImageView*) coverPhotoImage {
	if (!_coverPhotoImage) {
		_coverPhotoImage = [[UIImageView alloc] initWithFrame:self.frame];
		_coverPhotoImage.image = [UIImage imageNamed:NO_COVER_PHOTO_IMAGE];
		_coverPhotoImage.contentMode = UIViewContentModeScaleAspectFill;
		_coverPhotoImage.clipsToBounds = YES;
	}
	return _coverPhotoImage;
}

-(UILabel *) userNameLabel {
	if (!_userNameLabel) {
		_userNameLabel = [[UILabel alloc] init];
        [_userNameLabel setAdjustsFontSizeToFitWidth:YES];
        [_userNameLabel setTextAlignment:NSTextAlignmentRight];
        [_userNameLabel setFont:[UIFont fontWithName:INFO_LIST_HEADER_FONT size:DISCOVER_CHANNEL_NAME_FONT_SIZE]];
        [_userNameLabel setTextColor:[UIColor whiteColor]];
	}
	return _userNameLabel;
}

-(UIButton *) followButton {
	if (!_followButton) {
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchDown];
        _followButton.clipsToBounds = YES;
        _followButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _followButton.layer.borderWidth = 2.f;
        _followButton.layer.cornerRadius = 7.f;

	}
	return _followButton;
}

-(UILabel *) numFollowersLabel {
	if (!_numFollowersLabel) {
		_numFollowersLabel = [[UILabel alloc] init];
		[_numFollowersLabel setAdjustsFontSizeToFitWidth:YES];
		[_numFollowersLabel setTextAlignment:NSTextAlignmentRight];
		[_numFollowersLabel setFont:[UIFont fontWithName:REGULAR_FONT size:DISCOVER_USER_NAME_FONT_SIZE]];
		[_numFollowersLabel setTextColor:[UIColor whiteColor]];
	}
	return _numFollowersLabel;
}


-(void) dealloc {

}

@end
