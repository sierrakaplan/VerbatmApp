//
//  verbatmCustomPinchView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 11/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "ContentDevVC.h"
#import "CollectionPinchView.h"


@interface PinchView()

@property (nonatomic, readwrite) float radius;
@property (nonatomic) float unselectedRadius;
@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic) float initialRadius;
@property (nonatomic) CGPoint initialCenter;

#pragma mark Encoding Keys

#define CONTAINS_TEXT_KEY @"contains_text"
#define CONTAINS_IMAGE_KEY @"contains_image"
#define CONTAINS_VIDEO_KEY @"contains_video"
#define RADIUS_KEY @"radius"
#define CENTER_X_KEY @"center_x"
#define CENTER_Y_KEY @"center_y"

@end

@implementation PinchView

@dynamic center;

-(instancetype) initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		[self specifyFrame: frame];
		[self initialize];
	}
	return self;
}

//Instantiates an instance of the custom view
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center {

    if((self = [super init])) {
        //set up the properties
		self.initialCenter = self.center = center;
		self.initialRadius = self.radius = radius;
        self.frame = CGRectMake(self.center.x - self.radius,
								  self.center.y - self.radius,
								  self.radius*2, self.radius*2);
		[self initialize];
    }
    return self;
}

-(void) initialize {
	[self setBackgroundFrames];
	[self formatBackground];
	[self addBorderToPinchView];
	self.containsImage = NO;
	self.containsVideo = NO;
}

-(void) formatBackground {
	self.background.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];
	self.background.layer.masksToBounds = YES;
	[self addSubview: self.background];
}

//adds a thin circular border to the view
-(void)addBorderToPinchView {
    self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
    self.layer.borderWidth = PINCHVIEW_BORDER_WIDTH;
}


-(void) specifyRadius:(float)radius andCenter:(CGPoint)center {
	self.radius = radius;
	self.center = center;
	self.frame = CGRectMake(self.center.x - self.radius,
							self.center.y - self.radius,
							self.radius*2, self.radius*2);
	[self setBackgroundFrames];
}

-(void)specifyFrame:(CGRect)frame {
	self.radius = frame.size.width/2;
    self.center = CGPointMake(frame.origin.x + self.radius, frame.origin.y + self.radius);
	self.frame = frame;
	[self setBackgroundFrames];
}

-(void) setBackgroundFrames {
	self.background.frame = self.bounds;
	self.background.layer.cornerRadius = self.frame.size.width/2;
	self.layer.cornerRadius = self.frame.size.width/2;
	// This makes sure that moving the background canvas moves all the associated subviews too.
	self.autoresizesSubviews = YES;
	self.background.autoresizesSubviews = YES;
}

-(void)revertToInitialFrame {
	self.center = self.initialCenter;
	self.radius = self.initialRadius;
	self.frame = CGRectMake(self.center.x - self.radius,
							  self.center.y - self.radius,
							  self.radius*2, self.radius*2);
	[self setBackgroundFrames];
}

//allows the user to change the width and height of the frame keeping the same center
-(void) changeWidthTo: (double) width {
    //if(width < MIN_PINCHVIEW_SIZE) return;

    CGPoint center = self.center;
    [self specifyRadius:(width/2.f) andCenter:self.center];
}

-(void)removeBorder {
    self.layer.borderWidth = 0;
}

-(NSInteger) numTypesOfMedia {
	return (self.containsImage ? 1 : 0)
	+ (self.containsVideo ? 1 : 0);
}

+(PinchView*) pinchTogether:(NSArray*) pinchViews {
	if (!pinchViews || ([pinchViews count] < 1)) {
		return nil;
	}
	PinchView* firstPinchView = [pinchViews firstObject];
	if ([pinchViews count] < 2) {
		return	firstPinchView;
	}

	return [[CollectionPinchView alloc] initWithRadius:firstPinchView.radius withCenter:firstPinchView.center andPinchViews:pinchViews];
}

#pragma mark - Mark as selected or deleting -

-(void)markAsDeleting: (BOOL) deleting {
	if (deleting) {
		self.layer.borderColor = [UIColor DELETING_ITEM_COLOR].CGColor;
	} else {
		self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	}
}

-(void)markAsSelected: (BOOL) selected {
	if (selected) {
		self.layer.borderColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
		self.unselectedRadius = self.radius;
		[self specifyRadius:self.radius*1.05 andCenter:self.center];
		self.layer.shadowOffset = CGSizeMake(10, 0);
		self.layer.shadowRadius = 5;
		self.layer.shadowOpacity = 0.5;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
	} else {
		self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
		[self specifyRadius:self.unselectedRadius andCenter:self.center];
		self.layer.shadowOpacity = 0;
	}
	[self renderMedia];
}


#pragma mark - Should be overriden by subclasses -

-(NSInteger) getTotalPiecesOfMedia {
	return 0;
}

-(NSString*) getText {
	return nil;
}

-(NSArray*) getPhotosWithText {
	return nil;
}

-(NSArray*) getVideosWithText {
	return nil;
}

-(NSArray*) getVideosInDataFormat {
	return nil;
}

-(void)offScreen {}

-(void)onScreen {}

-(void)renderMedia {}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithBool:self.containsImage] forKey:CONTAINS_IMAGE_KEY];
	[coder encodeObject:[NSNumber numberWithBool:self.containsVideo] forKey:CONTAINS_VIDEO_KEY];
	[coder encodeObject:[NSNumber numberWithFloat:self.center.x] forKey:CENTER_X_KEY];
	[coder encodeObject:[NSNumber numberWithFloat:self.center.y] forKey:CENTER_Y_KEY];
	[coder encodeObject:[NSNumber numberWithFloat:self.radius] forKey:RADIUS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		float radius = [(NSNumber*)[decoder decodeObjectForKey:RADIUS_KEY] floatValue];
		float centerX = [(NSNumber*)[decoder decodeObjectForKey:CENTER_X_KEY] floatValue];
		float centerY = [(NSNumber*)[decoder decodeObjectForKey:CENTER_Y_KEY] floatValue];
		CGPoint center = CGPointMake(centerX, centerY);
		self = [self initWithRadius:radius withCenter:center];
		self.containsImage = [(NSNumber*)[decoder decodeObjectForKey:CONTAINS_IMAGE_KEY] boolValue];
		self.containsVideo = [(NSNumber*)[decoder decodeObjectForKey:CONTAINS_VIDEO_KEY] boolValue];
	}
	return self;
}

#pragma mark Lazy instantiation

-(UIView*)background {
	if(!_background) _background = [[UIView alloc] init];
	return _background;
}

@end


