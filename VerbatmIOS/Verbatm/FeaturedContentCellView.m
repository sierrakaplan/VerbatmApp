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

@interface FeaturedContentCellView() <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *horizontalScrollView;
@property (strong, nonatomic) NSMutableArray *channelViews;

#define CHANNEL_VIEW_WIDTH 230.f
#define CHANNEL_VIEW_OFFSET 10.f

@end

@implementation FeaturedContentCellView

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = [UIColor lightGrayColor];
		[self addSubview:self.horizontalScrollView];
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
	__block CGFloat xCoordinate = CHANNEL_VIEW_OFFSET;
	for (Channel *channel in channels) {
		[Post_BackendObject getPostsInChannel:channel withCompletionBlock:^(NSArray *postChannelActivityObjects) {
			//			for (PFObject *postChannelActivityObj in postChannelActivityObjects) {
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
				[self.channelViews addObject: channelView];
			}];
		}];
	}
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGFloat originX = self.horizontalScrollView.contentOffset.x;
	NSInteger postIndex = originX / (CHANNEL_VIEW_WIDTH + CHANNEL_VIEW_OFFSET);
	if (postIndex < self.channelViews.count) {
		[(FeaturedContentChannelView*)self.channelViews[postIndex] onScreen];
	}
	//Two posts are visible
	if (postIndex + 1 < self.channelViews.count) {
		[(FeaturedContentChannelView*)self.channelViews[postIndex+1] onScreen];
	}
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
		_horizontalScrollView.backgroundColor = [UIColor grayColor];
		_horizontalScrollView.delegate = self;
		_horizontalScrollView.showsVerticalScrollIndicator = NO;
		_horizontalScrollView.showsHorizontalScrollIndicator = YES;
	}
	return _horizontalScrollView;
}

@end
