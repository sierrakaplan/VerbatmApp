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
#import "TextPinchView.h"
#import "TextOverMediaView.h"

#import "UIImage+ImageEffectsAndTransforms.h"


@interface PhotoPVE() <UIGestureRecognizerDelegate, OpenCollectionViewDelegate, EditContentViewDelegate>

@property (strong, nonatomic) NSMutableArray* imageContainerViews;
@property (nonatomic) NSInteger currentPhotoIndex;

//When a view is animating it doesn't sense gestures very well. This makes it tough for users
// to scroll up and down while their photo slideshow is playing.
//To manage this we add to clear views above the animating views to catch the gestures.
//We add two views instead of one because of the buttons on the bottom right -- don't want
// to cover them.
@property (nonatomic, weak) UIView * panGestureSensingViewVertical;
@property (nonatomic, weak) UIView * panGestureSensingViewHorizontal;

#pragma mark - In Preview Mode -

@property (nonatomic, weak) PinchView *pinchView;
@property (nonatomic, weak) UIButton * pauseToRearrangeButton;
@property (nonatomic, weak) OpenCollectionView * rearrangeView;

// Tells whether should display smaller sized images
@property (nonatomic) BOOL small;

@property (nonatomic) BOOL photoVideoSubview;

#pragma mark - Slideshow -


@property (nonatomic) CABasicAnimation * circlePathAnimation;

@property (nonatomic) BOOL animating;
@property (nonatomic) BOOL slideShowPlaying;
@property (nonatomic) BOOL slideShowPaused;//when not in preview mode

@property (nonatomic) CAShapeLayer *slideshowProgressCircle;
@property (nonatomic) NSTimer * photoSlideShowTimer;
@property (nonatomic) NSDate * timerStarted;
@property (nonatomic) NSTimeInterval timerElapsed;

#define TEXT_VIEW_HEIGHT 70.f
#define OPEN_COLLECTION_FRAME_HEIGHT 70.f

#define IMAGE_FADE_OUT_ANIMATION_DURATION 1.f

#define CIRCLE_ANIMATION_DURATION ((PHOTO_SLIDESHOW_PROGRESS_PATH_SECTION_SPEED + IMAGE_FADE_OUT_ANIMATION_DURATION) * self.imageContainerViews.count)

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

-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView
				inPreviewMode: (BOOL) inPreviewMode isPhotoVideoSubview:(BOOL)halfScreen {
	self = [super initWithFrame:frame];
	if (self) {
		self.hasLoadedMedia = YES;
		self.small = NO;
		self.inPreviewMode = inPreviewMode;
		self.photoVideoSubview = halfScreen;
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


#pragma mark - Preview mode -

-(void) addContentFromImagePinchViews:(NSMutableArray *)pinchViewArray{
	NSMutableArray* photosTextArray = [[NSMutableArray alloc] init];

	for (ImagePinchView *imagePinchView in pinchViewArray) {
		if (self.inPreviewMode) {
			EditMediaContentView *editMediaContentView = [self getEditContentViewFromPinchView:imagePinchView];
			[self.imageContainerViews addObject:editMediaContentView];
		} else {
			[photosTextArray addObject: [imagePinchView getPhotosWithText][0]];
		}
	}
	if (!self.inPreviewMode) {
		[self addPhotos: photosTextArray];
	} else {
		[self layoutContainerViews];
		if(pinchViewArray.count > 1) {
			[self createRearrangeButton];
		}
	}
}

-(EditMediaContentView *) getEditContentViewFromPinchView: (ImagePinchView *)pinchView {
	EditMediaContentView * editMediaContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];
	//this has to be set before we set the text view information
	editMediaContentView.pinchView = pinchView;
	editMediaContentView.povViewMasterScrollView = self.postScrollView;
	editMediaContentView.delegate = self;

	PHImageRequestOptions *options = [PHImageRequestOptions new];
	options.synchronous = YES;
	__weak PhotoPVE * weakSelf = self;
	[pinchView getLargerImageWithHalfSize:weakSelf.photoVideoSubview].then(^(UIImage *image) {
		[editMediaContentView displayImage:image isHalfScreen:self.photoVideoSubview
						 withContentOffset:pinchView.imageContentOffset];

		BOOL textColorBlack = [pinchView.textColor isEqual:[UIColor blackColor]];
		[editMediaContentView setText:pinchView.text
					 andTextYPosition:[pinchView.textYPosition floatValue]
					andTextColorBlack:textColorBlack
					 andTextAlignment:[pinchView.textAlignment integerValue]
						  andTextSize:[pinchView.textSize floatValue] andFontName:pinchView.fontName];
		if (self.imageContainerViews.count < 2) {
			[editMediaContentView showTextToolbar:YES];
		}
		if (self.currentlyOnScreen) {
			[editMediaContentView onScreen];
		}
	});
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

#pragma mark - Rearrange content (preview mode) -

-(void)createRearrangeButton {
	[self.pauseToRearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
	self.pauseToRearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.pauseToRearrangeButton addTarget:self action:@selector(pauseToRearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self bringSubviewToFront:self.pauseToRearrangeButton];
}

-(void) pauseToRearrangeButtonPressed {
	// Pausing slideshow
	if(![self.pinchView isKindOfClass:[CollectionPinchView class]])return;

	if(!self.rearrangeView) {
		for (UIView * view in self.imageContainerViews) {
			if([view isKindOfClass:[EditMediaContentView class]]){
				[((EditMediaContentView *)view) showTextToolbar:YES];
			}
		}

		[self offScreen];
		CGFloat y_pos = (self.photoVideoSubview) ? 0.f : CUSTOM_NAV_BAR_HEIGHT;
		CGRect frame = CGRectMake(0.f,y_pos, self.frame.size.width, OPEN_COLLECTION_FRAME_HEIGHT);
		OpenCollectionView *rearrangeView = [[OpenCollectionView alloc] initWithFrame:frame
																	andPinchViewArray:((CollectionPinchView*)self.pinchView).imagePinchViews];
		[self insertSubview: rearrangeView belowSubview:self.pauseToRearrangeButton];
		self.rearrangeView = rearrangeView;
		self.rearrangeView.delegate = self;
		[self.pauseToRearrangeButton setImage:[UIImage imageNamed:PLAY_SLIDESHOW_ICON] forState:UIControlStateNormal];
	} else {
		for (UIView * view in self.imageContainerViews) {
			if([view isKindOfClass:[EditMediaContentView class]]){
				[((EditMediaContentView *)view) exiting];
				[((EditMediaContentView *)view) showTextToolbar: NO];
			}
		}
		[self.pauseToRearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
		[self.rearrangeView exitView];
		[self playWithSpeed:SLIDESHOW_SPEED_SECONDS];
	}
}

//new pinchview tapped in rearange view so we need to change what's presented
-(void)pinchViewSelected:(PinchView *) pv{
	NSInteger imageIndex = 0;
	for(NSInteger index = 0; index < self.imageContainerViews.count; index++){
		EditMediaContentView *eview = self.imageContainerViews[index];
		if(eview.pinchView == pv){
			imageIndex = index;
			break;
		}
	}
	[self setImageViewsToLocation:imageIndex];
}


-(void)addPauseTapGesture{
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

-(void)playWithSpeed:(CGFloat) speed {
	if(!self.animating){
        CGRect v_frame;
        CGRect h_frame;
        if(self.inPreviewMode){
             v_frame= CGRectMake(0.f, 0.f, self.frame.size.width, self.pauseToRearrangeButton.frame.origin.y);
             h_frame= CGRectMake(0.f, self.pauseToRearrangeButton.frame.origin.y,self.pauseToRearrangeButton.frame.origin.x - 10.f,
									self.frame.size.height - self.pauseToRearrangeButton.frame.origin.y);
        }else{
            v_frame= self.bounds;
            h_frame= CGRectMake(0.f,0.f,0.f,0.f);
        }

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
            if(!self.inPreviewMode){
                [self addPauseTapGesture];
            }

		}
        
        [self startBaseSlideshowTimer];
		
        if([self okToAnimatePath] && !self.slideShowPaused)[self animateCirclePathNext];
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
            
            if(nextIndex >= weakSelf.imageContainerViews.count && [self okToAnimatePath]){
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

-(BOOL)okToAnimatePath{
    return (!self.inPreviewMode);
}
#pragma mark OpenCollectionView delegate method

-(void) collectionClosedWithFinalArray:(NSMutableArray *) pinchViews {
	if(self.rearrangeView){
		[self.rearrangeView removeFromSuperview];
		self.rearrangeView = nil;
	}
	self.imageContainerViews = nil;
	((CollectionPinchView*)self.pinchView).imagePinchViews = pinchViews;
	[[PostInProgress sharedInstance] removePinchViewAtIndex:self.indexInPost andReplaceWithPinchView:self.pinchView];
	[self.pinchView renderMedia];
	[self addContentFromImagePinchViews: pinchViews];
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

#pragma mark - Gesture Recognizer Delegate methods -


#pragma mark - Overriding ArticleViewingExperience methods -

-(void) onScreen {
	self.currentlyOnScreen = YES;
	if (!self.hasLoadedMedia && !self.photoVideoSubview) {
		[self.customActivityIndicator startCustomActivityIndicator];
		return;
	}
	if(self.imageContainerViews.count > 1){
		if(!self.slideShowPlaying){
			[self playWithSpeed:SLIDESHOW_SPEED_SECONDS];
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

#pragma mark - EditContentViewDelegate methods -

-(void) textIsEditing {

	if (self.imageContainerViews.count > 1) {
		// Pause slideshow
		if(!self.rearrangeView) {
			[self pauseToRearrangeButtonPressed];
		}
		[self.rearrangeView setHidden:YES];
		[self.pauseToRearrangeButton setHidden:YES];
	}

	if([self.textEntryDelegate respondsToSelector:@selector(editContentViewTextIsEditing)])[self.textEntryDelegate editContentViewTextIsEditing];
}

-(void) textDoneEditing {
	[self.pauseToRearrangeButton setHidden:NO];
	[self.rearrangeView setHidden:NO];
	if([self.textEntryDelegate respondsToSelector:@selector(editContentViewTextDoneEditing)])[self.textEntryDelegate editContentViewTextDoneEditing];
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
