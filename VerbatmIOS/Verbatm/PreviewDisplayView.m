//
//  PreviewDisplay.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/2/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


#import "PreviewDisplayView.h"

#import "AveTypeAnalyzer.h"
#import "CoverPhotoAVE.h"
#import "CustomNavigationBar.h"
#import "Durations.h"
#import "Icons.h"
#import "POVView.h"
#import "PhotoAVE.h"
#import "SizesAndPositions.h"
#import "Strings.h"
#import "Styles.h"
#import "UIView+Glow.h"
#import "UIView+Effects.h"

@interface PreviewDisplayView() <UIGestureRecognizerDelegate, UIScrollViewDelegate, CustomNavigationBarDelegate>

@property (nonatomic) CGRect viewingFrame;
@property (nonatomic) CGRect restingFrame;

#pragma mark - View that lays out POV -
@property (strong, nonatomic) POVView* povView;

#pragma mark - Content -

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) UIImage* coverPhoto;
@property (strong, nonatomic) NSArray* pinchViews;

#pragma mark - Publish Button -
@property (strong, nonatomic) UIButton* publishButton;
@property (nonatomic) NSAttributedString *publishButtonTitle;

#pragma mark - Back Button -
@property (strong, nonatomic) UIButton* backButton;

//saves the prev point for the exit (pan) gesture
@property (nonatomic) CGPoint previousGesturePoint;

//the amount of space that must be pulled to exit
#define EXIT_EPSILON 60

#define BUTTON_HEIGHT 15.f

@end


@implementation PreviewDisplayView

-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.viewingFrame = frame;
		self.restingFrame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y,
									   self.frame.size.width, self.frame.size.height);
		self.frame = self.restingFrame;
		[self setBackgroundColor:[UIColor AVE_BACKGROUND_COLOR]];
		[self addShadowToView];
	}
	return self;
}

#pragma mark - Load & display preview from pinch views -

-(void) displayPreviewPOVWithTitle: (NSString*) title andCoverPhoto: (UIImage*) coverPhoto andPinchViews: (NSArray*) pinchViews withStartIndex: (NSInteger) index {

	self.title = title;
	self.coverPhoto = coverPhoto;
	self.pinchViews = pinchViews;

    
	//if we have nothing in our article then return to the list view-
	//we shouldn't need this because all downloaded articles should have legit pages
	if(![pinchViews count]) {
		[self revealPreview:NO];
		return;
	}

	AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc]init];
	NSMutableArray* aves = [analyzer getAVESFromPinchViews: pinchViews withFrame: self.viewingFrame];
	CoverPhotoAVE* coverAVE = [[CoverPhotoAVE alloc] initWithFrame:self.viewingFrame andImage: coverPhoto andTitle:title];
	[aves insertObject:coverAVE atIndex:0];
	self.povView = [[POVView alloc] initWithFrame: CGRectMake(0.f, 0.f,
															  self.frame.size.width, self.frame.size.height)];
	[self.povView renderAVES: aves];
    [self.povView addDownArrowButton];
	[self addSubview: self.povView];
	[self addNavigationBar];
	[self revealPreview:YES];
}

#pragma mark - Buttons -

-(void) addNavigationBar {
	CustomNavigationBar* navigationBar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, CUSTOM_NAV_BAR_HEIGHT)
																 andBackgroundColor:[UIColor whiteColor]];
	[navigationBar createLeftButtonWithTitle:@"BACK" orImage:nil];
	[navigationBar createRightButtonWithTitle:@"PUBLISH" orImage:nil];
	navigationBar.delegate = self;
	[self addSubview:navigationBar];
}

-(UIButton*) getButtonWithIcon: (UIImage*) icon {
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button.imageView setContentMode: UIViewContentModeScaleAspectFit];
	[button setImage:icon forState:UIControlStateNormal];
	[self addSubview: button];
	return button;
}

#pragma mark - Show the preview or hide it - 

// if show, return scrollView to its previous position
// else remove scrollview
-(void) revealPreview: (BOOL) show {
	if(show)  {
		[UIView animateWithDuration:PUBLISH_ANIMATION_DURATION animations:^{
			self.frame = self.viewingFrame;
		} completion:^(BOOL finished) {
			[self.povView displayMediaOnCurrentAVE];
		}];
	}else {
		[UIView animateWithDuration:PUBLISH_ANIMATION_DURATION animations:^{
			self.frame = self.restingFrame;
		}completion:^(BOOL finished) {
			if(finished) {
				[self.povView clearArticle];
				[self.povView removeFromSuperview];
				self.povView = nil;
				[self.publishButton removeFromSuperview];
			}
		}];
	}
}

#pragma mark - Navigation Bar Delegate methods -

#pragma mark Publish Button
-(void) rightButtonPressed {
	[self revealPreview:NO];
	[self.delegate publishWithTitle:self.title andCoverPhoto:self.coverPhoto andPinchViews:self.pinchViews];
}

#pragma mark Back Button
-(void) leftButtonPressed {
	[self revealPreview:NO];
}

#pragma mark - Exit Display -

//called from left edge pan
- (void) exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender {

	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			if (sender.numberOfTouches < 1) return;
			CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
			self.previousGesturePoint  = touchLocation;
			break;
		}
		case UIGestureRecognizerStateChanged: {
			if (sender.numberOfTouches < 1) return;
			CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
			CGPoint currentPoint = touchLocation;
			int diff = currentPoint.x - self.previousGesturePoint.x;
			self.previousGesturePoint = currentPoint;
			self.frame = CGRectMake(self.frame.origin.x + diff, self.frame.origin.y,  self.frame.size.width,  self.frame.size.height);
			break;
		}
		case UIGestureRecognizerStateEnded: {
			if(self.frame.origin.x > EXIT_EPSILON) {
				//exit article
				[self revealPreview:NO];
			}else{
				//return view to original position
				[self revealPreview:YES];
			}
			break;
		}
		default:
			break;
	}
}

@end
