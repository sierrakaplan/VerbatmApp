//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Like_BackendManager.h"
#import <Parse/PFObject.h>
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PostCollectionViewCell.h"
#import "Share_BackendManager.h"

@interface PostCollectionViewCell () <PostViewDelegate>

@property (nonatomic, readwrite) PostView *ourCurrentPost;
@property (nonatomic) PFObject *postBeingPresented;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL isOnScreen;

@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		self.isOnScreen = NO;
	}
	return self;
}

-(void) prepareForReuse {
	//todo: clear data from our current post more?
	[self.ourCurrentPost removeFromSuperview];
	self.ourCurrentPost = nil;
}

-(void) layoutSubviews {
	self.ourCurrentPost.frame = self.bounds;
}

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete {
	PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
	[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
		self.ourCurrentPost = [[PostView alloc] initWithFrame:self.bounds
								andPostChannelActivityObject:pfActivityObj small:NO];

		NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
		[self.ourCurrentPost renderPostFromPageObjects: pages];
		if (self.isOnScreen) {
			[self.ourCurrentPost postOnScreen];
		} else {
			[self.ourCurrentPost postOffScreen];
		}
		self.ourCurrentPost.delegate = self;
		self.ourCurrentPost.listChannel = channelForList;
		[self addSubview:self.ourCurrentPost];

		AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
		AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
		PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
			NSNumber *numLikes = likesAndShares[0];
			NSNumber *numShares = likesAndShares[1];
			[self.ourCurrentPost createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
											   numberOfPages:numberOfPages
									   andStartingPageNumber:@(1)
													 startUp:YES
											withDeleteButton:withDelete];
			[self.ourCurrentPost addCreatorInfo];
		});
	}];
}

-(void) shiftLikeShareBarDown:(BOOL) down {
	if (self.ourCurrentPost) {
		[self.ourCurrentPost shiftLikeShareBarDown: down];
	}
}

-(void) almostOnScreen {
	if(self.ourCurrentPost){
		[self.ourCurrentPost preparepostToBePresented];
	}
}

-(void) onScreen {
	self.isOnScreen = YES;
	if(self.ourCurrentPost) {
		[self.ourCurrentPost postOnScreen];
	}
}

-(void) offScreen {
	self.isOnScreen = NO;
	if(self.ourCurrentPost){
		[self.ourCurrentPost postOffScreen];
	}
}

#pragma mark - Lazy Instantiation -

-(PostView *) ourCurrentPost{
	if(!_ourCurrentPost){
		_ourCurrentPost = [[PostView alloc] initWithFrame:self.bounds andPostChannelActivityObject:nil small:NO];
		[self addSubview:_ourCurrentPost];
	}
	return _ourCurrentPost;
}

-(UIActivityIndicatorView*) activityIndicator {
	if (!_activityIndicator) {
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicator.color = [UIColor grayColor];
		_activityIndicator.hidesWhenStopped = YES;
		_activityIndicator.center = CGPointMake(self.center.x, self.frame.size.height * 1.f/3.f);
		[self.contentView addSubview:_activityIndicator];
		[self.contentView bringSubviewToFront:_activityIndicator];
	}
	return _activityIndicator;
}
@end
