//
//  ExploreChannelCellView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ExploreChannelCellView.h"
#import "ParseBackendKeys.h"
#import "Page_BackendObject.h"
#import "Post_BackendObject.h"
#import "PostView.h"
#import "Styles.h"

@interface ExploreChannelCellView() <UIScrollViewDelegate>

// view for content so that there can be a black footer in every cell
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UILabel *channelNameLabel;

@property (strong, nonatomic) UIScrollView *horizontalScrollView;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableArray *postViews;


#define POST_VIEW_OFFSET 20.f
#define POST_VIEW_WIDTH 160.f

#define POST_SCROLLVIEW_OFFSET 60.f
#define OFFSET 10.f
#define FOOTER_HEIGHT 20.f

@end

@implementation ExploreChannelCellView

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = [UIColor darkGrayColor];
		[self addSubview:self.horizontalScrollView];
		[self addSubview:self.footerView];
		[self addSubview:self.followButton];
		[self addSubview:self.userNameLabel];
		[self addSubview:self.channelNameLabel];
	}
	return self;
}

-(void) layoutSubviews {
	self.horizontalScrollView.frame = CGRectMake(0.f, POST_SCROLLVIEW_OFFSET, self.frame.size.width,
												 self.frame.size.height - POST_SCROLLVIEW_OFFSET - FOOTER_HEIGHT);
	self.footerView.frame = CGRectMake(0.f, self.frame.size.height - FOOTER_HEIGHT, self.frame.size.width, FOOTER_HEIGHT);
	self.channelNameLabel.frame = CGRectMake(OFFSET, self.followButton.frame.size.height + self.followButton.frame.origin.y,
											 self.frame.size.width - (OFFSET *2), 40.f);
	self.followButton.frame = CGRectMake(self.frame.size.width - 70.f, OFFSET, 70.f, 20.f);
	self.userNameLabel.frame = CGRectMake(OFFSET, OFFSET, 150.f, 20.f);


	CGFloat xCoordinate = POST_VIEW_OFFSET;
	for (PostView *postView in self.postViews) {
		CGRect frame = CGRectMake(xCoordinate, POST_VIEW_OFFSET, POST_VIEW_WIDTH,
								  self.horizontalScrollView.frame.size.height - (POST_VIEW_OFFSET*2));
		postView.frame = frame;
		xCoordinate += POST_VIEW_WIDTH + POST_VIEW_OFFSET;
	}
	self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate, self.horizontalScrollView.contentSize.height);
}

-(void) presentChannel:(Channel *)channel {
	[self.channelNameLabel setText: channel.name];
	[self.userNameLabel setText: [channel getChannelOwnerUserName]];
	__block CGFloat xCoordinate = POST_VIEW_OFFSET;
	[Post_BackendObject getPostsInChannel:channel withCompletionBlock:^(NSArray *postChannelActivityObjects) {
		for (PFObject *postChannelActivityObj in postChannelActivityObjects) {
			PFObject *post = [postChannelActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
			[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
				CGRect frame = CGRectMake(xCoordinate, POST_VIEW_OFFSET, POST_VIEW_WIDTH,
										  self.horizontalScrollView.frame.size.height - (POST_VIEW_OFFSET*2));
				PostView *postView = [[PostView alloc] initWithFrame:frame andPostChannelActivityObject:post];
				[postView postOffScreen];
				[postView renderPostFromPageObjects: pages];
				xCoordinate += POST_VIEW_WIDTH + POST_VIEW_OFFSET;
				self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate, self.horizontalScrollView.contentSize.height);
				[self.horizontalScrollView addSubview: postView];
				[self.postViews addObject: postView];
			}];
		}
	}];
}

-(void) followButtonPressed {
	//todo
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	//todo: put posts on and off screen
}

#pragma mark - Lazy Instantiation -

-(UIView *) footerView {
	if (!_footerView) {
		CGRect frame = CGRectMake(0.f, self.frame.size.height - FOOTER_HEIGHT, self.frame.size.width, FOOTER_HEIGHT);
		_footerView = [[UIView alloc] initWithFrame:frame];
		_footerView.backgroundColor = [UIColor blackColor];
	}
	return _footerView;
}

-(UIScrollView *) horizontalScrollView {
	if (!_horizontalScrollView) {
		CGRect frame = CGRectMake(0.f, POST_SCROLLVIEW_OFFSET, self.frame.size.width,
								  self.frame.size.height - POST_SCROLLVIEW_OFFSET);
		_horizontalScrollView = [[UIScrollView alloc] initWithFrame: frame];
		_horizontalScrollView.backgroundColor = self.backgroundColor;
		_horizontalScrollView.delegate = self;
		_horizontalScrollView.showsVerticalScrollIndicator = NO;
		_horizontalScrollView.showsHorizontalScrollIndicator = YES;
	}
	return _horizontalScrollView;
}

-(NSMutableArray *) postViews {
	if (!_postViews) {
		_postViews = [[NSMutableArray alloc] init];
	}
	return _postViews;
}

-(UILabel *) userNameLabel {
	if (!_userNameLabel) {
		CGRect labelFrame = CGRectMake(OFFSET, OFFSET, 150.f, 20.f);
		_userNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
		[_userNameLabel setAdjustsFontSizeToFitWidth:YES];
		[_userNameLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:20.f]];
		[_userNameLabel setTextColor:VERBATM_GOLD_COLOR];
	}
	return _userNameLabel;
}

-(UIButton *) followButton {
	if (!_followButton) {
		CGRect followFrame = CGRectMake(self.frame.size.width - 70.f, OFFSET, 70.f, 20.f); //todo
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = followFrame;
		NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Follow"
																			  attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
																						   NSFontAttributeName: [UIFont fontWithName:DEFAULT_FONT size:16.f]}]; //todo
		[_followButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
		[_followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _followButton;
}

-(UILabel *) channelNameLabel {
	if (!_channelNameLabel) {
		CGRect channelNameFrame = CGRectMake(OFFSET, self.followButton.frame.size.height + self.followButton.frame.origin.y,
											 self.frame.size.width - (OFFSET *2), 40.f);
		_channelNameLabel = [[UILabel alloc] initWithFrame:channelNameFrame];
		[_channelNameLabel setAdjustsFontSizeToFitWidth:YES];
		[_channelNameLabel setTextAlignment:NSTextAlignmentCenter];
		[_channelNameLabel setFont:[UIFont fontWithName:INFO_LIST_HEADER_FONT size:20.f]]; //todo:
		[_channelNameLabel setTextColor:[UIColor whiteColor]];
	}
	return _channelNameLabel;
}

@end
