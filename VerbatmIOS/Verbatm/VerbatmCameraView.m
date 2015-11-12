//
//  VerbatmCameraView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/14/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraFocusSquare.h"
#import "Durations.h"
#import "Icons.h"
#import "MediaSessionManager.h"
#import "SizesAndPositions.h"
#import "VerbatmCameraView.h"

@interface VerbatmCameraView() <MediaSessionManagerDelegate>
#pragma mark - Capture Media -

@property (strong, nonatomic) MediaSessionManager* sessionManager;
@property(nonatomic,strong) UIButton * captureMediaButton;
@property (strong, nonatomic) CAShapeLayer* videoProgressCircle;
@property (nonatomic) BOOL isTakingVideo;
@property (nonatomic, strong) NSTimer *videoTimer;

// Used so after media is captured appears media goes into corner
@property (strong, nonatomic) UIImageView* previewImageView;
@property (nonatomic) BOOL mediaPreviewPaused;

#pragma  mark - Camera Customization -
@property (strong, nonatomic) CameraFocusSquare* focusSquare;
@property (strong, nonatomic) UIButton* switchCameraButton;
@property (strong, nonatomic) UIButton* switchFlashButton;
@property (strong, nonatomic) UIImage* flashOnIcon;
@property (strong, nonatomic) UIImage* flashOffIcon;
@property (nonatomic) BOOL flashOn;

#pragma mark - Close camera -

@property (strong, nonatomic) UIButton* closeButton;

@end

@implementation VerbatmCameraView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor blackColor];
		self.effectiveScale = 1.0f;
		[self setDelegates];
		[self registerForNotifications];
		[self createSubViews];
	}
	return self;
}

#pragma mark Create Sub Views

-(void) createSubViews {
	[self addCloseButton];
	[self createCapturePicButton];
	[self addToggleFlashButton];
	[self addSwitchCameraOrientationButton];
}

-(void) addCloseButton {
	self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.closeButton setImage:[UIImage imageNamed:MINIMIZE_ICON] forState:UIControlStateNormal];
	[self.closeButton setFrame:CGRectMake(CAPTURE_MEDIA_BUTTON_OFFSET, CAPTURE_MEDIA_BUTTON_OFFSET,
										  CAPTURE_MEDIA_BUTTON_SIZE, CAPTURE_MEDIA_BUTTON_SIZE)];
	[self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.closeButton];
}

-(void)createCapturePicButton {
	self.isTakingVideo = NO;
	self.captureMediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *cameraImage = [UIImage imageNamed: CAPTURE_IMAGE_ICON];
	[self.captureMediaButton setImage:cameraImage forState:UIControlStateNormal];
	[self.captureMediaButton setFrame:CGRectMake((self.frame.size.width - CAPTURE_MEDIA_BUTTON_SIZE)/2.f,
												 self.frame.size.height - CAPTURE_MEDIA_BUTTON_SIZE - CAPTURE_MEDIA_BUTTON_OFFSET,
												 CAPTURE_MEDIA_BUTTON_SIZE, CAPTURE_MEDIA_BUTTON_SIZE)];
	[self.captureMediaButton addTarget:self action:@selector(tappedCaptureMediaButton:) forControlEvents:UIControlEventTouchUpInside];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(takeVideo:)];
	longPress.minimumPressDuration = MINIMUM_PRESS_DURATION_FOR_VIDEO;
	[self.captureMediaButton addGestureRecognizer:longPress];

	[self addSubview:self.captureMediaButton];
	[self bringSubviewToFront:self.captureMediaButton];
}

-(void) addSwitchCameraOrientationButton {
	self.switchCameraButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[self.switchCameraButton setImage:[UIImage imageNamed:SWITCH_CAMERA_ORIENTATION_ICON] forState:UIControlStateNormal];
	[self.switchCameraButton setFrame:CGRectMake(self.bounds.size.width - CAPTURE_MEDIA_BUTTON_OFFSET - SWITCH_ORIENTATION_ICON_SIZE,
												 self.bounds.size.height - FLASH_ICON_SIZE - CAPTURE_MEDIA_BUTTON_OFFSET,
												 SWITCH_ORIENTATION_ICON_SIZE,
												 SWITCH_ORIENTATION_ICON_SIZE)];
	self.switchCameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.switchCameraButton addTarget:self action:@selector(switchCameraOrientation:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.switchCameraButton];
}

-(void) addToggleFlashButton {
	self.switchFlashButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[self.switchFlashButton setFrame:CGRectMake(CAPTURE_MEDIA_BUTTON_OFFSET,
												self.bounds.size.height - FLASH_ICON_SIZE - CAPTURE_MEDIA_BUTTON_OFFSET,
												FLASH_ICON_SIZE, FLASH_ICON_SIZE)];
	self.switchFlashButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.switchFlashButton addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
	self.flashOffIcon = [UIImage imageNamed:FLASH_ICON_OFF];
	self.flashOnIcon = [UIImage imageNamed:FLASH_ICON_ON];
	[self setFlashButtonOn:NO];
	[self addSubview:self.switchFlashButton];
}

-(void) setFlashButtonOn: (BOOL) on {
	if (on) {
		self.flashOn = YES;
		[self.switchFlashButton setImage:self.flashOnIcon forState:UIControlStateNormal];
	} else {
		self.flashOn = NO;
		[self.switchFlashButton setImage:self.flashOffIcon forState:UIControlStateNormal];
	}
}


#pragma mark - Saved Media animation -

-(void) capturedImage:(UIImage *)image {
	self.previewImageView = [[UIImageView alloc] initWithImage: image];
	if (!self.mediaPreviewPaused) {
		[self animatePreviewImage];
	}
	[self.delegate imageCaptured:image];
}

-(void) didFinishSavingMediaToAsset:(PHAsset *)asset {
	if (asset.mediaType == PHAssetMediaTypeVideo) {
		//animate image of asset
		@autoreleasepool {
			[[PHImageManager defaultManager] requestImageForAsset:asset targetSize: self.bounds.size
													  contentMode:PHImageContentModeAspectFit options:nil
													resultHandler:^(UIImage *image, NSDictionary *info) {
														dispatch_async(dispatch_get_main_queue(), ^{
															self.previewImageView = [[UIImageView alloc] initWithImage:image];
															if (!self.mediaPreviewPaused) {
																[self animatePreviewImage];
															}
														});
													}];
		}
		[self.delegate videoAssetCaptured:asset];
	}
}


#pragma mark - Customize camera -

-(void) switchCameraOrientation:(UITapGestureRecognizer *)sender {
	[self.sessionManager switchCameraOrientation];
}

-(void) toggleFlash:(id)sender {
	[self.sessionManager toggleFlash];
	if(self.flashOn) {
		[self setFlashButtonOn:NO];
	}else{
		[self setFlashButtonOn:YES];
	}
}

#pragma mark - Create Customize Camera Gestures -

-(void) createAndInstantiateGestures {
	[self createTapGestureToFocus];
	[self createPinchGestureToZoom];
	[self createDoubleTapToSwitchCamera];
}

-(void)createDoubleTapToSwitchCamera{
	UITapGestureRecognizer* cameraFace = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchCameraOrientation:)];
	cameraFace.numberOfTapsRequired = 2;
	cameraFace.cancelsTouchesInView =  NO;
	[cameraFace setDelegate: self];
	[self addGestureRecognizer:cameraFace];
}

-(void) createTapGestureToFocus {
	UITapGestureRecognizer* focusRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusPhoto:)];
	//    self.takePhotoGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
	//focusRecognizer.numberOfTapsRequired = 2;
	focusRecognizer.cancelsTouchesInView =  NO;
	[focusRecognizer setDelegate:self];
	[self addGestureRecognizer:focusRecognizer];
}

-(void) createPinchGestureToZoom {
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomPreview:)];
	[pinchRecognizer setDelegate:self];
	[self addGestureRecognizer:pinchRecognizer];
}

#pragma mark Other Initialization
-(void) setDelegates {
	self.sessionManager.delegate = self;
}

-(void)registerForNotifications {

	//for postitioning the blurView when the orientation of the device changes
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

#pragma mark - Capture Media

- (void) tappedCaptureMediaButton:(id)sender {
	if(self.isTakingVideo) {
		[self endVideoRecordingSession];
	} else {
		[self takePhoto:sender];
	}
}

- (void) takePhoto:(id)sender {
	[self.sessionManager captureImage];
	[self freezeFrame];
}

-(void) takeVideo:(UILongPressGestureRecognizer*)sender {

	if(!self.isTakingVideo && sender.state == UIGestureRecognizerStateBegan){
		self.isTakingVideo = YES;
		[self.sessionManager startVideoRecordingInOrientation:[UIDevice currentDevice].orientation];
		[self createCircleVideoProgressView];
		self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_VID_SECONDS target:self selector:@selector(endVideoRecordingSession) userInfo:nil repeats:NO];
		[self.captureMediaButton setImage:[UIImage imageNamed: CAPTURE_RECORDING_ICON] forState:UIControlStateNormal];

	}
}

-(void) endVideoRecordingSession {

	if(!self.videoProgressCircle) return;
	self.isTakingVideo = NO;
	[self.sessionManager stopVideoRecording];
	[self clearCircleVideoProgressView];  //removes the video progress bar
	[self.captureMediaButton setImage:[UIImage imageNamed: CAPTURE_IMAGE_ICON] forState:UIControlStateNormal];
	[self.videoTimer invalidate];
	self.videoTimer = nil;
	[self freezeFrame];
}

// When a photo is taken "freeze" it on the screen) for a short period of time before removing it
-(void)freezeFrame {
	self.sessionManager.videoPreview.connection.enabled = NO;
	[NSTimer scheduledTimerWithTimeInterval:TIME_FOR_SESSION_TO_RESUME_POST_MEDIA_CAPTURE target:self selector:@selector(resumeSession:) userInfo:nil repeats:NO];
	self.mediaPreviewPaused = YES;
}

// Resume session after freezing frame on taking picture/video
-(void)resumeSession:(NSTimer*)timer {
	if (self.previewImageView) {
		[self animatePreviewImage];
	}
	self.sessionManager.videoPreview.connection.enabled = YES;
	self.mediaPreviewPaused = NO;
	[timer invalidate];
}

// Animates appearance of media just captured sliding into the gallery in the corner
-(void) animatePreviewImage {
	self.previewImageView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.frame.size.width, self.frame.size.height - NAV_BAR_HEIGHT);
	[self addSubview:self.previewImageView];
	[UIView animateWithDuration:1.f animations:^{
		self.previewImageView.frame = CGRectMake(self.bounds.size.width/2.f, 0, 0, 0);
	} completion:^(BOOL finished) {
		[self.previewImageView removeFromSuperview];
		self.previewImageView = nil;
	}];
}

// Create circle view showing video progress
-(void) createCircleVideoProgressView {

	self.videoProgressCircle = [[CAShapeLayer alloc]init];
	[self animateVideoProgressPath];
	self.videoProgressCircle.frame = self.bounds;
	self.videoProgressCircle.fillColor = [UIColor clearColor].CGColor;
	self.videoProgressCircle.strokeColor = [UIColor colorWithRed:1.f green:0.f blue:0.f alpha:PROGRESS_CIRCLE_OPACITY].CGColor;
	self.videoProgressCircle.lineWidth = PROGRESS_CIRCLE_THICKNESS;
	[self.layer addSublayer:self.videoProgressCircle];

	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	animation.duration = MAX_VID_SECONDS;
	animation.fromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	[self.videoProgressCircle addAnimation:animation forKey:@"strokeEnd"];

}

// Animate circle view showing video progress
-(void) animateVideoProgressPath {

	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint center = CGPointMake((self.frame.size.width)/2.f,
								 self.frame.size.height - CAPTURE_MEDIA_BUTTON_OFFSET - CAPTURE_MEDIA_BUTTON_SIZE/2.f);
	CGRect frame = CGRectMake(center.x - PROGRESS_CIRCLE_SIZE/2.f, center.y -PROGRESS_CIRCLE_SIZE/2.f, PROGRESS_CIRCLE_SIZE, PROGRESS_CIRCLE_SIZE);
	float midX = CGRectGetMidX(frame);
	float midY = CGRectGetMidY(frame);
	CGAffineTransform t = CGAffineTransformConcat(
												  CGAffineTransformConcat(
																		  CGAffineTransformMakeTranslation(-midX, -midY),
																		  CGAffineTransformMakeRotation(-(M_PI/2.f))),
												  CGAffineTransformMakeTranslation(midX, midY));
	CGPathAddEllipseInRect(path, &t, frame);
	self.videoProgressCircle.path = path;
}

-(void) clearCircleVideoProgressView {
	[self.videoProgressCircle removeFromSuperlayer];
	self.videoProgressCircle = nil;
}


#pragma mark - Actions to enhance the camera view

-(void) focusPhoto: (UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		CGPoint point = [sender locationInView: self];

		// focus square animation
		if (self.focusSquare)
		{
			[self.focusSquare removeFromSuperview];
		}
		self.focusSquare = [[CameraFocusSquare alloc]initWithFrame:CGRectMake(point.x-40, point.y-40, 80, 80)];
		[self.focusSquare setBackgroundColor:[UIColor clearColor]];
		[self addSubview:self.focusSquare];
		[self.focusSquare setNeedsDisplay];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.5];
		[self.focusSquare setAlpha:0.0];
		[UIView commitAnimations];

		[self.sessionManager focusAtPoint:point];
	}
}

- (void) zoomPreview:(UIPinchGestureRecognizer *)recognizer {
	float scale = self.beginGestureScale * recognizer.scale;
	self.effectiveScale = scale > 1.0f ? scale : 1.0f;
	[self.sessionManager zoomPreviewWithScale:self.effectiveScale];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([touch.view isKindOfClass:[UIControl class]]) {
		// we touched our control surface
		return NO;
	}
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		self.beginGestureScale = self.effectiveScale;
	}
	return YES;
}

#pragma mark - Exit View -

-(void) closeButtonTapped {
	[self.delegate minimizeCameraViewButtonTapped];
}

#pragma mark - Lazy Instantiation -

-(MediaSessionManager*)sessionManager{
	if(!_sessionManager){
		_sessionManager = [[MediaSessionManager alloc] initSessionWithView:self];
	}
	return _sessionManager;
}

@end
