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
#import "verbatmCustomPinchView.h"

@interface verbatmMediaPageViewController () <UITextFieldDelegate>
#pragma mark - Outlets -
    @property (weak, nonatomic) IBOutlet UIView *pullBar;//the outlets
    @property (weak, nonatomic) IBOutlet UITextField *whatSandwich;
    @property (weak, nonatomic) IBOutlet UITextField *whereSandwich;
    @property (weak, nonatomic) IBOutlet UIButton *raiseKeyboardButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

#pragma mark - SubViews of screen-
    @property (weak, nonatomic) IBOutlet UIView *containerView;
    @property (strong, nonatomic) UIView *verbatmCameraView;
    @property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
    @property (strong, nonatomic) UIImageView* videoProgressImageView;

    @property(nonatomic) CGRect containerViewNoMSAVFrame;
    @property (nonatomic) CGRect containerViewMSAVFrame;
    @property (nonatomic) CGRect pullBarNoMSAVFrame;
    @property (nonatomic) CGRect pullBarMSAVFrame;

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

#pragma mark  pulldown 
    @property (nonatomic) CGPoint panStartPoint;
    @property (nonatomic) CGPoint previousTranslation;
    @property (nonatomic) BOOL containerViewFullScreen;
    @property (nonatomic) BOOL containerViewMSAVMode;

#pragma mark keyboard properties
    @property (nonatomic) NSInteger keyboardHeight;



#pragma mark Filter helpers
#define FILTER_NOTIFICATION_ORIGINAL @"addOriginalFilter"
#define FILTER_NOTIFICATION_BW @"addBlackAndWhiteFilter"
#define FILTER_NOTIFICATION_WARM @"addWarmFilter"

#pragma mark helpers for VCs
    #define ID_FOR_CONTENTPAGEVC @"contentPage"
    #define ID_FOR_BOTTOM_SPLITSCREENVC @"splitScreenBottomView"
    #define NUMBER_OF_VCS 2
    #define VC_TRANSITION_ANIMATION_TIME 0.5


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

#pragma Transtition helpers
    #define TRANSITION_MARGIN_OFFSET 50
#define TRANSLATION_THRESHOLD 70

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
    
    //Register for notifications to show and remove the pullbar
    //Listen for when the keyboard is about to disappear
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePullBar)
                                                 name:@"Notification_shouldHidePullBar"
                                               object:nil];
    //Register for notifications to show and remove the pullbar
    //Listen for when the keyboard is about to disappear
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPullBar)
                                                 name:@"Notification_shouldShowPullBar"
                                               object:nil];
    
    
    
    //register for keyboard events
    [self registerForKeyboardNotifications];
    
    //setting contentPage view controllers
    [self setContentPage_vc];
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
    
    [self saveDefaultFrames];
    [self.vc_contentPage freeMainScrollView:NO];//makes sure the contentpage isn't scrolling


}


-(void) removeStatusBar
{
    //remove the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}


//saves the intitial frames for the pulldown bar and the container view
-(void)saveDefaultFrames
{
    self.containerViewNoMSAVFrame = self.containerView.frame;
    self.containerViewMSAVFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/6);
    self.pullBarNoMSAVFrame = self.pullBar.frame;
    self.pullBarMSAVFrame = CGRectMake(0, self.containerViewMSAVFrame.size.height , self.view.frame.size.width, self.pullBar.frame.size.height);
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
    self.vc_contentPage.pullBarHeight = self.pullBar.frame.size.height; // Sending the pullbar height over to
    
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
    self.sessionManager.delegate = self;
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
    [self.sessionManager captureImage: !self.canRaise];
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
        self.videoProgressImageView.frame = CGRectMake(0,0,  self.view.frame.size.width, self.view.frame.size.height - self.containerViewNoMSAVFrame.size.height);
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
        //[self prepareVideoProgressView];
        //just toke out the snake.... if it is required later it will be reset.
        [self.sessionManager startVideoRecordingInOrientation:[UIDevice currentDevice].orientation isHalScreen:!self.canRaise];
//        self.counter = 0;
//        self.startOrientation = [UIDevice currentDevice].orientation;
//        switch (self.startOrientation) {
//            case UIDeviceOrientationLandscapeRight:
//                self.lastPoint = CGPointMake(0, self.videoProgressImageView.frame.size.height/2);
//                break;
//            case UIDeviceOrientationLandscapeLeft:
//                self.lastPoint = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height/2);
//                break;
//            default:
//                self.lastPoint = CGPointMake(self.videoProgressImageView.frame.size.width/2, 0);
//                break;
//        }
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(createProgressPath) userInfo:nil repeats:YES];
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
//    [self freezeFrame];
    [self.videoProgressImageView removeFromSuperview];
}

#pragma mark -on device orientation

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


-(void)positionContainerView
{
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        if(!self.containerView.isHidden && !self.canRaise){
            [UIView animateWithDuration:0.5 animations:^{
                self.containerView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, 0);
                self.pullBar.frame = CGRectMake(0, 0, self.pullBar.frame.size.width, 0);;
                for(UIView* view in self.pullBar.subviews){
                    view.hidden = YES;
                }
                //preferably use autolayout
                if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
                    self.switchCameraButton.transform  = CGAffineTransformMakeRotation(M_PI_2);
                    self.switchFlashButton.transform = CGAffineTransformMakeRotation(M_PI_2);
                }else{
                    self.switchCameraButton.transform  = CGAffineTransformMakeRotation(-M_PI_2);
                    self.switchFlashButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
            } completion:^(BOOL finished) {
                if(finished){
                    self.containerView.hidden = YES;
                }
            }];
        }
    }else{
        if(self.containerView.hidden && !self.canRaise){
            self.containerView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                [self positionContainerViewTo:NO orTo:NO orTo:YES];//Positions the container view to the right frame
                [self positionPullBarTransitionDown:NO];//positions the pullbar to the right frame
                for(UIView* view in self.pullBar.subviews){
                    view.hidden = NO;
                }
//                self.switchCameraButton.transform = self.switchTransform;
//                self.switchFlashButton.transform = self.flashTransform;
            }];
        }
    }

}

-(void)viewWillLayoutSubviews
{
    [self positionContainerView];
}


#pragma mark - Lazy instantiation -

-(verbatmMediaSessionManager*)sessionManager
{
    if(!_sessionManager){
        _sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    }
    return _sessionManager;
}

#pragma mark - Transition 

//Move the pull bar down- gestures sensed
- (IBAction)expandContentPage:(UIPanGestureRecognizer *)sender
{
    
    if (sender.state==UIGestureRecognizerStateChanged)//finger is dragging
    {
        [self expandContentPage_Began:sender];
    }
    
    if(sender.state==UIGestureRecognizerStateEnded)
    {
        [self expandContentPage_Changed:sender];
    }
}

-(void)expandContentPage_Began:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.pullBar.superview]; //how far the transisiton has come
    
    int newtranslation = translation.y-self.previousTranslation.y;
    
    CGRect newFrame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height + newtranslation);
    
    CGRect newPullBarFrame = CGRectMake(self.pullBar.frame.origin.x, self.pullBar.frame.origin.y + newtranslation, self.pullBar.frame.size.width, self.pullBar.frame.size.height);
    
    //set frames of bar and
    self.pullBar.frame = newPullBarFrame;
    self.containerView.frame = newFrame;
    
    self.previousTranslation = translation;
}

//handles the user continuing to pull the pull bar
-(void) expandContentPage_Changed :(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.pullBar.superview]; //how far the transisiton has come

    if( translation.y > TRANSITION_MARGIN_OFFSET) //snap the container view to full screen
    {
        [UIView animateWithDuration:VC_TRANSITION_ANIMATION_TIME animations:^
         {
             [self positionContainerViewTo:YES orTo:NO orTo:NO];//Positions the container view to the right frame
             [self positionPullBarTransitionDown:YES];//positions the pullbar to the right frame
             
         }];
    }else
    {
        float fl = translation.y;
        if(/*gets the abs for a float*/fabsf(fl) > TRANSITION_MARGIN_OFFSET) //snap the container view back up to no MSAV
        {
            
            [UIView animateWithDuration:VC_TRANSITION_ANIMATION_TIME animations:^
             {
                 [self positionContainerViewTo:NO orTo:NO orTo:YES];//Sets the frame to base mode
                 [self positionPullBarTransitionDown:NO];

             }];
        }else
        {
            
            [UIView animateWithDuration:VC_TRANSITION_ANIMATION_TIME animations:^
             {
                 [self positionContainerViewTo:NO orTo:NO orTo:YES];//Sets the frame to base mode
                 [self positionPullBarTransitionDown:NO];
                 
             }];
        }
    }
    self.previousTranslation = CGPointMake(0, 0);//sanitize the translation difference so that the next round is sent back up
}

//sets the postion of the pull bar depending on what's happening on the screen
-(void) positionPullBarTransitionDown: (BOOL) transitionDown
{

    [UIView animateWithDuration:VC_TRANSITION_ANIMATION_TIME animations:^
     {
         if(transitionDown)
         {
             CGRect newPullBarFrame = CGRectMake(self.pullBar.frame.origin.x, self.view.frame.size.height - (self.pullBar.frame.size.height+self.keyboardHeight), self.pullBar.frame.size.width, self.pullBar.frame.size.height);
             self.pullBar.frame = newPullBarFrame;
         }else
         {
             if(self.containerViewMSAVMode)
             {
                 self.pullBar.frame = self.pullBarMSAVFrame;
                 
             }else
             {
                 self.pullBar.frame = self.pullBarNoMSAVFrame;
             }
             
         }
         
     }];
}


//Sets the container view to the appropriate frame
-(void) positionContainerViewTo:(BOOL) fullScreen orTo:(BOOL) MSAV orTo: (BOOL) Base
{
    [UIView animateWithDuration:VC_TRANSITION_ANIMATION_TIME animations:^
     {
        if(fullScreen)
        {
            CGRect newContainerFrame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.view.frame.size.height-self.pullBarNoMSAVFrame.size.height);//subtract the pullbar height so the container view is never behind it
            
            self.containerViewFullScreen = YES;
            self.containerViewMSAVMode = NO;
            [self.vc_contentPage freeMainScrollView:YES]; //makes sure it's scrollable
            self.containerView.frame = newContainerFrame;
        }else if (MSAV)
        {
            self.containerViewMSAVMode = YES;
            self.containerViewFullScreen = NO;
            self.containerView.frame= self.containerViewMSAVFrame;
        }else if (Base)
        {
            self.containerViewMSAVMode = NO;
            self.containerViewFullScreen = NO;
            self.containerView.frame = self.containerViewNoMSAVFrame;
            [self.vc_contentPage freeMainScrollView:NO]; //makes sure it's not scrollable and resets to offset 0
        }
         self.vc_contentPage.containerViewFrame = self.containerView.frame;
    }];
}


#pragma mark - Textfields
//Iain
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //S@nwiches shouldn't have any spaces between them
    if([string isEqualToString:@" "]) return NO;
    return YES;
}


#pragma mark - Keyboard-

- (IBAction)revealKeyboard:(id)sender
{
    if(!self.containerViewMSAVMode)
    {
        [self bringUpNewTextForMSAV];//brings up the new text view for the msav
        if(!self.containerViewFullScreen && !self.containerViewMSAVMode) self.containerViewMSAVMode=YES;
        [self positionPullBarTransitionDown:NO];
        //adjust the frame
        [self positionContainerViewTo:NO orTo:YES  orTo:NO];
        [self positionPullBarTransitionDown:NO];
        
    }else if (self.containerViewMSAVMode)
    {
        [self.vc_contentPage removeImageScrollview:nil];
        [self positionContainerViewTo:NO orTo:NO  orTo:YES];
        [self positionPullBarTransitionDown:NO];
    }
}

//Iain
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.whereSandwich)
    {
        
        [self.whereSandwich resignFirstResponder];
        
    }else if(textField == self.whatSandwich)
    {
        
        [self.whatSandwich resignFirstResponder];
    }
    return YES;
}


//finds the last
-(void) bringUpNewTextForMSAV
{
    verbatmCustomPinchView * last_textPinchView;
    
    //function backtracks from the end of the array
    for(long i = (self.vc_contentPage.pageElements.count -1); i>=0; i--)
    {
        if([self.vc_contentPage.pageElements[i]  isKindOfClass: [verbatmCustomPinchView class]])
        {
            
            verbatmCustomPinchView * pinch = (verbatmCustomPinchView *)self.vc_contentPage.pageElements[i];
            
            //breaks on the firs textview you find
            if(pinch.there_is_text && !pinch.there_is_picture && !pinch.there_is_video)
            {
                last_textPinchView = (verbatmCustomPinchView *) self.vc_contentPage.pageElements[i];
                break;
            }
        }
    }
    
    
    if(!last_textPinchView || ![[last_textPinchView getTextFromPinchObject] isEqualToString:@""])
    {
        
        int second_to_last_object = self.vc_contentPage.pageElements.count - 2;
        
        if(second_to_last_object >=0)
        {
            [self.vc_contentPage newPinchObjectBelowView:self.vc_contentPage.pageElements[second_to_last_object] fromView: nil isTextView:YES];
            
            [self.vc_contentPage createCustomImageScrollViewFromPinchView:self.vc_contentPage.pageElements[second_to_last_object+1] andImageView:nil orTextView:[[verbatmUITextView alloc]init]];
        
        
        }else if (second_to_last_object <0)
        {
            [self.vc_contentPage newPinchObjectBelowView:nil fromView: nil isTextView:YES];
            
            [self.vc_contentPage createCustomImageScrollViewFromPinchView:self.vc_contentPage.pageElements[0] andImageView:nil orTextView:[[verbatmUITextView alloc]init]];
        }
        
    }else if (last_textPinchView)
    {
        [self.vc_contentPage createCustomImageScrollViewFromPinchView:last_textPinchView andImageView:nil orTextView:[[verbatmUITextView alloc]init]];
    }
}


//Iain
//When keyboard appears get its height. This is only neccessary when the keyboard first appears
- (void)keyboardWasShown:(NSNotification *)notification
{
    self.raiseKeyboardButton.imageView.image = [UIImage imageNamed:@"key_trans"];//set keyboard button to transparent
}


-(void)keyboardWillShow: (NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
     self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    //Make sure the pullbar is in line with the keyboard
    if (self.containerViewFullScreen)[self positionPullBarTransitionDown:YES];
}


-(void) keyboardWillDisappear: (NSNotification *)notification
{
    self.keyboardHeight = 0;//sanitize keyboard height marker
    if(self.containerViewFullScreen)
    {
        [self positionPullBarTransitionDown:YES];//send the pull bar down now that the keyboard is leaving
    }else if(self.containerViewMSAVMode)
    {
        //now that the keyboard is leaving we should leave MSAV mode
        self.containerViewMSAVMode = NO;
        [self positionContainerViewTo:NO orTo:NO orTo:YES];//Sets the frame to base
        [self positionPullBarTransitionDown:NO];
    }
    self.raiseKeyboardButton.imageView.image = [UIImage imageNamed:@"key_whole"];//set the keyboard button to opaque
}



//Lucio
//This method registers the application for keyboard notifications. UIKeyboardWillShowNotification and UIKeyboardWillHideNotification are listened for.
-(void)registerForKeyboardNotifications
{
    
    //Tune in to get notifications of keyboard behavior
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //Listen for when the keyboard is about to disappear
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}






#pragma mark - delegate method for media session class -
-(void)didFinishSavingMediaToAsset:(ALAsset*)asset
{
    [self.vc_contentPage alertGallery: asset];
}


-(void)hidePullBar
{
    if(!self.pullBar.hidden)
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.containerView.frame = self.view.frame;
            self.pullBar.hidden = YES;
        }];
    }
}

-(void) showPullBar
{
    if(self.pullBar.hidden)
    {
       [UIView animateWithDuration:0.4 animations:^{
           self.pullBar.hidden = NO;
           [self positionContainerViewTo:YES orTo:NO orTo:NO];
       }];
    }
}

- (void)dealloc
{
    //tune out of nsnotification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end









