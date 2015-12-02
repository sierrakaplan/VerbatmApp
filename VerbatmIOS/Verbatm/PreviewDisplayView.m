//
//  PreviewDisplay.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/2/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


#import "PreviewDisplayView.h"
#import "AveTypeAnalyzer.h"
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
	self.povView = [[POVView alloc] initWithFrame: self.bounds andPOVInfo:nil];
	[self.povView renderAVES: aves];
	[self addSubview: self.povView];
	[self addNavigationBar];
    [self.povView moveViewTopPageIndex:index];
    [self.povView povOnScreen];
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
        [self.delegate aboutToShowPreview];
			self.frame = self.viewingFrame;
	}else {
        [self.delegate aboutToRemovePreview];
        self.frame = self.restingFrame;
        [self.povView clearArticle];
        [self.povView removeFromSuperview];
        self.povView = nil;
        [self.publishButton removeFromSuperview];
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

- (void) exitDisplay{
    [self revealPreview:NO];
}


@end
