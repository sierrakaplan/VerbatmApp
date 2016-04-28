//
//  FeaturedContentCellView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "FeaturedContentCellView.h"
#import "FeaturedContentChannelView.h"
#import "ParseBackendKeys.h"
#import "Page_BackendObject.h"
#import "Post_BackendObject.h"
#import "PostsQueryManager.h"

@interface FeaturedContentCellView() <UIScrollViewDelegate, FeaturedChannelViewDelegate>

@property (strong, nonatomic) UIScrollView *horizontalScrollView;
@property (strong, nonatomic) NSMutableArray *channelViews;

@property (nonatomic) NSInteger indexOnScreen;

#define CHANNEL_VIEW_WIDTH 200.f
#define CHANNEL_VIEW_OFFSET 10.f

@end

@implementation FeaturedContentCellView

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.alreadyPresented = NO;
		self.backgroundColor = [UIColor lightGrayColor];
		[self addSubview:self.horizontalScrollView];
		self.indexOnScreen = 0;
	}
	return self;
}

-(void) layoutSubviews {
	self.horizontalScrollView.frame = self.bounds;
	CGFloat xCoordinate = CHANNEL_VIEW_OFFSET;
	for (FeaturedContentCellView *channelView in self.channelViews) {
		CGRect frame = CGRectMake(xCoordinate, CHANNEL_VIEW_OFFSET, CHANNEL_VIEW_WIDTH,
								  self.frame.size.height - (CHANNEL_VIEW_OFFSET*2));
		channelView.frame = frame;
		xCoordinate += CHANNEL_VIEW_WIDTH + CHANNEL_VIEW_OFFSET;
	}
	self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate, self.horizontalScrollView.contentSize.height);
}

-(void) presentChannels:(NSArray *)channels {
	self.alreadyPresented = YES;
	__block CGFloat xCoordinate = CHANNEL_VIEW_OFFSET;
	for (Channel *channel in channels) {
		[PostsQueryManager getPostsInChannel:channel withLimit:1 withCompletionBlock:^(NSArray *postChannelActivityObjects) {
			if (postChannelActivityObjects.count < 1) return;
			PFObject *postChannelActivityObj = postChannelActivityObjects[0];
			PFObject *post = [postChannelActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
			[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
				CGRect frame = CGRectMake(xCoordinate, CHANNEL_VIEW_OFFSET, CHANNEL_VIEW_WIDTH,
										  self.frame.size.height - (CHANNEL_VIEW_OFFSET*2));
				FeaturedContentChannelView *channelView = [[FeaturedContentChannelView alloc] initWithFrame:frame andChannel:channel
																							  andPostObject:post andPages: pages];
				xCoordinate += CHANNEL_VIEW_WIDTH + CHANNEL_VIEW_OFFSET;
				self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate, self.horizontalScrollView.contentSize.height);
				[self.horizontalScrollView addSubview:channelView];
				if (self.channelViews.count == self.indexOnScreen || self.channelViews.count == self.indexOnScreen+1) {
					[channelView onScreen];
				} else if (self.channelViews.count == (self.indexOnScreen+2)) {
					[channelView almostOnScreen];
				}
				channelView.delegate = self;
				[self.channelViews addObject: channelView];
			}];
		}];
	}
}

-(void) clearViews {
	self.alreadyPresented = NO;
	[self offScreen];
	for (FeaturedContentChannelView *channelView in self.channelViews) {
		[channelView removeFromSuperview];
	}
	self.channelViews = nil;
	self.indexOnScreen = 0;
}

-(void) channelSelected:(Channel *)channel {
	[self.delegate channelSelected:channel];
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
	NSInteger postIndex = originX / (CHANNEL_VIEW_WIDTH + CHANNEL_VIEW_OFFSET);

	//Three posts can be visible
	for (NSInteger i = postIndex; i < postIndex+3; i++) {
		// Set previous on screen posts off screen
		NSInteger previousPostIndex = self.indexOnScreen+(i-postIndex);
		if (previousPostIndex < self.channelViews.count &&
			(previousPostIndex < postIndex || previousPostIndex > postIndex+2)) {
			[(FeaturedContentChannelView*)self.channelViews[previousPostIndex] offScreen];
		}
		// set posts on screen
		if (i < self.channelViews.count) {
			[(FeaturedContentChannelView*)self.channelViews[i] onScreen];
		}
	}
	// Prepare next view
	if (postIndex + 3 < self.channelViews.count) {
		[(FeaturedContentChannelView*)self.channelViews[postIndex+3] almostOnScreen];
	}
}

-(void) setAllPostsOffScreen {
	for (FeaturedContentChannelView* channelView in self.channelViews) {
		[channelView offScreen];
	}
}

-(void) offScreen {
	[self setAllPostsOffScreen];
}

-(void) onScreen {
	[self setPostsOnScreen];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray *) channelViews {
	if (!_channelViews) {
		_channelViews = [[NSMutableArray alloc] init];
	}
	return _channelViews;
}

-(UIScrollView *) horizontalScrollView {
	if (!_horizontalScrollView) {
		_horizontalScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_horizontalScrollView.backgroundColor = self.backgroundColor;
		_horizontalScrollView.delegate = self;
		_horizontalScrollView.showsVerticalScrollIndicator = NO;
		_horizontalScrollView.showsHorizontalScrollIndicator = YES;
	}
	return _horizontalScrollView;
}

@end
