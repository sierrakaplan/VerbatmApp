//  verbatmMediaPageViewController.m
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "Article.h"
#import "AVETypeAnalyzer.h"

#import "ContentDevVC.h"
#import "ContentPageElementScrollView.h"
#import "ContentDevVC.h"
#import "CameraFocusSquare.h"

#import "Icons.h"
#import "Identifiers.h"
#import "Durations.h"
#import "UserPinchViews.h"

#import "MasterNavigationVC.h"
#import "MediaPreview.h"
#import "MediaDevVC.h"
#import <math.h>
#import "MediaSessionManager.h"
#import <MediaPlayer/MediaPlayer.h>

#import "Notifications.h"

#import "PinchView.h"
#import "POVPublisher.h"

#import "Strings.h"
#import "SizesAndPositions.h"

#import "testerTransitionDelegate.h"

#import "verbatmPullBarView.h"
#import "VerbatmUser.h"
#import "VerbatmCameraView.h"

#import "UIEffects.h"


@interface MediaDevVC () <MediaSessionManagerDelegate, PullBarDelegate, ChangePullBarDelegate>

#pragma mark - Outlets -

@property (strong, nonatomic) VerbatmPullBarView *pullBar;

#pragma mark - SubViews of screen
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture_PullBar;
// view with content development part of ADK
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (strong, nonatomic) VerbatmCameraView *verbatmCameraView;

@property(nonatomic) CGRect contentContainerViewFrameTop;
@property(nonatomic) CGRect contentContainerViewFrameBottom;
@property (nonatomic) CGRect pullBarFrameTop;
@property (nonatomic) CGRect pullBarFrameBottom;
@property (nonatomic) CGRect pullBarFrameOffScreen;

#pragma mark - Camera properties
#pragma mark buttons
@property (strong, nonatomic) MediaSessionManager* sessionManager;
@property (strong, nonatomic) CAShapeLayer* circle;
@property (strong, nonatomic) CameraFocusSquare* focusSquare;
@property (strong, nonatomic) MediaPreview * mediaPreviewView;

@property (strong, nonatomic)UIButton* switchCameraButton;
@property (strong, nonatomic)UIButton* switchFlashButton;
@property (nonatomic) CGAffineTransform flashTransform;
@property (nonatomic) CGAffineTransform switchTransform;
@property(nonatomic,strong) UIButton * capturePicButton;
@property (nonatomic) BOOL isTakingVideo;

#pragma mark - View controllers
@property (strong,nonatomic) ContentDevVC* contentDevVC;

#pragma mark taking the photo
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL flashOn;
@property (nonatomic) BOOL canRaise;
@property (nonatomic)CGPoint currentPoint;
@property (nonatomic) UIDeviceOrientation startOrientation;

#pragma mark  pulldown
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) CGPoint previousTranslation;
@property (nonatomic) ContentContainerViewMode contentContainerViewMode;
//layout of the screen before it was made landscape
@property(nonatomic) ContentContainerViewMode previousMode;

#pragma mark keyboard properties
@property (nonatomic) NSInteger keyboardHeight;

#define Preview_X_offset 10
#define Preview_Y_offset 20
#define Preview_Width 75
#define Preview_Height 100
#define ID_FOR_CONTENTDEVVC @"content_dev_vc"

@end

@implementation MediaDevVC

#pragma mark - Synthesize

@synthesize verbatmCameraView = _verbatmCameraView;
@synthesize sessionManager = _sessionManager;
@synthesize timer = _timer;
@synthesize switchCameraButton = _switchCameraButton;


#pragma mark - Preparing View

- (void)viewDidLoad{
	[super viewDidLoad];
	[self setDefaultFrames];
	[self prepareCameraView];
	[self createAndInstantiateGestures];

	//make sure the frames are correctly centered
	self.canRaise = NO;
	self.currentPoint = CGPointZero;

	[self setDelegates];
	[self registerForNotifications];
	[self createSubViews];
	[self setContentDevVC];
	[self transitionContentContainerViewToMode:ContentContainerViewModeBase];
    
}

-(void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	[self positionContainerView];
}

-(void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	//get the view controllers in the storyboard and store them
}

-(void) viewDidAppear:(BOOL)animated
{
	//patch solution to the pullbar being drawn strange
	self.pullBar.frame = self.pullBarFrameTop;
	[self.sessionManager startSession];
    [self prepareCameraCapturePreview];
}

//prepares the view that will show camera content that's caputered
-(void)prepareCameraCapturePreview {
    self.mediaPreviewView = [[MediaPreview alloc] initWithFrame:CGRectMake(Preview_X_offset, self.view.frame.size.height - Preview_Y_offset - Preview_Height,
                                                                            Preview_Width,Preview_Height)];
    [self.view insertSubview:self.mediaPreviewView  aboveSubview:self.verbatmCameraView];
}


-(void) viewDidDisappear:(BOOL)animated {
	[self.sessionManager stopSession];
}

#pragma mark - Initialization

-(void)setContentDevVC {
	self.contentDevVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_CONTENTDEVVC];
	[self.contentContainerView addSubview: self.contentDevVC.view];
	self.contentDevVC.pullBarHeight = self.pullBar.frame.size.height;
	self.contentDevVC.changePullBarDelegate = self;
	[self.contentDevVC loadPinchViews];
}


#pragma mark Create Sub Views

//saves the intitial frames for the pulldown bar and the container view
-(void)setDefaultFrames {

	self.contentContainerViewFrameTop = CGRectMake(0, 0, self.view.frame.size.width, self.contentContainerView.frame.size.height + PULLBAR_HEIGHT_PULLDOWN_MODE);
	self.contentContainerViewFrameBottom = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

	int frameHeight = self.view.frame.size.height;
	self.pullBarFrameTop = CGRectMake(0.f, self.contentContainerView.frame.size.height, self.view.frame.size.width, PULLBAR_HEIGHT_PULLDOWN_MODE);
	self.pullBarFrameBottom = CGRectMake(self.pullBarFrameTop.origin.x, (frameHeight - PULLBAR_HEIGHT_MENU_MODE), self.pullBarFrameTop.size.width, PULLBAR_HEIGHT_MENU_MODE);
	self.pullBarFrameOffScreen = CGRectMake(self.pullBar.frame.origin.x, self.view.frame.size.height, self.pullBar.frame.size.width, self.pullBar.frame.size.height);
}

-(void) createSubViews {
	[self createPullBar];
	[self createCapturePicButton];
    [self createSwitchFlashButton];
}

-(void) prepareCameraView {
	[self.view insertSubview: self.verbatmCameraView atIndex:0];
}

-(void)createCapturePicButton {
	self.isTakingVideo = NO;
	self.capturePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *cameraImage = [UIImage imageNamed:CAMERA_BUTTON_IMAGE];
	[self.capturePicButton setImage:cameraImage forState:UIControlStateNormal];
	[self.capturePicButton setFrame:CGRectMake((self.view.frame.size.width -CAMERA_BUTTON_SIZE)/2.f, self.view.frame.size.height - CAMERA_BUTTON_SIZE - CAMERA_BUTTON_Y_OFFSET, CAMERA_BUTTON_SIZE, CAMERA_BUTTON_SIZE)];
	[self.capturePicButton addTarget:self action:@selector(tappedPhotoButton:) forControlEvents:UIControlEventTouchUpInside];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(takeVideo:)];
	longPress.minimumPressDuration = MINIMUM_PRESS_DURATION_FOR_VIDEO;
	[self.capturePicButton addGestureRecognizer:longPress];

	[self.verbatmCameraView addSubview:self.capturePicButton];
	[self.verbatmCameraView bringSubviewToFront:self.capturePicButton];
}

//creates the pullbar object then saves it as a property
-(void)createPullBar {
	self.pullBar = [[VerbatmPullBarView alloc] initWithFrame:self.pullBarFrameTop];
	self.pullBar.delegate = self;
	[self.panGesture_PullBar setDelegate:self.pullBar];
	[self.pullBar addGestureRecognizer:self.panGesture_PullBar];
	[self.view addSubview:self.pullBar];
	[self.view bringSubviewToFront:self.pullBar];
}

#pragma mark -Flash Button-

-(void)createSwitchCameraButton {
	self.switchCameraButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[self.switchCameraButton setImage:[UIImage imageNamed:CAMERA_ICON_FRONT] forState:UIControlStateNormal];
	[self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_START_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
	[self.switchCameraButton addTarget:self action:@selector(switchFaces:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview: self.switchCameraButton];
	self.switchTransform = self.switchCameraButton.transform;
}

-(void)createSwitchFlashButton {
	self.switchFlashButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[self.switchFlashButton setImage:[UIImage imageNamed: @"lightbulb_final_OFF" /*FLASH_ICON_OFF*/] forState:UIControlStateNormal];
	[self.switchFlashButton setFrame:CGRectMake(FLASH_START_POSITION, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
	[self.switchFlashButton addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
	self.flashOn = NO;
	[self.view insertSubview:self.switchFlashButton belowSubview:self.contentContainerView];
	self.flashTransform = self.switchFlashButton.transform;
}


-(void)didFinishSavingMediaToAsset:(ALAsset*)asset {
    [self.mediaPreviewView setAsset:asset];
}


-(void)switchFaces:(UITapGestureRecognizer *)sender {
    [self.sessionManager switchVideoFace];
}

-(IBAction)switchFlash:(id)sender {
    [self.sessionManager switchFlash];
    if(self.flashOn) {
        [self.switchFlashButton setImage:[UIImage imageNamed:FLASH_ICON_OFF]forState:UIControlStateNormal];
    }else{
        [self.switchFlashButton setImage:[UIImage imageNamed:FLASH_ICON_ON] forState:UIControlStateNormal];
    }
    self.flashOn = !self.flashOn;
}


#pragma mark Create Gestures
-(void) createAndInstantiateGestures {
	[self createTapGestureToFocus];
	[self createPinchGestureToZoom];
    [self createDoubleTapToSwitchCamera];
}


-(void)createDoubleTapToSwitchCamera{
    UITapGestureRecognizer* cameraFace = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchFaces:)];
    cameraFace.numberOfTapsRequired = 2;
    cameraFace.cancelsTouchesInView =  NO;
    [cameraFace setDelegate:self.verbatmCameraView];
    [self.verbatmCameraView addGestureRecognizer:cameraFace];
}

-(void) createTapGestureToFocus {
	UITapGestureRecognizer* focusRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusPhoto:)];
	//    self.takePhotoGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
	//focusRecognizer.numberOfTapsRequired = 2;
	focusRecognizer.cancelsTouchesInView =  NO;
	[focusRecognizer setDelegate:self.verbatmCameraView];
	[self.verbatmCameraView addGestureRecognizer:focusRecognizer];
}

-(void) createPinchGestureToZoom {
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomPreview:)];
	[pinchRecognizer setDelegate:self.verbatmCameraView];
	[self.verbatmCameraView addGestureRecognizer:pinchRecognizer];
}

#pragma mark Other Initialization
-(void) setDelegates
{
	self.sessionManager.delegate = self;
}

-(void)registerForNotifications {

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(positionContainerView)
												 name:UIDeviceOrientationDidChangeNotification
											   object: [UIDevice currentDevice]];

	//for postitioning the blurView when the orientation of the device changes
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

//Tells the screen to hide the status bar
- (BOOL)prefersStatusBarHidden
{
	return YES;
}

-(void) removeStatusBar {
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
		// iOS 7
		[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
	} else {
		// iOS 6
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	}
}


#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	// TODO: dispose of any resources that can be recreated
	[super didReceiveMemoryWarning];
}


#pragma mark - Capture Media

- (IBAction)tappedPhotoButton:(id)sender {
	if(self.isTakingVideo) {
		[self endVideoRecordingSession];
	} else {
		[self takePhoto:sender];
	}
}

- (IBAction) takePhoto:(id)sender
{
	[self.sessionManager captureImage: !self.canRaise];
	[self freezeFrame];
}

-(void) takeVideo:(UILongPressGestureRecognizer*)sender {

	if(!self.isTakingVideo && sender.state == UIGestureRecognizerStateBegan){
		self.isTakingVideo = YES;
		[self.sessionManager startVideoRecordingInOrientation:[UIDevice currentDevice].orientation];
		[self createCircleVideoProgressView];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:NUM_VID_SECONDS target:self selector:@selector(endVideoRecordingSession) userInfo:nil repeats:NO];
		[self.capturePicButton setImage:[UIImage imageNamed:RECORDING_IMAGE] forState:UIControlStateNormal];

	}
}

-(void) endVideoRecordingSession {

	if(!self.circle) return;
	self.isTakingVideo = NO;
	[self.sessionManager stopVideoRecording];
	[self clearCircleVideoProgressView];  //removes the video progress bar
	[self.capturePicButton setImage:[UIImage imageNamed:CAMERA_BUTTON_IMAGE] forState:UIControlStateNormal];
	[self.timer invalidate];
	self.timer = nil;
	[self freezeFrame];
}

// When a photo is taken "freeze" it on the screen) for a short period of time before removing it
-(void)freezeFrame {
	self.sessionManager.videoPreview.connection.enabled = NO;
	[NSTimer scheduledTimerWithTimeInterval:TIME_FOR_SESSION_TO_RESUME_POST_MEDIA_CAPTURE target:self selector:@selector(resumeSession:) userInfo:nil repeats:NO];
}

// Resume session after freezing frame on taking picture/video
-(void)resumeSession:(NSTimer*)timer {
	self.sessionManager.videoPreview.connection.enabled = YES;
	[timer invalidate];
}

// Create circle view showing video progress
-(void) createCircleVideoProgressView {

	self.circle = [[CAShapeLayer alloc]init];
	[self animateVideoProgressPath];
	self.circle.frame = self.view.bounds;
	self.circle.fillColor = [UIColor clearColor].CGColor;
	self.circle.strokeColor = [UIColor colorWithRed:1.f green:0.f blue:0.f alpha:PROGRESS_CIRCLE_OPACITY].CGColor;
	self.circle.lineWidth = PROGRESS_CIRCLE_THICKNESS;
	[self.view.layer addSublayer:self.circle];

	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	animation.duration = NUM_VID_SECONDS;
	animation.fromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	[self.circle addAnimation:animation forKey:@"strokeEnd"];

}

// Animate circle view showing video progress
-(void) animateVideoProgressPath {

	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint center = CGPointMake((self.view.frame.size.width)/2.f, self.view.frame.size.height - CAMERA_BUTTON_Y_OFFSET - CAMERA_BUTTON_SIZE/2.f);
	CGRect frame = CGRectMake(center.x - PROGRESS_CIRCLE_SIZE/2.f, center.y -PROGRESS_CIRCLE_SIZE/2.f, PROGRESS_CIRCLE_SIZE, PROGRESS_CIRCLE_SIZE);
	float midX = CGRectGetMidX(frame);
	float midY = CGRectGetMidY(frame);
	CGAffineTransform t = CGAffineTransformConcat(
												  CGAffineTransformConcat(
																		  CGAffineTransformMakeTranslation(-midX, -midY),
																		  CGAffineTransformMakeRotation(-(M_PI/2.f))),
												  CGAffineTransformMakeTranslation(midX, midY));
	CGPathAddEllipseInRect(path, &t, frame);
	self.circle.path = path;
}

-(void) clearCircleVideoProgressView {
	[self.circle removeFromSuperlayer];
	self.circle = nil;
}


#pragma mark - Actions to enhance the camera view

-(void) focusPhoto: (UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		CGPoint point = [sender locationInView:self.verbatmCameraView];

		// focus square animation
		if (self.focusSquare)
		{
			[self.focusSquare removeFromSuperview];
		}
		self.focusSquare = [[CameraFocusSquare alloc]initWithFrame:CGRectMake(point.x-40, point.y-40, 80, 80)];
		[self.focusSquare setBackgroundColor:[UIColor clearColor]];
		[self.verbatmCameraView addSubview:self.focusSquare];
		[self.focusSquare setNeedsDisplay];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.5];
		[self.focusSquare setAlpha:0.0];
		[UIView commitAnimations];

		[self.sessionManager focusAtPoint:point];
	}
}

- (void) zoomPreview:(UIPinchGestureRecognizer *)recognizer {
	float scale = self.verbatmCameraView.beginGestureScale * recognizer.scale;
	self.verbatmCameraView.effectiveScale = scale > 1.0f ? scale : 1.0f;
	[self.sessionManager zoomPreviewWithScale:self.verbatmCameraView.effectiveScale];
}


#pragma mark - Change size of container view based on orientation

-(void)positionContainerView {
	if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
	   && ![self.contentContainerView isHidden] && !self.canRaise) {

		if (self.contentDevVC.openEditContentView && self.contentDevVC.openEditContentView.textView
			&& self.contentContainerViewMode == ContentContainerViewModeFullScreen) {
			return;
		}

		[self positionContainerViewLandscape];

	} else if([self.contentContainerView isHidden] && !self.canRaise) {
		self.contentContainerView.hidden = NO;

		[UIView animateWithDuration:0.5 animations:^{
			[self transitionContentContainerViewToMode:self.previousMode];
		}];
	}
}

-(void) positionContainerViewLandscape {
	[UIView animateWithDuration:0.5 animations:^{

		self.previousMode = self.contentContainerViewMode;

		int containerY = -1 * self.contentContainerView.frame.size.height;
		self.contentContainerView.frame = CGRectMake(0, containerY, self.contentContainerView.frame.size.width, self.contentContainerView.frame.size.height);

		int pullBarY = -1 * self.pullBar.frame.size.height;
		self.pullBar.frame = CGRectMake(0,pullBarY, self.pullBar.frame.size.width, self.pullBar.frame.size.height);;

	} completion:^(BOOL finished) {
		if(finished)
		{
			self.contentContainerView.hidden = YES;
			[self.contentDevVC removeKeyboardFromScreen];
		}
	}];
}


#pragma mark - Transition container view and pull bar

//Sets the content container view to the appropriate frame, sets the pull bar mode,
//and sets whether the content container view is scrollable
-(void) transitionContentContainerViewToMode: (ContentContainerViewMode) mode {

	[UIView animateWithDuration:CONTAINER_VIEW_TRANSITION_ANIMATION_TIME animations:^{
		self.contentContainerViewMode = mode;
		if(mode == ContentContainerViewModeFullScreen) {
			//makes sure content view is scrollable
			[self.contentDevVC setMainScrollViewEnabled:YES];
			self.contentContainerView.frame = self.contentContainerViewFrameBottom;
			[self pullBarTransitionToMode:PullBarModeMenu];

		}else if (mode == ContentContainerViewModeBase) {
			//makes sure content view is not scrollable
			[self.contentDevVC setMainScrollViewEnabled:NO];
			self.contentContainerView.frame = self.contentContainerViewFrameTop;
			[self pullBarTransitionToMode:PullBarModePullDown];
		}
	}];
}

// Moving pull bar gesture sensed
- (IBAction)expandContentPage:(UIPanGestureRecognizer *)sender {
	switch(sender.state) {
		case UIGestureRecognizerStateBegan: {
			if (self.isTakingVideo) {
				[self endVideoRecordingSession];
			}
			break;
		}
		case UIGestureRecognizerStateChanged: {
			[self expandContentPageChanged:sender];
			break;
		}
		case UIGestureRecognizerStateEnded: {
			[self expandContentPageEnded:sender];
			break;
		}
		default: {
			return;
		}
	}
}

// Handles the user continuing to pull the pull bar
-(void)expandContentPageChanged:(UIPanGestureRecognizer *)sender{
	// How far has the transition come
	CGPoint translation = [sender translationInView:self.pullBar.superview];
	int newtranslation = translation.y-self.previousTranslation.y;
	float pullBarHeight = self.pullBar.frame.size.height;
	float contentViewHeight = self.contentContainerView.frame.size.height + newtranslation;

	//pull bar is being moved up, immediately remove buttons
	if(translation.y < 0.f && (self.pullBar.mode == PullBarModeMenu)) {
		[self.pullBar switchToMode:PullBarModePullDown];
		pullBarHeight = PULLBAR_HEIGHT_PULLDOWN_MODE;
		contentViewHeight = contentViewHeight - (PULLBAR_HEIGHT_MENU_MODE-PULLBAR_HEIGHT_PULLDOWN_MODE);
	}

	CGRect newPullBarFrame = CGRectMake(self.pullBar.frame.origin.x, self.pullBar.frame.origin.y + newtranslation, self.view.frame.size.width, pullBarHeight);
	CGRect newContentContainerViewFrame = CGRectMake(self.contentContainerView.frame.origin.x, self.contentContainerView.frame.origin.y, self.view.frame.size.width, contentViewHeight);

	self.pullBar.frame = newPullBarFrame;
	self.contentContainerView.frame = newContentContainerViewFrame;
	self.previousTranslation = translation;
}

// snaps the content container view into base or full screen
// (depending on direction of pull and if user has pulled far enough)
-(void) expandContentPageEnded:(UIPanGestureRecognizer *)sender{
	//how far has the transition come
	CGPoint translation = [sender translationInView:self.pullBar.superview];

	[UIView animateWithDuration:CONTAINER_VIEW_TRANSITION_ANIMATION_TIME animations:^{
		//snap the container view to full screen, else snap back to base
		if( translation.y > TRANSLATION_CONTENT_DEV_CONTAINER_VIEW_THRESHOLD) {
			[self transitionContentContainerViewToMode:ContentContainerViewModeFullScreen];
		}else {
			[self transitionContentContainerViewToMode:ContentContainerViewModeBase];
		}
	}];

	self.previousTranslation = CGPointMake(0, 0);//sanitize the translation difference so that the next round is sent back up
}

// Sets pull bar to mode and changes its frame based on mode
-(void) pullBarTransitionToMode: (PullBarMode) mode {

	[UIView animateWithDuration:CONTAINER_VIEW_TRANSITION_ANIMATION_TIME animations:^
	 {
		 if (mode == PullBarModeMenu) {
			 self.pullBar.frame = self.pullBarFrameBottom;
		 } else {
			 self.pullBar.frame = self.pullBarFrameTop;
		 }
		 [self.pullBar switchToMode:mode];
	 }];
}

#pragma mark - Change pull bar Delegate Methods (for pullbar) -



-(void)canUndo:(BOOL)canUndo {
	if (canUndo) {
		[self.pullBar unGrayOutUndo];
	} else {
		[self.pullBar grayOutUndo];
	}
}

-(void)canPreview:(BOOL)canPreview {
	if (canPreview) {
		[self.pullBar unGrayOutPreview];
	} else {
		[self.pullBar grayOutPreview];
	}
}

#pragma mark - PullBar Delegate Methods (pullbar button actions)

-(void) showPullBar:(BOOL)showPullBar withTransition:(BOOL)withTransition {
	if (!withTransition) {
		[self showPullBar:showPullBar];
	} else {
		[UIView animateWithDuration:PULLBAR_TRANSITION_ANIMATION_TIME animations:^{
			[self showPullBar:showPullBar];
		}];
	}
}

-(void) showPullBar:(BOOL)showPullBar {
	if (showPullBar) {
		self.pullBar.frame = self.pullBarFrameBottom;
	} else {
		self.pullBar.frame = self.pullBarFrameOffScreen;
	}
}

-(void) undoButtonPressed {
	[self.contentDevVC undoTileDeleteSwipe];
}

-(void) pullUpButtonPressed {
	[self transitionContentContainerViewToMode:ContentContainerViewModeBase];
}

// Displays article preview from pinch objects
-(void) previewButtonPressed {
	[self.contentDevVC closeAllOpenCollections];

	NSArray *pinchViews = [self getPinchViewsFromContentDev];

	if(![pinchViews count]) {
		NSLog(@"Can't preview with no pinch views");
		return;
	}

	[self.delegate previewPOVFromPinchViews: pinchViews];
}

-(NSArray*) getPinchViewsFromContentDev {
	NSMutableArray *pinchViews = [[NSMutableArray alloc]init];
	for(ContentPageElementScrollView* elementScrollView in [self.contentDevVC pageElementScrollViews]) {
		if ([elementScrollView.pageElement isKindOfClass:[PinchView class]]) {
			[pinchViews addObject:[elementScrollView pageElement]];
		}
	}
	return pinchViews;
}

#pragma mark - Publishing POV -

-(void) publishPOV {

	//make sure we have an article title, and that we have multiple pinch elements in the deck

	if (![self.contentDevVC.articleTitleField.text length]) {
		//TODO: animation telling them to enter a title

	} else {
		NSArray *pinchViewsArray = [self getPinchViewsFromContentDev];

		if(![pinchViewsArray count]) {
			NSLog(@"Can't publish with no pinch objects");
			return;
		}
		[POVPublisher publishPOVFromPinchViews: pinchViewsArray];
		//TODO: Transition to feed

		[[UserPinchViews sharedInstance] clearPinchViews];
		[self.contentDevVC cleanUp];
	}
}

// NOT IN USE
-(void) publishArticleContentToParse:(NSArray*)pinchObjectsArray {
	//this creates and saves an article. the return value is unnecesary
	Article * newArticle = [[Article alloc]initAndSaveWithTitle:self.contentDevVC.articleTitleField.text  andSandWichWhat:self.contentDevVC.sandwichWhat.text  Where:self.contentDevVC.sandwichWhere.text andPinchObjects:pinchObjectsArray andIsTesting:NO];
	if(newArticle) {
		//TODO: exit content page
	}
}

#pragma mark - Lazy Instantiation -

-(MediaSessionManager*)sessionManager{
	if(!_sessionManager){
		_sessionManager = [[MediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
	}
	return _sessionManager;
}

//creates the camera view with the preview session
-(VerbatmCameraView*) verbatmCameraView {
	if(!_verbatmCameraView){
		_verbatmCameraView = [[VerbatmCameraView alloc] initWithFrame: self.view.frame];
	}
	return _verbatmCameraView;
}

@end









