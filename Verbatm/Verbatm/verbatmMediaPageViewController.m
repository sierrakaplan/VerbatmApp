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
@property (strong, nonatomic) UIImageView* blurrFilter;


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
#define FLASH_START_POSITION  10, 12
#define FLASH_ROTATED_POSITION 20, 8
#define SWITCH_CAMERA_START_POSITION 260, 20
#define SWITCH_CAMERA_ROTATED_POSITION 480, 22
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
    [self.view addSubview: self.verbatmCameraView];
    self.sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    [self.view addSubview: self.videoProgressImageView];
    [self blurrView: self.blurrFilter];
    [self.view addSubview:self.blurrFilter];
    [self.view addSubview: self.blurrFilter];
    //[self createSlideDownGesture];
    //[self createSlideUpGesture];
    [self createTapGesture];
    [self createLongPressGesture];
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
//creates the camera view with the preview session
-(UIView*)verbatmCameraView
{
    if(!_verbatmCameraView){
        _verbatmCameraView = [[UIView alloc]initWithFrame:  self.view.frame];
        _verbatmCameraView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;  //check this please!
    }
    return _verbatmCameraView;
}

-(UIView*)blurrFilter
{
    if(!_blurrFilter){
        CGRect frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
        _blurrFilter = [[UIImageView alloc] initWithFrame:frame];
        _blurrFilter.backgroundColor = [UIColor clearColor];
    }
    return _blurrFilter;
}

//By Lucio
-(void)createSwitchCameraButton
{
    self.switchCameraButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setImage:[UIImage imageNamed:CAMERA_ICON_FRONT] forState:UIControlStateNormal];
    [self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_START_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
    [self.switchCameraButton addTarget:self action:@selector(switchFaces:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.switchCameraButton];
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
}


#pragma mark -creating gestures

//by Lucio
-(void) createTapGesture
{
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    self.tap.numberOfTapsRequired = 1;
    self.tap.cancelsTouchesInView =  NO;
    [self.videoProgressImageView addGestureRecognizer:self.tap];
}

//by Lucio
-(void) createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(takeVideo:)];
    longPress.minimumPressDuration = 1;
    longPress.cancelsTouchesInView = NO;
    [self.videoProgressImageView addGestureRecognizer:longPress];
}

//by Lucio
-(void)createSlideDownGesture
{
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendScreen:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.blurrFilter addGestureRecognizer:swipeDownGesture];
}

//by Lucio
-(void)createSlideUpGesture
{
    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(raiseVideoPreviewScreen:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.verbatmCameraView addGestureRecognizer:swipeUpGesture];
}

//by Lucio
-(UIView*)videoProgressImageView
{
    if(!_videoProgressImageView){
        _videoProgressImageView =  [[UIImageView alloc] init];
        _videoProgressImageView.backgroundColor = [UIColor clearColor];
        _videoProgressImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    }
    return _videoProgressImageView;
}

#pragma mark -touch gesture selectors
//Lucio
- (IBAction)takePhoto:(id)sender
{
    CGPoint point = [self.tap locationInView:self.verbatmCameraView];
    if(point.y < (self.switchCameraButton.frame.origin.y+self.switchCameraButton.frame.size.height))return;
    
    [self.sessionManager captureImage];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(freezeFrame) userInfo:nil repeats:NO];
}

-(void)freezeFrame
{
    [self.sessionManager stopSession];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(resumeSession) userInfo:nil repeats:NO];
}

-(void)resumeSession
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
        self.lastPoint = CGPointMake(self.videoProgressImageView.frame.size.width/2, self.videoProgressImageView.frame.size.height);
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
            [self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_ROTATED_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
            [self.switchFlashButton setFrame: CGRectMake(FLASH_ROTATED_POSITION, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
        }else{
            if(self.extended)self.verbatmCameraView.frame = self.view.frame;
            [self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_START_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
            [self.switchFlashButton setFrame: CGRectMake(FLASH_START_POSITION, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
        }
        [self.sessionManager setSessionOrientationToDeviceOrientation];
        [self.sessionManager setToFrameOfView:self.verbatmCameraView];
        self.videoProgressImageView.frame = self.verbatmCameraView.frame;
        [self.blurrFilter removeFromSuperview];
    }];
}

//by Lucio
-(IBAction)raiseVideoPreviewScreen:(id)sender
{
    BOOL canRaise = self.videoProgressImageView.frame.size.height < self.verbatmCameraView.frame.size.height;
    self.extended = NO;
    if(canRaise){
        [UIView animateWithDuration:0.05 animations:^{
            self.videoProgressImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
            self.blurrFilter.frame = CGRectMake(0, self.view.frame.size.height - self.view.frame.size.width, self.view.frame.size.width, self.view.frame.size.width);
            [self.verbatmCameraView addSubview:self.blurrFilter];
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

-(void)blurrView:(UIImageView*)myView
{
    CGRect boundary = myView.bounds;
    UIGraphicsBeginImageContextWithOptions(boundary.size, YES, [UIScreen mainScreen]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.sessionManager.videoPreview renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //Blur the image
    CIImage *blurImg = [CIImage imageWithCGImage:capturedImage.CGImage];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:blurImg forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    
    CIContext* acontext = [CIContext contextWithOptions:nil];
    CGImageRef cgImg = [acontext createCGImage:gaussianBlurFilter.outputImage fromRect:[blurImg extent]];
    UIImage *outputImg = [UIImage imageWithCGImage:cgImg];

    [myView setImage:outputImg];
}


@end
