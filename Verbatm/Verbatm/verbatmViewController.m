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
#import <AssetsLibrary/AssetsLibrary.h>

@interface verbatmViewController () <UITextFieldDelegate, AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) IBOutlet UIView *verbatmCameraView;
@property (weak, nonatomic) IBOutlet UILabel *testingLabel;
@property (weak, nonatomic) IBOutlet UIView *whiteBackgroundUIView;
@property (weak, nonatomic) IBOutlet UITextField *whereTextView;
@property (weak, nonatomic) IBOutlet UITextField *whatTextView;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong)UIImage* stillImage;
@property (strong, nonatomic) AVCaptureMovieFileOutput * movieOutputFile;
@property (strong, nonatomic) NSURL* verbatmFolderURL;
@property (strong, nonatomic) ALAssetsLibrary* assetLibrary;
@property (strong, nonatomic) ALAssetsGroup* verbatmAlbum;
@property (nonatomic, weak) CAShapeLayer *pathLayer;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat counter;


#define SWITCH_ICON_SIZE 60
#define CAMERA_ICON @"switch_back3"
#define MAX_VIDEO_LENGTH 30
@end

@implementation verbatmViewController

@synthesize stillImageOutput = _stillImageOutput;
@synthesize stillImage = _stillImage;
@synthesize verbatmFolderURL = _verbatmFolderURL;
@synthesize assetLibrary = _assetLibrary;
@synthesize verbatmAlbum = _verbatmAlbum;
@synthesize videoProgressImageView= _videoProgressImageView;
@synthesize timer = _timer;


//Test function for top shadow
//Iain
-(void) addTopShadowToView: (UIView *) view
{
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    view.layer.shadowOpacity = 0.4f;
    view.layer.shadowPath = shadowPath.CGPath;
}


#pragma mark - creating album for verbatm

//Lucio
-(void)createVerbatmDirectory
{
    NSString* albumName = @"Verbatm";
    [self.assetLibrary addAssetsGroupAlbumWithName:albumName
                                       resultBlock:^(ALAssetsGroup *group) {
                                           NSLog(@"added album:%@", albumName);
                                       }
                                      failureBlock:^(NSError *error) {
                                          NSLog(@"error adding album");
                                      }];
    
    //gets the album once ints created.
    __weak verbatmViewController* weakSelf = self;
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                        NSLog(@"found album %@", albumName);
                                        weakSelf.verbatmAlbum = group;
                                    }
                                }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                              }];
}


#pragma mark - saving photos and videos

//Lucio
-(void)saveImageToVerbatmFolder
{
    //    UIImageWriteToSavedPhotosAlbum(self.stillImage, self, nil, nil);
    //[[UIImage alloc] initWithCGImage:self.stillImage.CGImage scale:1 orientation:UIImageOrientationLeft];
    UIImage* image = [self imageByRotatingImage:self.stillImage fromImageOrientation: self.stillImage.imageOrientation];
    if(image) NSLog(@"image is not null");
    CGImageRef img = [image CGImage];
    
    [self.assetLibrary writeImageToSavedPhotosAlbum:img
                                           metadata:nil
                                    completionBlock:^(NSURL* assetURL, NSError* error) {
                                        if (error.code == 0) {
                                            NSLog(@"saved image completed:\nurl: %@", assetURL);
                                            
                                            // try to get the asset
                                            [self.assetLibrary assetForURL:assetURL
                                                               resultBlock:^(ALAsset *asset) {
                                                                   // assign the photo to the album
                                                                   [self.verbatmAlbum addAsset:asset];
                                                                   NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], @"Verbatm");
                                                               }
                                                              failureBlock:^(NSError* error) {
                                                                  NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                              }];
                                        }
                                        else {
                                            NSLog(@"saved image failed.\nerror code %li\n%@", (long)error.code, [error localizedDescription]);
                                        }
                                    }];
}



#pragma mark - touch gesture selectors

- (IBAction)switch:(id)sender
{
    if(self.session)
    {
        //indicate that changes will be made to this session
        [self.session beginConfiguration];
        
        //remove existing input
        AVCaptureInput* currentInput = [self.session.inputs firstObject];
        currentInput = ([((AVCaptureDeviceInput*)currentInput).device hasMediaType:AVMediaTypeVideo])? currentInput : [self.session.inputs lastObject];
        [self.session removeInput:  currentInput];
        
        //get a new input
        AVCaptureDevice* newCamera = nil;
        if(((AVCaptureDeviceInput*)currentInput).device.position == AVCaptureDevicePositionFront ){
            newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionBack];
        }else{
            newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionFront];
        }
        
        AVCaptureDeviceInput* newInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        AVCaptureInput* currentAudioInput = [self.session.inputs firstObject];
        [self.session removeInput:  currentAudioInput];
        [self.session addInput:newInput];
        [self.session addInput:currentAudioInput];
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
    [self createVideoProgressView];
    [self createTapGesture];
    [self createLongPressGesture];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    [self createVerbatmDirectory];
    
    //[self addTopShadowToView:self.whiteBackgroundUIView];
}

#pragma mark -create video progess bar

-(void)createVideoProgressView
{
    self.videoProgressImageView =  [[UIImageView alloc] initWithImage:nil];
    self.videoProgressImageView.backgroundColor = [UIColor clearColor];
    self.videoProgressImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*2/3); //look for a better way than using magic number.
    [self.view addSubview: self.videoProgressImageView];
}

#pragma mark -creating gestures

-(void) createTapGesture
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    tap.numberOfTapsRequired = 1;
    [self.verbatmCameraView addGestureRecognizer:tap];
}

-(void) createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(takeVideo:)];
    longPress.minimumPressDuration = 2;
    [self.verbatmCameraView addGestureRecognizer:longPress];
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
	
	
	//----- SHOW LIVE CAMERA PREVIEW -----
	self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = AVCaptureSessionPresetMedium;
    [self addStillImageOutput];
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
	
	captureVideoPreviewLayer.frame = self.verbatmCameraView.frame;
	[self.verbatmCameraView.layer addSublayer:captureVideoPreviewLayer];
	   
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
	
	NSError *errorVideo = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&errorVideo];
    
    NSError* error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
	if (!input || !audioInput) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.whiteBackgroundUIView.bounds];
//    self.whiteBackgroundUIView.layer.masksToBounds = YES;
//    self.whiteBackgroundUIView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.whiteBackgroundUIView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    self.whiteBackgroundUIView.layer.shadowOpacity = 0.5f;
//    self.whiteBackgroundUIView.layer.shadowPath = shadowPath.CGPath;
    
    
    [self createVerbatmDirectory];
    
	[self.session addInput:input];
    [self.session addInput:audioInput];
    
    if([self.session canAddOutput:self.movieOutputFile]){
        [self.session addOutput: self.movieOutputFile];   //need to check if it cant
    }else{
        NSLog(@"couldn't add output");
    }
	
	[self.session startRunning];
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
    //AVCaptureConnection *conn = [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo];
    [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    //requesting a capture
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData* dataForImage = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [self setStillImage:[[UIImage alloc] initWithData: dataForImage]];
        [self saveImageToVerbatmFolder];
    }];
}




//Lucio
- (IBAction)takePhoto:(id)sender
{
    [self captureImage];
}


#pragma mark - video recording
//Lucio
-(IBAction)takeVideo:(id)sender
{
    UITapGestureRecognizer* recognizer = [self.verbatmCameraView.gestureRecognizers objectAtIndex:1];
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self startVideoRecording];
        self.counter = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(createProgressPath) userInfo:nil repeats:YES];
    }else{
        if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed ||
           recognizer.state == UIGestureRecognizerStateCancelled){
            [self stopVideoRecording];
            [self clearVideoProgressImage];
            [self.timer invalidate];
            self.counter = 0;
        }
    }
}

//Lucio
-(void)clearVideoProgressImage
{
    self.videoProgressImageView.image = nil;
}

-(void)createProgressPath
{
    self.counter += 0.1;
    UIGraphicsBeginImageContext(self.videoProgressImageView.frame.size);
    [self.videoProgressImageView.image drawInRect:self.videoProgressImageView.frame];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    if(self.counter < MAX_VIDEO_LENGTH/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 0, 0, 1);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width/2, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake((self.videoProgressImageView.frame.size.width/2)*(1 - (self.counter/ (MAX_VIDEO_LENGTH/8))), self.videoProgressImageView.frame.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= MAX_VIDEO_LENGTH/8 && self.counter < (MAX_VIDEO_LENGTH*3)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),0, 0,1,1);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(0, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(0, self.videoProgressImageView.frame.size.height*(1 - (self.counter - (MAX_VIDEO_LENGTH/8)/ (MAX_VIDEO_LENGTH*2/8))));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*3)/8  && self.counter < (MAX_VIDEO_LENGTH*5)/8 ){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0 ,0,1);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(0, 0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width*((self.counter - (MAX_VIDEO_LENGTH*3/8))/ (MAX_VIDEO_LENGTH*2/8)), 0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*5)/8  && self.counter < (MAX_VIDEO_LENGTH*7)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 255, 215, 0, 1);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width, 0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH*5)/8)/ (MAX_VIDEO_LENGTH*2/8)));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 255, 181, 197, 1);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width - ((self.videoProgressImageView.frame.size.width/2)*(self.counter - ((MAX_VIDEO_LENGTH*7)/8))/(MAX_VIDEO_LENGTH/8)), self.videoProgressImageView.frame.size.height);
         CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.videoProgressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    [self.view addSubview: self.videoProgressImageView];
}

//Lucio
-(void)startVideoRecording
{
    NSLog(@"video is recording");
    NSString *movieOutput = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:movieOutput];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:movieOutput])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:movieOutput error:&error] == NO)
        {
            NSLog(@"output path  is wrong");
        }
    }
    //Start recording
    [self.movieOutputFile startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

//Lucio
-(void)stopVideoRecording
{
    [self.movieOutputFile stopRecording];
}

//Lucio
-(AVCaptureMovieFileOutput*)movieOutputFile
{
    if(!_movieOutputFile){
        _movieOutputFile = [[AVCaptureMovieFileOutput alloc]init];
        int64_t numSeconds = 960;
        int32_t framesPerSecond = 32;
        CMTime maxDuration = CMTimeMake(numSeconds, framesPerSecond);
        _movieOutputFile.maxRecordedDuration = maxDuration;
    }
    return _movieOutputFile;
}

#pragma mark Required protocol methods for AVCapture
//Lucio

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([self.assetLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]){
        [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            [self.assetLibrary assetForURL:assetURL
                               resultBlock:^(ALAsset *asset) {
                                   // assign the photo to the album
                                   [self.verbatmAlbum addAsset:asset];
                                   NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], @"Verbatm");
                               }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                              }];
        }];
    }else{
        NSLog(@"wrong output location");
    }
}



//Lucio
//Directly from stack overflow
-(UIImage*)imageByRotatingImage:(UIImage*)initImage fromImageOrientation:(UIImageOrientation)orientation
{
    CGImageRef imgRef = initImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            return initImage;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -bounds.size.width, -bounds.size.height);
    
    CGContextConcatCTM(context, transform);
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);
    
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:initImage.scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return image;
}

@end
