//
//  PhotoAVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
#import "BaseArticleViewingExperience.h"
#import "Durations.h"
#import "Icons.h"
#import "MathOperations.h"
#import "PointObject.h"
#import "PhotoAVE.h"
#import "TextAndImageView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Icons.h"
#import "Durations.h"
#import "PointObject.h"
#import "MathOperations.h"
#import "UIImage+ImageEffectsAndTransforms.h"
#import "BaseArticleViewingExperience.h"


@interface PhotoAVE() <UIGestureRecognizerDelegate>

@property (nonatomic) CGPoint originPoint;
//contains PointObjects showing dots on circle
@property (strong, nonatomic) NSMutableArray* pointsOnCircle;
@property (strong, nonatomic) NSMutableArray* dotViewsOnCircle;
//contains the UIImageViews
@property (strong, nonatomic) NSMutableArray* imageContainerViews;
@property (strong, nonatomic) UIImageView* circleView;

@property (nonatomic) NSInteger currentPhotoIndex;
@property (nonatomic) NSInteger draggingFromPointIndex;
@property (nonatomic) float lastDistanceFromStartingPoint;
@property (strong, nonatomic) NSTimer * showCircleTimer;


@property (nonatomic, strong) UIView * panGestureSensingView;

@property (strong, nonatomic) UIPanGestureRecognizer * circlePanGesture;

@property (nonatomic, strong) UIButton * textViewButton;


#define TEXT_CREATION_ICON @"textCreateIcon"
#define TEXT_VIEW_HEIGHT 70.f
@end

@implementation PhotoAVE

//TODO: limit on how many photos can be pinched together?
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSArray *) photos {
	self = [super initWithFrame:frame];
	if (self) {
		if ([photos count]) {
			[self addPhotos:photos];
		}
		if ([photos count] > 1) {
			[self createCircleViewAndPoints];
			self.draggingFromPointIndex = -1;
			self.currentPhotoIndex = 0;
			[self highlightDot];
		}
		[self addTapGestureToView:self];
	}
	return self;
}

#pragma mark - Sub Views -

-(void) addPhotos:(NSArray*)photosTextArray {
    
	for (NSArray* photoText in photosTextArray) {
		UIImage* image = photoText[0];
		NSString* text = photoText[1];
		NSNumber* textYPosition = photoText[2];
        TextAndImageView* imageContainerView = [[TextAndImageView alloc] initWithFrame:self.bounds
																			  andImage: image
																			   andText: text andTextYPosition: textYPosition.floatValue];
        [self.imageContainerViews addObject:imageContainerView];
	}

	//add extra copy of photo 1 at bottom for last arc of circle transition
	NSArray* firstPhotoText = photosTextArray[0];
	UIImage* firstImage = firstPhotoText[0];
	NSString* firstText = firstPhotoText[1];
	NSNumber* textYPosition = firstPhotoText[2];
	TextAndImageView* firstImageContainerView = [[TextAndImageView alloc] initWithFrame:self.bounds
																		  andImage: firstImage
																		   andText: firstText andTextYPosition: textYPosition.floatValue];
	[self addSubview: firstImageContainerView];
	//adding subviews in reverse order so that imageview at index 0 on top
	for (int i = (int)[self.imageContainerViews count]-1; i >= 0; i--) {
		[self addSubview:[self.imageContainerViews objectAtIndex:i]];
	}
	//add textview button if the first image has text
	if(firstText && firstText.length) {
		[self createTextViewButton];
	}
}

-(void) createCircleViewAndPoints {

	NSUInteger numCircles = [self.imageContainerViews count];
	for (int i = 0; i < numCircles; i++) {
		PointObject *point = [MathOperations getPointFromCircleRadius: CIRCLE_RADIUS andCurrentPointIndex:i withTotalPoints:numCircles];
		//set relative to the center of the circle
		point.x = point.x + self.frame.size.width/2.f;
		point.y = point.y + PAN_CIRCLE_CENTER_Y;
		[self.pointsOnCircle addObject:point];
		[self createDotViewFromPoint:point];
	}
	[self createMainCircleView];
}

-(void) createMainCircleView {
	self.originPoint = CGPointMake(self.frame.size.width/2.f, PAN_CIRCLE_CENTER_Y);
	CGRect frame = CGRectMake(self.originPoint.x-CIRCLE_RADIUS-CIRCLE_OVER_IMAGES_BORDER_WIDTH/2.f,
							  self.originPoint.y-CIRCLE_RADIUS,
							  CIRCLE_RADIUS*2 + CIRCLE_OVER_IMAGES_BORDER_WIDTH, CIRCLE_RADIUS*2);

	self.circleView = [[UIImageView alloc] initWithFrame:frame];
 	self.circleView.backgroundColor = [UIColor clearColor];
	self.circleView.layer.cornerRadius = frame.size.width/2.f;
 	self.circleView.layer.borderWidth = CIRCLE_OVER_IMAGES_BORDER_WIDTH;
 	self.circleView.layer.borderColor = [UIColor CIRCLE_OVER_IMAGES_COLOR].CGColor;
	self.circleView.alpha = 0.f;
    
    self.panGestureSensingView.frame = CGRectMake(self.circleView.frame.origin.x -SLIDE_THRESHOLD ,
                                                  self.circleView.frame.origin.y - SLIDE_THRESHOLD,
                                                  self.circleView.frame.size.width + SLIDE_THRESHOLD,
                                                  self.circleView.frame.size.height + SLIDE_THRESHOLD);
    [self addPanGestureToView:self.panGestureSensingView];
    [self addSubview:self.circleView];
    [self addSubview:self.panGestureSensingView];
}

-(void) createDotViewFromPoint:(PointObject*)point {
	CGRect frame = CGRectMake(point.x-POINTS_ON_CIRCLE_RADIUS,
							  point.y-POINTS_ON_CIRCLE_RADIUS,
							  POINTS_ON_CIRCLE_RADIUS*2, POINTS_ON_CIRCLE_RADIUS*2);
	UIView* dot = [[UIView alloc] initWithFrame:frame];
	dot.backgroundColor = [UIColor CIRCLE_OVER_IMAGES_COLOR];
	dot.layer.cornerRadius = frame.size.width/2.f;
	dot.layer.borderColor = [UIColor CIRCLE_OVER_IMAGES_COLOR].CGColor;
	dot.alpha = 0.f;
	[self.dotViewsOnCircle addObject:dot];
	[self addSubview:dot];
}

-(void)addPanGestureToView:(UIView *) view {
	self.circlePanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(trackMovementOnCircle:)];
	self.circlePanGesture.minimumNumberOfTouches = 1;
	self.circlePanGesture.maximumNumberOfTouches = 1;
	self.circlePanGesture.delegate = self;
	[view addGestureRecognizer:self.circlePanGesture];
}

#pragma mark - Text View -

-(void)createTextViewButton {
    [self.textCreationButton setImage:[UIImage imageNamed:TEXT_CREATION_ICON] forState:UIControlStateNormal];
    [self.textCreationButton addTarget:self action:@selector(textViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.textCreationButton];
    [self bringSubviewToFront:self.textCreationButton];
}

-(void)textViewButtonClicked:(UIButton*) sender {
    TextAndImageView * currentView = self.imageContainerViews[self.currentPhotoIndex];
	[currentView showText: !currentView.textShowing];
}

#pragma mark - Tap Gesture -

-(void)addTapGestureToView:(UIView*)view {
	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(mainViewTapped:)];
	[view addGestureRecognizer:tapGesture];
}

-(void) mainViewTapped:(UITapGestureRecognizer *) sender {
	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
	if ([self circleTapped:touchLocation]) {
        if(!self.circleView.alpha){
            [self displayCircle:YES];
            self.showCircleTimer = [NSTimer scheduledTimerWithTimeInterval:CIRCLE_TAPPED_REMAIN_DURATION target:self selector:@selector(removeCircle) userInfo:nil repeats:YES];
        }else {
            [self removeCircle];
        }
        [self checkTextButtonPresentation];
	} else {
        [self displayCircle:NO];
	}
}

//check if tap is within radius of circle
-(BOOL) circleTapped:(CGPoint) touchLocation {
	if ((touchLocation.x - self.originPoint.x) < (CIRCLE_RADIUS + SLIDE_THRESHOLD)
		&&	(touchLocation.y - self.originPoint.y) < (CIRCLE_RADIUS + SLIDE_THRESHOLD)) {
		[self goToPhoto:touchLocation];
		return YES;
	}
	return NO;
}


-(BOOL) goToPhoto:(CGPoint) touchLocation {
	NSInteger indexOfPoint = [self getPointIndexFromLocation:touchLocation];
	if (indexOfPoint >= 0) {
		[self setImageViewsToLocation:indexOfPoint];
		return YES;
	}
	return NO;
}

#pragma mark - Pan Gesture -

-(void) trackMovementOnCircle:(UIPanGestureRecognizer*) sender {
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			[self handleCircleGestureBegan:sender];
			break;
		case UIGestureRecognizerStateChanged:
			[self handleCircleGestureChanged:sender];
			break;
		case UIGestureRecognizerStateEnded:
			[self handleCircleGestureEnded:sender];
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			//TODO: clean up all state data created in touchesBegan
			break;
		default:
			return;
	}
}

-(void) handleCircleGestureBegan:(UIPanGestureRecognizer*) sender {
	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
	self.draggingFromPointIndex = [self getPointIndexFromLocation:touchLocation];
	if (self.draggingFromPointIndex >= 0) {
		//[self.delegate startedDraggingAroundCircle];
		[self displayCircle:YES];
		[self setImageViewsToLocation:self.draggingFromPointIndex];
		self.lastDistanceFromStartingPoint = 0.f;
	}
    
    [self.textViewButton removeFromSuperview];
}

-(void) handleCircleGestureChanged:(UIPanGestureRecognizer*) sender {
	if (self.draggingFromPointIndex < 0) {
		return;
	}
	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];

	if(![MathOperations point:touchLocation onCircleWithRadius:CIRCLE_RADIUS andOrigin:self.originPoint withThreshold:SLIDE_THRESHOLD]) {
		return;
	}
	PointObject * point = self.pointsOnCircle [self.draggingFromPointIndex];
	float totalDistanceToTravel = (2.f * M_PI * CIRCLE_RADIUS)/[self.pointsOnCircle count];
	float distanceFromStartingTouch = [MathOperations distanceClockwiseBetweenTwoPoints:[point getCGPoint] and:touchLocation onCircleWithRadius:CIRCLE_RADIUS andOrigin:self.originPoint];

	[self fadeWithDistance:distanceFromStartingTouch andTotalDistance:totalDistanceToTravel];
	self.lastDistanceFromStartingPoint = distanceFromStartingTouch;
}

-(void) fadeWithDistance:(float)distanceFromStartingTouch andTotalDistance:(float)totalDistanceToTravel {
//	NSLog(@"Distance from starting touch: %f", distanceFromStartingTouch);
//	NSLog(@"Last distance from starting touch: %f", self.lastDistanceFromStartingPoint);
	//switch current point and image
	if (distanceFromStartingTouch > totalDistanceToTravel) {
		self.draggingFromPointIndex = self.draggingFromPointIndex + 1;
		self.currentPhotoIndex = self.currentPhotoIndex + 1;
		self.lastDistanceFromStartingPoint = 0;
		// if we're at the last photo reload photos behind it
		if (self.currentPhotoIndex >= [self.imageContainerViews count]) {
			self.currentPhotoIndex = 0;
			self.draggingFromPointIndex = 0;
			[self reloadImages];
		}
		[self highlightDot];
		return;

	}
	// traveling backwards
//	else if (self.lastDistanceFromStartingPoint > distanceFromStartingTouch
//			   && distanceFromStartingTouch < POINTS_ON_CIRCLE_RADIUS*2
//			   && self.draggingFromPointIndex > 0) {
//		self.draggingFromPointIndex = self.draggingFromPointIndex -1;
//		self.currentPhotoIndex = self.currentPhotoIndex -1;
//		self.lastDistanceFromStartingPoint = 0;
//	[self highlightDot];
//		return;
//	}
	float fractionOfDistance = distanceFromStartingTouch / totalDistanceToTravel;

	UIView* currentImageView = self.imageContainerViews[self.currentPhotoIndex];
	float alpha = 1.f-fractionOfDistance;
//	NSLog(@"Alpha:%f", alpha);
	[currentImageView setAlpha:alpha];
    [self checkTextButtonPresentation];
}

-(void) handleCircleGestureEnded:(UIPanGestureRecognizer*) sender {
	self.draggingFromPointIndex = -1;
	[self displayCircle:NO];
	[self.delegate stoppedDraggingAroundCircle];
    [self checkTextButtonPresentation];
}

//checks if a text button should be presented depending on the current image presented
-(void)checkTextButtonPresentation{
    TextAndImageView * view = self.imageContainerViews[self.currentPhotoIndex];
    if(view.textView.text && view.textView.text.length){
        [self createTextViewButton];
    }else{
        [self.textViewButton removeFromSuperview];
    }
}


-(void) showAndRemoveCircle {
	[self displayCircle:YES];
	self.showCircleTimer = [NSTimer scheduledTimerWithTimeInterval:CIRCLE_FIRST_APPEAR_REMAIN_DURATION target:self selector:@selector(removeCircle) userInfo:nil repeats:YES];
    
    //we expect this superview to be a scrollview
    UIView * view = self.superview.superview;
    
    if([view isKindOfClass:[UIScrollView class]] && self.circlePanGesture){
        [((UIScrollView *) view).panGestureRecognizer requireGestureRecognizerToFail: self.circlePanGesture];
    }
    
}

-(void) displayCircle:(BOOL)display {
	if (self.showCircleTimer) {
		[self.showCircleTimer invalidate];
		self.showCircleTimer = nil;
	}
	if(!display) {
		 self.showCircleTimer = [NSTimer scheduledTimerWithTimeInterval:CIRCLE_REMAIN_DURATION target:self selector:@selector(removeCircle) userInfo:nil repeats:YES];
	} else {
		[self animateFadeCircleDisplay:YES];
	}
}

-(void) removeCircle {
	if (self.showCircleTimer) {
		[self.showCircleTimer invalidate];
		self.showCircleTimer = nil;
	}
	[self animateFadeCircleDisplay:NO];
}

-(void) animateFadeCircleDisplay:(BOOL) display {
	[UIView animateWithDuration:CIRCLE_FADE_DURATION animations:^{
		[self.circleView setAlpha: display ? CIRCLE_OVER_IMAGES_ALPHA : 0.f];
		for (UIView* dotView in self.dotViewsOnCircle) {
			[dotView setAlpha: display ? POINTS_ON_CIRCLE_ALPHA : 0.f];
		}
	} completion:^(BOOL finished) {
	}];
}

#pragma mark Helper methods for gesture

-(NSInteger) getPointIndexFromLocation:(CGPoint)touchLocation {
	for (int i = 0; i < [self.pointsOnCircle count]; i++) {
		PointObject* point = self.pointsOnCircle[i];
		if(fabs(point.x - touchLocation.x) <= TAP_THRESHOLD
		   && fabs(point.y - touchLocation.y) <= TAP_THRESHOLD) {
			return i;
		}
	}
	return -1;
}

-(void) highlightDot {
	for (UIView* dot in self.dotViewsOnCircle) {
		[dot setBackgroundColor:[UIColor CIRCLE_OVER_IMAGES_COLOR]];
	}
	UIView* highlightedDot = self.dotViewsOnCircle[self.currentPhotoIndex];
	[highlightedDot setBackgroundColor:[UIColor CIRCLE_OVER_IMAGES_HIGHLIGHT_COLOR]];
}

#pragma mark Change image views locations and visibility

//sets image at given index to front by setting the opacity of all those in front of it to 0
//and those behind it to 1
-(void) setImageViewsToLocation:(NSInteger)index {
	self.currentPhotoIndex = index;
	for (int i = 0; i < [self.imageContainerViews count]; i++) {
		UIView* imageView = self.imageContainerViews[i];
		if (i < index) {
			imageView.alpha = 0.f;
		} else {
			imageView.alpha = 1.f;
		}
	}
	[self highlightDot];
}

//sets all views to opaque again
-(void) reloadImages {
	for (UIView* imageView in self.imageContainerViews) {
		imageView.alpha = 1.f;
	}
}

#pragma mark - Gesture Recognizer Delegate methods -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

#pragma mark - Lazy Instantiation


-(UIView *) panGestureSensingView {
    if(!_panGestureSensingView) _panGestureSensingView = [[UIView alloc] init];
    return _panGestureSensingView;
}

@synthesize pointsOnCircle = _pointsOnCircle;

-(NSMutableArray *) pointsOnCircle {
	if(!_pointsOnCircle) _pointsOnCircle = [[NSMutableArray alloc] init];
	return _pointsOnCircle;
}

- (void) setPointsOnCircle:(NSMutableArray *)pointsOnCircle {
	_pointsOnCircle = pointsOnCircle;
}

@synthesize dotViewsOnCircle = _dotViewsOnCircle;

-(NSMutableArray *) dotViewsOnCircle {
	if(!_dotViewsOnCircle) _dotViewsOnCircle = [[NSMutableArray alloc] init];
	return _dotViewsOnCircle;
}

- (void) setDotViewsOnCircle:(NSMutableArray *)dotViewsOnCircle {
	_dotViewsOnCircle = dotViewsOnCircle;
}

@synthesize imageContainerViews = _imageContainerViews;

-(NSMutableArray*) imageContainerViews {
	if(!_imageContainerViews) _imageContainerViews = [[NSMutableArray alloc] init];
	return _imageContainerViews;
}

-(void) setImageContainerViews:(NSMutableArray *)imageContainerViews {
	_imageContainerViews = imageContainerViews;
}


-(UIButton *)textCreationButton{
    if(!_textViewButton){
        _textViewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
                                                                         EXIT_CV_BUTTON_WIDTH,
                                                                         self.frame.size.height - EXIT_CV_BUTTON_WIDTH -
                                                                         EXIT_CV_BUTTON_WALL_OFFSET,
                                                                         EXIT_CV_BUTTON_WIDTH,
                                                                         EXIT_CV_BUTTON_WIDTH)];
    }
    return _textViewButton;
}


@end
