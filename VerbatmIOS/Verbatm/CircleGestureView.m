//
//  CircleGestureView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CircleGestureView.h"
#import "PointObject.h"
#import "MathOperations.h"
#import "Styles.h"
#import "SizesAndPositions.h"


@interface  CircleGestureView()

//contains PointObjects showing dots on circle
@property (strong, nonatomic) NSMutableArray* dotViewsOnCircle;
@property (strong, nonatomic) UIImageView* circleImageView;


@end


@implementation CircleGestureView


-(id) initWithFrame:(CGRect)frame andRadius:(float)radius andNumDots:(NSInteger) numDots {
	self = [super initWithFrame:frame];
	if (self) {
		self.circleRadius = radius;
		[self createCircleViewAndPoints:numDots];
		[self setBackgroundColor:[UIColor whiteColor]];
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

@synthesize dotViewsOnCircle = _dotViewsOnCircle;

-(NSMutableArray *) dotViewsOnCircle {
	if(!_dotViewsOnCircle) _dotViewsOnCircle = [[NSMutableArray alloc] init];
	return _dotViewsOnCircle;
}

- (void) setDotViewsOnCircle:(NSMutableArray *)dotViewsOnCircle {
	_dotViewsOnCircle = dotViewsOnCircle;
}


-(void) createCircleViewAndPoints:(NSInteger)numDots {
	
	for (int i = 0; i < numDots; i++) {
		PointObject *point = [MathOperations getPointFromCircleRadius:self.circleRadius andCurrentPointIndex:i withTotalPoints:numDots];
		//set relative to the center of the circle
		point.x = point.x + self.frame.size.width/2.f;
		point.y = point.y + self.frame.size.height/2.f;
		[self.pointsOnCircle addObject:point];
		[self createDotViewFromPoint:point];
	}
	[self createMainCircleView];
}


-(void) createMainCircleView {
	self.originPoint = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
	CGRect frame = CGRectMake(self.originPoint.x-self.circleRadius-CIRCLE_OVER_IMAGES_BORDER_WIDTH/2.f,
							  self.originPoint.y-self.circleRadius,
							  self.circleRadius*2 + CIRCLE_OVER_IMAGES_BORDER_WIDTH, self.circleRadius*2);

	self.circleImageView = [[UIImageView alloc] initWithFrame:frame];
	self.circleImageView.backgroundColor = [UIColor clearColor];
	self.circleImageView.layer.cornerRadius = frame.size.width/2.f;
	self.circleImageView.layer.borderWidth = CIRCLE_OVER_IMAGES_BORDER_WIDTH;
	self.circleImageView.layer.borderColor = [UIColor CIRCLE_OVER_IMAGES_COLOR].CGColor;
	self.circleImageView.alpha = 0.f;
	//	[self.circleView setImage:[UIImage imageNamed:CIRCLE_OVER_IMAGES_ICON]];
	[self addSubview:self.circleImageView];
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

-(void) highlightDotAtIndex:(NSInteger) index {
	for (UIView* dot in self.dotViewsOnCircle) {
		[dot setBackgroundColor:[UIColor CIRCLE_OVER_IMAGES_COLOR]];
	}
	UIView* highlightedDot = self.dotViewsOnCircle[index];
	[highlightedDot setBackgroundColor:[UIColor CIRCLE_OVER_IMAGES_HIGHLIGHT_COLOR]];
}

@end
