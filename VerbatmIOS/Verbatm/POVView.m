//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVView.h"
#import "Analytics.h"
#import "CoverPhotoAVE.h"
#import "BaseArticleViewingExperience.h"
#import "Icons.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "SizesAndPositions.h"
#import "TextAVE.h"
#import "VideoAVE.h"
#import "UserManager.h"

@interface POVView ()<UIScrollViewDelegate, PhotoAVEDelegate>

// mapping between integer and uiview
@property (strong, nonatomic) NSMutableDictionary * pageAves;
@property (nonatomic) NSNumber* currentIndexOfPageLoading;

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) NSInteger currentPageIndex;

// Like button added by another class
@property (strong, nonatomic) UIButton* likeButton;
@property (nonatomic) BOOL liked;
@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;
@property (weak, nonatomic) id<LikeButtonDelegate> likeButtonDelegate;
@property (strong, nonatomic) PovInfo* povInfo;

@property (nonatomic, strong) UIButton * downArrow;

#define DOWN_ARROW_WIDTH 30
#define DOWN_ARROE_DISTANCE_FROM_BOTTOM 30
#define SCROLL_UP_ANIMATION_DURATION 0.7
@end

@implementation POVView

-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addSubview: self.mainScrollView];
		self.currentIndexOfPageLoading = [NSNumber numberWithInteger:0];
	}
	return self;
}

-(instancetype)initWithFrame:(CGRect)frame andPOVInfo:(PovInfo*) povInfo {
    self = [self initWithFrame:frame];
    if (self) {
		self.povInfo = povInfo;
    }
    return self;
}


-(void)moveViewTopPageIndex:(NSInteger) pageIndex{
    if(pageIndex < self.pageAves.count){
        self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollView.frame.size.height * (pageIndex+1));//+1 for the cover photo
        
        [self displayMediaOnCurrentAVE];
    }
}


-(void) renderNextAve: (UIView*) ave withIndex: (NSNumber*) pageIndex {
	[self.pageAves setObject:ave forKey:pageIndex];
	if (pageIndex == self.currentIndexOfPageLoading) {
		self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width,
													 (self.currentIndexOfPageLoading.integerValue+1) * self.frame.size.height);
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
		UIView* ave = aves[i];
		[self.pageAves setObject:ave forKey:[NSNumber numberWithInt:i]];
		[self setDelegateOnPhotoAVE: ave];
		ave.frame = viewFrame;
		[self.mainScrollView addSubview: ave];
		viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
	}
}

#pragma mark - Add like button -

//should be called by another class (since preview does not have like)
//Sets the like button delegate and the povID since the delegate method
//requires a pov ID be passed back
-(void) addLikeButtonWithDelegate: (id<LikeButtonDelegate>) delegate {
	self.likeButtonDelegate = delegate;
	// check if current user likes story
	self.liked = [[UserManager sharedInstance] currentUserLikesStory: self.povInfo];
	if (self.liked) {
		[self.likeButton setImage:self.likeButtonLikedImage forState:UIControlStateNormal];
	} else {
		[self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
	}
	[self addSubview: self.likeButton];
}

-(void) likeButtonPressed {
	self.liked = !self.liked;
	if (self.liked) {
		[self.likeButton setImage:self.likeButtonLikedImage forState:UIControlStateNormal];
	} else {
		[self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
	}
	[self.likeButtonDelegate likeButtonLiked: self.liked onPOV: self.povInfo];
}

#pragma mark - Scroll view delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self displayMediaOnCurrentAVE];
}

#pragma mark - Handle Display Media on AVE -

-(void) setDelegateOnPhotoAVE: (UIView*) ave {
	if ([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
		[self setDelegateOnPhotoAVE:[(BaseArticleViewingExperience*)ave subAVE]];
	} else if ([ave isKindOfClass:[PhotoAVE class]]) {
		((PhotoAVE*) ave).delegate = self;
	}
}

//takes care of playing video if necessary
//or showing circle if multiple photo ave
-(void) displayMediaOnCurrentAVE {
	NSInteger nextIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	BaseArticleViewingExperience *nextPage = [self.pageAves objectForKey:[NSNumber numberWithInteger:nextIndex]];
    BaseArticleViewingExperience * currentPage = [self.pageAves objectForKey:[NSNumber numberWithInteger: self.currentPageIndex]];
    if(self.currentPageIndex != nextIndex){
        //stop recording old page
        [self logAVEDoneViewing:currentPage];
        //start recoring new page
        [[Analytics getSharedInstance]pageStartedViewingWithIndex:nextIndex];
    }else if (!nextIndex){//first page of the article
        //start recoring new page
        [[Analytics getSharedInstance]pageStartedViewingWithIndex:nextIndex];
    }
    
	if(self.currentPageIndex != nextIndex){
		if (self.currentPageIndex >= 0) {
			[self pauseVideosInAVE: currentPage];
		}
        self.currentPageIndex = nextIndex;
		[self displayCircleOnAVE: nextPage];
		[self playVideosInAVE: nextPage];
	}
    
    [self prepareOutLiersToEnterScreen];
}


-(void)logAVEDoneViewing:(BaseArticleViewingExperience *) ave{
    
    NSString * pageType = @"";

   if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave offScreen];
        pageType = @"VideoAVE";
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] offScreen];
        pageType = @"PhotoVideoAVE";
    }else if ([ave isKindOfClass:[PhotoAVE class] ]){
        pageType = @"PhotoAVE";
    }else{//must be textAve
        pageType = @"textAve";
    }
    
    [[Analytics getSharedInstance] pageEndedViewingWithIndex:self.currentPageIndex aveType:pageType];
}

-(void) displayCircleOnAVE:(UIView*) ave {
    if ([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self displayCircleOnAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[PhotoAVE class]]) {
        ((PhotoAVE *)ave).povScrollView = self.mainScrollView;
        [(PhotoAVE*)ave showAndRemoveCircle];
    }else if ([ave isKindOfClass:[PhotoVideoAVE class]]){
        ((PhotoVideoAVE *)ave).povScrollView = self.mainScrollView;
        [(PhotoVideoAVE*)ave showAndRemoveCircle];
    }
}

#pragma mark - Video playback

-(void) stopVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self stopVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    }else{
        if(![ave isKindOfClass:[CoverPhotoAVE class]])[(VideoAVE *)ave offScreen];//all aves have an offscreen function
    }
}

-(void) pauseVideosInAVE:(UIView*) ave {
    NSString * pageType = @"";
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self pauseVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave offScreen];
        pageType = @"VideoAVE";
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] offScreen];
        pageType = @"PhotoVideoAVE";
    }else if ([ave isKindOfClass:[PhotoAVE class] ]){
        pageType = @"PhotoAVE";
    }else{//must be textAve
        pageType = @"textAve";
    }
}

-(void) playVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self playVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave onScreen];
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] onScreen];
    }
}

//given a boarder view  and we prepare its video media to appear
//these are views that are one swipe (up/down) away from being shown
-(void)prepareOutLiersToEnterScreen{
    NSInteger currIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
    NSInteger  indexAbove = currIndex -1;
    NSInteger indexBelow = currIndex +1;
    
    for (int i =0; i < self.pageAves.count; i++) {
        UIView * page = [self.pageAves objectForKey:[NSNumber numberWithInt:i]];
        if(i == indexAbove){
            [self prepareView:page];
        }else if(i == indexBelow){
            [self prepareView:page];
        }else if (i != currIndex){
            [self pauseVideosInAVE:page];
        }
    }
}

-(void)prepareView:(UIView *) ave{
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self prepareView:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave almostOnScreen];
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] almostOnScreen];
    }
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

#pragma mark - Photo AVE Delegate -

-(void) startedDraggingAroundCircle {
	self.mainScrollView.scrollEnabled = NO;
}

-(void) stoppedDraggingAroundCircle {
	self.mainScrollView.scrollEnabled = YES;
}

#pragma mark - Clean up -

-(void) clearArticle {
    //We clear these so that the media is released
    [self stopAllVideos];
    for(UIView *view in self.mainScrollView.subviews) {
        [view removeFromSuperview];
    }
    [self.likeButton removeFromSuperview];
    self.currentPageIndex = -1;
    self.pageAves = nil;
}

//make sure to stop all videos
-(void) stopAllVideos {
    if (!self.pageAves) return;
    for (NSNumber * key in self.pageAves) {
        [self stopVideosInAVE:self.pageAves[key]];
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

-(UIButton *)likeButton {
	if (!_likeButton) {
		CGRect likeButtonFrame = CGRectMake(LIKE_BUTTON_OFFSET,
											self.frame.size.height - LIKE_BUTTON_SIZE - DOWN_ARROE_DISTANCE_FROM_BOTTOM,
											LIKE_BUTTON_SIZE, LIKE_BUTTON_SIZE);

		self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_ICON];
		self.likeButtonLikedImage = [UIImage imageNamed:LIKE_PRESSED_ICON];
		_likeButton = [UIButton buttonWithType: UIButtonTypeCustom];
		[_likeButton setFrame: likeButtonFrame];
		[_likeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[_likeButton setImage: self.likeButtonNotLikedImage forState:UIControlStateNormal];
		[_likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _likeButton;
}

-(UIButton*) downArrow {
	if (!_downArrow) {
		_downArrow = [[UIButton alloc] init];
		[_downArrow setImage:[UIImage imageNamed:PULLDOWN_ICON] forState:UIControlStateNormal];
		_downArrow.frame = CGRectMake(self.center.x - (DOWN_ARROW_WIDTH/2),
										  self.frame.size.height - DOWN_ARROW_WIDTH - DOWN_ARROE_DISTANCE_FROM_BOTTOM,
										  DOWN_ARROW_WIDTH, DOWN_ARROW_WIDTH);
		[_downArrow addTarget:self action:@selector(downArrowClicked) forControlEvents:UIControlEventTouchUpInside];
	}
	return _downArrow;
}


@end
