//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVView.h"

#import "Article.h"
#import "BaseArticleViewingExperience.h"
#import "PhotoVideoAVE.h"
#import "Page.h"
#import "PhotoAVE.h"
#import "SizesAndPositions.h"
#import "TextAVE.h"
#import "VideoAVE.h"

@interface POVView ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic) NSInteger currentPageIndex;
@property (strong, nonatomic) NSArray * pageAves;
@property (nonatomic) float pageScrollTopBottomArea;

@end

@implementation POVView

-(instancetype)initWithFrame:(CGRect)frame andAVES:(NSArray *)povPages {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self formatSelf];
        [self renderPages: povPages];
		[self addLikeButton];
		self.currentPageIndex = -1;
    }
    return self;
}

-(void) formatSelf {
	self.pagingEnabled = YES;
	self.scrollEnabled = YES;
	[self setShowsVerticalScrollIndicator:NO];
	[self setShowsHorizontalScrollIndicator:NO];
	self.bounces = YES;
	//scroll view delegate
	self.delegate = self;
}

//renders POV pages onto the view
-(void)renderPages: (NSArray *) povPages {
	self.pageAves = povPages;
	
    self.contentSize = CGSizeMake(self.frame.size.width, [self.pageAves count] * self.frame.size.height);
	self.contentOffset = CGPointMake(0, 0);
    
    CGRect viewFrame = self.bounds;
    for(UIView* view in povPages){
		view.frame = viewFrame;
		[self addSubview: view];
		viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
    }
    float middleScreenSize = (self.frame.size.height/CIRCLE_OVER_IMAGES_RADIUS_FACTOR_OF_HEIGHT)*2 + TOUCH_THRESHOLD*2;
    self.pageScrollTopBottomArea = (self.frame.size.height - middleScreenSize)/2.f;

    [self setUpGestureRecognizers];
}

-(void) addLikeButton {
	//TODO: add like button
}

#pragma mark - Scroll view delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self displayMediaOnCurrentAVE];
}

#pragma mark - Handle Display Media on AVE -

//takes care of playing video if necessary
//or showing circle if multiple photo ave
-(void) displayMediaOnCurrentAVE {
	int nextIndex = (self.contentOffset.y/self.frame.size.height);
	UIView *currentPage = self.pageAves[nextIndex];
	if(self.currentPageIndex != nextIndex){
		if (self.currentPageIndex >= 0) {
			[self pauseVideosInAVE: self.pageAves[self.currentPageIndex]];
		}

		[self displayCircleOnAVE: currentPage];
		[self playVideosInAVE: currentPage];
		//[self showImageScrollViewBounceInAVE: self.currentPage];
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

-(void) showImageScrollViewBounceInAVE:(UIView*) ave {
    if ([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self showImageScrollViewBounceInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[PhotoVideoAVE class]]) {
        [(PhotoVideoAVE*)ave imageScrollViewBounce];
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

#pragma mark - Gesture recognizers

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
            
            CGPoint touchLocation = [sender locationOfTouch:0 inView:[self superview]];
            if (touchLocation.y < (self.frame.size.height - self.pageScrollTopBottomArea)
                && touchLocation.y > self.pageScrollTopBottomArea) {
                self.scrollEnabled = NO;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            self.scrollEnabled = YES;
            break;
        }
        default:
            break;
    }
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Clean up -

-(void) clearArticle {
    //We clear these so that the media is released
    [self stopAllVideos];
    for(UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
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
@end
