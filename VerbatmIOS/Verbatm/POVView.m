//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVView.h"

#import "BaseArticleViewingExperience.h"
#import "Icons.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "SizesAndPositions.h"
#import "TextAVE.h"
#import "VideoAVE.h"

@interface POVView ()<UIGestureRecognizerDelegate, UIScrollViewDelegate, PhotoAVEDelegate>

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) NSInteger currentPageIndex;

// Like button added by another class
@property (strong, nonatomic) UIButton* likeButton;
@property (nonatomic) BOOL liked;
@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;
@property (weak, nonatomic) id<LikeButtonDelegate> likeButtonDelegate;
@property (strong, nonatomic) NSNumber* povID;

@property (nonatomic, strong) UIButton * downArrow;

#define DOWN_ARROW_WIDTH 40
#define DOWN_ARROE_DISTANCE_FROM_BOTTOM 5
#define DOWN_ARROW_IMAGE  @"downarrow"
#define SCROLL_UP_ANIMATION_DURATION 0.7
@end

@implementation POVView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self addSubview: self.mainScrollView];
    }
    return self;
}

//renders aves (pages) onto the view
-(void) renderAVES: (NSMutableArray *) aves {
	self.pageAves = aves;
	self.currentPageIndex = -1;
	
    self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width, [self.pageAves count] * self.frame.size.height);
	self.mainScrollView.contentOffset = CGPointMake(0, 0);
    
    CGRect viewFrame = self.bounds;
    for(UIView* view in self.pageAves){
		[self setDelegateOnPhotoAVE: view];
		view.frame = viewFrame;
		[self.mainScrollView addSubview: view];
		viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
    }
    [self setUpGestureRecognizers];
}

#pragma mark - Add like button -

//should be called by another class (since preview does not have like)
//Sets the like button delegate and the povID since the delegate method
//requires a pov ID be passed back
-(void) addLikeButtonWithDelegate: (id<LikeButtonDelegate>) delegate andSetPOVID: (NSNumber*) povID {
	self.likeButtonDelegate = delegate;
	self.povID = povID;

	CGRect likeButtonFrame = CGRectMake(self.frame.size.width - LIKE_BUTTON_SIZE - LIKE_BUTTON_OFFSET,
										 LIKE_BUTTON_OFFSET, LIKE_BUTTON_SIZE, LIKE_BUTTON_SIZE);
	self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_ICON];
	self.likeButtonLikedImage = [UIImage imageNamed:LIKE_PRESSED_ICON];
	self.likeButton = [UIButton buttonWithType: UIButtonTypeCustom];
	[self.likeButton setFrame: likeButtonFrame];
	[self.likeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];

	self.liked = NO;
	[self.likeButton setImage: self.likeButtonNotLikedImage forState:UIControlStateNormal];

	[self.likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview: self.likeButton];
}

-(void) likeButtonPressed {
	self.liked = !self.liked;
	if (self.liked) {
		[self.likeButton setImage:self.likeButtonLikedImage forState:UIControlStateNormal];
	} else {
		[self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
	}
	[self.likeButtonDelegate likeButtonLiked: self.liked onPOVWithID:self.povID];
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
	int nextIndex = (self.mainScrollView.contentOffset.y/self.frame.size.height);
	UIView *currentPage = self.pageAves[nextIndex];
	if(self.currentPageIndex != nextIndex){
		if (self.currentPageIndex >= 0) {
			[self pauseVideosInAVE: self.pageAves[self.currentPageIndex]];
		}

		[self displayCircleOnAVE: currentPage];
		[self playVideosInAVE: currentPage];
		self.currentPageIndex = nextIndex;
	}
}

-(void) displayCircleOnAVE:(UIView*) ave {
    if ([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self displayCircleOnAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[PhotoAVE class]]) {
        [(PhotoAVE*)ave showAndRemoveCircle];
    }
}

#pragma mark - Video playback

-(void) stopVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self stopVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave stopVideo];
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] stopVideo];
    }
}

-(void) pauseVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self pauseVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave pauseVideo];
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] pauseVideo];
    }
}

-(void) playVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self playVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave continueVideo];
    } else if([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [[(PhotoVideoAVE*)ave videoView] continueVideo];
    }
}

#pragma mark - Down arrow -

-(void)addDownArrowButton{
    self.downArrow = [[UIButton alloc] init];
    [self.downArrow setImage:[UIImage imageNamed:DOWN_ARROW_IMAGE] forState:UIControlStateNormal];
    self.downArrow.frame = CGRectMake(self.center.x - (DOWN_ARROW_WIDTH/2),
                                      self.frame.size.height - DOWN_ARROW_WIDTH - DOWN_ARROE_DISTANCE_FROM_BOTTOM,
                                      DOWN_ARROW_WIDTH, DOWN_ARROW_WIDTH);
    [self.mainScrollView addSubview:self.downArrow];
    [self.downArrow addTarget:self action:@selector(downArrowClicked) forControlEvents:UIControlEventTouchUpInside];
}

-(void)downArrowClicked {
    [UIView animateWithDuration:SCROLL_UP_ANIMATION_DURATION animations:^{
        self.mainScrollView.contentOffset = CGPointMake(0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[self displayMediaOnCurrentAVE];
	}];
}

#pragma mark - Gesture recognizers -

//Sets up the gesture recognizer for dragging from the edges.
-(void) setUpGestureRecognizers {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(scrollPage:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}


-(void) scrollPage:(UIPanGestureRecognizer*) sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if ([sender numberOfTouches] != 1) return;
//            
//            CGPoint touchLocation = [sender locationOfTouch:0 inView:[self superview]];
//            if (touchLocation.y < (self.frame.size.height - self.pageScrollTopBottomArea)
//                && touchLocation.y > self.pageScrollTopBottomArea) {
//                self.mainScrollView.scrollEnabled = NO;
//            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            self.mainScrollView.scrollEnabled = YES;
            break;
        }
        default:
            break;
    }
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
    for (UIView* ave in self.pageAves) {
        [self stopVideosInAVE:ave];
    }
}


#pragma mark - Lazy Instantiation -

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

@end
