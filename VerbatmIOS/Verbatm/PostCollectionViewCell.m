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
@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    
	self = [super initWithFrame:frame];
	if (self) {
        self.backgroundColor = [UIColor clearColor];
		[self clearViews];
        [self setClipsToBounds:YES];
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
	[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
		self.currentPostView = [[PostView alloc] initWithFrame:self.bounds
								andPostChannelActivityObject:pfActivityObj small:self.inSmallMode andPageObjects:pages];

        if(self.inSmallMode)[self.currentPostView muteAllVideos:YES];
		NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
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
        self.currentPostView.inSmallMode = self.inSmallMode;
        
        if(!self.inSmallMode){
            AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
            AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
            PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
                NSNumber *numLikes = likesAndShares[0];
                NSNumber *numShares = likesAndShares[1];
                [self.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
                                                   numberOfPages:numberOfPages
                                           andStartingPageNumber:@(1)
                                                         startUp:up
                                                withDeleteButton:withDelete];
                [self.currentPostView addCreatorInfo];
            });
        }
	}];
}
-(void) showWhoLikesThePost:(PFObject *) post{
    [self.cellDelegate showWhoLikesThePost:post];
}

-(void) shiftLikeShareBarDown:(BOOL) down {
    if(!self.hasPublishingView){
        if (self.currentPostView) {
            [self.currentPostView shiftLikeShareBarDown: down];
        } else {
            self.footerUp = !down;
        }
    }
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

-(void) offScreen {
	self.isOnScreen = NO;
    if(!self.hasPublishingView){
        if(self.currentPostView) {
            [self.currentPostView postOffScreen];
        }
    }else{
        [self.publishingProgressView removeFromSuperview];
        @autoreleasepool {
            _publishingProgressView = nil;
        }
    }
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

@end
