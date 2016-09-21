//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"

#import "LoadingIndicator.h"
#import "CreatorAndChannelBar.h"
#import "Notifications.h"
#import "Durations.h"

#import "Icons.h"

#import "Like_BackendManager.h"

#import "PageTypeAnalyzer.h"
#import "PhotoVideoPVE.h"
#import "PhotoPVE.h"
#import "PostView.h"
#import "ParseBackendKeys.h"
#import <PromiseKit/PromiseKit.h>
#import "Post_Channel_RelationshipManager.h"
#import "PostLikeAndShareBar.h"

#import "SizesAndPositions.h"
#import "Share_BackendManager.h"
#import "Styles.h"

#import "UserManager.h"
#import "UIView+Effects.h"

#import "VideoPVE.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface PostView () <UIScrollViewDelegate, PostLikeAndShareBarProtocol, CreatorAndChannelBarProtocol,PhotoPVETextEntryDelegate, PhotoVideoPVETextEntryDelegate>


@property (nonatomic) UIScrollView *mainScrollView;
// List of PFObjects
@property (nonatomic) NSArray *pageObjects;

// List of PageViewingExperiences
@property (strong, nonatomic) NSMutableArray* pageViews;

@property (strong, nonatomic) PageViewingExperience *currentPage;
@property (nonatomic) NSInteger currentPageIndex;

@property (nonatomic) CreatorAndChannelBar *creatorAndChannelBar;

@property (strong, nonatomic) UIButton* likeButton;
@property (nonatomic) BOOL liked;

@property (nonatomic, strong) UIButton * downArrow;

@property (nonatomic) PostLikeAndShareBar * likeShareBar;
@property (nonatomic) CGRect lsBarDownFrame;// the frame of the like share button with the tab down
@property (nonatomic) CGRect creatorBarFrameUp;
@property (nonatomic) CGRect creatorBarFrameDown;

@property (nonatomic) UIImageView * swipeUpAndDownInstruction;
//line that moves up and down as the user swipes up and down
@property (nonatomic) UIView * pagingLine;

@property (nonatomic) UIImageView * pageUpIndicator;
@property (nonatomic) BOOL pageUpIndicatorDisplayed;

@property(nonatomic) BOOL postIsCurrentlyBeingShown;
@property(nonatomic) BOOL postIsAlmostOnScreen;
@property(nonatomic) BOOL postMuted;

//Tells whether should display media in small format
@property (nonatomic) BOOL small;

#define DOWN_ARROW_WIDTH 30.f
#define DOWN_ARROW_DISTANCE_FROM_BOTTOM 40.f
#define SCROLL_UP_ANIMATION_DURATION 0.7
#define ACTIVITY_ANIMATION_Y 100.f

#define PAGE_UP_ICON_IMAGE @"Page_up"

#define PAGING_LINE_WIDTH 4.f
#define PAGING_LINE_ANIMATION_DURATION 0.5
#define PAGING_LINE_COLE [UIColor whiteColor]

@end

@implementation PostView

-(instancetype)initWithFrame:(CGRect)frame andPostChannelActivityObject:(PFObject*) postChannelActivityObject
					   small:(BOOL) small andPageObjects:(NSArray*) pageObjects {
	self = [self initWithFrame:frame];
	if (self) {
		self.small = small;
		//load all page views
		self.pageObjects = pageObjects;
		if (self.pageObjects) [self createPageViews];
        if (postChannelActivityObject){
            self.parsePostChannelActivityObject = postChannelActivityObject;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newCommentRegistered:)
                                                     name:NOTIFICATION_NEW_COMMENT_USER
                                                   object:nil];

	}
	return self;
}

-(void)newCommentRegistered:(NSNotification *)notification{
    NSString * postCommentedOnObjectId = [[notification userInfo] objectForKey:POST_COMMENTED_ON_NOTIFICATION_USERINFO_KEY];
    
    PFObject * postObject = [self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST];
    
    if(postObject && [[postObject objectId] isEqualToString:postCommentedOnObjectId]){
        [self.likeShareBar incrementComments];
    }
}


-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.pageUpIndicatorDisplayed = NO;
		self.postMuted = NO;
		[self addSubview: self.mainScrollView];
		self.mainScrollView.backgroundColor = [UIColor blackColor];
		[self createBorder];
		[self addPagingLine];
	}
	return self;
}

-(void)addPageToPageViews:(PFObject *)pageObject{
    PageTypes type = [((NSNumber *)[pageObject valueForKey:PAGE_VIEW_TYPE]) intValue];
    switch (type) {
        case PageTypePhoto:
            [self.pageViews addObject:[[PhotoPVE alloc] initWithFrame:self.bounds small:self.small
                                                  isPhotoVideoSubview:NO]];
            break;
        case PageTypeVideo:
            [self.pageViews addObject:[[VideoPVE alloc] initWithFrame:self.bounds]];
            break;
        case PageTypePhotoVideo:
            [self.pageViews addObject:[[PhotoVideoPVE alloc] initWithFrame:self.bounds small:self.small]];
            break;
        default:
            break;
    }
}

// Creates empty PageViewingExperiences to show activity icons but doesn't load media
-(void) createPageViews {
    if(self.small){
        PFObject *pageObject = [self.pageObjects firstObject];
        [self addPageToPageViews:pageObject];
    }else{
        for (PFObject *pageObject in self.pageObjects) {
            [self addPageToPageViews:pageObject];
        }
        self.mainScrollView.scrollEnabled = (self.pageObjects.count > 1);
    }
	
    [self displayPageViews: self.pageViews];
}

-(void) displayPageViews: (NSMutableArray *) pageViews {
	self.pageViews = pageViews;
	self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width,
												 pageViews.count * self.frame.size.height);
	self.mainScrollView.contentOffset = CGPointMake(0, 0);
	CGRect viewFrame = self.bounds;

	for (int i = 0; i < self.pageViews.count; i++) {
		PageViewingExperience* pageView = pageViews[i];
		[pageView offScreen];
		pageView.frame = viewFrame;
		if (self.postMuted && ([pageView isKindOfClass:[VideoPVE class]] ||
							   [pageView isKindOfClass:[PhotoVideoPVE class]])) {
			[(VideoPVE *)pageView muteVideo: YES];
		}
        
        
        if([pageView isKindOfClass:[PhotoVideoPVE class]]){
            ((PhotoVideoPVE *) pageView).textEntryDelegate = self;
        }else if ([pageView isKindOfClass:[PhotoPVE class]]){
            ((PhotoPVE *) pageView).textEntryDelegate = self;
        }
		[self.mainScrollView addSubview: pageView];
		viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
	}
}

-(void) editContentViewTextIsEditing_PhotoVideoPVE{
    [self editContentViewTextIsEditing];
}
-(void) editContentViewTextDoneEditing_PhotoVideoPVE{
    [self editContentViewTextDoneEditing];
}
-(void) editContentViewTextIsEditing{
    [self.mainScrollView setScrollEnabled:NO];
}
-(void) editContentViewTextDoneEditing{
    [self.mainScrollView setScrollEnabled:YES];
}

-(void)createBorder{
    [self setClipsToBounds:YES];
	[self.layer setBorderWidth:0.5];
	[self.layer setCornerRadius:POST_VIEW_CORNER_RADIUS];
	[self.layer setBorderColor:[UIColor blackColor].CGColor];

	self.lsBarDownFrame = CGRectMake(self.frame.size.width - (LIKE_SHARE_BAR_WIDTH + 3.f),
                                     (self.frame.size.height + 10.f) - LIKE_SHARE_BAR_HEIGHT,
                                     LIKE_SHARE_BAR_WIDTH, LIKE_SHARE_BAR_HEIGHT);
}

-(void)addPagingLine{
	CGRect lineFrame = CGRectMake(self.frame.size.width - PAGING_LINE_WIDTH, self.frame.size.height, PAGING_LINE_WIDTH, 0.f);
	self.pagingLine = [[UIView alloc] initWithFrame:lineFrame];
	self.pagingLine.backgroundColor = PAGING_LINE_COLE;
	[self addSubview:self.pagingLine];
	[self bringSubviewToFront:self.pagingLine];
}

-(void)upDatePagingLine{
	//we subtract the page height because the contentOffset is never == contentSize... but our ratio needs to become 1
	CGFloat lineRatio = self.mainScrollView.contentOffset.y/(self.mainScrollView.contentSize.height-self.frame.size.height);
	CGFloat lineHeight = self.frame.size.height * lineRatio;
	CGRect lineFrame = CGRectMake(self.pagingLine.frame.origin.x, self.frame.size.height - lineHeight,
								  self.pagingLine.frame.size.width, lineHeight);
	self.pagingLine.frame = lineFrame;
}

#pragma mark - Display page -

-(void) scrollToPageAtIndex:(NSInteger) pageIndex{
	if(pageIndex < self.pageViews.count && pageIndex >= 0){
		self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollView.frame.size.height * (pageIndex));
		[self displayMediaOnCurrentPage];
	}

	if((![PFUser currentUser][USER_FTUE] || !((NSNumber*)[PFUser currentUser][USER_FTUE]).boolValue)) {
		[self presentSwipeUpAndDownInstruction];
	}
}

-(void) checkIfUserHasLikedThePost {
    __weak PostView *weakSelf = self;
    //this checks if the parse object has been fetched - hack but it's the simplest way
    if([self.parsePostChannelActivityObject createdAt]){
        [Like_BackendManager currentUserLikesPost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST] withCompletionBlock:^(bool userLikedPost) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(weakSelf.inSmallMode){
                    weakSelf.liked = userLikedPost;
                    [weakSelf.delegate presentSmallLikeButton];
                    [weakSelf.delegate startLikeButtonAsLiked:userLikedPost];
                }else{
                    [weakSelf.likeShareBar shouldStartPostAsLiked:userLikedPost];
                }
            });
        }];
    }
}


-(void)updateLikeButton{
    [self.delegate updateSmallLikeButton:self.liked];
}

-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfComments:(NSNumber *) numComments
								numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage
									  startUp:(BOOL)up withDeleteButton: (BOOL)withDelete {

	self.likeShareBar = [[PostLikeAndShareBar alloc] initWithFrame: self.lsBarDownFrame numberOfLikes:numLikes
                                                    numberOfShares:numShares numComments:numComments numberOfPages:numPages andStartingPageNumber:startPage];
	self.likeShareBar.delegate = self;
	if (withDelete) {
		[self.likeShareBar createDeleteButton];
	} else {
		[self.likeShareBar createFlagButton];
	}
	[self addSubview:self.likeShareBar];
	[self checkIfUserHasLikedThePost];
	[self checkForMuteButton:self.currentPage];
    
    if(numPages.integerValue > 1){
        [self showPageUpIndicator];
        self.mainScrollView.scrollEnabled = YES;
    }
}

-(void) showWhoLikesThePost {
    [self.delegate showWhoLikesThePost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
}

-(void)showWhoCommentedOnthePost{
    [self.delegate showWhoCommentedOnPost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];

}

-(void) showwhoHasSharedThePost{
	//todo:
}

-(void)prepareForScreenShot{
    for(PageViewingExperience * pageView in self.pageViews){
                [pageView prepareForScreenShot];
    }
}

//todo: optimize this
-(void) addCreatorInfo {
	self.creatorBarFrameUp = CGRectMake(0.f, -STATUS_BAR_HEIGHT, self.frame.size.width, CREATOR_CHANNEL_BAR_HEIGHT + STATUS_BAR_HEIGHT);
	self.creatorBarFrameDown = CGRectMake(0.f, 0.f, self.frame.size.width, CREATOR_CHANNEL_BAR_HEIGHT + STATUS_BAR_HEIGHT);
    __weak PostView *weakSelf = self;
	//todo: fix creator bar slowness
	[Post_Channel_RelationshipManager getChannelObjectFromParsePCRelationship:weakSelf.parsePostChannelActivityObject
														  withCompletionBlock:^(Channel * channel) {
															  weakSelf.postChannel = channel;
															  //we only add the channel info to posts that don't belong to the current user
															  if(channel.parseChannelObject != weakSelf.listChannel.parseChannelObject) {
                                                                  
																  dispatch_async(dispatch_get_main_queue(), ^{
																	  weakSelf.creatorAndChannelBar = [[CreatorAndChannelBar alloc] initWithFrame:weakSelf.creatorBarFrameDown andChannel:channel];
																	  weakSelf.creatorAndChannelBar.delegate = weakSelf;
																	  [weakSelf addSubview:weakSelf.creatorAndChannelBar];
																  });
                                                                  
															  }
														  }];
}

-(void)channelSelected:(Channel *) channel {
	[self.delegate channelSelected:channel];
}

-(void)exitSelected{
    [self.delegate removePostViewSelected];
}

-(void)shareButtonPressed{
    [self userAction:Share isPositive:YES];
}

#pragma mark - Like Share Bar -



-(void)userAction:(ActivityOptions) action isPositive:(BOOL) positive {
	PFObject *post = [self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST];
	switch (action) {
		case Like:
			if(positive) {
				[Like_BackendManager currentUserLikePost:post];
			} else{
				[Like_BackendManager currentUserStopLikingPost:post];
			}
			break;
		case Share:
			[self.delegate shareOptionSelectedForParsePostObject:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
			break;
        case CommentListPresent:
            [self showWhoCommentedOnthePost];
            break;
		default:
			break;
	}
}


#pragma mark - Scroll view delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self displayMediaOnCurrentPage];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self upDatePagingLine];
}

#pragma mark - Display media on current page -

// Tells previous page it's offscreen and current page it's onscreen, and loads next page
-(void) displayMediaOnCurrentPage {
	NSInteger currentViewableIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	NSInteger indexBelow = currentViewableIndex + 1;

	if (self.pageUpIndicatorDisplayed) {
		if (indexBelow < self.pageViews.count) {
			[self showPageUpIndicator];
		} else {
			[self removePageUpIndicatorFromView];
		}
	}
    
    if(currentViewableIndex < self.pageViews.count){
        PageViewingExperience *newCurrentPage = self.pageViews[currentViewableIndex];
        [self.currentPage offScreen];
        self.currentPage = newCurrentPage;
		if (!self.postMuted && self.likeShareBar) {
			[self checkForMuteButton:self.currentPage];
		}
        [self.currentPage onScreen];
        
        if(!self.small){
            //Load media for next two pages
            //(if more than 3 pages at some point the next will already be loading from previous call
            //- this case is taken care of in loadMediaForPage. Also takes care of case where pages don't exist.)
            [self loadMediaForPageAtIndex: indexBelow];
            [self loadMediaForPageAtIndex: indexBelow+1];
        }
    }
}

-(void)setInSmallMode:(BOOL)inSmallMode{
    _inSmallMode = inSmallMode;
    for(PageViewingExperience *pageView in self.pageViews){
        [pageView setInPreviewMode:inSmallMode];
    }
    self.mainScrollView.scrollEnabled = inSmallMode;
}

-(void)checkForMuteButton:(PageViewingExperience * )currentPageOnScreen {
	if ([currentPageOnScreen isKindOfClass:[VideoPVE class]] ||
		[currentPageOnScreen isKindOfClass:[PhotoVideoPVE class]]) {
		[self.likeShareBar presentMuteButton:YES];
	}else {
		[self.likeShareBar presentMuteButton:NO];
	}
}

-(void)muteButtonSelected:(BOOL)shouldMute{
	[self muteAllVideos:shouldMute];
}

-(void) likeButtonPressed {
    if(self.liked){
        [self.likeButton setImage:[UIImage imageNamed:LIKE_ICON_UNPRESSED] forState:UIControlStateNormal];
        self.liked = NO;
    }else{
        [self.likeButton setImage:[UIImage imageNamed:LIKE_ICON_PRESSED] forState:UIControlStateNormal];
        self.liked = YES;
    }
    [self userAction:Like isPositive:self.liked];
    [self updateLikeButton];
}

-(void)commentButtonPressed{
    [self userAction:CommentListPresent isPositive:YES];
}

-(void)muteAllVideos:(BOOL) shouldMute {
	self.postMuted = shouldMute;
	for(PageViewingExperience *pageView in self.pageViews){
		if ([pageView isKindOfClass:[VideoPVE class]] ||
			[pageView isKindOfClass:[PhotoVideoPVE class]]) {
			[(VideoPVE *)pageView muteVideo: shouldMute];
		}
	}
}

-(void)presentSwipeUpAndDownInstruction {

	UIImage * instructionImage = [UIImage imageNamed:SWIPE_UP_DOWN_INSTRUCTION];

	CGFloat frameHeight = 300.f;
	CGFloat frameOriginX = self.frame.size.width - frameHeight - 10.f;
	CGFloat frameOriginY = (self.frame.size.height/2.f) - frameHeight/2.f;
	CGRect instructionFrame = CGRectMake(frameOriginX, frameOriginY, frameHeight, frameHeight);
	self.swipeUpAndDownInstruction = [[UIImageView alloc] initWithImage:instructionImage];
	self.swipeUpAndDownInstruction.frame = instructionFrame;
	self.swipeUpAndDownInstruction.contentMode =  UIViewContentModeScaleAspectFit;
	[self addSubview:self.swipeUpAndDownInstruction];
	[self bringSubviewToFront:self.swipeUpAndDownInstruction];
    __weak PostView *weakSelf = self;
	[UIView animateWithDuration:7.f animations:^{
		weakSelf.swipeUpAndDownInstruction.alpha = 0.f;
	}completion:^(BOOL finished) {
		if(finished){
			[weakSelf.swipeUpAndDownInstruction removeFromSuperview];
			weakSelf.swipeUpAndDownInstruction = nil;
		}
	}];
}

#pragma mark - Down arrow -

-(void)addDownArrowButton{
	[self.mainScrollView addSubview:self.downArrow];
}

-(void)downArrowClicked {
    __weak PostView *weakSelf = self;
	[UIView animateWithDuration:SCROLL_UP_ANIMATION_DURATION animations:^{
		weakSelf.mainScrollView.contentOffset = CGPointMake(0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[weakSelf displayMediaOnCurrentPage];
	}];
}

-(void) loadMediaForPageAtIndex:(NSInteger)index {
	if (index >= self.pageViews.count || self.pageViews == nil ||
        self.pageViews.count == 0 || (self.pageObjects && self.pageObjects.count == 0)) return;
	//preview mode
	if (!self.pageObjects) {
		PageViewingExperience *pageView = self.pageViews[index];
		if (pageView.currentlyOnScreen) [pageView onScreen];
		else [pageView almostOnScreen];
		return;
	}
	PFObject *parsePageObject = self.pageObjects[index];
	PageViewingExperience *pageView = self.pageViews[index];
	// Don't load again if already loading
	if (pageView.currentlyLoadingMedia) return;
	pageView.currentlyLoadingMedia = YES;
	//todo: go through process of loading content and reduce number of steps
    __weak PostView *weakSelf = self;

	//todo: delete debugging
//	NSDate *beforeMedia = [NSDate date];
	[PageTypeAnalyzer getPageMediaFromPage:parsePageObject withCompletionBlock:^(NSArray * pageMedia) {
		if (!_pageViews) return; //If post has been cleared before we get here

//		NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate: beforeMedia];

		if ([pageView isKindOfClass:[PhotoPVE class]]) {
			[(PhotoPVE*)pageView displayPhotos: pageMedia[1]];
//			NSLog(@"%@",[NSString stringWithFormat:@"Time loading media in photo page %ld %f seconds", (long)index, timeInterval]);
		} else if ([pageView isKindOfClass:[VideoPVE class]] ) {
			[(VideoPVE*)pageView setThumbnailImage:pageMedia[1][1] andVideo:pageMedia[1][0]];
			[(VideoPVE *)pageView muteVideo: weakSelf.postMuted];
//			NSLog(@"%@",[NSString stringWithFormat:@"Time loading media in video page %ld %f seconds", (long)index, timeInterval]);
		} else if([pageView isKindOfClass:[PhotoVideoPVE class]]) {
			[(PhotoVideoPVE *)pageView displayPhotos:pageMedia[1] andVideo:pageMedia[2][0]
								   andVideoThumbnail:pageMedia[2][1]];
			[(PhotoVideoPVE *)pageView muteVideo: weakSelf.postMuted];
//			NSLog(@"%@",[NSString stringWithFormat:@"Time loading media in photo video page %ld %f seconds", (long)index, timeInterval]);
		}
		if (pageView.currentlyOnScreen) [pageView onScreen];
		else [pageView almostOnScreen];
	}];
}

#pragma mark - Post on screen & off screen -

-(void) postOnScreen {
	self.mainScrollView.scrollEnabled = YES;
	if (!self.postIsAlmostOnScreen) {
		[self loadMediaForPageAtIndex: 0];
	}
	self.postIsAlmostOnScreen = NO;
	self.postIsCurrentlyBeingShown = YES;
	[self displayMediaOnCurrentPage];
}

//todo: remove all pages but first page?
-(void) postOffScreen{
	self.postIsCurrentlyBeingShown = NO;
	[self stopAllVideos];
	[self removePageUpIndicatorFromView];
}

-(void) postAlmostOnScreen {
	if (self.postIsAlmostOnScreen) return;
	self.postIsAlmostOnScreen = YES;
	[self loadMediaForPageAtIndex: 0];
}


#pragma mark - Clean up -

-(void) clearPost {
//	We clear these so that the media is released
	[self stopAllVideos];
	for(UIView *view in self.mainScrollView.subviews) {
		[view removeFromSuperview];
	}
	if (self.likeButton.superview) [self.likeButton removeFromSuperview];
	[self.likeShareBar removeFromSuperview];
    @autoreleasepool {
        self.likeShareBar =  nil;
        self.currentPageIndex = -1;
        self.pageViews = nil;
    }
	[self removePageUpIndicatorFromView];
}

//make sure to stop all videos
-(void) stopAllVideos {
	if (!self.pageViews) return;
	for (PageViewingExperience* pageView in self.pageViews) {
		[pageView offScreen];
	}
}

//removes the little bouncing arrow in the right corner of the screen
-(void)removePageUpIndicatorFromView{
	if(self.pageUpIndicator){
        __weak PostView *weakSelf = self;
		[UIView animateWithDuration:0.2f animations:^{
			weakSelf.pageUpIndicator.alpha = 0.f;
		} completion:^(BOOL finished) {
			[weakSelf.pageUpIndicator removeFromSuperview];
			weakSelf.pageUpIndicator = nil;
            weakSelf.pageUpIndicatorDisplayed = NO;
		}];
	}
}

-(void)logAVEDoneViewing:(PageViewingExperience*) pve {
	
    NSString * pageType = @"";
	
    if ([pve isKindOfClass:[VideoPVE class]]) {
		pageType = @"VideoPageView";
	} else if([pve isKindOfClass:[PhotoVideoPVE class]]) {
		pageType = @"PhotoVideoPageView";
	} else if ([pve isKindOfClass:[PhotoPVE class] ]){
		pageType = @"PhotoPageView";
	}

	[[Analytics getSharedInstance] pageEndedViewingWithIndex:self.currentPageIndex aveType:pageType];
    
}

-(void)showPageUpIndicator {
    if(!self.pageUpIndicatorDisplayed && self.pageObjects.count > 1){
        self.pageUpIndicatorDisplayed = YES;
        if(!self.pageUpIndicator && self.pageViews.count) {
            UIImage * arrowImage = [UIImage imageNamed:PAGE_UP_ICON_IMAGE];
            self.pageUpIndicator = [[UIImageView alloc] initWithImage:arrowImage];
            self.pageUpIndicator.contentMode = UIViewContentModeScaleAspectFit;
        }
        [self.pageUpIndicator removeFromSuperview];
        [self addSubview:self.pageUpIndicator];
        [self bringSubviewToFront:self.pageUpIndicator];
        self.likeShareBar.clipsToBounds = NO;
        CGFloat size = PAGE_UP_ICON_SIZE;
        CGFloat x_cord = self.frame.size.width/2.f - size/2.f;
        CGFloat y_cord = self.frame.size.height -  (size + 10.f);
        CGRect frame = CGRectMake(x_cord, y_cord, size, size);
        self.pageUpIndicator.frame = frame;

    }
}

#pragma mark - Delete Post -

-(void)deleteButtonPressed {
	BOOL reblogged = ![self.postChannel.parseChannelObject.objectId isEqualToString:self.listChannel.parseChannelObject.objectId];
	[self.delegate deleteButtonSelectedOnPostView:self withPostObject:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST] reblogged: reblogged];
}

-(void)flagButtonPressed{
	[self.delegate flagButtonSelectedOnPostView:self withPostObject:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) pageViews {
	if(!_pageViews) {
		_pageViews = [[NSMutableArray alloc] init];
	}
	return _pageViews;
}

-(UIScrollView*) mainScrollView {
	if (!_mainScrollView) {
		_mainScrollView = [[UIScrollView alloc] initWithFrame: self.bounds];
		_mainScrollView.backgroundColor = [UIColor blueColor];
		_mainScrollView.pagingEnabled = YES;
		_mainScrollView.scrollEnabled = YES;
		[_mainScrollView setShowsVerticalScrollIndicator:NO];
		[_mainScrollView setShowsHorizontalScrollIndicator:NO];
		_mainScrollView.bounces = YES;
		//scroll view delegate
		_mainScrollView.delegate = self;
	}
	return _mainScrollView;
}

-(UIButton*) downArrow {
	if (!_downArrow) {
		_downArrow = [[UIButton alloc] init];
		[_downArrow setImage:[UIImage imageNamed:PULLDOWN_ICON] forState:UIControlStateNormal];
		_downArrow.frame = CGRectMake(self.center.x - (DOWN_ARROW_WIDTH/2),
									  self.frame.size.height - DOWN_ARROW_WIDTH - DOWN_ARROW_DISTANCE_FROM_BOTTOM,
									  DOWN_ARROW_WIDTH, DOWN_ARROW_WIDTH);
		[_downArrow addTarget:self action:@selector(downArrowClicked) forControlEvents:UIControlEventTouchUpInside];
	}
	return _downArrow;
}



-(void) dealloc {
}

@end
