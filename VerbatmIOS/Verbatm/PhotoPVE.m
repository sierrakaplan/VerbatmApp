 //
//  PhotoPVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import "CustomNavigationBar.h"

#import "Durations.h"

#import "EditMediaContentView.h"

#import "Icons.h"
#import "ImagePinchView.h"

#import "MathOperations.h"

#import "PointObject.h"
#import "PostInProgress.h"
#import "PhotoPVE.h"

#import "OpenCollectionView.h"

#import "SizesAndPositions.h"
#import "Styles.h"

#import "TextOverMediaView.h"

#import "UIImage+ImageEffectsAndTransforms.h"


@interface PhotoPVE() <UIGestureRecognizerDelegate, OpenCollectionViewDelegate, EditContentViewDelegate>

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

//When a view is animating it doesn't sense gestures very well. This makes it tough for users
// to scroll up and down while their photo slideshow is playing.
//To manage this we add to clear views above the animating views to catch the gestures.
//We add two views instead of one because of the buttons on the bottom right -- don't want
// to cover them.
@property (nonatomic, strong) UIView * panGestureSensingViewVertical;
@property (nonatomic, strong) UIView * panGestureSensingViewHorizontal;

@property (strong, nonatomic) UIPanGestureRecognizer * circlePanGesture;
@property (nonatomic, strong) UIButton * textViewButton;

#pragma mark - In Preview Mode -

@property (nonatomic) PinchView *pinchView;
@property (nonatomic, strong) UIButton * rearrangeButton;
@property (nonatomic) OpenCollectionView * rearrangeView;

// Tells whether should display smaller sized images
@property (nonatomic) BOOL small;

#define TEXT_VIEW_HEIGHT 70.f

#define OPEN_COLLECTION_FRAME_HEIGHT 70.f

//this view manages the tapping gesture of the set circles
@property (nonatomic, strong) UIView * circleTapView;

@property (nonatomic) BOOL slideShowPlaying;
@end

@implementation PhotoPVE

-(instancetype) initWithFrame:(CGRect)frame andPhotoArray:(NSArray *)photos
						small:(BOOL) small {
	self = [super initWithFrame:frame];
	if (self) {
		self.small = small;
		self.inPreviewMode = NO;
        if ([photos count]) {
			[self addPhotos:photos];
		}
		[self initialFormatting];
	}
	return self;
}

-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView inPreviewMode: (BOOL) inPreviewMode {
	self = [super initWithFrame:frame];
	if (self) {
		self.small = NO;
		self.inPreviewMode = inPreviewMode;
		self.pinchView = pinchView;
		if([self.pinchView isKindOfClass:[CollectionPinchView class]]){
			[self addContentFromImagePinchViews:((CollectionPinchView *)self.pinchView).imagePinchViews];
		}else{
			[self addContentFromImagePinchViews:[NSMutableArray arrayWithObject:pinchView]];
		}
		[self initialFormatting];
	}
	return self;
}

-(void) initialFormatting {
	[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
}

-(void)prepareCirclePan{
    if(self.dotViewsOnCircle.count){
        for(UIView * view in self.dotViewsOnCircle){
            [view removeFromSuperview];
        }
        self.pointsOnCircle = nil;
        self.dotViewsOnCircle = nil;
    }

    [self createCircleViewAndPoints];
    self.draggingFromPointIndex = -1;
    self.currentPhotoIndex = 0;
    [self highlightDot];
}

#pragma mark - Preview mode -

-(void) addContentFromImagePinchViews:(NSMutableArray *)pinchViewArray{
	NSMutableArray* photosTextArray = [[NSMutableArray alloc] init];

    for (ImagePinchView * imagePinchView in pinchViewArray) {
		if (self.inPreviewMode) {
			EditMediaContentView * editMediaContentView = [self getEditContentViewFromPinchView:imagePinchView];
			[self.imageContainerViews addObject:editMediaContentView];
		} else {
			[photosTextArray addObject: [imagePinchView getPhotosWithText][0]];
		}
    }
	if (!self.inPreviewMode) {
		[self addPhotos: photosTextArray];
	} else {
		//add first photo again so it doesn't fade to black
//		EditMediaContentView *firstPhotoEditContentView = [self getEditContentViewFromPinchView:pinchViewArray[0]];
//		[self addSubview:firstPhotoEditContentView];
		[self layoutContainerViews];
		if(pinchViewArray.count > 1)
         	[self createRearrangeButton];
    }
}

-(EditMediaContentView *) getEditContentViewFromPinchView: (ImagePinchView *)pinchView {
	EditMediaContentView * editMediaContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];

	PHImageRequestOptions *options = [PHImageRequestOptions new];
	options.synchronous = YES;
	[pinchView getLargerImageWithSize: pinchView.largeSize].then(^(UIImage *image) {
		[editMediaContentView changeImageTo:image];
	});

	//Display low quality image before loading high quality version
	[editMediaContentView displayImages:[pinchView filteredImages] atIndex:pinchView.filterImageIndex];

	if(pinchView.text && pinchView.text.length) {
		[editMediaContentView setText:pinchView.text
					 andTextYPosition:[pinchView.textYPosition floatValue]
						 andTextColor:pinchView.textColor
					 andTextAlignment:[pinchView.textAlignment integerValue]
						  andTextSize:[pinchView.textSize floatValue]];
	}

	editMediaContentView.pinchView = pinchView;
	editMediaContentView.povViewMasterScrollView = self.postScrollView;
	editMediaContentView.delegate = self;
	return editMediaContentView;
}

-(void)layoutContainerViews{
	//adding subviews in reverse order so that imageview at index 0 on top
	for (int i = (int)[self.imageContainerViews count]-1; i >= 0; i--) {
		[self addSubview:[self.imageContainerViews objectAtIndex:i]];
	}
}

#pragma mark - Not preview mode -

/* photoTextArray is array containing subarrays of photo and text info
  @[@[photo, text, textYPosition, textColor, textAlignment, textSize],...] */
-(void) addPhotos:(NSArray*)photosTextArray {
    
	for (NSArray* photoText in photosTextArray) {
        [self.imageContainerViews addObject:[self getImageContainerViewFromPhotoTextArray:photoText]];
	}

	// Has to add duplicate of first photo to bottom so that you can fade from the last photo into the first
	//NSArray* firstPhotoText = photosTextArray[0];
	//[self addSubview: [self getImageContainerViewFromPhotoTextArray: firstPhotoText]];
	[self layoutContainerViews];
}

-(TextOverMediaView*) getImageContainerViewFromPhotoTextArray: (NSArray*) photoTextArray {
	NSURL *url = photoTextArray[0];
	NSString* text = photoTextArray[1];
	CGFloat textYPosition = [(NSNumber *)photoTextArray[2] floatValue];
	UIColor *textColor = photoTextArray[3];
	NSTextAlignment textAlignment = (NSTextAlignment) ([(NSNumber *)photoTextArray[4] integerValue]);
	CGFloat textSize = [(NSNumber *)photoTextArray[5] floatValue];

	if(self.isPhotoVideoSubview) {
		textYPosition = textYPosition/2.f;
	}

	TextOverMediaView* textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.bounds
																		  andImageURL: url
																	withSmallImage:self.small];
	if (text && text.length) {
		[textAndImageView setText: text
				 andTextYPosition: textYPosition
					 andTextColor: textColor
				 andTextAlignment: textAlignment
					  andTextSize: textSize];
		[textAndImageView showText:YES];
	}
	return textAndImageView;
}

#pragma mark - Fade circle views -

-(void) createCircleViewAndPoints {
	NSUInteger numCircles = [self.imageContainerViews count];
	for (int i = 0; i < numCircles; i++) {
		PointObject *point = [MathOperations getPointFromCircleRadius:CIRCLE_RADIUS andCurrentPointIndex:i withTotalPoints:numCircles];
		//set relative to the center of the circle
		point.x = point.x + self.frame.size.width/2.f;
		point.y = point.y + PAN_CIRCLE_CENTER_Y;
		[self.pointsOnCircle addObject:point];
	}
    
    if(self.circleView){
        [self.circleView removeFromSuperview];
        self.circleView = nil;
    }
    
}


#pragma mark - Text View -

-(void)textViewButtonClicked:(UIButton*) sender {
    TextOverMediaView * currentView = self.imageContainerViews[self.currentPhotoIndex];
	[currentView showText: !currentView.textShowing];
}

#pragma mark - Tap Gesture -


#pragma mark - Rearrange content (preview mode) -

-(void)createRearrangeButton {
    [self.rearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
    self.rearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.rearrangeButton addTarget:self action:@selector(rearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rearrangeButton];
    [self bringSubviewToFront:self.rearrangeButton];
}

-(void) rearrangeButtonPressed {
    if(!self.rearrangeView){
		[self offScreen];
        
        CGFloat y_pos = (self.isPhotoVideoSubview) ? 0.f : CUSTOM_NAV_BAR_HEIGHT;

        CGRect frame = CGRectMake(0.f,y_pos, self.frame.size.width, OPEN_COLLECTION_FRAME_HEIGHT);
        self.rearrangeView = [[OpenCollectionView alloc] initWithFrame:frame
													 andPinchViewArray:((CollectionPinchView*)self.pinchView).imagePinchViews];
        self.rearrangeView.delegate = self;
        [self insertSubview:self.rearrangeView belowSubview:self.rearrangeButton];
        [self.rearrangeButton setImage:[UIImage imageNamed:PLAY_SLIDESHOW_ICON] forState:UIControlStateNormal];
    } else {
        [self.rearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
        [self.rearrangeView exitView];
        [self playWithSpeed:2.f];
    }
}

//new pinchview tapped in rearange view so we need to change what's presented
-(void)pinchViewSelected:(PinchView *) pv{
    NSInteger imageIndex;
    for(NSInteger index = 0; index < self.imageContainerViews.count; index++){
        EditMediaContentView * eview = self.imageContainerViews[index];
        if(eview.pinchView == pv){
            imageIndex = index;
            break;
        }
    }
    [self setImageViewsToLocation:imageIndex];
}



-(void)playWithSpeed:(CGFloat) speed {
    CGRect h_frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.rearrangeButton.frame.origin.y);
    CGRect v_frame = CGRectMake(0.f, self.rearrangeButton.frame.origin.y,self.rearrangeButton.frame.origin.x - 10.f, self.frame.size.height - self.rearrangeButton.frame.origin.y);
    
    //create view to sense swiping
    self.panGestureSensingViewVertical = [[UIView alloc] initWithFrame:h_frame];
    self.panGestureSensingViewVertical.backgroundColor = [UIColor clearColor];
    
    self.panGestureSensingViewHorizontal = [[UIView alloc] initWithFrame:v_frame];
    self.panGestureSensingViewHorizontal.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.panGestureSensingViewVertical];
    [self bringSubviewToFront:self.panGestureSensingViewVertical];
    [self addSubview:self.panGestureSensingViewHorizontal];
    [self bringSubviewToFront:self.panGestureSensingViewHorizontal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateNextView) userInfo:nil repeats:NO];
    self.slideShowPlaying = YES;
}
-(void)stopSlideshow{
    self.slideShowPlaying = NO;
    [self.panGestureSensingViewHorizontal removeFromSuperview];
    self.panGestureSensingViewHorizontal = nil;
    [self.panGestureSensingViewVertical removeFromSuperview];
    self.panGestureSensingViewVertical = nil;
}

-(void)animateNextView{
    [UIView animateWithDuration:1.f animations:^{
        [self setImageViewsToLocation:(self.currentPhotoIndex + 1)];
    } completion:^(BOOL finished) {
        if(self.slideShowPlaying)[self animateNextView];
    }];
}


#pragma mark OpenCollectionView delegate method

-(void) collectionClosedWithFinalArray:(NSMutableArray *) pinchViews {
	if(self.rearrangeView){
		[self.rearrangeView removeFromSuperview];
		self.rearrangeView = nil;
	}
	self.imageContainerViews = nil;
	for (UIView * view in self.subviews) {
		[view removeFromSuperview];
	}
	((CollectionPinchView*)self.pinchView).imagePinchViews = pinchViews;
	[[PostInProgress sharedInstance] removePinchViewAtIndex:self.indexInPost andReplaceWithPinchView:self.pinchView];
	[self.pinchView renderMedia];
	[self addContentFromImagePinchViews: pinchViews];
   // [self createRearrangeButton];
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
	if (sender.numberOfTouches < 1) return;
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
	if (self.draggingFromPointIndex < 0 || sender.numberOfTouches < 1) {
		return;
	}
	CGPoint touchLocation = [sender locationOfTouch:0 inView:self];

	if(![MathOperations point:touchLocation onCircleWithRadius:CIRCLE_RADIUS andOrigin:self.originPoint withThreshold:SLIDE_THRESHOLD]) {
		return;
	}
    
    if(self.draggingFromPointIndex < self.pointsOnCircle.count){
    
        PointObject * point = self.pointsOnCircle [self.draggingFromPointIndex];
        float totalDistanceToTravel = (2.f * M_PI * CIRCLE_RADIUS)/[self.pointsOnCircle count];
        float distanceFromStartingTouch = [MathOperations distanceClockwiseBetweenTwoPoints:[point getCGPoint] and:touchLocation onCircleWithRadius:CIRCLE_RADIUS andOrigin:self.originPoint];

        [self fadeWithDistance:distanceFromStartingTouch andTotalDistance:totalDistanceToTravel];
        self.lastDistanceFromStartingPoint = distanceFromStartingTouch;
    }
}

-(void) fadeWithDistance:(float)distanceFromStartingTouch andTotalDistance:(float)totalDistanceToTravel {
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
	[currentImageView setAlpha:alpha];
}

-(void) handleCircleGestureEnded:(UIPanGestureRecognizer*) sender {
	self.draggingFromPointIndex = -1;
	[self displayCircle:NO];
	[self.delegate stoppedDraggingAroundCircle];
}

-(void) showAndRemoveCircle {
	[self displayCircle:YES];
	self.showCircleTimer = [NSTimer scheduledTimerWithTimeInterval:CIRCLE_FIRST_APPEAR_REMAIN_DURATION target:self selector:@selector(removeCircle) userInfo:nil repeats:YES];
    if(self.postScrollView && self.circlePanGesture){
        [self.postScrollView.panGestureRecognizer requireGestureRecognizerToFail: self.circlePanGesture];
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
    if(display){//prevents circle fade from disappearing
        [UIView animateWithDuration:CIRCLE_FADE_DURATION animations:^{
            [self.circleView setAlpha: display ? CIRCLE_OVER_IMAGES_ALPHA : 0.f];
            for (UIView* dotView in self.dotViewsOnCircle) {
                [dotView setAlpha: display ? POINTS_ON_CIRCLE_ALPHA : 0.f];
            }
        } completion:^(BOOL finished) {
        }];
    }
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
	
    if(index >= self.imageContainerViews.count){
        index = 0;
        ((UIView *) self.imageContainerViews[index]).alpha = 1.f;
    }
    self.currentPhotoIndex = index;
	for (int i = 0; i < [self.imageContainerViews count]; i++) {
		UIView* imageView = self.imageContainerViews[i];
		if (i < index) {
			imageView.alpha = 0.f;
		} else {
			imageView.alpha = 1.f;
		}
	}
}

//sets all views to opaque again
-(void) reloadImages {
	for (UIView* imageView in self.imageContainerViews) {
		imageView.alpha = 1.f;
	}
}

#pragma mark - Gesture Recognizer Delegate methods -


#pragma mark - Overriding ArticleViewingExperience methods -

-(void) onScreen {
    if(self.imageContainerViews.count > 1){
        if(!self.slideShowPlaying){
            [self playWithSpeed:2.f];
        }
    }
}

- (void)offScreen {
    [self stopSlideshow];
    for (UIView * view in self.imageContainerViews) {
        if([view isKindOfClass:[EditMediaContentView class]]){
            [((EditMediaContentView *)view) exiting];
        }
    }
	if (self.inPreviewMode) {
		[[PostInProgress sharedInstance] removePinchViewAtIndex:self.indexInPost andReplaceWithPinchView:self.pinchView];
	}

    if(self.rearrangeView)[self.rearrangeView exitView];
}

#pragma mark - EditContentViewDelegate methods -

-(void) textIsEditing{
    if(self.isPhotoVideoSubview) [self.textEntryDelegate editContentViewTextIsEditing];
}

-(void) textDoneEditing{
    if(self.isPhotoVideoSubview) [self.textEntryDelegate editContentViewTextDoneEditing];
}


#pragma mark - Lazy Instantiation


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
                                                                         self.frame.size.height - EXIT_CV_BUTTON_HEIGHT -
                                                                         EXIT_CV_BUTTON_WALL_OFFSET,
                                                                         EXIT_CV_BUTTON_WIDTH,
                                                                         EXIT_CV_BUTTON_HEIGHT)];
    }
    return _textViewButton;
}

-(UIButton *)rearrangeButton {
    if(!_rearrangeButton){
        _rearrangeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
                                                                     EXIT_CV_BUTTON_WIDTH,
                                                                     self.frame.size.height - (EXIT_CV_BUTTON_HEIGHT*2) -
                                                                     (EXIT_CV_BUTTON_WALL_OFFSET*3),
                                                                     EXIT_CV_BUTTON_WIDTH,
                                                                     EXIT_CV_BUTTON_HEIGHT)];
    }
    return _rearrangeButton;
}


@end
