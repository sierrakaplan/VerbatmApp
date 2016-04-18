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
#import "Page_BackendObject.h"
#import "Post_BackendObject.h"

@interface FeaturedContentCellView()

@property (strong, nonatomic) UIScrollView *horizontalScrollView;
@property (strong, nonatomic) NSMutableArray *channelViews;

#define CHANNEL_VIEW_WIDTH 200.f
#define CHANNEL_VIEW_OFFSET 20.f

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
		[Post_BackendObject getPostsInChannel:channel withCompletionBlock:^(NSArray *posts) {
			if (posts.count > 0) {
				[Page_BackendObject getPagesFromPost:posts[0] andCompletionBlock:^(NSArray * pages) {
					CGRect frame = CGRectMake(xCoordinate, CHANNEL_VIEW_OFFSET, CHANNEL_VIEW_WIDTH,
											  self.frame.size.height - (CHANNEL_VIEW_OFFSET*2));
					FeaturedContentChannelView *channelView = [[FeaturedContentChannelView alloc] initWithFrame:frame andChannel:channel
																									   andPostObject:posts[0] andPages: pages];
					xCoordinate += CHANNEL_VIEW_WIDTH + CHANNEL_VIEW_OFFSET;
					self.horizontalScrollView.contentSize = CGSizeMake(xCoordinate, self.horizontalScrollView.contentSize.height);
					[self.horizontalScrollView addSubview:channelView];
					[self.channelViews addObject: channelView];
				}];
			}
		}];
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
		_horizontalScrollView.showsVerticalScrollIndicator = NO;
		_horizontalScrollView.showsHorizontalScrollIndicator = YES;
	}
	return _horizontalScrollView;
}

@end
