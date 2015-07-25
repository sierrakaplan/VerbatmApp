//
//  PhotoAVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "PhotoAVE.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "PointObject.h"
#import "MathOperations.h"
#import "UIEffects.h"

@interface PhotoAVE() <UIGestureRecognizerDelegate>

@property (nonatomic) CGPoint originPoint;
//contains PointObjects showing dots on circle
@property (strong, nonatomic) NSMutableArray* pointsOnCircle;
//contains the UIImageViews
@property (strong, nonatomic) NSMutableArray* imageViews;
@property (strong, nonatomic) UIView* circleView;

@property (nonatomic) NSInteger currentPhotoIndex;
@property (nonatomic) NSInteger draggingFromPointIndex;
@property (nonatomic) CGPoint lastTouch;

@end

@implementation PhotoAVE

//TODO: limit on how many photos can be pinched together?
//TODO: allow users to arrange order of pinched photos?
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSMutableArray *) photos {

	self = [super initWithFrame:frame];
	if (self) {
		[self addPhotos:photos];
		if ([photos count] > 1) {
			[self createCircleViewAndPoints];
		}
		self.draggingFromPointIndex = -1;
		self.currentPhotoIndex = 0;
	}
	return self;
}

#pragma mark - Lazy Instantiation

@synthesize pointsOnCircle = _pointsOnCircle;

-(NSMutableArray *) pointsOnCircle {
	if(!_pointsOnCircle) _pointsOnCircle = [[NSMutableArray alloc] init];
	return _pointsOnCircle;
}

- (void) setPointsOnCircle:(NSMutableArray *)pointsOnCircle {
	_pointsOnCircle = pointsOnCircle;
}

@synthesize imageViews = _imageViews;

-(NSMutableArray*) imageViews {
	if(!_imageViews) _imageViews = [[NSMutableArray alloc] init];
	return _imageViews;
}

-(void) setImageViews:(NSMutableArray *)imageViews {
	_imageViews = imageViews;
}

#pragma mark - Sub Views -

-(void) addPhotos:(NSMutableArray*)photos {
	for (NSData* photoData in photos) {
		UIImage* photo = [[UIImage alloc] initWithData:photoData];
		UIImageView* photoView = [[UIImageView alloc] initWithImage:photo];
		photoView.frame = self.bounds;
		[self.imageViews addObject:photoView];
	}
	//adding subviews in reverse order so that imageview at index 0 on top
	for (int i = (int)[self.imageViews count]-1; i >= 0; i--) {
		[self addSubview:[self.imageViews objectAtIndex:i]];
	}
}

-(void) createCircleViewAndPoints {

	[self createMainCircleView];
	NSUInteger numCircles = [self.imageViews count];
	for (int i = 0; i < numCircles; i++) {
		PointObject *point = [MathOperations getPointFromCircleRadius:CIRCLE_OVER_IMAGES_RADIUS andCurrentPointIndex:i withTotalPoints:numCircles];
		//set relative to the center of the circle
		point.x = point.x + self.frame.size.width/2.f;
		point.y = point.y + self.frame.size.height/2.f;
		[self.pointsOnCircle addObject:point];
		[self createDotViewFromPoint:point];
	}
	[self addSwipeGestureToView:self];
	[self addTapGestureToView:self];
}


-(void) createMainCircleView {
	self.originPoint = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
	CGRect frame = CGRectMake(self.originPoint.x-CIRCLE_OVER_IMAGES_RADIUS-CIRCLE_OVER_IMAGES_BORDER_WIDTH/2.f,
							  self.originPoint.y-CIRCLE_OVER_IMAGES_RADIUS,
							  CIRCLE_OVER_IMAGES_RADIUS*2 + CIRCLE_OVER_IMAGES_BORDER_WIDTH, CIRCLE_OVER_IMAGES_RADIUS*2);

	self.circleView = [[UIView alloc] initWithFrame:frame];
 	self.circleView.backgroundColor = [UIColor clearColor];
	self.circleView.layer.cornerRadius = frame.size.width/2.f;
 	self.circleView.layer.borderWidth = CIRCLE_OVER_IMAGES_BORDER_WIDTH;
 	self.circleView.layer.borderColor = [UIColor CIRCLE_OVER_IMAGES_COLOR].CGColor;
 	[self addSubview:self.circleView];
}

-(void) createDotViewFromPoint:(PointObject*)point {
	CGRect frame = CGRectMake(point.x-POINTS_ON_CIRCLE_RADIUS,
							  point.y-POINTS_ON_CIRCLE_RADIUS,
							  POINTS_ON_CIRCLE_RADIUS*2, POINTS_ON_CIRCLE_RADIUS*2);

	UIView* dot = self.circleView = [[UIView alloc] initWithFrame:frame];
	dot.backgroundColor = [UIColor CIRCLE_OVER_IMAGES_COLOR];
	self.circleView.layer.cornerRadius = frame.size.width/2.f;
	dot.layer.borderColor = [UIColor CIRCLE_OVER_IMAGES_COLOR].CGColor;
	[self addSubview:dot];
}

-(void)addSwipeGestureToView:(UIView *) view
{
	UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:view action:@selector(trackMovementOnCircle:)];
	panGesture.delegate = self;
	[view addGestureRecognizer:panGesture];
}

-(void)addTapGestureToView:(UIView*)view {
	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(goToPhoto:)];
	[view addGestureRecognizer:tapGesture];
}

#pragma mark - Tap Gesture -

-(void) goToPhoto:(UITapGestureRecognizer*) sender {
	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
	NSInteger indexOfPoint = [self getPointIndexFromLocation:touchLocation];
	if (indexOfPoint >= 0) {
		[self setImageViewsToLocation:indexOfPoint];
	}
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
	if ([sender numberOfTouches] != 1) {
		return;
	}

	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];
	self.draggingFromPointIndex = [self getPointIndexFromLocation:touchLocation];
	if (self.draggingFromPointIndex > 0) {
		[self setImageViewsToLocation:self.draggingFromPointIndex];
	}
	self.lastTouch = touchLocation;
}

-(void) handleCircleGestureChanged:(UIPanGestureRecognizer*) sender {
	if ([sender numberOfTouches] != 1 || self.draggingFromPointIndex < 0) {
		return;
	}
	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];

	if(![MathOperations point:touchLocation onCircleWithRadius:CIRCLE_OVER_IMAGES_RADIUS andOrigin:self.originPoint withThreshold:TOUCH_THRESHOLD]) {
		return;
	}
	PointObject * point = [self.pointsOnCircle objectAtIndex:self.draggingFromPointIndex];
	float totalDistanceToTravel = (2.f * M_PI * CIRCLE_OVER_IMAGES_RADIUS)/[self.pointsOnCircle count];
	float distanceFromStartingTouch = [MathOperations distanceClockwiseBetweenTwoPoints:[point getCGPoint] and:touchLocation onCircleWithRadius:CIRCLE_OVER_IMAGES_RADIUS andOrigin:self.originPoint];
	float distanceFromLastTouch = [MathOperations distanceClockwiseBetweenTwoPoints:self.lastTouch and:touchLocation onCircleWithRadius:CIRCLE_OVER_IMAGES_RADIUS andOrigin:self.originPoint];

	if (distanceFromLastTouch < 0) {
		[self fadeBackwardsWithDistance:fabs(distanceFromStartingTouch) andTotalDistance:totalDistanceToTravel];
	} else {
		[self fadeForwardsWithDistance:distanceFromStartingTouch andTotalDistance:totalDistanceToTravel];
	}
	self.lastTouch = touchLocation;
}

-(void) fadeForwardsWithDistance:(float)distanceFromStartingTouch andTotalDistance:(float)totalDistanceToTravel {
	//switch current point and image
	if (distanceFromStartingTouch > totalDistanceToTravel) {
		self.draggingFromPointIndex = self.draggingFromPointIndex + 1;
		self.currentPhotoIndex = self.currentPhotoIndex + 1;
		// if we're at the last photo reload photos behind it
		if (self.currentPhotoIndex >= [self.imageViews count]) {
			self.currentPhotoIndex = 0;
			self.draggingFromPointIndex = 0;
		}
		[self checkPhotoViewLocations];
		return;
	}
	float fractionOfDistance = distanceFromStartingTouch / totalDistanceToTravel;

	UIImageView* currentImageView = [self.imageViews objectAtIndex:self.currentPhotoIndex];
	float alpha = 1.f-fractionOfDistance;
	NSLog(@"Alpha:%f", alpha);
	[currentImageView setAlpha:alpha];
}

-(void) fadeBackwardsWithDistance:(float)distanceFromStartingTouch andTotalDistance:(float)totalDistanceToTravel {
	//don't allow fading backwards past first image
	if(self.draggingFromPointIndex == 0) return;

	if (distanceFromStartingTouch > totalDistanceToTravel) {
		self.draggingFromPointIndex = self.draggingFromPointIndex -1;
		self.currentPhotoIndex = self.currentPhotoIndex -1;
		return;
	}
	float fractionOfDistance = distanceFromStartingTouch / totalDistanceToTravel;
	UIImageView* previousImageView = [self.imageViews objectAtIndex:(self.currentPhotoIndex-1)];
	[previousImageView setAlpha: fractionOfDistance];
}

-(void) handleCircleGestureEnded:(UIPanGestureRecognizer*) sender {
	self.draggingFromPointIndex = -1;
}


#pragma mark Helper methods for gesture

-(NSInteger) getPointIndexFromLocation:(CGPoint)touchLocation {

	for (int i = 0; i < [self.pointsOnCircle count]; i++) {
		PointObject* point = [self.pointsOnCircle objectAtIndex:i];
		if(fabs(point.x - touchLocation.x) <= TOUCH_THRESHOLD
		   && fabs(point.y - touchLocation.y) <= TOUCH_THRESHOLD) {
			return i;
		}
	}
	return -1;
}

#pragma mark Change image views locations and visibility

//sets image at given index to front by setting the opacity of all those in front of it to 0
-(void) setImageViewsToLocation:(NSInteger)index {
	self.currentPhotoIndex = index;
	for (int i = 0; i < [self.imageViews count]; i++) {
		UIImageView* imageView = [self.imageViews objectAtIndex:i];
		imageView.alpha = 0;
	}

	UIImageView* currentImage = [self.imageViews objectAtIndex:index];
	currentImage.alpha = 1.f;


	[self checkPhotoViewLocations];
}

//makes sure all photo views are loaded where they should be
-(void) checkPhotoViewLocations {
	if (self.currentPhotoIndex == ([self.imageViews count]-1)) {
		[self reloadImageViews];
	} else if (self.currentPhotoIndex == 0) {
		[self reloadLastImage];
	}
}

// reloads photo views so that you can keep swiping around circle forever
-(void) reloadImageViews {

	UIImageView* precedingImage = [self.imageViews objectAtIndex:([self.imageViews count]-1)];
	for (int i = 0; i < (int)[self.imageViews count]-1; i++) {
		UIImageView* imageView = [self.imageViews objectAtIndex:i];
		[imageView removeFromSuperview];
		imageView.alpha = 1.0;
		[self insertSubview:imageView belowSubview:precedingImage];
		precedingImage = imageView;
	}
}

-(void) reloadLastImage {
	UIImageView* lastImage = [self.imageViews objectAtIndex:([self.imageViews count]-1)];
	[lastImage removeFromSuperview];
	lastImage.alpha = 1.0;
	[self insertSubview:lastImage belowSubview:[self.imageViews objectAtIndex:([self.imageViews count]-2)]];
}

#pragma mark - Gesture Recognizer Delegate methods -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}


@end
