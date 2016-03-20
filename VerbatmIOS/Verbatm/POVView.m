//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"
#import "AveTypeAnalyzer.h"
#import "LoadingIndicator.h"
#import "CreatorAndChannelBar.h"

#import "Durations.h"

#import "Icons.h"

#import "Like_BackendManager.h"

#import "POVLikeAndShareBar.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "POVView.h"
#import "Page.h"
#import "PagesLoadManager.h"
#import "ParseBackendKeys.h"
#import <PromiseKit/PromiseKit.h>

#import "SizesAndPositions.h"
#import "Styles.h"

#import "UserManager.h"
#import "UserSetupParameters.h"
#import "UIView+Effects.h"

#import "VideoAVE.h"

@interface POVView ()<UIScrollViewDelegate, PhotoAVEDelegate,
    PagesLoadManagerDelegate, POVLikeAndShareBarProtocol>

// Load manager in charge of getting page objects and all their media for each pov
@property (strong, nonatomic) PagesLoadManager* pageLoadManager;


@property (nonatomic) CreatorAndChannelBar * creatorAndChannelBar;


// mapping between NSNumber of type Integer and ArticleViewingExperience
@property (strong, nonatomic) NSMutableDictionary * pageAves;

//used to lazily instantiate pages when the view is about to presented
//se save the page media here and then load and present the pages on demand
@property (strong, nonatomic) NSMutableDictionary * pageAveMedia;

@property (nonatomic) NSNumber* currentIndexOfPageLoading;

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) NSInteger currentPageIndex;

// Like button added by another class
@property (strong, nonatomic) UIButton* likeButton;
@property (nonatomic) BOOL liked;
@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;
//@property (weak, nonatomic) id<LikeButtonDelegate> likeButtonDelegate;

@property (nonatomic, strong) UIButton * downArrow;

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;
@property (strong, nonatomic) LoadingIndicator * customActivityIndicator;
@property (nonatomic) POVLikeAndShareBar * likeShareBar;
@property (nonatomic) CGRect lsBarDownFrame;// the framw of the like share button with the tab down
@property (nonatomic) CGRect lsBarUpFrame;//the frame of the like share button with the tab up

@property (nonatomic) UIImageView * swipeUpAndDownInstruction;///tell user they can swipe up and down to navigate


@property (nonatomic) NSMutableArray * mediaPageContent;//TODO

@property(nonatomic) BOOL povIsCurrentlyBeingShown;

#define DOWN_ARROW_WIDTH 30.f
#define DOWN_ARROW_DISTANCE_FROM_BOTTOM 40.f
#define SCROLL_UP_ANIMATION_DURATION 0.7
#define ACTIVITY_ANIMATION_Y 100.f
@end

@implementation POVView

-(instancetype)initWithFrame:(CGRect)frame andPovParseObject:(PFObject*) povObject {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview: self.mainScrollView];
        self.mainScrollView.backgroundColor = [UIColor blackColor];
        if(povObject)self.parsePostObject = povObject;
        [self createBorder];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview: self.mainScrollView];
        self.mainScrollView.backgroundColor = [UIColor blackColor];
        [self createBorder];
    }
    return self;
}

-(void)createBorder{
    [self.layer setBorderWidth:2.0];
    [self.layer setCornerRadius:0.0];
    [self.layer setBorderColor:[UIColor blackColor].CGColor];
}



#pragma mark - Display page -

-(void) scrollToPageAtIndex:(NSInteger) pageIndex{
    if(pageIndex < self.pageAves.count && pageIndex >= 0){
        self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollView.frame.size.height * (pageIndex));
        [self displayMediaOnCurrentAVE];
    }
}

-(void) renderNextAve: (ArticleViewingExperience*)ave withIndex: (NSNumber*) pageIndex {
    [self setDelegateOnPhotoAVE: ave];
    CGRect frame = CGRectMake(0, [pageIndex integerValue] * self.mainScrollView.frame.size.height , self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
    ave.frame = frame;
    
    [self.mainScrollView addSubview:ave];

    [self.pageAves setObject:ave forKey:pageIndex];
}

//renders aves (pages) onto the view
-(void) renderAVES: (NSMutableArray *) aves {

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
}
-(void)checkIfUserHasLikedThePost{
    [Like_BackendManager currentUserLikesPost:self.parsePostObject withCompletionBlock:^(bool userLikedPost) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.likeShareBar shouldStartPostAsLiked:userLikedPost];
        });
    }];
}

-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage startUp:(BOOL)up{
    
    self.lsBarUpFrame = CGRectMake(0.f,self.frame.size.height -LIKE_SHARE_BAR_HEIGHT - TAB_BAR_HEIGHT ,
                                 self.frame.size.width, LIKE_SHARE_BAR_HEIGHT);
    
    self.lsBarDownFrame = CGRectMake(0.f,self.frame.size.height - LIKE_SHARE_BAR_HEIGHT,
                                     self.frame.size.width, LIKE_SHARE_BAR_HEIGHT);
    
    CGRect startFrame = (up) ? self.lsBarUpFrame : self.lsBarDownFrame;
    
    self.likeShareBar = [[POVLikeAndShareBar alloc] initWithFrame: startFrame numberOfLikes:numLikes numberOfShares:numShares numberOfPages:numPages andStartingPageNumber:startPage];
    self.likeShareBar.delegate = self;
    [self addSubview:self.likeShareBar];
    [self checkIfUserHasLikedThePost];
}

//like-share bar protocol

-(void)shareButtonPressed {
    [self.delegate shareOptionSelectedForParsePostObject:self.parsePostObject];
}


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

-(void)userAction:(ActivityOptions) action isPositive:(BOOL) positive{
    
    switch (action) {
        case Like:
            if(positive){
                [Like_BackendManager currentUserLikePost:self.parsePostObject];
            }else{
                [Like_BackendManager currentUserStopLikingPost:self.parsePostObject];
            }
            
            break;
        case Share:
            
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
	NSInteger currentViewableIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	ArticleViewingExperience *currentPageOnScreen = [self.pageAves objectForKey:[NSNumber numberWithInteger:currentViewableIndex]];
    
	[currentPageOnScreen onScreen];
    
    [self checkForMuteButton:currentPageOnScreen];
    
    [self prepareNextPage];
    
}


-(void)checkForMuteButton:(ArticleViewingExperience * )currentPageOnScreen {
    
    if ([currentPageOnScreen isKindOfClass:[VideoAVE class]] ||
        [currentPageOnScreen isKindOfClass:[PhotoVideoAVE class]]) {
     
        [self.likeShareBar presentMuteButton:YES];
    }else {
        [self.likeShareBar presentMuteButton:NO];
    }

}




-(void)presentSwipeUpAndDownInstruction {
    
    
    UIImage * instructionImage = [UIImage imageNamed:SWIPE_UP_DOWN_INSTRUCTION];
    
    CGFloat frameHeight = 120.f;
    CGFloat frameWidth = ((frameHeight * 117.f)/284.f);
    
    
    CGFloat frameOriginX = self.frame.size.width - frameWidth - 10.f;
    CGFloat frameOriginY = (self.frame.size.height/2.f) + 50.f;
    
    CGRect instructionFrame = CGRectMake(frameOriginX,frameOriginY, frameWidth,frameHeight);
                                         
    
    
    self.swipeUpAndDownInstruction = [[UIImageView alloc] initWithImage:instructionImage];
    self.swipeUpAndDownInstruction.frame = instructionFrame;
    [self addSubview:self.swipeUpAndDownInstruction];
    [self bringSubviewToFront:self.swipeUpAndDownInstruction];
    
    
}


-(void)presentFilterSwipeForInstructionWithAve:(ArticleViewingExperience *) currentAve{
    
    
    
    BOOL isPhotoAve = [currentAve isKindOfClass:[PhotoAVE class]];
    BOOL isVideoAve = [currentAve isKindOfClass:[PhotoVideoAVE class]];
    
    BOOL filterInstructionHasNotBeenPresented = ![[UserSetupParameters sharedInstance] isFilter_InstructionShown];
    
    if( (isPhotoAve || isVideoAve)  && filterInstructionHasNotBeenPresented){
        UIImage * instructionImage = [UIImage imageNamed:FILTER_SWIPE_INSTRUCTION];
        CGFloat frameWidth = 200.f;
        CGFloat frameHeight = (frameWidth * 320.f) /488.f;
        
        UIImageView * filterInstruction = [[UIImageView alloc] initWithImage:instructionImage];
        filterInstruction.backgroundColor = [UIColor clearColor];
        
        CGFloat imageOriginX = (self.frame.size.width/2.f) - (frameWidth/2.f);
        
        
        if(isPhotoAve){
           filterInstruction.frame = CGRectMake(imageOriginX,
                                                (self.frame.size.height/2.f) + frameHeight,
                                                frameWidth, frameHeight);
        }else{
            
          filterInstruction.frame = CGRectMake(imageOriginX,
                                          self.frame.size.height - (frameHeight + 50.f), frameWidth, frameHeight);

        }
        
        [self addSubview:filterInstruction];
        [self bringSubviewToFront:filterInstruction];
        //commented out for debugging but should not be
        //[[UserSetupParameters sharedInstance] set_filter_InstructionAsShown];
    }
    
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
		[self displayMediaOnCurrentAVE];
	}];
}


#pragma mark - Pages Downloaded -

-(void) pagesLoadedForPOV:(NSNumber *)povID {
//    NSArray* pages = [self.pageLoadManager getPagesForPOV: povID];
//    [self renderPOVFromPages:pages andLikeButtonDelegate:self];
}

-(void) renderPOVFromPages:(NSArray *) pages{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.customActivityIndicator startCustomActivityIndicator];
        
        //[self.activityIndicator startAnimating];
    });
    AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc] init];
    
    NSMutableArray * downloadPromises = [[NSMutableArray alloc] init];
    
    for (PFObject * parsePageObject in pages) {
        
         AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
            [analyzer getAVEFromPage:parsePageObject withFrame:self.bounds andCompletionBlock:^(NSArray * aveMedia) {
                [self storeMedia:aveMedia forPageIndex:[parsePageObject valueForKey:PAGE_INDEX_KEY]];
                resolve(nil);
            }];
         }];
        [downloadPromises addObject:promise];
    }
    
    PMKWhen(downloadPromises).then(^(id data){
        if(self.povIsCurrentlyBeingShown){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentMediaContent];
                [self povOnScreen];
            });
        }
    });
}


-(void)storeMedia:(NSArray *) media forPageIndex:(NSNumber*) pageIndex{
    if(media){
        [self.pageAveMedia setObject:media forKey:pageIndex];
    }
}

-(void)presentMediaContent{
    if(self.pageAveMedia.count > 0){
        [self.customActivityIndicator stopCustomActivityIndicator];

        
//        [self.activityIndicator stopAnimating];
//        self.activityIndicator = nil;
        
        for(NSInteger key = 0; key < self.pageAveMedia.count; key++){
            NSArray * media = [self.pageAveMedia objectForKey:[NSNumber numberWithInteger:key]];
            ArticleViewingExperience * ave = [AVETypeAnalyzer getAVEFromPageMedia:media withFrame:self.bounds];
            //add bar at the bottom with page numbers etc
            [self renderNextAve:ave withIndex:[NSNumber numberWithInteger:key]];
            [self setApproprioateScrollViewContentSize];
        }
        
        [self.pageAveMedia removeAllObjects];
    }
}



#pragma mark - Playing POV content -

-(void) povOnScreen{
    if(self.pageAveMedia.count > 0 &&
       self.pageAves.count ==0){
        //we lazily create out pages
        [self presentMediaContent];
    }
    
    [self displayMediaOnCurrentAVE];
    self.povIsCurrentlyBeingShown = YES;
}

-(void) povOffScreen{
    [self stopAllVideos];
    self.povIsCurrentlyBeingShown = NO;
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


-(void)setApproprioateScrollViewContentSize{
    self.mainScrollView.contentSize = CGSizeMake(0, self.pageAves.count * self.frame.size.height);
}


#pragma mark - Clean up -

-(void) clearArticle {
	//We clear these so that the media is released
	[self stopAllVideos];
	
	for(UIView *view in self.mainScrollView.subviews) {
		[view removeFromSuperview];
	}
	if (self.likeButton.superview) [self.likeButton removeFromSuperview];
    [self.likeShareBar removeFromSuperview];
    self.likeShareBar =  nil;
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



-(NSMutableDictionary*) pageAveMedia {
    if(!_pageAveMedia) {
        _pageAveMedia = [[NSMutableDictionary alloc] init];
    }
    return _pageAveMedia;
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
-(LoadingIndicator *)customActivityIndicator{
    if(!_customActivityIndicator){
        CGPoint newCenter = CGPointMake(self.center.x, self.frame.size.height * 1.f/2.f);
        _customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:newCenter];
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
