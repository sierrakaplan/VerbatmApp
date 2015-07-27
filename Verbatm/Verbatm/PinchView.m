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
#import "UIEffects.h"
#import "ContentDevVC.h"
#import "CollectionPinchView.h"
#import "TextPinchView.h"


@interface PinchView() <ContentDevElementDelegate>

@property (nonatomic) float radius;
@property (nonatomic) CGPoint center;

@end

@implementation PinchView

@dynamic center;

//Instantiates an instance of the custom view
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center {

    if((self = [super init])) {
        //set up the properties
		self.center = center;
		self.radius = radius;
		[self formatBackground];
		self.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];
        CGRect frame = CGRectMake(center.x - radius, center.y - radius, radius*2, radius*2);
        [self specifyFrame:frame];
        [self addBorderToPinchView];

		self.containsText = NO;
		self.containsImage = NO;
		self.containsVideo = NO;
    }
    return self;
}

#pragma mark Lazy instantiation

-(UIView*)background {
	if(!_background) _background = [[UIView alloc] init];
	return _background;
}

-(void) formatBackground {
	self.background.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];
	self.background.layer.masksToBounds = YES;
	[self addSubview: self.background];
}


//adds a thin circular border to the view
-(void)addBorderToPinchView
{
    self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
    self.layer.borderWidth = PINCHVIEW_BORDER_WIDTH;
}

/* It modifies the object to have a circular shape by setting the
 *corner radius
 */
-(void)specifyFrame:(CGRect)frame {
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    self.center = center;
    self.frame = frame;
	self.background.frame = self.bounds;
	self.background.layer.cornerRadius = frame.size.width/2;
    self.layer.cornerRadius = frame.size.width/2;
	// This makes sure that moving the background canvas moves all the associated subviews too.
    self.autoresizesSubviews = YES;
	self.background.autoresizesSubviews = YES;
}

//allows the user to change the width and height of the frame keeping the same center
-(void) changeWidthTo: (double) width {
    if(width < MIN_PINCHVIEW_SIZE) return;

    CGPoint center = self.center;
    CGRect newFrame = CGRectMake(center.x- width/2, center.y - width/2, width, width);
	CGRect new_bounds_frame =CGRectMake(0, 0, width, width);

	self.background.frame = new_bounds_frame;
    self.frame = newFrame;
}

-(void)removeBorder {
    self.layer.borderWidth = 0;
}

-(NSInteger) numTypesOfMedia {
	return (self.containsText ? 1 : 0)
	+ (self.containsImage ? 1 : 0)
	+ (self.containsVideo ? 1 : 0);
}

+(PinchView*) pinchTogether:(NSArray*) pinchViews {
	if (!pinchViews || ([pinchViews count] < 1)) {
		return Nil;
	}
	PinchView* firstPinchView = [pinchViews firstObject];
	if ([pinchViews count] < 2) {
		return	firstPinchView;
	}

	//check if they are only text
	NSString* pinchedText = @"";
	BOOL allTextPinchViews = YES;
	for (PinchView* pinchView in pinchViews) {
		if ([pinchView isKindOfClass:[TextPinchView class]]) {
			pinchedText = [pinchedText stringByAppendingString:[pinchView getText]];
		} else {
			allTextPinchViews = NO;
		}
	}

	if (allTextPinchViews) {
		return [[TextPinchView alloc] initWithRadius:firstPinchView.radius withCenter:firstPinchView.center andText:pinchedText];
	}

	return [[CollectionPinchView alloc] initWithRadius:firstPinchView.radius withCenter:firstPinchView.center andPinchViews:pinchViews];
}

#pragma mark - Mark as selected or deleting -

-(void)markAsDeleting: (BOOL) deleting {
	if (deleting) {
		self.layer.borderColor = [UIColor DELETING_ITEM_COLOR].CGColor;
	} else {
		[self addBorderToPinchView];
	}
}

-(void)markAsSelected: (BOOL) selected {
	if (selected) {
		self.layer.borderColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
	} else {
		[self addBorderToPinchView];
	}
}


#pragma mark - Should be overriden by subclasses -

-(NSString*) getText {
	return Nil;
}

-(NSArray*) getPhotos {
	return Nil;
}

-(NSArray*) getVideos {
	return Nil;
}

-(void)offScreen {}

-(void)onScreen {}

-(void)renderMedia {}

@end


