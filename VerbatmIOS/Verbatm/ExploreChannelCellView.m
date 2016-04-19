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

@interface ExploreChannelCellView() <UIScrollViewDelegate, UIGestureRecognizerDelegate>

// view for content so that there can be a black footer in every cell
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UILabel *channelNameLabel;

@property (strong, nonatomic) UIScrollView *horizontalScrollView;
@property (strong, nonatomic) NSMutableArray *postViews;
@property (nonatomic) NSInteger indexOnScreen;

@property (weak, readwrite) Channel *channelBeingPresented;


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
		self.indexOnScreen = 0;
		self.backgroundColor = [UIColor darkGrayColor];
		[self addSubview:self.horizontalScrollView];
		[self addSubview:self.footerView];

		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
		tap.delegate = self;
		[self addGestureRecognizer:tap];
	}
	return self;
}

-(void) cellTapped:(UITapGestureRecognizer*)gesture {
	[self.delegate channelSelected:self.channelBeingPresented];
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
	[self setPostsOnScreen];
}

-(void) presentChannel:(Channel *)channel {
	self.channelBeingPresented = channel;
	[self.channelNameLabel setText: channel.name];
	[channel getChannelOwnerNameWithCompletionBlock:^(NSString *name) {
		[self.userNameLabel setText: name];
	}];

	__block CGFloat xCoordinate = POST_VIEW_OFFSET;
	[Post_BackendObject getPostsInChannel:channel withCompletionBlock:^(NSArray *postChannelActivityObjects) {
		for (PFObject *postChannelActivityObj in postChannelActivityObjects) {
			PFObject *post = [postChannelActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
			[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
				CGRect frame = CGRectMake(xCoordinate, POST_VIEW_OFFSET, POST_VIEW_WIDTH,
										  self.horizontalScrollView.frame.size.height - (POST_VIEW_OFFSET*2));
				PostView *postView = [[PostView alloc] initWithFrame:frame andPostChannelActivityObject:post small:YES];
				[postView postOffScreen];
				[postView renderPostFromPageObjects: pages];
				xCoordinate += POST_VIEW_WIDTH + POST_VIEW_OFFSET;
				self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate, self.horizontalScrollView.contentSize.height);
				[self.horizontalScrollView addSubview: postView];
				if (self.postViews.count >= self.indexOnScreen && self.postViews.count <= self.indexOnScreen+2) {
					[postView postOnScreen];
				} else if (self.postViews.count == (self.indexOnScreen+3)) {
					[postView preparepostToBePresented];
				}
				[self.postViews addObject: postView];
			}];
		}
	}];

	[self addSubview:self.followButton];
	[self addSubview:self.userNameLabel];
	[self addSubview:self.channelNameLabel];
}

-(void) clearViews {
	[self offScreen];
	self.indexOnScreen = 0;
	[self.userNameLabel removeFromSuperview];
	[self.followButton removeFromSuperview];
	[self.channelNameLabel removeFromSuperview];
	self.userNameLabel = nil;
	self.followButton = nil;
	self.channelNameLabel = nil;

	for (PostView *postView in self.postViews) {
		[postView removeFromSuperview];
	}
	self.postViews = nil;
}

-(void) followButtonPressed {
	[self.delegate channelFollowed:self.channelBeingPresented];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self setPostsOnScreen];
	}
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self setPostsOnScreen];
}

-(void) setPostsOnScreen {
	CGFloat originX = self.horizontalScrollView.contentOffset.x;
	//Round down/truncate
	NSInteger postIndex = originX / (POST_VIEW_WIDTH + POST_VIEW_OFFSET);

	//Three posts can be visible
	for (NSInteger i = postIndex; i < postIndex+3; i++) {
		// Set previous on screen posts off screen
		NSInteger previousPostIndex = self.indexOnScreen+(i-postIndex);
		if (previousPostIndex < self.postViews.count &&
			(previousPostIndex < postIndex || previousPostIndex > postIndex+2)) {
			[(PostView*)self.postViews[previousPostIndex] postOffScreen];
		}
		// set posts on screen
		if (i < self.postViews.count) {
			[(PostView*)self.postViews[i] postOnScreen];
		}
	}
	// Prepare next view
	if (postIndex + 3 < self.postViews.count) {
		[(PostView*)self.postViews[postIndex+3] preparepostToBePresented];
	}
}

-(void) setAllPostsOffScreen {
	for (PostView* postView in self.postViews) {
		[postView postOffScreen];
	}
}

-(void) offScreen {
	[self setAllPostsOffScreen];
}

-(void) onScreen {
	[self setPostsOnScreen];
}

-(void) almostOnScreen {
	for (PostView* postView in self.postViews) {
		[postView preparepostToBePresented];
	}
}

-(void) pauseAllVideos {

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
