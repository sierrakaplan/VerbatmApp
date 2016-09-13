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


#import "SizesAndPositions.h"
#import "Styles.h"
#import "TextPinchView.h"
#import "TextOverMediaView.h"

#import "UIImage+ImageEffectsAndTransforms.h"


@interface PhotoPVE() <UIGestureRecognizerDelegate>


#pragma mark - Slideshow -


@property (nonatomic) CABasicAnimation * circlePathAnimation;

@property (nonatomic) CAShapeLayer *slideshowProgressCircle;
@property (nonatomic) NSTimer * photoSlideShowTimer;
@property (nonatomic) NSDate * timerStarted;
@property (nonatomic) NSTimeInterval timerElapsed;


@end

@implementation PhotoPVE

-(instancetype) initWithFrame:(CGRect)frame small:(BOOL) small isPhotoVideoSubview:(BOOL)halfScreen {
	self = [super initWithFrame:frame];
	if (self) {
		self.small = small;
		self.photoVideoSubview = halfScreen;
		self.inPreviewMode = NO;
		[self initialFormatting];
	}
	return self;
}

-(void) displayPhotos:(NSArray *)photos {
	self.hasLoadedMedia = YES;
	[self.customActivityIndicator stopCustomActivityIndicator];
	[self.customActivityIndicator removeFromSuperview];
	if ([photos count]) {
		[self addPhotos:photos];
    }
	if (self.currentlyOnScreen) {
		[self onScreen];
	}
}

-(void) initialFormatting {
	[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
}


#pragma mark - Not preview mode -

/* photoTextArray is array containing subarrays of photo and text info
 @[@[photourl,photo, text, textYPosition, textColor, textAlignment, textSize],...] */
-(void) addPhotos:(NSArray*)photosTextArray {

	for (NSArray* photoText in photosTextArray) {
		[self.imageContainerViews addObject:[self getImageContainerViewFromPhotoTextArray:photoText]];
	}

	// Has to add duplicate of first photo to bottom so that you can fade from the last photo into the first
	//NSArray* firstPhotoText = photosTextArray[0];
	//[self addSubview: [self getImageContainerViewFromPhotoTextArray: firstPhotoText]];
	[self layoutContainerViews];
}

-(void)layoutContainerViews{
    //adding subviews in reverse order so that imageview at index 0 on top
    for (int i = (int)[self.imageContainerViews count]-1; i >= 0; i--) {
        [self addSubview:[self.imageContainerViews objectAtIndex:i]];
    }
}

-(TextOverMediaView*) getImageContainerViewFromPhotoTextArray: (NSArray*) photoTextArray {
	NSURL *url = photoTextArray[0];
	UIImage *thumbnailimage = photoTextArray[1];
	NSString* text = photoTextArray[2];
	CGFloat textYPosition = [(NSNumber *)photoTextArray[3] floatValue];
	UIColor *textColor = photoTextArray[4];
	NSTextAlignment textAlignment = (NSTextAlignment) ([(NSNumber *)photoTextArray[5] integerValue]);
	CGFloat textSize = [(NSNumber *)photoTextArray[6] floatValue];

	if(self.photoVideoSubview) {
		textYPosition = textYPosition/2.f;
	}

	TextOverMediaView* textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.bounds
																		  andImageURL: url withSmallImage:thumbnailimage
																		   asSmall:self.small];
	BOOL textColorBlack = [textColor isEqual:[UIColor blackColor]];
	[textAndImageView setText: text
			 andTextYPosition: textYPosition
			andTextColorBlack: textColorBlack
			 andTextAlignment: textAlignment
				  andTextSize: textSize andFontName:TEXT_PAGE_VIEW_DEFAULT_FONT];
	[textAndImageView showText:YES];
	return textAndImageView;
}


-(void)addPauseLongPressGesture{
    UILongPressGestureRecognizer * pauseGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureFelt:)];
    pauseGesture.minimumPressDuration = 0.f;
    pauseGesture.delegate = self;
    [self.panGestureSensingViewVertical addGestureRecognizer:pauseGesture];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)longPressGestureFelt:(UILongPressGestureRecognizer *) gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.slideShowPaused = YES;
            [self pauseSlideShow];
            [self pauseSlideShowCircleAnimation];
            break;
        case UIGestureRecognizerStateEnded:
            [self continePlaySlideShow];
            [self continueSlideShowAnimation];
            //this has to be after playWithSpeed function
            self.slideShowPaused = NO;
            break;
        default:
            break;
    }
}


-(void)pauseSlideShow{
    self.slideShowPlaying = NO;
    //pause timer
    [self killCurrentTimer];
    self.timerElapsed = [[NSDate date] timeIntervalSinceDate:self.timerStarted];
}

-(void)continePlaySlideShow{
    [self killCurrentTimer];
    self.slideShowPlaying = YES;
    CGFloat timerSecondsLeft = ((CGFloat)SLIDESHOW_SPEED_SECONDS - ((CGFloat)self.timerElapsed));
    if(timerSecondsLeft >= 0)self.photoSlideShowTimer = [NSTimer scheduledTimerWithTimeInterval: timerSecondsLeft target:self selector:@selector(animateNextView) userInfo:nil repeats:NO];
    else [self startBaseSlideshowTimer];
}

-(void)startBaseSlideshowTimer{
    [self killCurrentTimer];
    self.photoSlideShowTimer = [NSTimer scheduledTimerWithTimeInterval:SLIDESHOW_SPEED_SECONDS target:self selector:@selector(animateNextView) userInfo:nil repeats:NO];
    self.timerStarted = [NSDate date];
}



-(void)playSlideshow{
	if(!self.animating){
        CGRect v_frame;
        CGRect h_frame;
        
        v_frame= self.bounds;
        h_frame= CGRectMake(0.f,0.f,0.f,0.f);

		//create view to sense swiping
		if(self.panGestureSensingViewHorizontal == nil){
			UIView *panViewVertical = [[UIView alloc] initWithFrame:v_frame];
			[self addSubview: panViewVertical];
			self.panGestureSensingViewVertical = panViewVertical;
			self.panGestureSensingViewVertical.backgroundColor = [UIColor clearColor];

			UIView *panViewHorizontal = [[UIView alloc] initWithFrame:h_frame];
			[self addSubview: panViewHorizontal];
			self.panGestureSensingViewHorizontal = panViewHorizontal;
			self.panGestureSensingViewHorizontal.backgroundColor = [UIColor clearColor];

			[self bringSubviewToFront:self.panGestureSensingViewVertical];
			[self bringSubviewToFront:self.panGestureSensingViewHorizontal];
            //create press and hold to pause gesture
            if(!self.small){
                [self addPauseLongPressGesture];
            }

		}
        
        [self startBaseSlideshowTimer];
		
        if(!self.slideShowPaused)[self animateCirclePathNext];
	}
    
	self.slideShowPlaying = YES;
}





// Create circle view showing video progress
-(void)stopSlideshow {
	self.slideShowPlaying = NO;
	if(self.inPreviewMode){
		[self.panGestureSensingViewHorizontal removeFromSuperview];
		self.panGestureSensingViewHorizontal = nil;
		[self.panGestureSensingViewVertical removeFromSuperview];
		self.panGestureSensingViewVertical = nil;
    }
}

-(void)pauseSlideShowCircleAnimation{
    if(self.circlePathAnimation){
        CFTimeInterval pausedTime = [self.slideshowProgressCircle convertTime:CACurrentMediaTime() fromLayer:nil];
        self.slideshowProgressCircle.speed = 0.0;
        self.slideshowProgressCircle.timeOffset = pausedTime;
    }
}
-(void)continueSlideShowAnimation{
    
    CFTimeInterval pausedTime = [self.slideshowProgressCircle timeOffset];
    self.slideshowProgressCircle.speed = 1.0;
    self.slideshowProgressCircle.timeOffset = 0.0;
    self.slideshowProgressCircle.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.slideshowProgressCircle convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.slideshowProgressCircle.beginTime = timeSincePause;
    
}

-(void)animateNextView{
	__weak PhotoPVE * weakSelf = self;
    NSInteger nextIndex = weakSelf.currentPhotoIndex + 1;
	if(weakSelf.slideShowPlaying && !weakSelf.animating){
		//todo: This is a hack. Find where animations get disabled
		if(![UIView areAnimationsEnabled]){
			//            NSLog(@"Animations are disabled.");
			[UIView setAnimationsEnabled:YES];
		}
		[UIView animateWithDuration:IMAGE_FADE_OUT_ANIMATION_DURATION animations:^{
            weakSelf.animating = YES;
            
			[weakSelf setImageViewsToLocation:nextIndex];
		} completion:^(BOOL finished) {
			weakSelf.animating = NO;
            
            if(nextIndex >= weakSelf.imageContainerViews.count){
                [self clearCircleVideoProgressView];
                [self animateCirclePathNext];
            }
            
            [self startBaseSlideshowTimer];
		}];

	}
}


-(void)killCurrentTimer{
    if(self.photoSlideShowTimer){
        [self.photoSlideShowTimer invalidate];
        self.photoSlideShowTimer = nil;
    }
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
	for (int i = 0; i < self.imageContainerViews.count; i++) {
		UIView* imageView = self.imageContainerViews[i];
		if (i < self.currentPhotoIndex) {
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


#pragma mark - Overriding ArticleViewingExperience methods -

-(void) onScreen {
	self.currentlyOnScreen = YES;
	if (!self.hasLoadedMedia && !self.photoVideoSubview) {
		[self.customActivityIndicator startCustomActivityIndicator];
		return;
	}
	if(self.imageContainerViews.count > 1){
		if(!self.slideShowPlaying){
			[self playSlideshow];
		}
	}else{
		if([self.pinchView isKindOfClass:[SingleMediaAndTextPinchView class]]){
			EditMediaContentView *editContentView = [self.imageContainerViews firstObject];
			[editContentView onScreen];
		}
	}
}

- (void)offScreen {
	[self.customActivityIndicator stopCustomActivityIndicator];
	self.currentlyOnScreen = NO;
	[self stopSlideshow];
	for (UIView * view in self.imageContainerViews) {
		if([view isKindOfClass:[EditMediaContentView class]]){
			[((EditMediaContentView *)view) offScreen];
		}
	}
	if(self.rearrangeView)[self.rearrangeView exitView];
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

-(UIButton *)pauseToRearrangeButton {
	if(!_pauseToRearrangeButton){
		UIButton *pauseToRearrangeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
																					  EXIT_CV_BUTTON_WIDTH,
																					  self.frame.size.height - (EXIT_CV_BUTTON_HEIGHT*2) -
																					  (EXIT_CV_BUTTON_WALL_OFFSET*3),
																					  EXIT_CV_BUTTON_WIDTH,
																					  EXIT_CV_BUTTON_HEIGHT)];
		[self addSubview: pauseToRearrangeButton];
		_pauseToRearrangeButton = pauseToRearrangeButton;
	}
	return _pauseToRearrangeButton;
}

-(CAShapeLayer*) slideshowProgressCircle {
	if (!_slideshowProgressCircle) {
		_slideshowProgressCircle = [[CAShapeLayer alloc]init];
		_slideshowProgressCircle.frame = self.bounds;
		_slideshowProgressCircle.fillColor = [UIColor clearColor].CGColor;
		_slideshowProgressCircle.strokeColor = [UIColor whiteColor].CGColor;
		_slideshowProgressCircle.lineWidth = SLIDESHOW_PROGRESS_CIRCLE_THICKNESS;
        [self.panGestureSensingViewVertical.layer addSublayer: self.slideshowProgressCircle];
	}
	return _slideshowProgressCircle;
}



-(void)animateCirclePathNext{
    self.circlePathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    self.circlePathAnimation.duration = CIRCLE_ANIMATION_DURATION;
    self.circlePathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    self.circlePathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    self.circlePathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.slideshowProgressCircle addAnimation:self.circlePathAnimation forKey:@"strokeEnd"];
    [self animateSlideshowProgressPath];
    if(self.slideShowPaused)[self pauseSlideShowCircleAnimation];
}

// Animate circle view showing video progress
-(void) animateSlideshowProgressPath {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat yPos =   5.f + ((self.photoVideoSubview) ? 2.f : CREATOR_CHANNEL_BAR_HEIGHT + STATUS_BAR_HEIGHT);
    
    
    CGRect frame =CGRectMake(10.f,yPos , SLIDESHOW_PROGRESS_CIRCLE_SIZE, SLIDESHOW_PROGRESS_CIRCLE_SIZE);

    float midX = CGRectGetMidX(frame);
    float midY = CGRectGetMidY(frame);
    CGAffineTransform t = CGAffineTransformConcat(
                                                  CGAffineTransformConcat(
                                                                          CGAffineTransformMakeTranslation(-midX, -midY),
                                                                          CGAffineTransformMakeRotation(-(M_PI/2.f))),
                                                  CGAffineTransformMakeTranslation(midX, midY));
    CGPathAddEllipseInRect(path, &t, frame);
    self.slideshowProgressCircle.path = path;
}

-(void) clearCircleVideoProgressView {
    [_slideshowProgressCircle removeFromSuperlayer];
    _slideshowProgressCircle = nil;
}


-(void) dealloc {
}
@end
