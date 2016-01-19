//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"
#import "AveTypeAnalyzer.h"

#import "CreatorAndChannelBar.h"

#import "Durations.h"

#import "Icons.h"

#import "POVLikeAndShareBar.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "POVView.h"
#import "Page.h"
#import "PagesLoadManager.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UserManager.h"
#import "UIView+Effects.h"

#import "VideoAVE.h"

@interface POVView ()<UIScrollViewDelegate, PhotoAVEDelegate,
    PagesLoadManagerDelegate, POVLikeAndShareBarProtocol>

// Load manager in charge of getting page objects and all their media for each pov
@property (strong, nonatomic) PagesLoadManager* pageLoadManager;


@property (nonatomic) CreatorAndChannelBar * creatorAndChannelBar;


// mapping between NSNumber of type Integer and ArticleViewingExperience
@property (strong, nonatomic) NSMutableDictionary * pageAves;
@property (nonatomic) NSNumber* currentIndexOfPageLoading;

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) NSInteger currentPageIndex;

// Like button added by another class
@property (strong, nonatomic) UIButton* likeButton;
@property (nonatomic) BOOL liked;
@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;
//@property (weak, nonatomic) id<LikeButtonDelegate> likeButtonDelegate;
@property (strong, nonatomic) PovInfo* povInfo;

@property (nonatomic, strong) UIButton * downArrow;

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

@property (nonatomic) POVLikeAndShareBar * likeShareBar;
@property (nonatomic) CGRect lsBarDownFrame;// the framw of the like share button with the tab down
@property (nonatomic) CGRect lsBarUpFrame;//the frame of the like share button with the tab up



#define DOWN_ARROW_WIDTH 30.f
#define DOWN_ARROW_DISTANCE_FROM_BOTTOM 40.f
#define SCROLL_UP_ANIMATION_DURATION 0.7
#define ACTIVITY_ANIMATION_Y 100.f
@end

@implementation POVView

-(instancetype)initWithFrame:(CGRect)frame andPOVInfo:(PovInfo*) povInfo {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview: self.mainScrollView];
//		if(povInfo) { // if being used in feed
//            self.povInfo = povInfo;
//            self.currentIndexOfPageLoading = [NSNumber numberWithInteger:0];
//            if(povInfo)[self createPageLoader];
//            self.activityIndicator = [self startActivityIndicatorOnViewWithCenter: CGPointMake(self.center.x, ACTIVITY_ANIMATION_Y)
//                                                                         andStyle:UIActivityIndicatorViewStyleWhiteLarge];
//            self.activityIndicator.color = [UIColor whiteColor];
//        }
    }
    return self;
}

-(void) createPageLoader{
    self.pageLoadManager = [[PagesLoadManager alloc] init];
    self.pageLoadManager.delegate = self;
    
    NSNumber* povID = self.povInfo.identifier;
    [self.pageLoadManager loadPagesForPOV: povID];
    
}

#pragma mark - Display page -

-(void) scrollToPageAtIndex:(NSInteger) pageIndex{
    if(pageIndex < self.pageAves.count && pageIndex >= 0){
        self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollView.frame.size.height * (pageIndex));
        [self displayMediaOnCurrentAVE];
    }
}

-(void) renderNextAve: (ArticleViewingExperience*)ave withIndex: (NSNumber*) pageIndex {
	[self.pageAves setObject:ave forKey:pageIndex];
	if (pageIndex == self.currentIndexOfPageLoading) {
		self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width,
													 (self.currentIndexOfPageLoading.integerValue) * self.frame.size.height);
        
		[self setDelegateOnPhotoAVE: ave];
		CGRect frame = CGRectOffset(self.bounds, 0, self.frame.size.height * self.currentIndexOfPageLoading.integerValue);
		ave.frame = frame;
		[self.mainScrollView addSubview:ave];
		self.currentIndexOfPageLoading = [NSNumber numberWithInteger:self.currentIndexOfPageLoading.integerValue+1];
		if ([self.pageAves objectForKey:self.currentIndexOfPageLoading]) {
			[self renderNextAve:[self.pageAves objectForKey:self.currentIndexOfPageLoading] withIndex:self.currentIndexOfPageLoading];
		}
	}
}

//renders aves (pages) onto the view
-(void) renderAVES: (NSMutableArray *) aves {

	self.currentPageIndex = -1;
	self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width, [aves count] * self.frame.size.height);
	self.mainScrollView.contentOffset = CGPointMake(0, 0);
	CGRect viewFrame = self.bounds;

	for (int i = 0; i < aves.count; i++) {
		ArticleViewingExperience* ave = aves[i];
		[self.pageAves setObject:ave forKey:[NSNumber numberWithInt:i]];
		[self setDelegateOnPhotoAVE: ave];
        [ave offScreen];
		ave.frame = viewFrame;
		[self.mainScrollView addSubview: ave];
		viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
	}
    
    
    ArticleViewingExperience * ave = [aves firstObject];
    if(ave){
        BOOL inADK = ave.inPreviewMode;
        if(!inADK){
            //temp just to test
            [self createLikeAndShareBarWithNumberOfLikes:@(10) numberOfShares:@(100) numberOfPages:@(aves.count) andStartingPageNumber:@(1)];
        }
    }
}

-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage{
    
    self.lsBarUpFrame = CGRectMake(0.f,self.frame.size.height -LIKE_SHARE_BAR_HEIGHT - TAB_BAR_HEIGHT ,
                                 self.frame.size.width, LIKE_SHARE_BAR_HEIGHT);
    
    self.lsBarDownFrame = CGRectMake(0.f,self.frame.size.height - LIKE_SHARE_BAR_HEIGHT,
                                     self.frame.size.width, LIKE_SHARE_BAR_HEIGHT);
    
    self.likeShareBar = [[POVLikeAndShareBar alloc] initWithFrame:self.lsBarUpFrame numberOfLikes:numLikes numberOfShares:numShares numberOfPages:numPages andStartingPageNumber:startPage];
    self.likeShareBar.delegate = self;
    [self addSubview:self.likeShareBar];
}

//like-share bar protocol

-(void)shareButtonPressed {
    [self.delegate shareOptionSelectedForPOVInfo:self.povInfo];
}

//-(void)likeButtonPressed{
//    
//}

-(void)showWhoLikesThePOV{
}

-(void)showwhoHasSharedThePOV{
    
}



-(void) addCreatorInfoFromChannel: (Channel *) channel {
    CGRect creatorBarFrame = CGRectMake(0.f, 0.f, self.frame.size.width, CREATOR_CHANNEL_BAR_HEIGHT);
    self.creatorAndChannelBar = [[CreatorAndChannelBar alloc] initWithFrame:creatorBarFrame andChannel:channel];
    [self addSubview:self.creatorAndChannelBar];
}

#pragma mark - Add like button -

//should be called by another class (since preview does not have like)
//Sets the like button delegate and the povID since the delegate method
//requires a pov ID be passed back
//-(void) addLikeButtonWithDelegate: (id<LikeButtonDelegate>) delegate {
//	self.likeButtonDelegate = delegate;
//	// check if current user likes story
//	self.liked = [[UserManager sharedInstance] currentUserLikesStory: self.povInfo];
//	if (self.liked) {
//		[self.likeButton setImage:self.likeButtonLikedImage forState:UIControlStateNormal];
//	} else {
//		[self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
//	}
//	[self addSubview: self.likeButton];
//}


-(void) shiftLikeShareBarDown:(BOOL) down{
    if(down){
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.likeShareBar.frame = self.lsBarDownFrame;
        }];
    }else{
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.likeShareBar.frame = self.lsBarUpFrame;
        }];
    }
}



-(void) likeButtonPressed {
	self.liked = !self.liked;

}

#pragma mark - Scroll view delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setPageNumberOnShareBarFromScrollView:scrollView];
    [self displayMediaOnCurrentAVE];
}

-(void) setPageNumberOnShareBarFromScrollView:(UIScrollView *) scrollview {
    CGFloat scrollViewHeigthOffset = scrollview.contentOffset.y;
    CGFloat screenHeight = scrollview.frame.size.height;
    CGFloat pageIndex = scrollViewHeigthOffset/screenHeight;
    NSNumber * pageNumber = @((pageIndex + 1.f));
    [self.likeShareBar setPageNumber:pageNumber];
}

#pragma mark - Handle Display Media on AVE -

-(void) setDelegateOnPhotoAVE: (ArticleViewingExperience*) ave {
	if ([ave isKindOfClass:[PhotoAVE class]]) {
		((PhotoAVE *)ave).povScrollView = self.mainScrollView;
		((PhotoAVE*) ave).delegate = self;
	} else if ([ave isKindOfClass:[PhotoVideoAVE class]]){
		((PhotoVideoAVE *)ave).povScrollView = self.mainScrollView;
	}
}

// Tells previous page it's offscreen and current page it's onscreen
-(void) displayMediaOnCurrentAVE {
	NSInteger nextIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	ArticleViewingExperience *nextPage = [self.pageAves objectForKey:[NSNumber numberWithInteger:nextIndex]];
    ArticleViewingExperience *currentPage = [self.pageAves objectForKey:[NSNumber numberWithInteger: self.currentPageIndex]];
    if(self.currentPageIndex != nextIndex){
		[currentPage offScreen];
        [self logAVEDoneViewing:currentPage];
        [[Analytics getSharedInstance] pageStartedViewingWithIndex:nextIndex];
    } else if (nextIndex == 0){ //first page of the article
        [[Analytics getSharedInstance]pageStartedViewingWithIndex:nextIndex];
    }
    
    self.currentPageIndex = nextIndex;
	[nextPage onScreen];
    [self prepareNextPage];
}

-(void)logAVEDoneViewing:(ArticleViewingExperience*) ave {
    NSString * pageType = @"";
   if ([ave isKindOfClass:[VideoAVE class]]) {
        pageType = @"VideoAVE";
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        pageType = @"PhotoVideoAVE";
    }else if ([ave isKindOfClass:[PhotoAVE class] ]){
        pageType = @"PhotoAVE";
    }
    
    [[Analytics getSharedInstance] pageEndedViewingWithIndex:self.currentPageIndex aveType:pageType];
}

// Prepares aves almost on screen (one above or below current page)
-(void) prepareNextPage {
    NSInteger currentIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
    NSInteger indexAbove = currentIndex -1;
    NSInteger indexBelow = currentIndex +1;
	ArticleViewingExperience* pageAbove = [self.pageAves objectForKey:[NSNumber numberWithInteger:indexAbove]];
	ArticleViewingExperience* pageBelow = [self.pageAves objectForKey:[NSNumber numberWithInteger:indexBelow]];
	[pageAbove almostOnScreen];
	[pageBelow almostOnScreen];
}

#pragma mark - Down arrow -

-(void)addDownArrowButton{
    [self.mainScrollView addSubview:self.downArrow];
}

-(void)downArrowClicked {
    [UIView animateWithDuration:SCROLL_UP_ANIMATION_DURATION animations:^{
        self.mainScrollView.contentOffset = CGPointMake(0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[self displayMediaOnCurrentAVE];
	}];
}


#pragma mark - Pages Downloaded -

-(void) pagesLoadedForPOV:(NSNumber *)povID {
    NSArray* pages = [self.pageLoadManager getPagesForPOV: povID];
    [self renderPOVFromPages:pages andLikeButtonDelegate:self];
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
    if(pages.count > 1)[self addDownArrowButton];
}

-(void) renderPOVFromPages:(NSArray *) pages andLikeButtonDelegate:(id) likeDelegate{
    AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc] init];
    for (Page * page in pages) {
        [analyzer getAVEFromPage: page withFrame: self.bounds].then(^(UIView* ave) {
            NSInteger pageIndex = page.indexInPOV;
            // When first page loads, show down arrow
            if (pageIndex == 0) {
				//TODO: add like button and down arrows back
//                [self addDownArrowButton];
                
                    //[self addLikeButtonWithDelegate:likeDelegate];
            }
            [self renderNextAve: ave withIndex: [NSNumber numberWithInteger:pageIndex]];
        }).catch(^(NSError* error) {
            NSLog(@"Error getting AVE from page: %@", error.description);
        });
    }
}



#pragma mark - Playing POV content -

-(void) povOnScreen{
    [self displayMediaOnCurrentAVE];
}

-(void) povOffScreen{
    [self stopAllVideos];
}

-(void)preparePOVToBePresented{
    NSInteger currentPage = self.mainScrollView.contentOffset.x / self.frame.size.width;
    ArticleViewingExperience* page = [self.pageAves objectForKey:[NSNumber numberWithInteger:currentPage]];
    [page onScreen];
    [self prepareNextPage];
}

#pragma mark - Photo AVE Delegate -

-(void) startedDraggingAroundCircle {
	self.mainScrollView.scrollEnabled = NO;
}

-(void) stoppedDraggingAroundCircle {
	self.mainScrollView.scrollEnabled = YES;
}

-(void) viewTapped {

}

#pragma mark - Clean up -

-(void) clearArticle {
	//We clear these so that the media is released
	[self stopAllVideos];
	
	for(UIView *view in self.mainScrollView.subviews) {
		[view removeFromSuperview];
	}
	if (self.likeButton.superview) [self.likeButton removeFromSuperview];

	self.currentPageIndex = -1;
	self.pageAves = nil;
	self.pageLoadManager = nil;
}

//make sure to stop all videos
-(void) stopAllVideos {
    if (!self.pageAves) return;
    for (NSNumber* key in self.pageAves) {
		ArticleViewingExperience* ave = [self.pageAves objectForKey:key];
		[ave offScreen];
    }
}

#pragma mark - Lazy Instantiation -

-(NSMutableDictionary*) pageAves {
	if(!_pageAves) {
		_pageAves = [[NSMutableDictionary alloc] init];
	}
	return _pageAves;
}

-(UIScrollView*) mainScrollView {
	if (!_mainScrollView) {
		_mainScrollView = [[UIScrollView alloc] initWithFrame: self.bounds];
		_mainScrollView.backgroundColor = [UIColor blueColor];
		_mainScrollView.pagingEnabled = YES;
		_mainScrollView.scrollEnabled = YES;
		[_mainScrollView setShowsVerticalScrollIndicator:NO];
		[_mainScrollView setShowsHorizontalScrollIndicator:NO];
		_mainScrollView.bounces = NO;
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


@end
