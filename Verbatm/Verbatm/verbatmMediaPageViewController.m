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
#import "v_Analyzer.h"
#import "articleDispalyViewController.h"
@interface verbatmMediaPageViewController () <UITextFieldDelegate>
#pragma mark - Outlets -
    @property (weak, nonatomic) IBOutlet UIView *pullBar;//the outlets
    @property (weak, nonatomic) IBOutlet UITextField *whatSandwich;
    @property (weak, nonatomic) IBOutlet UITextField *whereSandwich;
    @property (weak, nonatomic) IBOutlet UIButton *raiseKeyboardButton;

#pragma mark - SubViews of screen-
    @property (weak, nonatomic) IBOutlet UIView *containerView;
    @property (strong, nonatomic) UIView *verbatmCameraView;
    @property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
    @property (strong, nonatomic) CAShapeLayer* circle;

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
    @property (nonatomic) BOOL flashOn;
    @property (nonatomic) BOOL canRaise;
    @property (nonatomic)CGPoint currentPoint;
    @property (nonatomic) UIDeviceOrientation startOrientation;

#pragma mark  pulldown 
    @property (nonatomic) CGPoint panStartPoint;
    @property (nonatomic) CGPoint previousTranslation;
    @property (nonatomic) BOOL containerViewFullScreen;
    @property (nonatomic) BOOL containerViewMSAVMode;

#pragma mark keyboard properties
    @property (nonatomic) NSInteger keyboardHeight;

@property (nonatomic) CGRect oldPullBarFrame; //used when we hide the pullbar so we can restore it to what it was before

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
    #define TIME_FOR_SESSION_TO_RESUME 0.2
    #define NUM_VID_SECONDS 20

#pragma Transtition helpers
    #define TRANSITION_MARGIN_OFFSET 50
#define TRANSLATION_THRESHOLD 70
#define CIRCLE_PROGRESSVIEW_SIZE 100

#define NOTIFICATION_UNDO @"undoTileDeleteNotification"

@end

@implementation verbatmMediaPageViewController

#pragma mark - Synthesize-
@synthesize verbatmCameraView = _verbatmCameraView;
@synthesize sessionManager = _sessionManager;
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
    self.currentPoint = CGPointZero;
    
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

#pragma mark -touch gesture selectors
//Lucio
- (IBAction)takePhoto:(id)sender
{
    [self.sessionManager captureImage: !self.canRaise];
    [self freezeFrame];
}

//Lucio
-(void)freezeFrame
{
    UIView* dummyView = [[UIView alloc]initWithFrame: self.verbatmCameraView.frame];
    dummyView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:dummyView aboveSubview:self.verbatmCameraView];
    [NSTimer scheduledTimerWithTimeInterval:TIME_FOR_SESSION_TO_RESUME target:self selector:@selector(resumeSession:) userInfo:dummyView repeats:NO];
}

//Lucio
-(void)resumeSession:(NSTimer*)timer
{
    UIView* dummyView = (UIView*)timer.userInfo;
    [dummyView removeFromSuperview];
    [timer invalidate];
}



//Lucio
-(IBAction)takeVideo:(id)sender
{
    UILongPressGestureRecognizer* recognizer = (UILongPressGestureRecognizer*)sender;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self.sessionManager startVideoRecordingInOrientation:[UIDevice currentDevice].orientation];
        [self circleProgressViewAt:[sender locationInView: self.view]];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:NUM_VID_SECONDS target:self selector:@selector(endVideoRecordingSession) userInfo:nil repeats:NO];
    }else{
        if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed ||
           recognizer.state == UIGestureRecognizerStateCancelled){
            [self endVideoRecordingSession];
        }else{
            CGPoint center = [sender locationInView:self.view];
            [self createProgressPath:center];
        }
    }
}

-(void)circleProgressViewAt:(CGPoint)center
{
    self.circle = [[CAShapeLayer alloc]init];
    [self createProgressPath:center];
    self.circle.frame = self.view.bounds;
    self.circle.fillColor = [UIColor clearColor].CGColor;
    self.circle.strokeColor = [UIColor whiteColor].CGColor;
    self.circle.lineWidth = 15.0f;
    [self.view.layer addSublayer:self.circle];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 20.0f;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.circle addAnimation:animation forKey:@"strokeEnd"];

}

-(void)createProgressPath:(CGPoint)center
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect frame = CGRectMake(center.x - CIRCLE_PROGRESSVIEW_SIZE/2, center.y -CIRCLE_PROGRESSVIEW_SIZE/2, CIRCLE_PROGRESSVIEW_SIZE, CIRCLE_PROGRESSVIEW_SIZE);
    float midX = CGRectGetMidX(frame);
    float midY = CGRectGetMidY(frame);
    CGAffineTransform t = CGAffineTransformConcat(
                                                  CGAffineTransformConcat(
                                                                          CGAffineTransformMakeTranslation(-midX, -midY),
                                                                          CGAffineTransformMakeRotation(-1.57079633/0.99)),
                                                  CGAffineTransformMakeTranslation(midX, midY));
    CGPathAddEllipseInRect(path, &t, frame);
    self.circle.path = path;
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
    [self.circle removeFromSuperlayer];
    self.circle = nil;
}



//Lucio
-(void)endVideoRecordingSession
{
    if(!self.circle) return;
    [self.sessionManager stopVideoRecording];
    [self clearVideoProgressImage];  //removes the video progress bar
    [self freezeFrame];
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
            //gets rid of the text if there was typing going on
            [self.vc_contentPage removeImageScrollview:nil];
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
            self.oldPullBarFrame = self.pullBar.frame;
            self.pullBar.frame = CGRectMake(self.pullBar.frame.origin.x, self.view.frame.size.height, self.pullBar.frame.size.width, self.pullBar.frame.size.height);
            
        }];
    }
}

-(void) showPullBar
{
       [UIView animateWithDuration:0.4 animations:^{
        
           [self positionContainerViewTo:YES orTo:NO orTo:NO];

           if(self.oldPullBarFrame.origin.y >= self.view.frame.size.height)
           {
               self.pullBar.frame = CGRectMake(self.pullBar.frame.origin.x, self.view.frame.size.height - self.pullBar.frame.size.height, self.pullBar.frame.size.width, self.pullBar.frame.size.height);
   
           }else
           {
               self.pullBar.frame = self.oldPullBarFrame;

           }
           
       }];
}

//this makes sure that there are elements in the pinchview before a preview is called
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier
                                  sender:(id)sender
{
    
    if([identifier isEqualToString:@"previewVerbatmArticle"])
    {
        int counter=0;
        for(int i=0; i < self.vc_contentPage.pageElements.count; i++)
        {
            if([self.vc_contentPage.pageElements[i] isKindOfClass:[verbatmCustomPinchView class]])
            {
                counter ++;
            }
        }
        
        if(!counter) return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController * vc = [segue destinationViewController];
    NSMutableArray * pincObjetsArray = [[NSMutableArray alloc]init];
    
    for(int i=0; i < self.vc_contentPage.pageElements.count; i++)
    {
        if([self.vc_contentPage.pageElements[i] isKindOfClass:[verbatmCustomPinchView class]])
        {
            [pincObjetsArray addObject:self.vc_contentPage.pageElements[i]];
        }
    }
    v_Analyzer * analyser = [[v_Analyzer alloc]init];
    NSMutableArray * presenterViews = [analyser processPinchedObjectsFromArray:pincObjetsArray withFrame:self.view.frame];
    
    ((articleDispalyViewController *)vc).pinchedObjects = presenterViews;
}

#pragma mark - Undo Button -
- (IBAction)undo:(UIButton *)sender
{
    [self callNotifications];
}

-(void)callNotifications
{
    NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_UNDO object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


- (void)dealloc
{
    //tune out of nsnotification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end









