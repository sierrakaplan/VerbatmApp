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

@interface verbatmMediaPageViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet ILTranslucentView *blurView;
@property (strong, nonatomic) UIView *verbatmCameraView;
@property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat counter;
@property (strong, nonatomic)UIButton* switchCameraButton;
@property (strong, nonatomic)UIButton* switchFlashButton;
@property (nonatomic) BOOL flashOn;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic)CGPoint currentPoint;
@property (nonatomic) BOOL canRaise;
@property (nonatomic) int count;
@property (weak, nonatomic) IBOutlet UITextField *whatSandwich;
@property (weak, nonatomic) IBOutlet UITextField *whereSandwich;

@property (weak, nonatomic) IBOutlet UIButton *toContentPageSegue;


@property (strong, nonatomic) UITapGestureRecognizer * tap;


@property (strong, nonatomic) testerTransitionDelegate * testerTransitionDelegate;



#define ALBUM_NAME @"Verbatm"
#define ASPECT_RATIO 1
#define RGB_LEFT_SIDE 255,225,255, 0.7     //247, 0, 99, 1
#define RGB_RIGHT_SIDE 255,225,255, 0.7
#define RGB_BOTTOM_SIDE 255,225,255, 0.7
#define RGB_TOP_SIDE 255,225,255, 0.7
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
#define TIME_FOR_SESSION_TO_RESUME 0.6
#pragma mark Navigation property
#define CONTENT_PAGE_SEGUE @"moveToContenPage"
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
    self.count = 0;
    [super viewDidLoad];
    [self.view insertSubview: self.verbatmCameraView atIndex:0];
    self.sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    self.blurView.translucentStyle = UIBarStyleBlack;
    self.blurView.translucentAlpha = 1;
    [self createSlideDownGesture];
    [self createSlideUpGesture];
    [self createTapGesture];
    [self createLongPressGesture];
    [self createSwitchCameraButton];
    [self createSwitchFlashButton];
    [self setPlaceholderColors];
    self.canRaise = NO;
    
    //updated by Iain
    [self setDelegates];
    self.whatSandwich.keyboardAppearance = UIKeyboardAppearanceDark;
    self.whereSandwich.keyboardAppearance = UIKeyboardAppearanceDark;
    
    
    
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
        // TODO: Add fall-back code to set placeholder color.
    }
    if ([self.whereSandwich respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.whereSandwich.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.whereSandwich.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
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
    [self.verbatmCameraView addGestureRecognizer:self.tap];
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
-(void)createSlideDownGesture
{
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendScreen:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.blurView addGestureRecognizer:swipeDownGesture];
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
        _videoProgressImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    }
    return _videoProgressImageView;
}

#pragma mark -touch gesture selectors
//Lucio
- (IBAction)takePhoto:(id)sender
{
    CGPoint point = [self.tap locationInView:self.verbatmCameraView];
    if(point.y < (self.switchCameraButton.frame.origin.y+self.switchCameraButton.frame.size.height))return;
    
    [self.sessionManager captureImage: !self.canRaise];
    [NSTimer scheduledTimerWithTimeInterval:TIME_FOR_SESSION_TO_RESUME target:self selector:@selector(resumeSession) userInfo:nil repeats:NO];
}

-(void)freezeFrame
{
    [self.sessionManager stopSession];
    
}

-(void)resumeSession
{
    [self.sessionManager startSession];
}

-(void)prepareVideoProgressView
{
    if(!self.canRaise){
        self.videoProgressImageView.frame = CGRectMake(0,0,  self.view.frame.size.width, self.view.frame.size.height - self.blurView.frame.origin.y);
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
            [self.videoProgressImageView removeFromSuperview];
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
    [UIView animateWithDuration:0.5 animations:^{
        self.blurView.frame = CGRectMake(0, self.view.frame.size.height, self.blurView.frame.size.width, 0);
    }];
    self.canRaise = YES;
    
}

//by Lucio
-(IBAction)raiseVideoPreviewScreen:(id)sender
{
    if(self.canRaise){
        [UIView animateWithDuration:0.5 animations:^{
            self.blurView.frame =  CGRectMake(0, self.view.frame.size.height/2, self.blurView.frame.size.width, self.view.frame.size.height/2);
            [self.sessionManager setSessionOrientationToOrientation:[UIDevice currentDevice].orientation];
        }];
    }
    self.canRaise = NO;
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
    //CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 4.0), 20.0 , [UIColor yellowColor].CGColor);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.videoProgressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.lastPoint = self.currentPoint;
    UIGraphicsEndImageContext();
}

#pragma mark -on device orientation


-(NSUInteger)supportedInterfaceOrientations
{
    if(self.count >= 8){
        if([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait){
            if(!self.blurView.isHidden && !self.canRaise){
                [UIView animateWithDuration:0.5 animations:^{
                    self.blurView.frame = CGRectMake(0, self.view.frame.size.height, self.blurView.frame.size.width, 0);
                } completion:^(BOOL finished) {
                    if(finished) self.blurView.hidden = YES;
                }];
                
            }
        }else{
            if(self.blurView.hidden && !self.canRaise){
                self.blurView.hidden = NO;
                [UIView animateWithDuration:0.5 animations:^{
                    self.blurView.frame =  CGRectMake(0, self.view.frame.size.height/2, self.blurView.frame.size.width, self.view.frame.size.height/2);
                    [self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_START_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
                    [self.switchFlashButton setFrame: CGRectMake(FLASH_START_POSITION, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
                }];
            }
        }
    }
    self.count++;
    return UIInterfaceOrientationMaskPortrait;
    
}


#pragma mark - *Navigation
//Returning
//Iain
- (IBAction) goToRoot: (UIStoryboardSegue*) segue
{
    //set the s@andwhich to what was added in the screen before
    if(self.sandwhichWhat) self.whatSandwich.text = self.sandwhichWhat;
    if(self.sandwichWhere) self.whereSandwich.text = self.sandwichWhere;
    
    NSLog(@"Called goToRoot: unwind action");
}

//Leaving the split page
//Iain
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:CONTENT_PAGE_SEGUE])
    {
        verbatmContentPageViewController * vc = (verbatmContentPageViewController *) segue.destinationViewController;
        vc.sandWhichWhatString = self.whatSandwich.text;
        vc.sandWhichWhereString = self.whereSandwich.text;
        if(self.articleContent)vc.articleContentString = self.articleContent;
        if(self.articleTitle)vc.articleTitleString = self.articleTitle;
        if(self.contentPageElements) vc.pageElements = self.contentPageElements;
        vc.transitioningDelegate = self.testerTransitionDelegate;
        self.transitioningDelegate = self.testerTransitionDelegate;
    }
}

//Iain
//Move to content page OR remove bottom of dual page
- (IBAction)swipeUpSegueToContentPage:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction == UISwipeGestureRecognizerDirectionUp){
        //acts like the button has been pressed- so calls a modal segue
        [self.toContentPageSegue sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
}


#pragma mark - UI technicalities
//To be edited- adds a top shadow to the view that is sent
//Iain
-(void) addTopShadowToView: (UIView *) view
{
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowPath = shadowPath.CGPath;
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

#pragma mark - Textfields
//Iain
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //S@nwiches shouldn't have any spaces between them
    if([string isEqualToString:@" "]) return NO;
    return YES;
}



-(testerTransitionDelegate *) testerTransitionDelegate
{
    if(!_testerTransitionDelegate)_testerTransitionDelegate = [testerTransitionDelegate new];
    return _testerTransitionDelegate;
}



@end









/*/
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

@interface verbatmMediaPageViewController () <UITextFieldDelegate>

#pragma mark - *Properties
#pragma mark camera related
@property (weak, nonatomic) IBOutlet ILTranslucentView *blurView;
@property (strong, nonatomic) UIView *verbatmCameraView;
@property (strong, nonatomic) verbatmMediaSessionManager* sessionManager;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat counter;
@property (strong, nonatomic)UIButton* switchCameraButton;
@property (strong, nonatomic)UIButton* switchFlashButton;
@property (nonatomic) BOOL flashOn;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic)CGPoint currentPoint;
@property (nonatomic) BOOL canRaise;

@property (weak, nonatomic) IBOutlet UITextField *whatSandwich;
@property (weak, nonatomic) IBOutlet UITextField *whereSandwich;

@property (weak, nonatomic) IBOutlet UIButton *toContentPageSegue;


@property (strong, nonatomic) UITapGestureRecognizer * tap;

#define ALBUM_NAME @"Verbatm"
#define ASPECT_RATIO 1
#define RGB_LEFT_SIDE 255,255,255, 0.7     //247, 0, 99, 1
#define RGB_RIGHT_SIDE 255,255,255, 0.7
#define RGB_BOTTOM_SIDE 255,255,255, 0.7
#define RGB_TOP_SIDE 255,255,255, 0.7
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


#pragma mark Navigation property
#define CONTENT_PAGE_SEGUE @"moveToContenPage"


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
    
    
    [self.view insertSubview: self.verbatmCameraView atIndex:0];
    self.sessionManager = [[verbatmMediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
    self.blurView.translucentStyle = UIBarStyleBlack;
    [self createSlideDownGesture];
    [self createSlideUpGesture];
    [self createTapGesture];
    [self createLongPressGesture];
    [self createSwitchCameraButton];
    [self createSwitchFlashButton];
    [self setPlaceholderColors];
    self.canRaise = NO;
    
    
    //updated by Iain
    [self setDelegates];
    self.whatSandwich.keyboardAppearance = UIKeyboardAppearanceDark;
    self.whereSandwich.keyboardAppearance = UIKeyboardAppearanceDark;

    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
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
        // TODO: Add fall-back code to set placeholder color.
    }
    if ([self.whereSandwich respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.whereSandwich.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.whereSandwich.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
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
    [self.verbatmCameraView addGestureRecognizer:self.tap];
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
    CGPoint point = [self.tap locationInView:self.verbatmCameraView];
    if(point.y < (self.switchCameraButton.frame.origin.y+self.switchCameraButton.frame.size.height))return;
    
    [self.sessionManager captureImageUsingFrame:self.videoProgressImageView.frame];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(resumeSession) userInfo:nil repeats:NO];
}

-(void)freezeFrame
{
    [self.sessionManager stopSession];
    
}

-(void)resumeSession
{
    [self.sessionManager startSession];
}

-(void)prepareVideoProgressView
{
    if(!self.canRaise){
        self.videoProgressImageView.frame = CGRectMake(0,0,  self.view.frame.size.width, self.view.frame.size.height - self.blurView.frame.origin.y);
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
            [self.videoProgressImageView removeFromSuperview];
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
            self.blurView.hidden = YES;
        }else{
            self.verbatmCameraView.frame = self.view.frame;
            self.blurView.frame = CGRectMake(0, self.view.frame.size.height, self.blurView.frame.size.width, 0);
            [self.switchCameraButton setFrame:CGRectMake(SWITCH_CAMERA_START_POSITION, SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
            [self.switchFlashButton setFrame: CGRectMake(FLASH_START_POSITION, FLASH_ICON_SIZE , FLASH_ICON_SIZE)];
        }
        [self.sessionManager setToFrameOfView:self.verbatmCameraView];
        [self.sessionManager setSessionOrientationToOrientation: [UIDevice currentDevice].orientation];
    }];
    self.canRaise = YES;
}

//by Lucio
-(IBAction)raiseVideoPreviewScreen:(id)sender
{
    if(self.canRaise){
        if(self.blurView.hidden) self.blurView.hidden = NO;
        NSLog(@"here");
        [UIView animateWithDuration:0.5 animations:^{
            self.blurView.frame =  CGRectMake(0, self.view.frame.size.height/2, self.blurView.frame.size.width, self.view.frame.size.height/2);
            [self.sessionManager setSessionOrientationToOrientation: [UIDevice currentDevice].orientation];
        }];
    }
    self.canRaise = NO;
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
    //CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 4.0), 20.0 , [UIColor yellowColor].CGColor);
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


#pragma mark - *Navigation
//Returning
//Iain
- (IBAction) goToRoot: (UIStoryboardSegue*) segue
{
    //set the s@andwhich to what was added in the screen before
    if(self.sandwhichWhat) self.whatSandwich.text = self.sandwhichWhat;
    if(self.sandwichWhere) self.whereSandwich.text = self.sandwichWhere;
    
    NSLog(@"Called goToRoot: unwind action");
}

//Leaving the split page
//Iain
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:CONTENT_PAGE_SEGUE])
    {
        verbatmContentPageViewController * vc = (verbatmContentPageViewController *) segue.destinationViewController;
        vc.sandWhichWhatString = self.whatSandwich.text;
        vc.sandWhichWhereString = self.whereSandwich.text;
        if(self.articleContent)vc.articleContentString = self.articleContent;
        if(self.articleTitle)vc.articleTitleString = self.articleTitle;
        if(self.contentPageElements) vc.pageElements = self.contentPageElements;
    }
}

//Iain
//Move to content page OR remove bottom of dual page
- (IBAction)swipeUpSegueToContentPage:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction == UISwipeGestureRecognizerDirectionUp){
        //acts like the button has been pressed- so calls a modal segue
        [self.toContentPageSegue sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
}


#pragma mark - UI technicalities
//To be edited- adds a top shadow to the view that is sent
//Iain
-(void) addTopShadowToView: (UIView *) view
{
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowPath = shadowPath.CGPath;
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

#pragma mark - Textfields 
//Iain
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //S@nwiches shouldn't have any spaces between them
    if([string isEqualToString:@" "]) return NO;
    return YES;
}

@end
 */
