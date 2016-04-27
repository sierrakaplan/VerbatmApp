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

@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL isAlmostOnScreen;

@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self clearViews];
	}
	return self;
}

-(void) clearViews {
	//todo: clear data from our current post more?
	if (self.currentPostView) {
		[self.currentPostView removeFromSuperview];
		[self.currentPostView clearPost];
	}
	self.currentPostView = nil;
	self.currentPostActivityObject = nil;
	self.postBeingPresented = nil;
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
}

-(void) layoutSubviews {
	self.currentPostView.frame = self.bounds;
}

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete {
	self.currentPostActivityObject = pfActivityObj;
	PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
	[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
		self.currentPostView = [[PostView alloc] initWithFrame:self.bounds
								andPostChannelActivityObject:pfActivityObj small:NO];

		NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
		[self.currentPostView renderPostFromPageObjects: pages];
		if (self.isOnScreen) {
			[self.currentPostView postOnScreen];
		} else if (self.isAlmostOnScreen) {
			[self.currentPostView postAlmostOnScreen];
		} else {
			[self.currentPostView postOffScreen];
		}
		self.currentPostView.delegate = self;
		self.currentPostView.listChannel = channelForList;
		[self addSubview: self.currentPostView];

		AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
		AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
		PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
			NSNumber *numLikes = likesAndShares[0];
			NSNumber *numShares = likesAndShares[1];
			[self.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
											   numberOfPages:numberOfPages
									   andStartingPageNumber:@(1)
													 startUp:YES
											withDeleteButton:withDelete];
			[self.currentPostView addCreatorInfo];
		});
	}];
}

-(void) shiftLikeShareBarDown:(BOOL) down {
	if (self.currentPostView) {
		[self.currentPostView shiftLikeShareBarDown: down];
	}
}

-(void) almostOnScreen {
	self.isAlmostOnScreen = YES;
	if(self.currentPostView){
		[self.currentPostView postAlmostOnScreen];
	}
}

-(void) onScreen {
	self.isOnScreen = YES;
	self.isAlmostOnScreen = NO;
	if(self.currentPostView) {
		[self.currentPostView postOnScreen];
	}
}

-(void) offScreen {
	self.isOnScreen = NO;
	if(self.currentPostView) {
		[self.currentPostView postOffScreen];
	}
}

#pragma mark - Lazy Instantiation -

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
