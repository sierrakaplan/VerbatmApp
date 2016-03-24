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
#import "PostChannelAndCreatorBar.h"
#import "Post_Channel_RelationshipManger.h"

#import "SizesAndPositions.h"
#import "Styles.h"

#import "UserManager.h"
#import "UserSetupParameters.h"
#import "UIView+Effects.h"

#import "VideoAVE.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface POVView ()<UIScrollViewDelegate, PhotoAVEDelegate,
                    PagesLoadManagerDelegate, POVLikeAndShareBarProtocol, CreatorAndChannelBarProtocol>

// Load manager in charge of getting page objects and all their media for each pov
@property (strong, nonatomic) PagesLoadManager* pageLoadManager;


@property (nonatomic) CreatorAndChannelBar * creatorAndChannelBar;


// mapping between NSNumber of type Integer and ArticleViewingExperience
@property (strong, nonatomic) NSMutableDictionary * pageAves;

//used to lazily instantiate pages when the view is about to presented
//we save the page media here and then lazily load and present the pages
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


@property (nonatomic) UIView * PagingLine;//line that moves up and down as the user swipes up and down

@property (nonatomic) UIImageView * pageUpIndicator;

@property (nonatomic) NSMutableArray * mediaPageContent;//TODO

@property(nonatomic) BOOL povIsCurrentlyBeingShown;

#define DOWN_ARROW_WIDTH 30.f
#define DOWN_ARROW_DISTANCE_FROM_BOTTOM 40.f
#define SCROLL_UP_ANIMATION_DURATION 0.7
#define ACTIVITY_ANIMATION_Y 100.f

#define PAGING_LINE_WIDTH 4.f
#define PAGING_LINE_ANIMATION_DURATION 0.5
#define PAGING_LINE_COLE [UIColor whiteColor]
@end

@implementation POVView

-(instancetype)initWithFrame:(CGRect)frame andPovParseObject:(PFObject*) povObject {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview: self.mainScrollView];
        self.mainScrollView.backgroundColor = [UIColor blackColor];
        if(povObject)self.parsePostChannelActivityObject = povObject;
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
        [self addPagingLine];
    }
    return self;
}

-(void)createBorder{
    [self.layer setBorderWidth:2.0];
    [self.layer setCornerRadius:0.0];
    [self.layer setBorderColor:[UIColor blackColor].CGColor];
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
-(void) checkIfUserHasLikedThePost {
    [Like_BackendManager currentUserLikesPost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]withCompletionBlock:^(bool userLikedPost) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.likeShareBar shouldStartPostAsLiked:userLikedPost];
        });
    }];
}

-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage startUp:(BOOL)up{
    
    //verticle bar positioning
//    CGFloat barHeight = (self.frame.size.height/2.f);
//    
//    self.lsBarUpFrame = CGRectMake(0.f,barHeight - TAB_BAR_HEIGHT,
//                                 LIKE_SHARE_BAR_HEIGHT,barHeight);
//    
//    self.lsBarDownFrame = CGRectMake(0.f,barHeight,
//                                     LIKE_SHARE_BAR_HEIGHT,barHeight);
    
    //horizontal bar positioning
    CGFloat barHeight = LIKE_SHARE_BAR_HEIGHT;
    
    self.lsBarUpFrame = CGRectMake(0.f,self.frame.size.height - (barHeight + TAB_BAR_HEIGHT),
                                   self.frame.size.width,barHeight);
    
    self.lsBarDownFrame = CGRectMake(0.f,self.frame.size.height - barHeight,
                                     self.frame.size.width,barHeight);
    
    
    
    CGRect startFrame = (up) ? self.lsBarUpFrame : self.lsBarDownFrame;
    
    self.likeShareBar = [[POVLikeAndShareBar alloc] initWithFrame: startFrame numberOfLikes:numLikes numberOfShares:numShares numberOfPages:numPages andStartingPageNumber:startPage];
    self.likeShareBar.delegate = self;
    [self addSubview:self.likeShareBar];
    [self checkIfUserHasLikedThePost];
    [self addCreatorInfo];
}



-(void)showWhoLikesThePOV{
}

-(void)showwhoHasSharedThePOV{
    
}


-(void) addCreatorInfo{
    [Post_Channel_RelationshipManger getChannelObjectFromParsePCRelationship:self.parsePostChannelActivityObject withCompletionBlock:^(Channel * channel) {
        //we only add the channel info to posts that don't belong to the current
        //user
        if(![channel channelBelongsToCurrentUser]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect creatorBarFrame = CGRectMake(0.f, 0.f, self.frame.size.width, CREATOR_CHANNEL_BAR_HEIGHT);
                self.creatorAndChannelBar = [[CreatorAndChannelBar alloc] initWithFrame:creatorBarFrame andChannel:channel];
                self.creatorAndChannelBar.delegate = self;
                [self addSubview:self.creatorAndChannelBar];
            });
        }
    }];
}

-(void)channelSelected:(Channel *) channel withOwner:(PFUser *) owner{
    [self.delegate channelSelected:channel withOwner:owner];

}

#pragma mark - Add like button -


-(void) shiftLikeShareBarDown:(BOOL) down{
    BOOL shiftArrow = NO;
    if(self.pageUpIndicator){
        shiftArrow = YES;
        [self.pageUpIndicator removeFromSuperview];
        self.pageUpIndicator = nil;
    }
    
    if(down){
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.likeShareBar.frame = self.lsBarDownFrame;
        } completion:^(BOOL finished) {
            if(finished && shiftArrow){
                [self addUpArrowAnimation];
            }
        }];
    }else{
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.likeShareBar.frame = self.lsBarUpFrame;
        } completion:^(BOOL finished) {
            if(finished && shiftArrow){
                [self addUpArrowAnimation];
            }
        }];
    }
}

-(void)userAction:(ActivityOptions) action isPositive:(BOOL) positive{
    
    switch (action) {
        case Like:
            if(positive){
                [Like_BackendManager currentUserLikePost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
            }else{
                [Like_BackendManager currentUserStopLikingPost:[self.parsePostChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST]];
            }
            break;
        case Share:
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
    //[self setPageNumberOnShareBarFromScrollView:scrollView];
    [self displayMediaOnCurrentAVE];
    [self removePageUpIndicatorFromView];
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

-(void)muteButtonSelected:(BOOL)shouldMute{
        [self muteAllVideos:shouldMute];    
}


-(void)muteAllVideos:(BOOL) shouldMute{
    for(id ave in [self.pageAves allValues]){
       
        if ([ave isKindOfClass:[VideoAVE class]] ||
            [ave isKindOfClass:[PhotoVideoAVE class]]) {
           
            if(shouldMute){
                [(VideoAVE *)ave muteVideo];
            }else{
                [(VideoAVE *)ave unmuteVideo];
            }
            
        }
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
    self.povIsCurrentlyBeingShown = YES;
    
    if(self.pageAveMedia){
        if(self.pageAveMedia.count > 0 &&
           self.pageAves.count ==0){
            //we lazily create out pages
            [self presentMediaContent];
        }
        [self displayMediaOnCurrentAVE];
    }
    
    if(self.pageAves.count > 1){
        [self addUpArrowAnimation];
    }
}

-(void) povOffScreen{
     self.povIsCurrentlyBeingShown = NO;
    [self stopAllVideos];
    [self removePageUpIndicatorFromView];
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
    [self removePageUpIndicatorFromView];
}

//make sure to stop all videos
-(void) stopAllVideos {
    if (!self.pageAves) return;
    for (NSNumber* key in self.pageAves) {
		ArticleViewingExperience* ave = [self.pageAves objectForKey:key];
		[ave offScreen];
    }
}


//removes the little bouncing arrow in the right corner of the screen
-(void)removePageUpIndicatorFromView{
    if(self.pageUpIndicator){
        [UIView animateWithDuration:1.f animations:^{
            self.pageUpIndicator.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.pageUpIndicator removeFromSuperview];
            self.pageUpIndicator = nil;
        }];
        
    }
}

//adds the little bouncing arrow to the bottom right of the screen
-(void)addUpArrowAnimation{
    if(!self.pageUpIndicator && self.pageAves.count){
        if(![NSThread isMainThread]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startArrowAnimation];
            });
        }else{
            [self startArrowAnimation];
        }
    }
    
    
    
}

-(void)startArrowAnimation{
    
    UIImage * arrowImage = [UIImage imageNamed:@"up_arrow"];
    UIImageView * iv = [[UIImageView alloc] initWithImage:arrowImage];
    [self addSubview:iv];
    [self bringSubviewToFront:iv];
    
    CGFloat size = 30.f;
    CGFloat x_cord = self.frame.size.width - size - 8.f;
    CGFloat y_cord = (self.likeShareBar.frame.origin.y + self.likeShareBar.frame.size.height) - size - 3.f;
    CGRect frame = CGRectMake(x_cord,y_cord, size, size);
    iv.frame = frame;
    
    
    CABasicAnimation *pulse;
    pulse = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    pulse.duration = 0.5;
    pulse.autoreverses = YES;
    pulse.cumulative = NO;
    pulse.fillMode = kCAFillModeForwards;
    pulse.fromValue = [NSNumber numberWithFloat:1.f];
    pulse.toValue =[NSNumber numberWithFloat:(-20.f)];
    pulse.repeatCount = HUGE_VALF;
    
    [iv.layer removeAllAnimations];
    [iv.layer addAnimation:pulse forKey:@"Pulse"];
    self.pageUpIndicator = iv;
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
