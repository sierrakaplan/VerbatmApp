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

@interface PhotoAVE()

@property (nonatomic) CGPoint originPoint;
//contains PointObjects showing dots on circle
@property (strong, nonatomic) NSMutableArray* pointsOnCircle;
//contains the UIImageViews
@property (strong, nonatomic) NSMutableArray* imageViews;
@property (strong, nonatomic) UIView* circleView;

@property (nonatomic) NSInteger currentPhotoIndex;
@property (nonatomic) NSInteger draggingFromPointIndex;

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
		[self addSubview:photoView];
		[self.imageViews addObject:photoView];
	}
}

-(void) createCircleViewAndPoints {

	[self createMainCircleView];
	NSUInteger numCircles = [self.imageViews count];
	for (int i = 1; i <= numCircles; i++) {
		PointObject *point = [MathOperations getPointFromCircleRadius:CIRCLE_OVER_IMAGES_RADIUS andCurrentPointIndex:i withTotalPoints:numCircles];
		//set relative to the center of the circle
		point.x = point.x + self.frame.size.width/2.f;
		point.y = point.y + self.frame.size.height/2.f;
		[self.pointsOnCircle addObject:point];
		[self createDotViewFromPoint:point];
	}
	[self addSwipeGestureToView:self];
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
	UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(trackMovementOnCircle:)];
	[view addGestureRecognizer:panGesture];
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
	if (distanceFromStartingTouch > totalDistanceToTravel) {
		//TODO change current image
		return;
	}
	float fractionOfDistance = distanceFromStartingTouch / totalDistanceToTravel;

	UIImageView* currentImageView = [self.imageViews objectAtIndex:self.currentPhotoIndex];
	float alpha = 1.f-fractionOfDistance;
	NSLog(@"Alpha:%f", alpha);
	[currentImageView setAlpha:alpha];
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


@end
