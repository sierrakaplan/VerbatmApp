//
//  PreviewDisplay.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/2/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PreviewDisplayView.h"
#import "UIView+Glow.h"
#import "SizesAndPositions.h"
#import "Icons.h"
#import "Styles.h"
#import "Strings.h"
#import "Durations.h"
#import "AveTypeAnalyzer.h"
#import "POVView.h"
#import "PhotoAVE.h"
#import "CoverPhotoAVE.h"
#import "UIView+Effects.h"

@interface PreviewDisplayView() <UIGestureRecognizerDelegate, UIScrollViewDelegate>

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

@end


@implementation PreviewDisplayView

-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.viewingFrame = frame;
		self.restingFrame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y,
									   self.frame.size.width, self.frame.size.height);
		self.frame = self.restingFrame;
		[self setUpBackButton];

		[self setBackgroundColor:[UIColor blackColor]];
		[self addShadowToView];
		[self setUpGestureRecognizers];
	}
	return self;
}

#pragma mark - Load & display preview from pinch views -

-(void) displayPreviewPOVWithTitle: (NSString*) title andCoverPhoto: (UIImage*) coverPhoto andPinchViews: (NSArray*) pinchViews {

	self.title = title;
	self.coverPhoto = coverPhoto;
	self.pinchViews = pinchViews;
    [self setUpPublishButton];
    
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
	self.povView = [[POVView alloc] initWithFrame:self.bounds];
	[self.povView renderAVES: aves];
    [self.povView addDownArrowButton];
	[self addSubview: self.povView];
	[self addSubview: self.publishButton];
	[self bringSubviewToFront: self.publishButton];
	[self addSubview: self.backButton];
	[self bringSubviewToFront: self.backButton];
	[self revealPreview:YES];
}

#pragma mark - Set Up Views -

-(void) setUpPublishButton {
	CGRect publishButtonFrame = CGRectMake(self.viewingFrame.size.width - PUBLISH_BUTTON_OFFSET - PUBLISH_BUTTON_SIZE, 0, PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_SIZE);

	self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.publishButton setFrame: publishButtonFrame];
    
    
    UIColor *labelColor;
    
    if([self.title isEqualToString:@""] || !self.coverPhoto ){
        labelColor = [UIColor PUBLISH_BUTTON_LABEL_COLOR_INACTIVE];
        [self.publishButton setEnabled:NO];
    }else{
        labelColor = [UIColor PUBLISH_BUTTON_LABEL_COLOR_ACTIVE];
        [self.publishButton setEnabled:YES];
    }
    
	UIFont* labelFont = [UIFont fontWithName:PREVIEW_BUTTON_FONT size:PREVIEW_BUTTON_FONT_SIZE];
	self.publishButtonTitle = [[NSAttributedString alloc] initWithString:PUBLISH_BUTTON_LABEL attributes:@{NSForegroundColorAttributeName: labelColor, NSFontAttributeName : labelFont}];
	[self.publishButton setAttributedTitle:self.publishButtonTitle forState:UIControlStateNormal];
	[self.publishButton addTarget:self action:@selector(publishArticleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) setUpBackButton {
	CGRect backButtonFrame = CGRectMake(BACK_BUTTON_OFFSET,
										BACK_BUTTON_OFFSET, NAV_ICON_SIZE, NAV_ICON_SIZE);
	self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.backButton setFrame: backButtonFrame];
	[self.backButton setImage:[UIImage imageNamed:BACK_ARROW_LEFT] forState:UIControlStateNormal];
	self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Gesture recognizers

//Sets up the gesture recognizer for dragging from the edges.
-(void) setUpGestureRecognizers {
	UIScreenEdgePanGestureRecognizer* leftEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(exitDisplay:)];
	leftEdgePanGesture.minimumNumberOfTouches = 1;
	leftEdgePanGesture.maximumNumberOfTouches = 1;
	leftEdgePanGesture.edges = UIRectEdgeLeft;
	leftEdgePanGesture.delegate = self;
	[self addGestureRecognizer: leftEdgePanGesture];
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

#pragma mark - Publish button pressed -

-(void) publishArticleButtonPressed: (UIButton*)sender {
	[self revealPreview:NO];
	[self.delegate publishWithTitle:self.title andCoverPhoto:self.coverPhoto andPinchViews:self.pinchViews];
}

#pragma mark - Exit Display -

-(void) backButtonPressed:(UIButton*) sender {
	[self revealPreview:NO];
}

//called from left edge pan
- (void) exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender {

	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
			self.previousGesturePoint  = touchLocation;
			break;
		}
		case UIGestureRecognizerStateChanged: {
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
