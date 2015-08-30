//
//  verbatmArticleDisplayCV.m
//  Verbatm
//
//  Created by Iain Usiri on 6/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplaySV.h"
#import "AVETypeAnalyzer.h"
#import "BaseArticleViewingExperience.h"
#import "Durations.h"
#import "Icons.h"

#import "Notifications.h"

#import "SizesAndPositions.h"
#import "singleArticlePresenter.h"
#import "Strings.h"
#import "Styles.h"
#import "UIView+Glow.h"
#import "UIEffects.h"

@interface ArticleDisplaySV ()
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation ArticleDisplaySV

#pragma mark - View loading


#pragma mark - Rendering article

//called when we want to present an article. article should be set with our content
-(void)showArticle:(NSNotification *) notification {

//	Article* article = [[notification userInfo] objectForKey:ARTICLE_KEY_FOR_NOTIFICATION];
//	if(article) {
//		[self getPinchViewsFromArticle: article];
//	} else {
//		NSMutableArray* pinchViews = [[notification userInfo] objectForKey:PINCHVIEWS_KEY_FOR_NOTIFICATION];
//		[self showArticleFromPinchViews:pinchViews isPreview:YES];
//	}
}







#pragma mark Activity Indicator

-(void)startActivityIndicator {
	//add animation indicator here
	//Create and add the Activity Indicator to splashView
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.activityIndicator.alpha = 1.0;
	self.activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	self.activityIndicator.hidesWhenStopped = YES;
	[self addSubview:self.activityIndicator];
    [self bringSubviewToFront:self.activityIndicator];
	[self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
	[self.activityIndicator stopAnimating];
}

#pragma mark - Set Up Views -


//-(void) addPublishButton {
//	self.publishButtonFrame = CGRectMake(self.frame.size.width - PUBLISH_BUTTON_XOFFSET - PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_YOFFSET, PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_SIZE);
//	self.publishButtonRestingFrame = CGRectMake(self.frame.size.width, PUBLISH_BUTTON_YOFFSET, PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_SIZE);
//
//	self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	[self.publishButton setFrame:self.publishButtonRestingFrame];
//	[self.publishButton setBackgroundImage:[UIImage imageNamed:PUBLISH_BUTTON_IMAGE] forState:UIControlStateNormal];
//
//	UIColor *labelColor = [UIColor PUBLISH_BUTTON_LABEL_COLOR];
//	UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:PUBLISH_BUTTON_LABEL_FONT_SIZE];
//	NSShadow *shadow = [[NSShadow alloc] init];
//	[shadow setShadowBlurRadius:BUTTON_LABEL_SHADOW_BLUR_RADIUS];
//	[shadow setShadowColor:labelColor];
//	[shadow setShadowOffset:CGSizeMake(0, BUTTON_LABEL_SHADOW_YOFFSET)];
//	self.publishButtonTitle = [[NSAttributedString alloc] initWithString:PUBLISH_BUTTON_LABEL attributes:@{NSForegroundColorAttributeName: labelColor, NSFontAttributeName : labelFont, NSShadowAttributeName : shadow}];
//	[self.publishButton setAttributedTitle:self.publishButtonTitle forState:UIControlStateNormal];
//
//	[self.publishButton addTarget:self action:@selector(publishArticleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//	[self addSubview:self.publishButton];
//}


// if show, return scrollView to its previous position
// else remove scrollview
//-(void)showScrollView: (BOOL) show {
//	if(show)  {
//		[UIView animateWithDuration:PUBLISH_ANIMATION_DURATION animations:^{
//			self.articleCurrentlyViewing= YES;
//			self.scrollView.frame = self.view.bounds;
//			self.publishButton.frame = self.publishButtonFrame;
//		} completion:^(BOOL finished) {
//			if(self.publishButton)[self.publishButton startGlowing];
//            self.animatingView = self.pageAVEs[0];
//		}];
//	}else {
//		[self.publishButton stopGlowing];
//		[UIView animateWithDuration:PUBLISH_ANIMATION_DURATION animations:^{
//			self.scrollView.frame = self.scrollViewRestingFrame;
//			self.publishButton.frame = self.publishButtonRestingFrame;
//		}completion:^(BOOL finished) {
//			if(finished) {
//				self.articleCurrentlyViewing = NO;
//                //[self clearArticle];
//				//TODO if loaded from parse needs to tell feed this article isn't selected anymore
//			}
//		}];
//	}
//}

#pragma mark - Exit Display -

////called from left edge pan in master navigation vc
//- (void)exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender {
//
//	switch (sender.state) {
//		case UIGestureRecognizerStateBegan: {
//			//we want only one finger doing anything when exiting
//			if([sender numberOfTouches] != 1) {
//				return;
//			}
//			CGPoint touchLocation = [sender locationOfTouch:0 inView:self.view];
//			self.previousGesturePoint  = touchLocation;
//			[self.publishButton stopGlowing];
//			break;
//		}
//		case UIGestureRecognizerStateChanged: {
//			CGPoint touchLocation = [sender locationOfTouch:0 inView:self.view];
//			CGPoint currentPoint = touchLocation;
//			int diff = currentPoint.x - self.previousGesturePoint.x;
//			self.previousGesturePoint = currentPoint;
//			//self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x +diff, self.scrollView.frame.origin.y,  self.scrollView.frame.size.width,  self.scrollView.frame.size.height);
//			self.publishButton.frame = CGRectMake(self.publishButton.frame.origin.x +diff, self.publishButton.frame.origin.y,  self.publishButton.frame.size.width,  self.publishButton.frame.size.height);
//			break;
//		}
//		case UIGestureRecognizerStateEnded: {
//			if(self.scrollView.frame.origin.x > EXIT_EPSILON) {
//				//exit article
//				[self showScrollView:NO];
//			}else{
//				//return view to original position
//				[self showScrollView:YES];
//			}
//			break;
//		}
//		default:
//			break;
//	}
//
//}

#pragma mark - Publish button pressed -

-(void) publishArticleButtonPressed: (UIButton*)sender {
	//[self showScrollView:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUBLISH_ARTICLE
														object:nil
													  userInfo:nil];
}




@end
