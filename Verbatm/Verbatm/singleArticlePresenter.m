//
//  singleArticlePresenter.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "singleArticlePresenter.h"

#import "Article.h"
#import "BaseArticleViewingExperience.h"
#import "MultiplePhotoVideoAVE.h"
#import "Page.h"
#import "PhotoAVE.h"
#import "SizesAndPositions.h"
#import "TextAVE.h"
#import "VideoAVE.h"

@interface singleArticlePresenter ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIView* animatingView;
@property (strong, nonatomic) NSMutableArray * pageAves;
@property (nonatomic) float pageScrollTopBottomArea;

@end

@implementation singleArticlePresenter

-(instancetype)initWithFrame:(CGRect)frame andArticleList: (NSMutableArray *) articlePages {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self formatSelf];
        [self layArticlePages:articlePages];
    }
    return self;
}

//lays out the article pages onto the view
-(void)layArticlePages: (NSMutableArray *) articlePages {
    self.contentSize = CGSizeMake(self.frame.size.width, [articlePages count]*self.frame.size.height);
    
    CGRect viewFrame = self.bounds;
    for(UIView* view in articlePages){
        if([view isKindOfClass:[TextAVE class]]){
            view.frame = viewFrame;
            [self addSubview: view];
            viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
            continue;
        }
        [self insertSubview:view atIndex:0];
        view.frame = viewFrame;
        viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height);
    }
    float middleScreenSize = (self.frame.size.height/CIRCLE_OVER_IMAGES_RADIUS_FACTOR_OF_HEIGHT)*2 + TOUCH_THRESHOLD*2;
    self.pageScrollTopBottomArea = (self.frame.size.height - middleScreenSize)/2.f;
    self.pageAves = articlePages;
    [self setUpGestureRecognizers];
}

-(void) formatSelf {
    self.pagingEnabled = YES;
    self.scrollEnabled = YES;
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    self.bounces = NO;
    self.backgroundColor = [UIColor blackColor];
}


#pragma mark - Handle Display Media on AVE -
//takes care of playing video if necessary
//or showing circle if multiple photo ave
-(void) displayMediaOnAVE:(UIView*) ave {
    [self displayCircleOnAVE:ave];
    [self playVideosInAVE:ave];
    //[self showImageScrollViewBounceInAVE:ave];
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
    } else if ([ave isKindOfClass:[MultiplePhotoVideoAVE class]]) {
        [(MultiplePhotoVideoAVE*)ave imageScrollViewBounce];
    }
}

#pragma mark - Video playback

-(void) stopVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self stopVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave stopVideo];
    } else if([ave isKindOfClass:[MultiplePhotoVideoAVE class]]) {
        [[(MultiplePhotoVideoAVE*)ave videoView] stopVideo];
    }
}

-(void) pauseVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self pauseVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave pauseVideo];
    } else if([ave isKindOfClass:[MultiplePhotoVideoAVE class]]) {
        [[(MultiplePhotoVideoAVE*)ave videoView] pauseVideo];
    }
}

-(void) playVideosInAVE:(UIView*) ave {
    if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
        [self playVideosInAVE:[(BaseArticleViewingExperience*)ave subAVE]];
    } else if ([ave isKindOfClass:[VideoAVE class]]) {
        [(VideoAVE*)ave continueVideo];
    } else if([ave isKindOfClass:[MultiplePhotoVideoAVE class]]) {
        [[(MultiplePhotoVideoAVE*)ave videoView] continueVideo];
    }
}

#pragma mark - Playing/Pause Video -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int nextIndex = (self.contentOffset.y/self.frame.size.height);
    UIView * currentView = self.pageAves[nextIndex];
    if(self.animatingView != currentView){
        [self pauseVideosInAVE:self.animatingView];
        [self displayMediaOnAVE:currentView];
        self.animatingView = currentView;
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
    self.animatingView = Nil;
    self.pageAves = Nil;
}

//make sure to stop all videos
-(void) stopAllVideos {
    if (!self.pageAves) return;
    for (UIView* ave in self.pageAves) {
        [self stopVideosInAVE:ave];
    }
}
@end
