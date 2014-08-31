//
//  verbatmViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmViewController.h"
#import <Parse/Parse.h>
#import "VerbatmUser.h"
#import "Article.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface verbatmViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *verbatmCameraView;
@property (weak, nonatomic) IBOutlet UILabel *testingLabel;
@property (weak, nonatomic) IBOutlet UIView *whiteBackgroundUIView;
@property (weak, nonatomic) IBOutlet UITextField *whereTextView;
@property (weak, nonatomic) IBOutlet UITextField *whatTextView;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong)UIImage* stillImage;
@property (strong, nonatomic) AVCaptureMovieFileOutput * movieOutputFile;

#define SWITCH_ICON_SIZE 60
#define CAMERA_ICON @"switch_b"
@end

@implementation verbatmViewController

@synthesize stillImageOutput = _stillImageOutput;
@synthesize stillImage = _stillImage;


- (IBAction)switch:(id)sender
{
    if(self.session)
    {
        //indicate that changes will be made to this session
        [self.session beginConfiguration];
        
        //remove existing input
        AVCaptureInput* currentInput = [self.session.inputs firstObject];
        [self.session removeInput:  currentInput];
        
        //get a new input
        AVCaptureDevice* newCamera = nil;
        if(((AVCaptureDeviceInput*)currentInput).device.position == AVCaptureDevicePositionFront ){
            newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionBack];
        }else{
            newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionFront];
        }
        
        AVCaptureDeviceInput* newInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [self.session addInput:newInput];
        
        //commit the changes made
        
        [self.session commitConfiguration];
    }

}




//by Lucio Dery
//changes the camera orientation to front
-(AVCaptureDevice*)getCameraWithOrientation: (NSInteger)orientation
{
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice* device in devices){
        if([device position] == orientation){
            return device;
        }
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton* overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:CAMERA_ICON] forState:UIControlStateNormal];
    
    [overlayButton setFrame:CGRectMake(250, 10,SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
    [overlayButton addTarget:self action:@selector(switch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:overlayButton];
    
    
//    UIButton* overlayTakePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
//    [overlayTakePhoto setImage:[UIImage imageNamed:CAMERA_ICON] forState:UIControlStateNormal];
//    
//    [overlayTakePhoto setFrame:CGRectMake(150, 150, 60 , 60)];
//    [overlayTakePhoto addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:overlayTakePhoto];
//    
 
    [self createTapGesture];
    [self createLongPressGesture];
    
    
}

-(void) createTapGesture
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    tap.numberOfTapsRequired = 1;
    [self.verbatmCameraView addGestureRecognizer:tap];
}

-(void) createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(takeVideo:)];
    longPress.numberOfTapsRequired = 1;
    longPress.minimumPressDuration = 2;
    [self.verbatmCameraView addGestureRecognizer:longPress];
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
	
	
//	//----- SHOW LIVE CAMERA PREVIEW -----
//	self.session = [[AVCaptureSession alloc] init];
//	self.session.sessionPreset = AVCaptureSessionPresetMedium;
//    [self addStillImageOutput];
//	
//	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//	
//	captureVideoPreviewLayer.frame = self.verbatmCameraView.frame;
//	[self.verbatmCameraView.layer addSublayer:captureVideoPreviewLayer];
//	
//	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    
//    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    
//	
//	NSError *errorVideo = nil;
//	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&errorVideo];
//    
//    NSError* error = nil;
//    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
//    
//	if (!input) {
//		// Handle the error appropriately.
//		NSLog(@"ERROR: trying to open camera: %@", error);
//	}
//    
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.whiteBackgroundUIView.bounds];
//    self.whiteBackgroundUIView.layer.masksToBounds = YES;
//    self.whiteBackgroundUIView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.whiteBackgroundUIView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    self.whiteBackgroundUIView.layer.shadowOpacity = 0.5f;
//    self.whiteBackgroundUIView.layer.shadowPath = shadowPath.CGPath;
//    
//    
//    
//	[self.session addInput:input];
//    [self.session addInput:audioInput];
//	
//	[self.session startRunning];
}

-(BOOL) textFieldShouldReturn:(UITextField *)theTextField {
	if(theTextField == self.whereTextView)
    {
        [self.whereTextView resignFirstResponder];
    
    }else if(theTextField == self.whatTextView)
    {
        [self.whatTextView resignFirstResponder];
    }
	return YES;
}


//test function - not permanent 
-(void) buildRelationshipsBetween:(VerbatmUser *) me and: (VerbatmUser *) them
{
   // [me followUser:them];
    //[me endorseUser:them];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Lucio
-(void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary* outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    [self.session addOutput: self.stillImageOutput];
}

//Lucio
-(void)captureImage
{
    AVCaptureConnection* videoConnection = nil;
    for(AVCaptureConnection* connection in self.stillImageOutput.connections){
        for(AVCaptureInputPort* port in connection.inputPorts){
            if([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        if(videoConnection){
            break;
        }
    }
    //requesting a capture
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData* dataForImage = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [self setStillImage:[[UIImage alloc] initWithData: dataForImage]];
    }];
    
}

-(void)saveImageToVerbatmFolder
{
    UIImageWriteToSavedPhotosAlbum(self.stillImage, self, nil, nil);
}

//- (IBAction)takePhoto:(UITapGestureRecognizer *)sender
//{
//    //NSLog(@"%@",self.stillImage);
//    [self captureImage];
//    [self saveImageToVerbatmFolder];
//    if(self.stillImage){
//        NSLog(@"Photo taken");
//    }else{
//        NSLog(@"Photo not taken");
//    }
//}

- (IBAction)takePhoto:(id)sender
{
    [self captureImage];
    [self saveImageToVerbatmFolder];
    if(self.stillImage){
        NSLog(@"Photo taken");
    }else{
        NSLog(@"Photo not taken");
    }
}

-(IBAction)takeVideo:(id)sender
{
    UITapGestureRecognizer* recognizer = [self.verbatmCameraView.gestureRecognizers objectAtIndex:1];
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self startVideoRecording];
    }else{
        if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed ||
           recognizer.state == UIGestureRecognizerStateCancelled){
            [self stopVideoRecording];
        }
    }
}

-(void)startVideoRecording
{
//    if([self.session canAddOutput:self.movieOutputFile]){
//        [self.session addOutput: self.movieOutputFile];
//        NSString* documentsDirPath = 
//    }
}

-(void)stopVideoRecording
{
    
}

-(AVCaptureMovieFileOutput*)movieOutputFile
{
    if(!_movieOutputFile){
        _movieOutputFile = [[AVCaptureMovieFileOutput alloc]init];
        int64_t numSeconds = 30;
        int32_t framesPerSecond = 32;
        CMTime maxDuration = CMTimeMake(numSeconds, framesPerSecond);
        _movieOutputFile.maxRecordedDuration = maxDuration;
    }
    return _movieOutputFile;
}

@end
