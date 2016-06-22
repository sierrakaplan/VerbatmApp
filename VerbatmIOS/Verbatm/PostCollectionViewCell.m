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
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL isAlmostOnScreen;

@property (nonatomic) BOOL footerUp;

@property (nonatomic) BOOL inSmallMode;

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
	if (self.currentPostView) {
		[self.currentPostView removeFromSuperview];
		[self.currentPostView clearPost];
	}
    self.clipsToBounds = YES;
	self.currentPostView = nil;
	self.currentPostActivityObject = nil;
	self.postBeingPresented = nil;
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
    self.autoresizesSubviews = YES;
}

-(void) layoutSubviews {
	//self.currentPostView.frame = self.bounds;
}
-(void)putInSmallMode{
    self.inSmallMode = YES;
    [self.currentPostView putInSmallProfileMode];
}
-(void)removeFromSmallMode {

    self.inSmallMode = NO;
    [self.currentPostView removeFromSmallProfileMode];

}

-(void)changePostFrameToSize:(CGSize) newSize {
//    -(void)viewSizeAbouToChangeTo:(CGSize) newSize{
    [self.currentPostView viewSizeAbouToChangeTo:newSize];
    
//    
//    if(self.inSmallMode){
//        [self removeFromSmallMode];
//    }else{
//        [self putInSmallMode];
//    }
}

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete andLikeShareBarUp:(BOOL) up {
	self.footerUp = up;
	self.currentPostActivityObject = pfActivityObj;
	PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
	
    
    [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
		self.currentPostView = [[PostView alloc] initWithFrame:self.bounds
								andPostChannelActivityObject:pfActivityObj small:self.inSmallMode andPageObjects:pages];
        self.currentPostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.currentPostView.autoresizesSubviews = YES;
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
        
        
        
		AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
		AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
		PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
//			NSNumber *numLikes = likesAndShares[0];
//			NSNumber *numShares = likesAndShares[1];
//			[self.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
//											   numberOfPages:numberOfPages
//									   andStartingPageNumber:@(1)
//													 startUp:up
//											withDeleteButton:withDelete];
//			[self.currentPostView addCreatorInfo];
		});
	}];
}

-(void) shiftLikeShareBarDown:(BOOL) down {
	if (self.currentPostView) {
		[self.currentPostView shiftLikeShareBarDown: down];
	} else {
		self.footerUp = !down;
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

@end
