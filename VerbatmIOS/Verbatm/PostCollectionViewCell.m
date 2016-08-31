//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Like_BackendManager.h"

#import "Notifications.h"

#import <Parse/PFObject.h>
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PublishingProgressView.h"
#import "PostCollectionViewCell.h"
#import "Share_BackendManager.h"
#import "SizesAndPositions.h"
#import "UIView+Effects.h"
#import "Icons.h"

@interface PostCollectionViewCell () <PostViewDelegate>

@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PFObject *currentPostObject;//the post in the post activity object
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL isAlmostOnScreen;

@property (nonatomic) BOOL footerUp;
@property (nonatomic) PublishingProgressView * publishingProgressView;
@property (nonatomic) BOOL presentingPrompt;
@property (nonatomic) BOOL hasShadow;

@property (nonatomic) UIImageView * tapToExitNotification;
//temp
@property (nonatomic) UIView * dot;

@property (nonatomic) UIButton *smallLikeButton;
@property (nonatomic) UIButton *smallShareButton;
@property (nonatomic) UIButton *smallCommentButton;

@property (nonatomic) UILabel * numLikeLabel;
@property (nonatomic) UILabel * numSharesLabel;
@property (nonatomic) UILabel * numCommentsLabel;

@property (nonatomic) NSNumber * numLikes;
@property (nonatomic) NSNumber * numShares;
@property (nonatomic) NSNumber * numComments;

@property (nonatomic) UIButton * createPostPrompt;

#define POSTVIEW_FRAME ((self.inSmallMode) ? CGRectMake(0.f, SMALL_SQUARE_LIKESHAREBAR_HEIGHT, self.frame.size.width, self.frame.size.height - SMALL_SQUARE_LIKESHAREBAR_HEIGHT) : self.bounds)

#define LIKE_BUTTION_SIZE 25.f
#define SHARE_BUTTION_SIZE 20.f

#define LIKE_BUTTON_WALL_OFFSET 5.f
#define SMALL_ICON_SPACING 5.f

#define SMALL_NUMBER_TEXT_COLOR whiteColor
@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (self) {

		self.backgroundColor = [UIColor clearColor];
		[self clearViews];
		[self setClipsToBounds:NO];
		[self.layer setCornerRadius:POST_VIEW_CORNER_RADIUS];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newCommentRegistered:)
                                                     name:NOTIFICATION_NEW_COMMENT_USER
                                                   object:nil];
        

	}

	return self;

}



-(void)newCommentRegistered:(NSNotification *)notification{
    NSString * postCommentedOnObjectId = [[notification userInfo] objectForKey:POST_COMMENTED_ON_NOTIFICATION_USERINFO_KEY];
    if(self.postBeingPresented && self.inSmallMode && [[self.postBeingPresented objectId] isEqualToString:postCommentedOnObjectId]){
        self.numComments = [NSNumber numberWithInteger:([self.numComments integerValue]+1)];
        [self clearLikeAndCommentInformation];
        [self presentSmallLikeButton];
    }
}

-(void)clearLikeAndCommentInformation{
        [self.numSharesLabel removeFromSuperview];
        [self.smallShareButton removeFromSuperview];
        [self.numLikeLabel removeFromSuperview];
        [self.smallLikeButton removeFromSuperview];
        [self.numCommentsLabel removeFromSuperview];
        [self.smallCommentButton removeFromSuperview];
        self.numCommentsLabel = nil;
        self.smallCommentButton = nil;
        self.numSharesLabel = nil;
        self.smallShareButton = nil;
        self.numLikeLabel = nil;
        self.smallLikeButton = nil;
}

-(void) clearViews {

	if (self.currentPostView) {
		[self.currentPostView removeFromSuperview];
	}

	[self removePrompts];
    [self clearLikeAndCommentInformation];
    self.currentPostView = nil;
    self.currentPostActivityObject = nil;
    self.postBeingPresented = nil;

	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
    self.presentingPrompt = NO;
}

-(void) layoutSubviews {
	if (self.currentPostView) {
		self.currentPostView.frame = POSTVIEW_FRAME;
	}
	if(!self.hasShadow){
		//[self addShadowToView];
		self.hasShadow = YES;
	}
}

-(void)presentPromptView:(NSNumber *) promptType{
    LastPostType type = [promptType integerValue];
    if(type == PublishingPostPrompt){
        [self addSubview:self.publishingProgressView];
    }else{
        [self addSubview:self.createPostPrompt];
    }
    self.presentingPrompt = YES;
	
}

-(void)removePrompts{
	if(_publishingProgressView){
		[self.publishingProgressView removeFromSuperview];
		@autoreleasepool {
			_publishingProgressView = nil;
		}
	}
    
    if(_createPostPrompt){
        [self.createPostPrompt removeFromSuperview];
        _createPostPrompt = nil;
    }
}


-(BOOL)stillHasOriginalPost:(PFObject *)pfActivityObj{
    
    if (self.presentingPrompt || (self.currentPostActivityObject != nil && ![self.currentPostActivityObject.objectId isEqualToString:pfActivityObj.objectId])) {
        return NO;
    }
    return YES;
}

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete andLikeShareBarUp:(BOOL) up {

	[self removePrompts];
	self.presentingPrompt = NO;
    
	self.footerUp = up;
	self.currentPostActivityObject = pfActivityObj;
	PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
    self.postBeingPresented = post;
	[post fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (![self stillHasOriginalPost:pfActivityObj]) return;
        
		self.numLikes = object[POST_NUM_LIKES];
		self.numShares = object[POST_NUM_REBLOGS];
		self.numComments = object[POST_NUM_COMMENTS];

		[Page_BackendObject getPagesFromPost:object andCompletionBlock:^(NSArray * pages) {

			if (![self stillHasOriginalPost:pfActivityObj])return;
            
			self.currentPostView = [[PostView alloc] initWithFrame:POSTVIEW_FRAME
									  andPostChannelActivityObject:pfActivityObj small:self.inSmallMode andPageObjects:pages];
			if(self.inSmallMode)[self.currentPostView muteAllVideos:YES];
			NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
			if (self.isOnScreen) {
				[self.currentPostView postOnScreen];
			} else if (self.isAlmostOnScreen) {
				[self.currentPostView postAlmostOnScreen];
			} else {
				[self.currentPostView postAlmostOnScreen];
			}
			self.currentPostView.delegate = self;
			self.currentPostView.listChannel = channelForList;

			if(self.tapToExitNotification) {
				[self insertSubview: self.currentPostView belowSubview: self.tapToExitNotification];
			} else {
				[self addSubview: self.currentPostView];
			}
			self.currentPostView.inSmallMode = self.inSmallMode;

			if (self.inSmallMode){
				[self.currentPostView checkIfUserHasLikedThePost];
			} else {
				[self.currentPostView createLikeAndShareBarWithNumberOfLikes: self.numLikes
															  numberOfShares: self.numShares numberOfComments: self.numComments
															   numberOfPages:numberOfPages andStartingPageNumber:@(1) startUp:up
															withDeleteButton:withDelete];
				[self.currentPostView addCreatorInfo];

			}
			[self bringSubviewToFront: self.dot];
		}];
	}];
}


-(void) showWhoLikesThePost:(PFObject *) post{
	[self.cellDelegate showWhoLikesThePost:post];
}

-(void)showWhoCommentedOnPost:(PFObject *) post{
    [self.cellDelegate showWhoCommentedOnPost:post];
}


-(void)setInSmallMode:(BOOL)inSmallMode{
	_inSmallMode = inSmallMode;
	if(_currentPostView){
		_currentPostView.inSmallMode = inSmallMode;
	}
}

-(void) almostOnScreen {
	self.isAlmostOnScreen = YES;
	if(!self.presentingPrompt){
		if(self.currentPostView){
			[self.currentPostView postAlmostOnScreen];
		}
	}
}

-(void) onScreen {
	self.isOnScreen = YES;
	self.isAlmostOnScreen = NO;
	if(!self.presentingPrompt){
		if(self.currentPostView) {
			[self.currentPostView postOnScreen];
		}
	}
}

-(void) offScreen {
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
	[self.currentPostView postOffScreen];
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

-(void)presentTapToExitNotification{
	self.tapToExitNotification = [[UIImageView alloc] initWithImage:[UIImage imageNamed:TAP_TO_EXIT_FULLSCREENPOV_INSTRUCTION]];
	self.tapToExitNotification.frame = self.bounds;
	[self addSubview:self.tapToExitNotification];
	self.presentingTapToExitNotification = YES;
}

-(void)removeTapToExitNotification{
	if(self.tapToExitNotification){
		[self.tapToExitNotification removeFromSuperview];
		self.tapToExitNotification = nil;
		[self.cellDelegate justRemovedTapToExitNotification];
		self.presentingTapToExitNotification = NO;
	}
}

-(void)commentButtonPressed{
    [self.currentPostView commentButtonPressed];
}
-(void)likeButtonPressed{
	[self.currentPostView likeButtonPressed];
}

-(void)shareButtonPressed{
	[self.currentPostView shareButtonPressed];
}

#pragma mark - Post view delegate -

-(void)presentSmallLikeButton{
    if(self.presentingPrompt) return;
    
    if(self.numComments == nil){
        self.numComments = @(0);
    }
    
    //create LikeButton
    CGFloat likeButtonY =  2.5;
    CGFloat shareButtonY = 5.f;
    CGRect likeButtonFrame =  CGRectMake(LIKE_BUTTON_WALL_OFFSET,
                                         likeButtonY,
                                         LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE);
    if(!self.smallLikeButton){
        self.smallLikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smallLikeButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.smallLikeButton setFrame:likeButtonFrame];
        [self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_UNPRESSED] forState:UIControlStateNormal];
        [self.smallLikeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.smallLikeButton];
    }
    
    if(!self.numLikeLabel){
        self.numLikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.smallLikeButton.frame.origin.x + self.smallLikeButton.frame.size.width + SMALL_ICON_SPACING, likeButtonY, LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE)];
        [self.numLikeLabel setTextColor:[UIColor SMALL_NUMBER_TEXT_COLOR]];
        [self addSubview:self.numLikeLabel];
    }
    
    [self.numLikeLabel setText:[self.numLikes stringValue]];

    //create share button
    if(!self.smallShareButton){
        self.smallShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smallShareButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.smallShareButton setFrame:CGRectMake(self.numLikeLabel.frame.origin.x + self.numLikeLabel.frame.size.width + SMALL_ICON_SPACING, shareButtonY, SHARE_BUTTION_SIZE, SHARE_BUTTION_SIZE)];
        [self.smallShareButton setImage:[UIImage imageNamed:SMALL_SHARE_ICON] forState:UIControlStateNormal];
        [self.smallShareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.smallShareButton];
    }
    
    if(!self.numSharesLabel){
        self.numSharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.smallShareButton.frame.origin.x + self.smallShareButton.frame.size.width + SMALL_ICON_SPACING, shareButtonY, LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE)];
        [self.numSharesLabel setTextColor:[UIColor SMALL_NUMBER_TEXT_COLOR]];
        [self addSubview:self.numSharesLabel];
    }
    
    [self.numSharesLabel setText:[self.numShares stringValue]];
    
    //create comment button
    if(!self.smallCommentButton){
        self.smallCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smallCommentButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.smallCommentButton setFrame:CGRectMake(self.numSharesLabel.frame.origin.x + self.numSharesLabel.frame.size.width + SMALL_ICON_SPACING, shareButtonY, SHARE_BUTTION_SIZE, SHARE_BUTTION_SIZE)];
        [self.smallCommentButton setImage:[UIImage imageNamed:SMALL_COMMENT_ICON] forState:UIControlStateNormal];
        [self.smallCommentButton addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.smallCommentButton];
    }
    
    if(!self.numCommentsLabel){
        self.numCommentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.smallCommentButton.frame.origin.x + self.smallCommentButton.frame.size.width + SMALL_ICON_SPACING, shareButtonY, LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE)];
        [self.numCommentsLabel setTextColor:[UIColor SMALL_NUMBER_TEXT_COLOR]];
        [self addSubview:self.numCommentsLabel];
    }
    
    [self.numCommentsLabel setText:[self.numComments stringValue]];
}
//set the start state of the like button
-(void)startLikeButtonAsLiked:(BOOL)isLiked {
    if(isLiked){
        [self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_PRESSED ] forState:UIControlStateNormal];
    }else{
        [self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_UNPRESSED] forState:UIControlStateNormal];
    }
}

-(void)updateSmallLikeButton:(BOOL)isLiked {
	NSInteger numLikes;
	if(isLiked){
		[self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_PRESSED ] forState:UIControlStateNormal];
		numLikes = [self.numLikes integerValue] + 1;
	}else{
		[self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_UNPRESSED] forState:UIControlStateNormal];
		numLikes = (([self.numLikes integerValue]-1) < 0) ? 0 : ([self.numLikes integerValue]-1);
	}
	self.numLikes = [NSNumber numberWithInteger:numLikes];
	if(self.numLikeLabel)[self.numLikeLabel setText:[self.numLikes stringValue]];
}

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post {
	[self.cellDelegate shareOptionSelectedForParsePostObject:post];
}

-(void)removePostViewSelected{
	[self.cellDelegate removePostViewSelected];
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


-(void)createPostPromptSelected{
    [self.cellDelegate createPostPromptSelected];
}

-(UIButton *)createPostPrompt{
    
    if(!_createPostPrompt){
        _createPostPrompt = [[UIButton alloc] initWithFrame:self.bounds];
        [_createPostPrompt setImage:[UIImage imageNamed:ADD_FIRST_POST_ICON] forState:UIControlStateNormal];
        _createPostPrompt.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_createPostPrompt addTarget:self action:@selector(createPostPromptSelected) forControlEvents:UIControlEventTouchDown];
    }
    
    return _createPostPrompt;
    
}

-(PublishingProgressView *)publishingProgressView{
	if(!_publishingProgressView){
		_publishingProgressView = [[PublishingProgressView alloc] initWithFrame:POSTVIEW_FRAME];
	}
	return _publishingProgressView;
}

-(void)dealloc{
}

@end
