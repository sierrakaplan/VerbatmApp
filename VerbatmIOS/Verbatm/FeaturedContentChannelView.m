//
//  FeaturedContentChannelView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "FeaturedContentChannelView.h"
#import "ParseBackendKeys.h"
#import "Page_BackendObject.h"
#import "PostView.h"
#import "Post_BackendObject.h"
#import "Styles.h"

#import <Parse/PFObject.h>
#import <Parse/PFUser.h>

@interface FeaturedContentChannelView()

@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UILabel *channelNameLabel;
// shows latest post in channel
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) PostView *postView;
@property (nonatomic, strong) NSArray *posts; // array of post channel objects

@end

@implementation FeaturedContentChannelView

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel*)channel {
	self = [super initWithFrame:frame];
	if (self) {
		self.channel = channel;
		[self addSubview:self.followButton];
		[self.userNameLabel setText: [channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY]];
		[self addSubview:self.userNameLabel];
		[self.channelNameLabel setText: channel.name];
		[self addSubview: self.channelNameLabel];
		[self loadPostView];
	}
	return self;
}

-(void) loadPostView {
	CGRect postViewFrame = CGRectMake(10.f, 100.f, 60.f, 60.f);
	[Post_BackendObject getPostsInChannel:self.channel withCompletionBlock:^(NSArray *posts) {
		self.posts = posts;
		if (posts.count > 0) {
			[Page_BackendObject getPagesFromPost:posts[0] andCompletionBlock:^(NSArray * pages) {
				//todo: make sure that only channels with posts go into discover
				self.postView = [[PostView alloc] initWithFrame:postViewFrame andPostChannelActivityObject:posts[0]];
				[self.postView renderPostFromPageObjects:pages];
				[self.postView postOffScreen];
				[self addSubview: self.postView];
			}];
		}
	}];
}

-(void) followButtonPressed {
	//todo:
}

#pragma mark - Lazy Instantiation -

//todo: make numbers constants

-(UILabel *) userNameLabel {
	if (!_userNameLabel) {
		CGRect labelFrame = CGRectMake(0.f, 0.f, 50.f, 50.f);
		_userNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
		[_userNameLabel setAdjustsFontSizeToFitWidth:YES];
		[_userNameLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:14.f]];
		[_userNameLabel setTextColor:VERBATM_GOLD_COLOR];
	}
	return _userNameLabel;
}

-(UIButton *) followButton {
	if (!_followButton) {
		CGRect followFrame = CGRectMake(self.frame.size.width - 50.f, 0.f, 50.f, 50.f);
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = followFrame;
		[_followButton setTitle:@"Follow" forState:UIControlStateNormal];
		[_followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _followButton;
}

-(UILabel *) channelNameLabel {
	if (!_channelNameLabel) {
		CGRect channelNameFrame = CGRectMake(10.f, 60.f, self.frame.size.width - 20.f, 50.f);
		_channelNameLabel.frame = channelNameFrame;
		[_channelNameLabel setAdjustsFontSizeToFitWidth:YES];
		[_channelNameLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:14.f]];
		[_channelNameLabel setTextColor:VERBATM_GOLD_COLOR];
	}
	return _channelNameLabel;
}

@end
