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
#import "PublishingProgressView.h"
#import "PostCollectionViewCell.h"
#import "Share_BackendManager.h"
#import "SizesAndPositions.h"
#import "UIView+Effects.h"
@interface PostCollectionViewCell () <PostViewDelegate>

@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL isAlmostOnScreen;

@property (nonatomic) BOOL footerUp;
@property (nonatomic) PublishingProgressView * publishingProgressView;
@property (nonatomic) BOOL hasPublishingView;
@property (nonatomic) BOOL hasShadow;

//temp
@property (nonatomic) UIView * dot;
@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    
	self = [super initWithFrame:frame];
	if (self) {
        
		self.backgroundColor = [UIColor clearColor];
		[self clearViews];
		[self setClipsToBounds:NO];
        [self.layer setCornerRadius:POST_VIEW_CORNER_RADIUS];

    }
    
	return self;
    
}

-(void) clearViews {
	if (self.currentPostView) {
		[self.currentPostView removeFromSuperview];
	}

	[self removePublishingProgress];
    
	@autoreleasepool {
		self.currentPostView = nil;
		self.currentPostActivityObject = nil;
		self.postBeingPresented = nil;
	}
    
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
}

-(void) layoutSubviews {
	self.currentPostView.frame = self.bounds;
	if(!self.hasShadow){
		//[self addShadowToView];
		self.hasShadow = YES;
	}
}

-(void)presentPublishingView{
	[self addSubview:self.publishingProgressView];
	self.hasPublishingView = YES;
}

-(void)removePublishingProgress{
	if(_publishingProgressView != nil){
		[self.publishingProgressView removeFromSuperview];
		@autoreleasepool {
			_publishingProgressView = nil;
		}
	}
}

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete andLikeShareBarUp:(BOOL) up {

	[self removePublishingProgress];
	self.hasPublishingView = NO;
	self.footerUp = up;
	self.currentPostActivityObject = pfActivityObj;
	PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];

	__weak PostCollectionViewCell *weakSelf = self;

	[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
		weakSelf.currentPostView = [[PostView alloc] initWithFrame:weakSelf.bounds
									  andPostChannelActivityObject:pfActivityObj small:weakSelf.inSmallMode andPageObjects:pages];

		if(weakSelf.inSmallMode)[weakSelf.currentPostView muteAllVideos:YES];
		NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
		if (weakSelf.isOnScreen) {
			[weakSelf.currentPostView postOnScreen];
		} else if (weakSelf.isAlmostOnScreen) {
			[weakSelf.currentPostView postAlmostOnScreen];
		} else {
			[weakSelf.currentPostView postOffScreen];
		}
		weakSelf.currentPostView.delegate = weakSelf;
		weakSelf.currentPostView.listChannel = channelForList;
		[weakSelf addSubview: weakSelf.currentPostView];
		weakSelf.currentPostView.inSmallMode = weakSelf.inSmallMode;

		if(!weakSelf.inSmallMode){
			NSNumber *numLikes = post[POST_NUM_LIKES];
			NSNumber *numShares = post[POST_NUM_REBLOGS];
			[weakSelf.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
															   numberOfPages:numberOfPages
													   andStartingPageNumber:@(1)
																	 startUp:up
															withDeleteButton:withDelete];
			[weakSelf.currentPostView addCreatorInfo];
		}
        [weakSelf bringSubviewToFront:weakSelf.dot];
	}];
}

-(void) showWhoLikesThePost:(PFObject *) post{
	[self.cellDelegate showWhoLikesThePost:post];
}


-(void)setInSmallMode:(BOOL)inSmallMode{
	_inSmallMode = inSmallMode;
	if(_currentPostView){
		_currentPostView.inSmallMode = inSmallMode;
	}
}

-(void) almostOnScreen {
	self.isAlmostOnScreen = YES;
	if(!self.hasPublishingView){
		if(self.currentPostView){
			[self.currentPostView postAlmostOnScreen];
		}
	}
}

-(void) onScreen {
	self.isOnScreen = YES;
	self.isAlmostOnScreen = NO;
	if(!self.hasPublishingView){
		if(self.currentPostView) {
			[self.currentPostView postOnScreen];
		}
	}
}

-(void)removeDot{
    if(self.dot){
        [self.dot removeFromSuperview];
        self.dot = nil;
    }
}

-(void)addDot{
    if(self.dot){
        [self bringSubviewToFront:self.dot];
    }else{
        self.dot = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 15.f)/2.f,  -20.f, 15.f, 15.f)];
        [self.dot setBackgroundColor:[UIColor colorWithRed:0.f/255.f  green:191.f/255.f blue:255.f/255.f  alpha:1.f]];
        [self addSubview:self.dot];
        [self.dot.layer setCornerRadius:7.5];
    }
}



-(void) offScreen {
	[self clearViews];
}

#pragma mark - Post view delegate -

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post {
	[self.cellDelegate shareOptionSelectedForParsePostObject:post];
}

-(void) channelSelected:(Channel *) channel {
	[self.cellDelegate channelSelected:channel];
}

-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post reblogged: (BOOL)reblogged {
	[self.cellDelegate deleteButtonSelectedOnPostView:postView withPostObject:post
							andPostChannelActivityObj:self.currentPostActivityObject reblogged:reblogged];
}

-(void) flagButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post {
	[self.cellDelegate flagOrBlockButtonSelectedOnPostView:postView withPostObject:post];
}

-(PublishingProgressView *)publishingProgressView{
	if(!_publishingProgressView){
		_publishingProgressView = [[PublishingProgressView alloc] initWithFrame:self.bounds];
	}
	return _publishingProgressView;
}

-(void)dealloc{
}

@end
