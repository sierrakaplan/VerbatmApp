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
@property (strong, nonatomic) UIView *whiteLowerView;
@property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat counter;

#define ALBUM_NAME @"Verbatm"
#define ASPECT_RATIO 4/3
#define RGB_LEFT_SIDE 247, 0, 99, 1
#define RGB_RIGHT_SIDE 247, 0, 99, 1
#define RGB_BOTTOM_SIDE 247, 0, 99, 1
#define RGB_TOP_SIDE 247, 0, 99, 1
#define MAX_VIDEO_LENGTH 30
#define CAMERA_ICON @"switch_b"
#define SWITCH_ICON_SIZE 60
@end

@implementation verbatmMediaPageViewController
@synthesize verbatmCameraView = _verbatmCameraView;
@synthesize sessionManager = _sessionManager;
@synthesize videoProgressImageView = _videoProgressImageView;
@synthesize timer = _timer;
@synthesize whiteLowerView = _whiteLowerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createCameraView ];
    self.sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    [self createLongPressGesture];
    [self createSlideDownGesture];
    [self createSlideUpGesture];
    [self createTapGesture];
    [self createVideoProgressView];
    UIButton* overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:CAMERA_ICON] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(250, 10, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
    [overlayButton addTarget:self action:@selector(switchFaces:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:overlayButton];
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
//creates the camera view with the preview session
-(void)createCameraView
{
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width*ASPECT_RATIO);
    self.verbatmCameraView = [[UIView alloc]initWithFrame: frame];
    [self.view addSubview:self.verbatmCameraView];
    //extra to be taken out
    CGRect whiteViewFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.verbatmCameraView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.verbatmCameraView.frame.size.height);
    self.whiteLowerView = [[UIView alloc] initWithFrame:whiteViewFrame];
    [self.view addSubview: self.whiteLowerView];
}


#pragma mark -creating gestures

//by Lucio
-(void) createTapGesture
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    tap.numberOfTapsRequired = 1;
    [self.verbatmCameraView addGestureRecognizer:tap];
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
    NSLog(@"HERE");
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
    [self.sessionManager captureImage];
    [self slidePictureOut];
}

//Lucio
-(IBAction)takeVideo:(id)sender
{
    UITapGestureRecognizer* recognizer = [self.verbatmCameraView.gestureRecognizers objectAtIndex:1];
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self.sessionManager startVideoRecording];
        self.counter = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(createProgressPath) userInfo:nil repeats:YES];
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

//Lucio
-(IBAction)extendScreen:(id)sender
{
    [self changeImageScreenBounds];
}

//Lucio
-(void) changeImageScreenBounds
{
    [UIView animateWithDuration:0.5 animations:^{
        self.verbatmCameraView.frame = self.view.frame;
        UIDevice* currentDevice = [UIDevice currentDevice];
        if(currentDevice.orientation == UIDeviceOrientationLandscapeRight|| [[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft){
            self.verbatmCameraView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
        }
        [self.sessionManager setSessionOrientationToDeviceOrientation];
        [self.sessionManager setToFrameOfView:self.verbatmCameraView];
    }];
}

//by Lucio
-(IBAction)raiseVideoPreviewScreen:(id)sender
{
     NSLog(@"here");
    BOOL canRaise = self.verbatmCameraView.frame.size.height == self.view.frame.size.height;
    if(canRaise){
        NSLog(@"hrehrjeh");
        [UIView animateWithDuration:0.5 animations:^{
            self.verbatmCameraView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width*ASPECT_RATIO);
            [self.sessionManager setSessionOrientationToDeviceOrientation];
            [self.sessionManager setToFrameOfView:self.verbatmCameraView];
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
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 12.0);
    if(self.counter < MAX_VIDEO_LENGTH/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width/2, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake((self.videoProgressImageView.frame.size.width/2)*(1 - (self.counter/ (MAX_VIDEO_LENGTH/8))), self.videoProgressImageView.frame.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= MAX_VIDEO_LENGTH/8 && self.counter < (MAX_VIDEO_LENGTH*3)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),RGB_LEFT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(0, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(0, self.videoProgressImageView.frame.size.height - (self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH/8))/(MAX_VIDEO_LENGTH*2/8))));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*3)/8  && self.counter < (MAX_VIDEO_LENGTH*5)/8 ){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_TOP_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(0, 0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width*((self.counter - (MAX_VIDEO_LENGTH*3/8))/ (MAX_VIDEO_LENGTH*2/8)), 0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*5)/8  && self.counter < (MAX_VIDEO_LENGTH*7)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_RIGHT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width, 0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH*5)/8)/ (MAX_VIDEO_LENGTH*2/8)));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width - ((self.videoProgressImageView.frame.size.width/2)*(self.counter - ((MAX_VIDEO_LENGTH*7)/8))/(MAX_VIDEO_LENGTH/8)), self.videoProgressImageView.frame.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.videoProgressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark -on device orientation
//Lucio
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self changeImageScreenBounds];
}

@end
