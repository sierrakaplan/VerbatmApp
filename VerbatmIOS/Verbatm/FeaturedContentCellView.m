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

@interface FeaturedContentCellView()

@property (strong, nonatomic) UIScrollView *horizontalScrollView;

#define CHANNEL_VIEW_WIDTH 200.f

@end

@implementation FeaturedContentCellView

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = [UIColor grayColor];
		[self addSubview:self.horizontalScrollView];
	}
	return self;
}

-(void) layoutSubviews {
	// get post views to show up
}

-(void) presentChannels:(NSArray *)channels {
	CGFloat xCoordinate = 0.f;
	for (Channel *channel in channels) {
		CGRect frame = CGRectMake(xCoordinate, 0.f, CHANNEL_VIEW_WIDTH, self.frame.size.height);
//		[Post_BackendObject getPostsInChannel:self.channel withCompletionBlock:^(NSArray *posts) {
//			self.posts = posts;
//			if (posts.count > 0) {
//				[Page_BackendObject getPagesFromPost:posts[0] andCompletionBlock:^(NSArray * pages) {
//					//todo: make sure that only channels with posts go into discover
//					self.postView = [[PostView alloc] initWithFrame:postViewFrame andPostChannelActivityObject:posts[0]];
//					[self.postView renderPostFromPageObjects:pages];
//					[self.postView postOffScreen];
//					[self addSubview: self.postView];
//				}];
//			}
//		}];
		FeaturedContentChannelView *channelView = [[FeaturedContentChannelView alloc] initWithFrame:frame andChannel:channel];
		xCoordinate += CHANNEL_VIEW_WIDTH;
		[self.horizontalScrollView addSubview:channelView];
	}
	self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate + CHANNEL_VIEW_WIDTH, 0.f);
}

#pragma mark - Lazy Instantiation -

-(UIScrollView *) horizontalScrollView {
	if (!_horizontalScrollView) {
		_horizontalScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_horizontalScrollView.backgroundColor = [UIColor grayColor];
		_horizontalScrollView.showsVerticalScrollIndicator = NO;
		_horizontalScrollView.showsHorizontalScrollIndicator = YES;
	}
	return _horizontalScrollView;
}

@end
