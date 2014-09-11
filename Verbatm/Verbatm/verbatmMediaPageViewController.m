//
//  verbatmMediaPageViewController.m
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmMediaPageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "verbatmMediaSessionManager.h"

@interface verbatmMediaPageViewController ()

@property (strong, nonatomic) UIView *verbatmCameraView;
@property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat counter;
@property (strong, nonatomic)UIButton* switchCameraButton;
@property (strong, nonatomic)UIButton* switchFlashButton;
@property (nonatomic) BOOL flashOn;
@property (nonatomic) BOOL extended;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic)CGPoint currentPoint;
@property (nonatomic, strong) UIView* imageSlider;

@property (strong, nonatomic) UITapGestureRecognizer * tap;

#define ALBUM_NAME @"Verbatm"
#define ASPECT_RATIO 1               
#define RGB_LEFT_SIDE 255,223,0, 0.7     //247, 0, 99, 1
#define RGB_RIGHT_SIDE 255,223,0, 0.7
#define RGB_BOTTOM_SIDE 255,223,0, 0.7
#define RGB_TOP_SIDE 255,223,0, 0.7
#define MAX_VIDEO_LENGTH 30
#define CAMERA_ICON_FRONT @"camera_final_consolidated"
#define SWITCH_ICON_SIZE 60
#define FLASH_ICON_SIZE 60
#define FLASH_ICON_ON @"bulb_FINALANDFORALL_registered_ON(17pt)_one.bar.png"
#define FLASH_ICON_OFF @"bulb_FINALANDFORALL_registered_OFF(17pt)_one.bar.png"

@end

@implementation verbatmMediaPageViewController
@synthesize verbatmCameraView = _verbatmCameraView;
@synthesize sessionManager = _sessionManager;
@synthesize videoProgressImageView = _videoProgressImageView;
@synthesize timer = _timer;
@synthesize switchCameraButton = _switchCameraButton;
//@synthesize whiteLowerView = _whiteLowerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createImageSlider];
	[self createCameraView ];
    self.sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    [self createSlideDownGesture];
    [self createSlideUpGesture];
    [self createTapGesture];
    [self createLongPressGesture];
    [self createVideoProgressView];
    [self createSwitchCameraButton];
    [self createSwitchFlashButton];
    self.extended = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -initializing properties

-(verbatmMediaSessionManager*)sessionManager
{
    if(!_sessionManager){
        _sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    }
    return _sessionManager;
}

#pragma mark - creating views


//by Lucio
//creates the imageSlider
-(void)createImageSlider
{
    self.imageSlider = [[UIView alloc] init];
    [self.view addSubview: self.imageSlider];
}
//by Lucio
//creates the camera view with the preview session
-(void)createCameraView
{
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width*ASPECT_RATIO);
    self.verbatmCameraView = [[UIView alloc]initWithFrame: frame];
    self.verbatmCameraView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.verbatmCameraView];
}

//By Lucio
-(void)createSwitchCameraButton
{
    self.switchCameraButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setImage:[UIImage imageNamed:CAMERA_ICON_FRONT] forState:UIControlStateNormal];
    [self.switchCameraButton setFrame:CGRectMake(260, 20, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
    [self.switchCameraButton addTarget:self action:@selector(switchFaces:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.switchCameraButton];
}

//By Lucio
-(void)createSwitchFlashButton
{
    self.switchFlashButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchFlashButton setImage:[UIImage imageNamed:FLASH_ICON_OFF] forState:UIControlStateNormal];
    [self.switchFlashButton setFrame:CGRectMake(10, 12, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
    [self.switchFlashButton addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    self.flashOn = NO;
    [self.view addSubview: self.switchFlashButton];
}


#pragma mark -creating gestures

//by Lucio
-(void) createTapGesture
{
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    self.tap.numberOfTapsRequired = 1;
    [self.verbatmCameraView addGestureRecognizer:self.tap];
}

//by Lucio
-(void) createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(takeVideo:)];
    longPress.minimumPressDuration = 1;
    [self.verbatmCameraView addGestureRecognizer:longPress];
}

//by Lucio
-(void)createSlideDownGesture
{
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendScreen:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.verbatmCameraView addGestureRecognizer:swipeDownGesture];
}

//by Lucio
-(void)createSlideUpGesture
{
    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(raiseVideoPreviewScreen:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.verbatmCameraView addGestureRecognizer:swipeUpGesture];
}

//by Lucio
-(void)createVideoProgressView
{
    self.videoProgressImageView =  [[UIImageView alloc] initWithImage:nil];
    self.videoProgressImageView.backgroundColor = [UIColor clearColor];
    self.videoProgressImageView.frame = self.verbatmCameraView.frame;
    [self.view addSubview: self.videoProgressImageView];
}

#pragma mark -touch gesture selectors
//Lucio
- (IBAction)takePhoto:(id)sender
{
    CGPoint point = [self.tap locationInView:self.verbatmCameraView];
    if(point.y < (self.switchCameraButton.frame.origin.y+self.switchCameraButton.frame.size.height))return;
    
    [self.sessionManager captureImage];
    [self.sessionManager stopSession];
}

-(void)settingImage
{
    [self.sessionManager startSession];
}

//Lucio
-(IBAction)takeVideo:(id)sender
{
    UILongPressGestureRecognizer* recognizer = (UILongPressGestureRecognizer*)sender;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self.sessionManager startVideoRecording];
        self.counter = 0;
        self.lastPoint = CGPointMake(self.verbatmCameraView.frame.size.width/2, self.verbatmCameraView.frame.size.height);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(createProgressPath) userInfo:nil repeats:YES];
    }else{
        if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed ||
           recognizer.state == UIGestureRecognizerStateCancelled){
            [self.sessionManager stopVideoRecording];
            [self clearVideoProgressImage];  //removes the video progress bar
            [self.timer invalidate];
            self.counter = 0;
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

//Lucio
-(IBAction)extendScreen:(id)sender
{
    self.extended = YES;
    [self changeImageScreenBounds];
}

//Lucio
-(void) changeImageScreenBounds
{
    [UIView animateWithDuration:0.5 animations:^{
        UIDevice* currentDevice = [UIDevice currentDevice];
        if(currentDevice.orientation == UIDeviceOrientationLandscapeRight|| [[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft){
            self.verbatmCameraView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
            [self.switchCameraButton setFrame:CGRectMake(480, 22, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
            [self.switchFlashButton setFrame: CGRectMake(20, 8, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
        }else{
            if(self.extended)self.verbatmCameraView.frame = self.view.frame;
            [self.switchCameraButton setFrame:CGRectMake(260, 20, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
            [self.switchFlashButton setFrame: CGRectMake(10, 8, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
        }
        [self.sessionManager setSessionOrientationToDeviceOrientation];
        [self.sessionManager setToFrameOfView:self.verbatmCameraView];
        self.videoProgressImageView.frame = self.verbatmCameraView.frame;
    }];
}

//by Lucio
-(IBAction)raiseVideoPreviewScreen:(id)sender
{
    BOOL canRaise = self.verbatmCameraView.frame.size.height == self.view.frame.size.height;
    self.extended = NO;
    if(canRaise){
        [UIView animateWithDuration:0.05 animations:^{
            self.verbatmCameraView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width*ASPECT_RATIO);
            [self.sessionManager setSessionOrientationToDeviceOrientation];
            [self.sessionManager setToFrameOfView:self.verbatmCameraView];
            self.videoProgressImageView.frame = self.verbatmCameraView.frame;
        }];
    }
}


#pragma mark - supporting methods for media 

//Lucio
-(void)clearVideoProgressImage
{
    self.videoProgressImageView.image = nil;
}

//by Lucio
-(void)slidePictureOut
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setDuration:0.5f];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [self.verbatmCameraView.layer addAnimation:animation forKey:NULL];
}

//Lucio
-(void)createProgressPath
{
    self.counter += 0.05;
    UIGraphicsBeginImageContext(self.videoProgressImageView.frame.size);
    [self.videoProgressImageView.image drawInRect:self.videoProgressImageView.frame];
    self.videoProgressImageView.frame = self.verbatmCameraView.frame;
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
    if(self.counter < MAX_VIDEO_LENGTH/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        self.currentPoint = CGPointMake((self.videoProgressImageView.frame.size.width/2)*(1 - (self.counter/ (MAX_VIDEO_LENGTH/8))), self.videoProgressImageView.frame.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else if (self.counter >= MAX_VIDEO_LENGTH/8 && self.counter < (MAX_VIDEO_LENGTH*3)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),RGB_LEFT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        self.currentPoint = CGPointMake(0, self.videoProgressImageView.frame.size.height - (self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH/8))/(MAX_VIDEO_LENGTH*2/8))));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*3)/8  && self.counter < (MAX_VIDEO_LENGTH*5)/8 ){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_TOP_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width*((self.counter - (MAX_VIDEO_LENGTH*3/8))/ (MAX_VIDEO_LENGTH*2/8)), 0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*5)/8  && self.counter < (MAX_VIDEO_LENGTH*7)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_RIGHT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH*5)/8)/ (MAX_VIDEO_LENGTH*2/8)));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x , self.lastPoint.y);
        self.currentPoint = CGPointMake(self.videoProgressImageView.frame.size.width - ((self.videoProgressImageView.frame.size.width/2)*(self.counter - ((MAX_VIDEO_LENGTH*7)/8))/(MAX_VIDEO_LENGTH/8)), self.videoProgressImageView.frame.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    }
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 4.0), 20.0 , [UIColor yellowColor].CGColor);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.videoProgressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.lastPoint = self.currentPoint;
    UIGraphicsEndImageContext();
}

#pragma mark -on device orientation
//Lucio
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

        [self changeImageScreenBounds];
}

@end
