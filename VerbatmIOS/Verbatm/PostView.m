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

#import "Durations.h"

#import "Icons.h"

#import "Like_BackendManager.h"

#import "PageTypeAnalyzer.h"
#import "PostLikeAndShareBar.h"
#import "PhotoVideoPVE.h"
#import "PhotoPVE.h"
#import "PostView.h"
#import "ParseBackendKeys.h"
#import <PromiseKit/PromiseKit.h>
#import "Post_Channel_RelationshipManager.h"

#import "SizesAndPositions.h"
#import "Share_BackendManager.h"
#import "Styles.h"

#import "UserManager.h"
#import "UserSetupParameters.h"
#import "UIView+Effects.h"

#import "VideoPVE.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface PostView ()<UIScrollViewDelegate, PhotoPVEDelegate,
PostLikeAndShareBarProtocol, CreatorAndChannelBarProtocol>

@property (nonatomic) CreatorAndChannelBar * creatorAndChannelBar;

// mapping between NSNumber of type Integer and Page Views
@property (strong, nonatomic) NSMutableDictionary * pageViews;

//used to lazily instantiate pages when the view is about to presented
//we save the page media here and then load and present the pages on demand
@property (strong, nonatomic) NSMutableDictionary * pageMedia;

@property (nonatomic) NSNumber* currentIndexOfPageLoading;

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) NSInteger currentPageIndex;

// Like button added by another class
@property (strong, nonatomic) UIButton* likeButton;
@property (nonatomic) BOOL liked;
@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;

@property (nonatomic, strong) UIButton * downArrow;

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

@property (strong, nonatomic) LoadingIndicator * customActivityIndicator;
@property (nonatomic) PostLikeAndShareBar * likeShareBar;
@property (nonatomic) CGRect lsBarDownFrame;// the framw of the like share button with the tab down
@property (nonatomic) CGRect lsBarUpFrame;//the frame of the like share button with the tab up

@property (nonatomic) UIImageView * swipeUpAndDownInstruction;

@property (strong, nonatomic) PageViewingExperience *currentPage;

//@property (nonatomic) UIImageView * swipeInstructionView

@property (nonatomic) UIView * PagingLine;//line that moves up and down as the user swipes up and down

@property (nonatomic) UIImageView * pageUpIndicator;
@property (nonatomic) BOOL pageUpIndicatorDisplayed;

@property (nonatomic) NSMutableArray * mediaPageContent;//TODO

@property(nonatomic) BOOL postIsCurrentlyBeingShown;
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

-(instancetype)initWithFrame:(CGRect)frame andPostChannelActivityObject:(PFObject*) postObject
					   small:(BOOL) small {
	self = [super initWithFrame:frame];
	if (self) {
		self.pageUpIndicatorDisplayed = NO;
		self.postMuted = NO;
		self.small = small;
		[self addSubview: self.mainScrollView];
		self.mainScrollView.backgroundColor = [UIColor blackColor];
		if(postObject) self.parsePostChannelActivityObject = postObject;
		[self createBorder];
	}
	return self;
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

-(void)createBorder{
	[self.layer setBorderWidth:2.0];
	[self.layer setCornerRadius:0.0];
	[self.layer setBorderColor:[UIColor blackColor].CGColor];

	self.lsBarUpFrame = CGRectMake(0.f,self.frame.size.height - (LIKE_SHARE_BAR_HEIGHT + TAB_BAR_HEIGHT),
								   self.frame.size.width, LIKE_SHARE_BAR_HEIGHT);

	self.lsBarDownFrame = CGRectMake(0.f,self.frame.size.height - LIKE_SHARE_BAR_HEIGHT,
									 self.frame.size.width, LIKE_SHARE_BAR_HEIGHT);
}

-(void)addPagingLine{
	CGRect lineFrame = CGRectMake(self.frame.size.width - PAGING_LINE_WIDTH, self.frame.size.height, PAGING_LINE_WIDTH, 0.f);
	self.PagingLine = [[UIView alloc] initWithFrame:lineFrame];
	self.PagingLine.backgroundColor = PAGING_LINE_COLE;
	[self addSubview:self.PagingLine];
	[self bringSubviewToFront:self.PagingLine];
}

-(void)upDatePagingLine{
	//we subtract the page height because the contentOffset is never == contentSize... but our ratio needs to become 1
	CGFloat lineRatio = self.mainScrollView.contentOffset.y/(self.mainScrollView.contentSize.height-self.frame.size.height);
	CGFloat lineHeight = self.frame.size.height * lineRatio;
	CGRect lineFrame = CGRectMake(self.PagingLine.frame.origin.x, self.frame.size.height - lineHeight,
								  self.PagingLine.frame.size.width, lineHeight);
	self.PagingLine.frame = lineFrame;
}

#pragma mark - Display page -

-(void) scrollToPageAtIndex:(NSInteger) pageIndex{
	if(pageIndex < self.pageViews.count && pageIndex >= 0){
		self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollView.frame.size.height * (pageIndex));
		[self displayMediaOnCurrentPage];
	}

	if(![[UserSetupParameters sharedInstance] isSwipeUpDown_InstructionShown] &&
	   ([[UserSetupParameters sharedInstance] isFilter_InstructionShown] || [[self getCUrrentView] isKindOfClass:[VideoPVE class]])
	   &&  self.pageViews.count > 1) {

		[self presentSwipeUpAndDownInstruction];
		[[UserSetupParameters sharedInstance] set_SwipeUpDownNotification_InstructionAsShown];
	}
}

-(PageViewingExperience *)getCUrrentView{
	NSInteger currentViewableIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	PageViewingExperience *newCurrentPage = [self.pageViews objectForKey:[NSNumber numberWithInteger:currentViewableIndex]];
	return newCurrentPage;
}

-(void) renderNextPage: (PageViewingExperience*)pageView withIndex: (NSNumber*) pageIndex {
	[self setDelegateOnPhotoPage: pageView];
	CGRect frame = CGRectMake(0, [pageIndex integerValue] * self.mainScrollView.frame.size.height , self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
	pageView.frame = frame;

	[self.mainScrollView addSubview:pageView];
	[self.pageViews setObject:pageView forKey:pageIndex];
}

-(void) checkIfUserHasLikedThePost {
	[Like_BackendManager currentUserLikesPost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST] withCompletionBlock:^(bool userLikedPost) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.likeShareBar shouldStartPostAsLiked:userLikedPost];
		});
	}];
}

-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares
								numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage
									  startUp:(BOOL)up withDeleteButton: (BOOL)withDelete {

	CGRect startFrame = (up) ? self.lsBarUpFrame : self.lsBarDownFrame;
	[self.likeShareBar removeFromSuperview];
	self.likeShareBar = [[PostLikeAndShareBar alloc] initWithFrame: startFrame numberOfLikes:numLikes
													numberOfShares:numShares numberOfPages:numPages andStartingPageNumber:startPage];
	self.likeShareBar.delegate = self;
	if (withDelete) {
		[self.likeShareBar createDeleteButton];
	}else{
		[self.likeShareBar createFlagButton];
	}
	[self addSubview:self.likeShareBar];
	[self checkIfUserHasLikedThePost];
	self.pageUpIndicatorDisplayed = YES;
	[self displayMediaOnCurrentPage];
}

-(void) showWhoLikesThePost {
	//todo:
}

-(void) showwhoHasSharedThePost{
	//todo:
}

-(void) addCreatorInfo {
	[Post_Channel_RelationshipManager getChannelObjectFromParsePCRelationship:self.parsePostChannelActivityObject
														  withCompletionBlock:^(Channel * channel) {
															  self.postChannel = channel;
															  //we only add the channel info to posts that don't belong to the current user
															  //todo: or in profile
															  if(channel.parseChannelObject != self.listChannel.parseChannelObject
																 && ![channel channelBelongsToCurrentUser]) {
																  dispatch_async(dispatch_get_main_queue(), ^{
																	  CGRect creatorBarFrame = CGRectMake(0.f, 0.f, self.frame.size.width, CREATOR_CHANNEL_BAR_HEIGHT);
																	  self.creatorAndChannelBar = [[CreatorAndChannelBar alloc] initWithFrame:creatorBarFrame andChannel:channel];
																	  self.creatorAndChannelBar.delegate = self;
																	  [self addSubview:self.creatorAndChannelBar];
																  });
															  }
														  }];
}

-(void)channelSelected:(Channel *) channel {
	[self.delegate channelSelected:channel];
}

#pragma mark - Like Share Bar -

-(void) shiftLikeShareBarDown:(BOOL) down{
	if(down) {
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			self.likeShareBar.frame = self.lsBarDownFrame;
		} completion:^(BOOL finished) {
		}];
	}else{
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			self.likeShareBar.frame = self.lsBarUpFrame;
		} completion:^(BOOL finished) {
		}];
	}
}

-(void)userAction:(ActivityOptions) action isPositive:(BOOL) positive {
	PFObject *post = [self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST];
	switch (action) {
		case Like:
			if(positive){
				[Like_BackendManager currentUserLikePost:post];
			}else{
				[Like_BackendManager currentUserStopLikingPost:post];
			}
			break;
		case Share:
			[Share_BackendManager currentUserReblogPost:post toChannel:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO]];
			[self.delegate shareOptionSelectedForParsePostObject:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
			break;
		default:
			break;
	}
}

-(void) likeButtonPressed {
	self.liked = !self.liked;
}


#pragma mark - Scroll view delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self displayMediaOnCurrentPage];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self upDatePagingLine];
}

-(void) setPageNumberOnShareBarFromScrollView:(UIScrollView *) scrollview {
	CGFloat scrollViewHeigthOffset = scrollview.contentOffset.y;
	CGFloat screenHeight = scrollview.frame.size.height;
	CGFloat pageIndex = scrollViewHeigthOffset/screenHeight;
	NSNumber * pageNumber = @((pageIndex + 1.f));
	[self.likeShareBar setPageNumber:pageNumber];
}

#pragma mark - Handle Display Media on Page -

-(void) setDelegateOnPhotoPage: (PageViewingExperience*) pageView {
	if ([pageView isKindOfClass:[PhotoPVE class]]) {
		((PhotoPVE *)pageView).postScrollView = self.mainScrollView;
		((PhotoPVE *)pageView).delegate = self;
	} else if ([pageView isKindOfClass:[PhotoVideoPVE class]]){
		((PhotoVideoPVE *)pageView).postScrollView = self.mainScrollView;
	}
}

// Tells previous page it's offscreen and current page it's onscreen
-(void) displayMediaOnCurrentPage {
	NSInteger currentViewableIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	NSInteger indexBelow = currentViewableIndex +1;
	
	if (self.pageUpIndicatorDisplayed) {
		PageViewingExperience* pageBelow = [self.pageViews objectForKey:[NSNumber numberWithInteger:indexBelow]];
		if (pageBelow) {
			[self showPageUpIndicator];
		} else {
			[self removePageUpIndicatorFromView];
		}
	}

	PageViewingExperience *newCurrentPage = [self.pageViews objectForKey:[NSNumber numberWithInteger:currentViewableIndex]];
	[self.currentPage offScreen];
	self.currentPage = newCurrentPage;
	[self.currentPage onScreen];
	if (!self.postMuted && _likeShareBar) {
		[self checkForMuteButton:self.currentPage];
	}
	[self prepareNextPage];
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

-(void)muteAllVideos:(BOOL) shouldMute {
	self.postMuted = shouldMute;
	for(PageViewingExperience *pageView in [self.pageViews allValues]){
		if ([pageView isKindOfClass:[VideoPVE class]] ||
			[pageView isKindOfClass:[PhotoVideoPVE class]]) {

			[(VideoPVE *)pageView muteVideo: shouldMute];
		}
	}
}

-(void)presentSwipeUpAndDownInstruction {

	UIImage * instructionImage = [UIImage imageNamed:SWIPE_UP_DOWN_INSTRUCTION];

	CGFloat frameHeight = 200.f;
	CGFloat frameWidth = ((frameHeight * 117.f)/284.f);

	CGFloat frameOriginX = self.frame.size.width - frameWidth - 10.f;
	CGFloat frameOriginY = (self.frame.size.height/2.f) + 50.f;

	CGRect instructionFrame = CGRectMake(frameOriginX,frameOriginY, frameWidth,frameHeight);

	self.swipeUpAndDownInstruction = [[UIImageView alloc] initWithImage:instructionImage];
	self.swipeUpAndDownInstruction.frame = instructionFrame;
	self.swipeUpAndDownInstruction.contentMode =  UIViewContentModeScaleAspectFit;
	[self addSubview:self.swipeUpAndDownInstruction];
	[self bringSubviewToFront:self.swipeUpAndDownInstruction];
	[UIView animateWithDuration:7.f animations:^{
		self.swipeUpAndDownInstruction.alpha = 0.f;
	}completion:^(BOOL finished) {
		if(finished){
			[self.swipeUpAndDownInstruction removeFromSuperview];
			self.swipeUpAndDownInstruction = nil;
		}
	}];
}

-(void)presentFilterSwipeForInstructionWithPageView:(PageViewingExperience *) currentPage {

	BOOL isPhotoAve = [currentPage isKindOfClass:[PhotoPVE class]];
	BOOL isVideoAve = [currentPage isKindOfClass:[PhotoVideoPVE class]];

	BOOL filterInstructionHasNotBeenPresented = ![[UserSetupParameters sharedInstance] isFilter_InstructionShown];

	if( (isPhotoAve || isVideoAve)  && filterInstructionHasNotBeenPresented) {
		UIImage * instructionImage = [UIImage imageNamed:FILTER_SWIPE_INSTRUCTION];
		CGFloat frameWidth = 200.f;
		CGFloat frameHeight = (frameWidth * 320.f) /488.f;

		UIImageView * filterInstruction = [[UIImageView alloc] initWithImage:instructionImage];
		filterInstruction.backgroundColor = [UIColor clearColor];

		CGFloat imageOriginX = (self.frame.size.width/2.f) - (frameWidth/2.f);

		if (isPhotoAve) {
			filterInstruction.frame = CGRectMake(imageOriginX,
												 (self.frame.size.height/2.f) + frameHeight,
												 frameWidth, frameHeight);
		} else {
			filterInstruction.frame = CGRectMake(imageOriginX,
												 self.frame.size.height - (frameHeight + 50.f), frameWidth, frameHeight);
		}

		[self addSubview:filterInstruction];
		[self bringSubviewToFront:filterInstruction];
		[[UserSetupParameters sharedInstance] set_filter_InstructionAsShown];
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

// Prepares aves almost on screen (one above or below current page)
-(void) prepareNextPage {
	NSInteger currentIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	NSInteger indexAbove = currentIndex -1;
	NSInteger indexBelow = currentIndex +1;
	PageViewingExperience* pageAbove = [self.pageViews objectForKey:[NSNumber numberWithInteger:indexAbove]];
	PageViewingExperience* pageBelow = [self.pageViews objectForKey:[NSNumber numberWithInteger:indexBelow]];
	if(pageAbove)[pageAbove almostOnScreen];
	if(pageBelow)[pageBelow almostOnScreen];
}

#pragma mark - Down arrow -

-(void)addDownArrowButton{
	[self.mainScrollView addSubview:self.downArrow];
}

-(void)downArrowClicked {
	[UIView animateWithDuration:SCROLL_UP_ANIMATION_DURATION animations:^{
		self.mainScrollView.contentOffset = CGPointMake(0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[self displayMediaOnCurrentPage];
	}];
}


#pragma mark - Pages Downloaded -

-(void) renderPostFromPageObjects:(NSArray *) pages {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.customActivityIndicator startCustomActivityIndicator];
	});
	PageTypeAnalyzer * analyzer = [[PageTypeAnalyzer alloc] init];
	NSMutableArray * downloadPromises = [[NSMutableArray alloc] init];

	for (PFObject * parsePageObject in pages) {
		AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			[analyzer getPageViewFromPage:parsePageObject withFrame:self.bounds andCompletionBlock:^(NSArray * pageMedia) {
				[self storeMedia:pageMedia forPageIndex:[parsePageObject valueForKey:PAGE_INDEX_KEY]];
				resolve(nil);
			}];
		}];
		[downloadPromises addObject:promise];
	}

	PMKWhen(downloadPromises).then(^(id data){
		if (self.postIsCurrentlyBeingShown){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self presentMediaContent];
				[self postOnScreen];
			});
		}
	});
}

-(void) renderPageViews: (NSMutableArray *) pageViews {
	self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width,
												 pageViews.count * self.frame.size.height);
	self.mainScrollView.contentOffset = CGPointMake(0, 0);
	CGRect viewFrame = self.bounds;

	for (int i = 0; i < pageViews.count; i++) {
		PageViewingExperience* pageView = pageViews[i];
		[self.pageViews setObject:pageView forKey:[NSNumber numberWithInt:i]];
		[self setDelegateOnPhotoPage: pageView];
		[pageView offScreen];
		pageView.frame = viewFrame;
		if (self.postMuted && ([pageView isKindOfClass:[VideoPVE class]] ||
							   [pageView isKindOfClass:[PhotoVideoPVE class]])) {
			[(VideoPVE *)pageView muteVideo: YES];
		}
		[self.mainScrollView addSubview: pageView];
		viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
	}
}

-(void)storeMedia:(NSArray *) media forPageIndex:(NSNumber*) pageIndex{
	if(media) {
		[self.pageMedia setObject:media forKey:pageIndex];
	}
}

-(void) presentMediaContent {
	if(self.pageMedia.count > 0){
		[self.customActivityIndicator stopCustomActivityIndicator];

		for(NSInteger key = 0; key < self.pageMedia.count; key++){
			NSArray * media = [self.pageMedia objectForKey:[NSNumber numberWithInteger:key]];
			PageViewingExperience *pageView = [PageTypeAnalyzer getPageViewFromPageMedia:media withFrame:self.bounds
																				   small:self.small];
			if (self.postMuted && ([pageView isKindOfClass:[VideoPVE class]] ||
								   [pageView isKindOfClass:[PhotoVideoPVE class]])) {
				[(VideoPVE *)pageView muteVideo: YES];
			}
			//add bar at the bottom with page numbers etc
			[self renderNextPage:pageView withIndex:[NSNumber numberWithInteger:key]];
			[self setApproprioateScrollViewContentSize];
		}

		[self.pageMedia removeAllObjects];
	}
}

#pragma mark - Playing post content -

-(void) postOnScreen {
	self.postIsCurrentlyBeingShown = YES;

	if(self.pageMedia.count > 0 &&
	   self.pageViews.count ==0){
		//we lazily create out pages
		[self presentMediaContent];
	}
	[self displayMediaOnCurrentPage];
}

-(void) postOffScreen{
	self.postIsCurrentlyBeingShown = NO;
	[self stopAllVideos];
	[self removePageUpIndicatorFromView];
}

-(void) preparepostToBePresented {
	NSInteger currentPage = self.mainScrollView.contentOffset.x / self.frame.size.width;
	PageViewingExperience* page = [self.pageViews objectForKey:[NSNumber numberWithInteger:currentPage]];
	[page almostOnScreen];
	[self prepareNextPage];
}

#pragma mark - Photo View Delegate -

-(void) startedDraggingAroundCircle {
	self.mainScrollView.scrollEnabled = NO;
}

-(void) stoppedDraggingAroundCircle {
	self.mainScrollView.scrollEnabled = YES;
}

-(void) viewTapped {

}

-(void)setApproprioateScrollViewContentSize{
	self.mainScrollView.contentSize = CGSizeMake(0, self.pageViews.count * self.frame.size.height);
}


#pragma mark - Clean up -

-(void) clearPost {
	//We clear these so that the media is released
	[self stopAllVideos];

	for(UIView *view in self.mainScrollView.subviews) {
		[view removeFromSuperview];
	}
	if (self.likeButton.superview) [self.likeButton removeFromSuperview];
	[self.likeShareBar removeFromSuperview];
	self.likeShareBar =  nil;
	self.currentPageIndex = -1;
	self.pageViews = nil;
	[self removePageUpIndicatorFromView];
}

//make sure to stop all videos
-(void) stopAllVideos {
	if (!self.pageViews) return;
	for (NSNumber* key in self.pageViews) {
		PageViewingExperience* pageView = [self.pageViews objectForKey:key];
		[pageView offScreen];
	}
}

//removes the little bouncing arrow in the right corner of the screen
-(void)removePageUpIndicatorFromView{
	if(self.pageUpIndicator){
		[UIView animateWithDuration:0.2f animations:^{
			self.pageUpIndicator.alpha = 0.f;
		} completion:^(BOOL finished) {
			[self.pageUpIndicator removeFromSuperview];
			self.pageUpIndicator = nil;
		}];
	}
}

-(void)showPageUpIndicator {
	self.pageUpIndicatorDisplayed = YES;
	if(!self.pageUpIndicator && self.pageViews.count) {
		UIImage * arrowImage = [UIImage imageNamed:PAGE_UP_ICON_IMAGE];
		self.pageUpIndicator = [[UIImageView alloc] initWithImage:arrowImage];
		self.pageUpIndicator.contentMode = UIViewContentModeScaleAspectFit;
	}
	[self.pageUpIndicator removeFromSuperview];
	[self.likeShareBar addSubview:self.pageUpIndicator];
	CGFloat size = 50.f;
	CGFloat x_cord = self.frame.size.width/2.f - size/2.f;
	CGFloat y_cord = 0.f;
	CGRect frame = CGRectMake(x_cord, y_cord, size, size);
	self.pageUpIndicator.frame = frame;
}

#pragma mark - Delete Post -

-(void)deleteButtonPressed {
	BOOL reblogged = self.postChannel.parseChannelObject != self.listChannel.parseChannelObject;
	[self.delegate deleteButtonSelectedOnPostView:self withPostObject:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST] reblogged: reblogged];
}
-(void)flagButtonPressed{
	[self.delegate flagButtonSelectedOnPostView:self withPostObject:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
}

#pragma mark - Lazy Instantiation -

-(NSMutableDictionary*) pageViews {
	if(!_pageViews) {
		_pageViews = [[NSMutableDictionary alloc] init];
	}
	return _pageViews;
}

-(NSMutableDictionary*) pageMedia {
	if(!_pageMedia) {
		_pageMedia = [[NSMutableDictionary alloc] init];
	}
	return _pageMedia;
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

-(PostLikeAndShareBar*) likeShareBar {
	if (!_likeShareBar) {
		_likeShareBar = [[PostLikeAndShareBar alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height - LIKE_SHARE_BAR_HEIGHT, self.frame.size.width, LIKE_SHARE_BAR_HEIGHT)];
		[self addSubview:_likeShareBar];
	}
	return _likeShareBar;
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

-(LoadingIndicator *)customActivityIndicator{
	if(!_customActivityIndicator){
		CGPoint newCenter = CGPointMake(self.center.x, self.frame.size.height * 1.f/2.f);
		_customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:newCenter andImage:[UIImage imageNamed:LOAD_ICON_IMAGE]];
		[self addSubview:_customActivityIndicator];
	}
	return _customActivityIndicator;
}
-(UIActivityIndicatorView*) activityIndicator {
	if (!_activityIndicator) {
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicator.color = [UIColor grayColor];
		_activityIndicator.hidesWhenStopped = YES;
		_activityIndicator.center = CGPointMake(self.center.x, self.frame.size.height * 1.f/2.f);
		[self addSubview:_activityIndicator];
		[self bringSubviewToFront:_activityIndicator];
	}
	return _activityIndicator;
}

@end
