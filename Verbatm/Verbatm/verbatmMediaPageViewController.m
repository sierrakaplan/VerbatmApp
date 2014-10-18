//  verbatmMediaPageViewController.m
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmMediaPageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "verbatmMediaSessionManager.h"
#import "ILTranslucentView.h"
#import "verbatmContentPageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "testerTransitionDelegate.h"
#import "verbatmContentPageViewController.h"
#import "verbatmBlurBaseViewController.h"

@interface verbatmMediaPageViewController () <UITextFieldDelegate>
#pragma mark - Outlets -
@property (weak, nonatomic) IBOutlet UIView *cover_containerView; //the cover view for the container view that prevents any events from being sensed.


    //the outlets
    @property (weak, nonatomic) IBOutlet UITextField *whatSandwich;
    @property (weak, nonatomic) IBOutlet UITextField *whereSandwich;

#pragma mark - SubViews of screen-
    @property (weak, nonatomic) IBOutlet UIView *containerView;
    @property (strong, nonatomic) UIView *verbatmCameraView;
    @property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
    @property (strong, nonatomic) UIImageView* videoProgressImageView;

    @property(nonatomic) CGRect containerViewInitialFrame;

#pragma mark -Camera properties-
#pragma mark buttons
    @property (strong, nonatomic)UIButton* switchCameraButton;
    @property (strong, nonatomic)UIButton* switchFlashButton;
    @property (nonatomic) CGAffineTransform flashTransform;
    @property (nonatomic) CGAffineTransform switchTransform;


#pragma mark - view controllers
    @property (strong,nonatomic) verbatmContentPageViewController* vc_contentPage;


#pragma mark taking the photo
    @property (strong, nonatomic) UITapGestureRecognizer * takePhotoGesture;


    @property (nonatomic, strong) NSTimer *timer;
    @property (nonatomic) CGFloat counter;
    @property (nonatomic) BOOL flashOn;
    @property (nonatomic) BOOL canRaise;
    @property (nonatomic) CGPoint lastPoint;
    @property (nonatomic)CGPoint currentPoint;
    @property (nonatomic) UIDeviceOrientation startOrientation;


#pragma mark helpers for VCs
    #define ID_FOR_CONTENTPAGEVC @"contentPage"
    #define ID_FOR_BOTTOM_SPLITSCREENVC @"splitScreenBottomView"
    #define NUMBER_OF_VCS 2
    #define VC_TRANSITION_ANIMATION_TIME 0.3


#pragma mark helpers for VCs

    #define ALBUM_NAME @"Verbatm"
    #define ASPECT_RATIO 1
    #define MAX_VIDEO_LENGTH 20

#pragma mark snake color
    #define RGB_LEFT_SIDE 255,225,255, 0.7     //247, 0, 99, 1
    #define RGB_RIGHT_SIDE 255,225,255, 0.7
    #define RGB_BOTTOM_SIDE 255,225,255, 0.7
    #define RGB_TOP_SIDE 255,225,255, 0.7

#pragma mark Camera/Flash icons
    #define CAMERA_ICON_FRONT @"camera_back"
    #define FLASH_ICON_ON @"lightbulb_final_OFF(white)"
    #define FLASH_ICON_OFF @"lightbulb_final_OFF(white)"

#pragma mark Camera/Flash Icon sizes
    #define SWITCH_ICON_SIZE 50
    #define FLASH_ICON_SIZE 50

#pragma mark Camera/Flash positions
    #define FLASH_START_POSITION  10, 0
    #define SWITCH_CAMERA_START_POSITION 260, 5

#pragma mark Session timer time
    #define TIME_FOR_SESSION_TO_RESUME 0.5

#pragma mark container view transitions
    #define CONTENT_PAGE_MINI_SCREEN @"contentPageMiniMode"
    #define CONTENT_PAGE_FULL_SCREEN @"contentPageFullMode"

@end

@implementation verbatmMediaPageViewController

#pragma mark - Synthesize-
@synthesize verbatmCameraView = _verbatmCameraView;
@synthesize sessionManager = _sessionManager;
@synthesize videoProgressImageView = _videoProgressImageView;
@synthesize timer = _timer;
@synthesize switchCameraButton = _switchCameraButton;


#pragma mark - Preparing View-
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareCameraView];
    //[self createAndInstantiateCameraButtons];
    self.containerViewInitialFrame = self.containerView.frame;
    self.containerView.alpha=0;
    self.cover_containerView.alpha=0;
    [self createAndInstantiateGestures];
    
    [self setPlaceholderColors];
    self.canRaise = NO;
    
    //updated by Iain
    [self setDelegates];
    self.whatSandwich.keyboardAppearance = UIKeyboardAppearanceDark;
    self.whereSandwich.keyboardAppearance = UIKeyboardAppearanceDark;
    
    //for postitioning the blurView when the orientation of the device changes
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionContainerView) name:UIDeviceOrientationDidChangeNotification object: [UIDevice currentDevice]];
    
    
    //remove the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    //register for keyboard events
    [self registerForKeyboardNotifications];
    
    //setting contentPage view controllers
    [self setContentPage_vc];
}

//Iain
-(void) prepareCameraView
{
    [self.view insertSubview: self.verbatmCameraView atIndex:0];
    self.sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
}

-(void)setContentPage_vc
{
    [self getContentPagevc];
    [self.containerView addSubview: self.vc_contentPage.view];
    self.vc_contentPage.containerViewFrame = self.containerView.frame;
}


//get the two independent controllers and save them
-(void) getContentPagevc
{
    self.vc_contentPage = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_CONTENTPAGEVC];

}



//Iain
-(void) createAndInstantiateGestures
{
    [self createTapGesture];
    [self createLongPressGesture];
}

//Iain
-(void) createAndInstantiateCameraButtons
{
    [self createSwitchCameraButton];
    [self createSwitchFlashButton];
}

//Iain
//Tells the screen to hide the status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//Iain
-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //get the view controllers in the storyboard and store them
}

//Iain
-(void) setDelegates
{
    //set yourself as the delegate for textfields
    self.whatSandwich.delegate = self;
    self.whereSandwich.delegate = self;
}

//gives the placeholders a white color
-(void) setPlaceholderColors
{
    if ([self.whatSandwich respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.whatSandwich.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.whatSandwich.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    if ([self.whereSandwich respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.whereSandwich.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.whereSandwich.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  creating views

//by Lucio
//creates the camera view with the preview session
-(UIView*)verbatmCameraView
{
    if(!_verbatmCameraView){
        _verbatmCameraView = [[UIView alloc]initWithFrame:  self.view.frame];
        //        _verbatmCameraView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;  //check this please!
    }
    return _verbatmCameraView;
}

//By Lucio
-(void)createSwitchCameraButton
{
    self.switchCameraButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setImage:[UIImage imageNamed:CAMERA_ICON_FRONT] forState:UIControlStateNormal];
    [self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_START_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
    [self.switchCameraButton addTarget:self action:@selector(switchFaces:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.switchCameraButton];
    self.switchTransform = self.switchCameraButton.transform;
}

//By Lucio
-(void)createSwitchFlashButton
{
    self.switchFlashButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchFlashButton setImage:[UIImage imageNamed:FLASH_ICON_OFF] forState:UIControlStateNormal];
    [self.switchFlashButton setFrame:CGRectMake(FLASH_START_POSITION, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
    [self.switchFlashButton addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    self.flashOn = NO;
    [self.view addSubview: self.switchFlashButton];
    self.flashTransform = self.switchFlashButton.transform;
}


#pragma mark creating gestures

//by Lucio
-(void) createTapGesture
{
    self.takePhotoGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    self.takePhotoGesture.numberOfTapsRequired = 1;
    self.takePhotoGesture.cancelsTouchesInView =  NO;
    [self.verbatmCameraView addGestureRecognizer:self.takePhotoGesture];
}

//by Lucio
-(void) createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(takeVideo:)];
    longPress.minimumPressDuration = 1;
    //longPress.cancelsTouchesInView = YES;
    [self.verbatmCameraView addGestureRecognizer:longPress];
}


//by Lucio
-(UIView*)videoProgressImageView
{
    if(!_videoProgressImageView){
        _videoProgressImageView =  [[UIImageView alloc] init];
        _videoProgressImageView.backgroundColor = [UIColor clearColor];
        _videoProgressImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    }
    return _videoProgressImageView;
}

#pragma mark -touch gesture selectors
//Lucio
- (IBAction)takePhoto:(id)sender
{
    CGPoint point = [self.takePhotoGesture locationInView:self.verbatmCameraView];
    if(point.y < (self.switchCameraButton.frame.origin.y+self.switchCameraButton.frame.size.height))return;
    
    [self.sessionManager captureImage: !self.canRaise];
    [NSTimer scheduledTimerWithTimeInterval:TIME_FOR_SESSION_TO_RESUME target:self selector:@selector(resumeSession) userInfo:nil repeats:NO];
}

//Lucio
-(void)freezeFrame
{
    [self.sessionManager stopSession];
    [NSTimer scheduledTimerWithTimeInterval:TIME_FOR_SESSION_TO_RESUME target:self selector:@selector(resumeSession) userInfo:nil repeats:NO];
}

//Lucio
-(void)resumeSession
{
    [self.sessionManager startSession];
}

//Lucio
-(void)prepareVideoProgressView
{
    if(!self.canRaise && !UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        self.videoProgressImageView.frame = CGRectMake(0,0,  self.view.frame.size.width, self.view.frame.size.height - self.containerViewInitialFrame.size.height);
    }else{
        self.videoProgressImageView.frame = self.verbatmCameraView.frame;
    }
    [self.verbatmCameraView addSubview: self.videoProgressImageView];
}

//Lucio
-(IBAction)takeVideo:(id)sender
{
    UILongPressGestureRecognizer* recognizer = (UILongPressGestureRecognizer*)sender;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self prepareVideoProgressView];
        [self.sessionManager startVideoRecordingInOrientation:[UIDevice currentDevice].orientation isHalScreen:!self.canRaise];
        self.counter = 0;
        self.startOrientation = [UIDevice currentDevice].orientation;
        switch (self.startOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.lastPoint = CGPointMake(0, self.videoProgressImageView.frame.size.height/2);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.lastPoint = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height/2);
                break;
            default:
                self.lastPoint = CGPointMake(self.videoProgressImageView.frame.size.width/2, 0);
                break;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(createProgressPath) userInfo:nil repeats:YES];
    }else{
        if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed ||
           recognizer.state == UIGestureRecognizerStateCancelled){
            if(self.counter)[self endVideoRecordingSession];
        }
    }
}

//Lucio
-(IBAction)switchFaces:(id)sender
{
    [self.sessionManager switchVideoFace];
}

-(IBAction)switchFlash:(id)sender
{
    [self.sessionManager switchFlash];
    if(self.flashOn){
        [self.switchFlashButton setImage: [UIImage imageNamed:FLASH_ICON_OFF]forState:UIControlStateNormal];
    }else{
        [self.switchFlashButton setImage: [UIImage imageNamed:FLASH_ICON_ON] forState:UIControlStateNormal];
    }
    self.flashOn = !self.flashOn;
}


#pragma mark - supporting methods for media

//Lucio
-(void)clearVideoProgressImage
{
    self.videoProgressImageView.image = nil;
}

//Lucio
-(void)createProgressPath
{
    self.counter += 0.05;
    UIGraphicsBeginImageContext(self.videoProgressImageView.frame.size);
    [self.videoProgressImageView.image drawInRect:self.videoProgressImageView.frame];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
    if(self.counter < MAX_VIDEO_LENGTH/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        switch (self.startOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.currentPoint = CGPointMake(0, (self.videoProgressImageView.frame.size.height/2)*(1 - (self.counter/ (MAX_VIDEO_LENGTH/8))) );
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width, (self.videoProgressImageView.frame.size.height/2)*(1 + self.counter/(MAX_VIDEO_LENGTH/8)));
                break;
            default:
                self.currentPoint = CGPointMake((self.videoProgressImageView.frame.size.width/2)*(1 + self.counter/ (MAX_VIDEO_LENGTH/8)),0);
                break;
        }
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else if (self.counter >= MAX_VIDEO_LENGTH/8 && self.counter < (MAX_VIDEO_LENGTH*3)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),RGB_LEFT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        switch (self.startOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width*((self.counter - (MAX_VIDEO_LENGTH/8))/(MAX_VIDEO_LENGTH*2/8)),0);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width*(1 - (self.counter - (MAX_VIDEO_LENGTH/8))/(MAX_VIDEO_LENGTH*2/8)),self.videoProgressImageView.frame.size.height);
                break;
            default:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH/8))/(MAX_VIDEO_LENGTH*2/8)));
                break;
        }
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*3)/8  && self.counter < (MAX_VIDEO_LENGTH*5)/8 ){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_TOP_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        switch (self.startOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH*3/8))/(MAX_VIDEO_LENGTH*2/8)));
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.currentPoint = CGPointMake(0, self.verbatmCameraView.frame.size.height*(1 - (self.counter - (MAX_VIDEO_LENGTH*3/8))/(MAX_VIDEO_LENGTH*2/8)));
                break;
            default:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width*(1 - (self.counter - (MAX_VIDEO_LENGTH*3/8))/ (MAX_VIDEO_LENGTH*2/8)), self.videoProgressImageView.frame.size.height);
                break;
        }
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*5)/8  && self.counter < (MAX_VIDEO_LENGTH*7)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_RIGHT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        switch (self.startOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width*(1 - (self.counter - (MAX_VIDEO_LENGTH*5/8))/(MAX_VIDEO_LENGTH*2/8) ),self.videoProgressImageView.frame.size.height);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width*((self.counter - (MAX_VIDEO_LENGTH*5)/8)/ (MAX_VIDEO_LENGTH*2/8)),0);
                break;
            default:
                self.currentPoint = CGPointMake(0, self.videoProgressImageView.frame.size.height - (self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH*5/8))/(MAX_VIDEO_LENGTH*2/8))));
                break;
        }
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        switch (self.startOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.currentPoint = CGPointMake(0,self.videoProgressImageView.frame.size.height - ((self.videoProgressImageView.frame.size.height/2)*(self.counter - ((MAX_VIDEO_LENGTH*7)/8))/(MAX_VIDEO_LENGTH/8)));
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width, (self.videoProgressImageView.frame.size.height/2)*(self.counter - ((MAX_VIDEO_LENGTH*7)/8))/(MAX_VIDEO_LENGTH/8));
                break;
            default:
                self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width/2*(self.counter - (MAX_VIDEO_LENGTH*7/8))/(MAX_VIDEO_LENGTH/8), 0);
                break;
        }
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }
    //CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 4.0), 20.0 , [UIColor yellowColor].CGColor);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.videoProgressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.lastPoint = self.currentPoint;
    UIGraphicsEndImageContext();
    if(self.counter >= MAX_VIDEO_LENGTH) [self endVideoRecordingSession];
}

//Lucio
-(void)endVideoRecordingSession
{
    [self.sessionManager stopVideoRecording];
    [self clearVideoProgressImage];  //removes the video progress bar
    [self.timer invalidate];
    self.counter = 0;
    [self freezeFrame];
    [self.videoProgressImageView removeFromSuperview];
}

#pragma mark -on device orientation

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


-(void)positionContainerView
{
    if( UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        if(!self.containerView.isHidden && !self.canRaise){
            [UIView animateWithDuration:0.5 animations:^{
                self.containerView.frame = CGRectMake(0, self.view.frame.size.height, self.containerView.frame.size.width, 0);
                //preferably use autolayout
                if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
                    NSLog(@"was here");
                    self.switchCameraButton.transform  = CGAffineTransformMakeRotation(M_PI_2);
                    self.switchFlashButton.transform = CGAffineTransformMakeRotation(M_PI_2);
                }else{
                    self.switchCameraButton.transform  = CGAffineTransformMakeRotation(-M_PI_2);
                    self.switchFlashButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
            } completion:^(BOOL finished) {
                if(finished) self.containerView.hidden = YES;
            }];
        }
    }else{
        if(self.containerView.hidden && !self.canRaise){
            self.containerView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.containerView.frame =  self.containerViewInitialFrame;
                self.switchCameraButton.transform = self.switchTransform;
                self.switchFlashButton.transform = self.flashTransform;
            }];
        }
    }

}

-(void)viewWillLayoutSubviews
{
    [self positionContainerView];
}



#pragma mark -Lazy instantiation-

-(verbatmMediaSessionManager*)sessionManager
{
    if(!_sessionManager){
        _sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    }
    return _sessionManager;
}




#pragma mark - Keyboard
//Iain
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	if(textField == self.whereSandwich)
    {

        [self.whereSandwich resignFirstResponder];
        
    }else if(textField == self.whatSandwich)
    {

        [self.whatSandwich resignFirstResponder];
    }
	return YES;
}
- (IBAction)revealKeyboard:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.containerView.alpha = 1;
        self.cover_containerView.alpha=1;
    }];
    if(![[self.vc_contentPage.pageElements lastObject] isKindOfClass: [UITextView class]]){
        [self.vc_contentPage createNewTextViewBelowView: [self.vc_contentPage.pageElements lastObject]];
    }
    UITextView* lastTextView = [self.vc_contentPage.pageElements lastObject];
    [lastTextView becomeFirstResponder];
    lastTextView.returnKeyType = UIReturnKeyDone;   //adds a d one button to the keyboard
    [[NSNotificationCenter defaultCenter] postNotificationName: CONTENT_PAGE_MINI_SCREEN object: self];
}

//Lucio
//This method registers the application for keyboard notifications. UIKeyboardWillShowNotification and UIKeyboardWillHideNotification are listened for.
-(void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeWithdrawn:) name:UIKeyboardWillHideNotification object:nil];
}



//Lucio
//moves the transparent view up when the keyboard is about to appear
-(void)keyboardWillBeWithdrawn:(NSNotification*)aNotification
{
    self.containerView.alpha = 0;
    self.cover_containerView.alpha=0;
    [[NSNotificationCenter defaultCenter] postNotificationName: CONTENT_PAGE_FULL_SCREEN object: self];
}




#pragma mark - Textfields
//Iain
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //S@nwiches shouldn't have any spaces between them
    if([string isEqualToString:@" "]) return NO;
    return YES;
}
@end









