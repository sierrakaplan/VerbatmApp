//
//  verbatmAVCaptureSession.m
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmMediaSessionManager.h"

@interface verbatmMediaSessionManager() <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic)AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureMovieFileOutput * movieOutputFile;
@property (strong) AVCaptureStillImageOutput* stillImageOutput;
@property (strong, nonatomic) ALAssetsLibrary* assetLibrary;
@property (strong, nonatomic) ALAssetsGroup* verbatmAlbum;
@property (nonatomic, strong)UIImage* stillImage;


#define N_FRAMES_PER_SECOND 32
#define NUM_SECONDS 30
#define ALBUM_NAME @"Verbatm"

@end


@implementation verbatmMediaSessionManager
@synthesize session = _session;


#pragma mark - initialization
//By Lucio
//initialises the session
-(instancetype)initSessionWithView:(UIView*)containerView
{
    if((self = [super init])){
        //create the assetLibrary
        self.assetLibrary = [[ALAssetsLibrary alloc] init];
        [self createVerbatmDirectory];
        //Create the session and set its properties.
        self.session = [[AVCaptureSession alloc]init];
        self.session.sessionPreset = AVCaptureSessionPresetMedium;
        [self addStillImageOutput];
        
        //add the video and audio devices to the session
        [self addVideoAndAudioDevices];
        
        self.videoPreview = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
        self.videoPreview.frame = containerView.frame;
         self.videoPreview.videoGravity =  AVLayerVideoGravityResizeAspectFill;  //was originally resizeaspectfill
        [containerView.layer addSublayer: self.videoPreview];
        
        //start the session running
        [self.session startRunning];
    }
    return self;
}

//Lucio
-(void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary* outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    [self.session addOutput: self.stillImageOutput];
}

//By Lucio
//Adds video and audio devices to the session
-(void)addVideoAndAudioDevices
{
    //Getting video
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [videoDevice lockForConfiguration:nil]){
        [videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];  //added
        [videoDevice unlockForConfiguration];
    }
    NSError* error = nil;
    AVCaptureInput* videoInput = [AVCaptureDeviceInput deviceInputWithDevice: videoDevice error:&error];
    if(error){
        NSLog(@"video input not  available");
    }
    
    //Getting audio
    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (!videoInput || !audioInput) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    
    //adding video and audio inputs
    [self.session addInput: videoInput];
    [self.session addInput:audioInput];
    
    //adding the output for the video
    if([self.session canAddOutput:self.movieOutputFile]){
        [self.session addOutput: self.movieOutputFile];
    }else{
        NSLog(@"Couldn't add output for video");
    }
}

//By Lucio
//Create the movieOutputFile
-(AVCaptureMovieFileOutput*)movieOutputFile
{
    if(!_movieOutputFile){
        _movieOutputFile = [[AVCaptureMovieFileOutput alloc]init];
        int32_t framesPerSecond = N_FRAMES_PER_SECOND;
        int64_t numSeconds = NUM_SECONDS * N_FRAMES_PER_SECOND;
        CMTime maxDuration = CMTimeMake(numSeconds, framesPerSecond);
        _movieOutputFile.maxRecordedDuration = maxDuration;
    }
    return _movieOutputFile;
}

#pragma mark -verbatm folder setUp
//by Lucio
//create the verbatm Folder in the photo album if it doesn't already exist
-(void)createVerbatmDirectory
{
    NSString* albumName = ALBUM_NAME;
    [self.assetLibrary addAssetsGroupAlbumWithName:albumName
                                  resultBlock:^(ALAssetsGroup *group) {
                                      NSLog(@"added album:%@", albumName);
                                      
                                  }
                                 failureBlock:^(NSError *error) {
                                     NSLog(@"error adding album");
                                 }];
    //get the album
    __weak verbatmMediaSessionManager* weakSelf = self;
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                        NSLog(@"found album %@", albumName);
                                        weakSelf.verbatmAlbum = group;
                                        return;   //add this
                                    }
                                }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                              }];
}


#pragma mark - customize session

//By Lucio
//Switch the video prosition: front to back and vice versa
-(void)switchVideoFace
{
    //indicate that changes will be made to this session
    [self.session beginConfiguration];
    
    //remove existing input
    AVCaptureInput* currentVideoInput = [self.session.inputs firstObject];
    currentVideoInput = ([((AVCaptureDeviceInput*)currentVideoInput).device hasMediaType:AVMediaTypeVideo])? currentVideoInput : [self.session.inputs lastObject];
    [self.session removeInput: currentVideoInput];
    
    //get a new input
    AVCaptureDevice* newCamera = nil;
    if(((AVCaptureDeviceInput*)currentVideoInput).device.position == AVCaptureDevicePositionFront ){
        newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionBack];
    }else{
        newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionFront];
    }
    
    //add the new video
    AVCaptureDeviceInput* newInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
    [self.session addInput:newInput];
    
    //commit the changes made
    [self.session commitConfiguration];
}

//Lucio
-(void)switchFlash
{
    //indicate changes are going to be made
    [self.session beginConfiguration];
    
    AVCaptureInput* currentVideoInput = [self.session.inputs firstObject];
    currentVideoInput = ([((AVCaptureDeviceInput*)currentVideoInput).device hasMediaType:AVMediaTypeVideo])? currentVideoInput : [self.session.inputs lastObject];
    if(((AVCaptureDeviceInput*)currentVideoInput).device.hasFlash && [((AVCaptureDeviceInput*)currentVideoInput).device lockForConfiguration:nil] ){
        ((AVCaptureDeviceInput*)currentVideoInput).device.flashMode = (((AVCaptureDeviceInput*)currentVideoInput).device.flashActive)? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
        [((AVCaptureDeviceInput*)currentVideoInput).device unlockForConfiguration];
    }else{
        NSLog(@"Video device does not have flash settings");
    }
    [self.session commitConfiguration];
}

//by Lucio
//finds the camera orientation for front or back
-(AVCaptureDevice*)getCameraWithOrientation:(NSInteger)orientation
{
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice* device in devices){
        if([device position] == orientation){
            return device;
        }
    }
    return nil;
}

//by Lucio
//sets the session orientation to the device orientation
//it seems that left for the device corresponds to right for the session
-(void)setSessionOrientationToDeviceOrientation
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if(orientation == UIDeviceOrientationLandscapeLeft){
        self.videoPreview.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }else if (orientation == UIDeviceOrientationLandscapeRight){
        self.videoPreview.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }else if (orientation == UIDeviceOrientationPortraitUpsideDown){
        self.videoPreview.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }else{
        self.videoPreview.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

//by Lucio
//set the preview session to the the bounds of the view
-(void)setToFrameOfView:(UIView*)containerView
{
    if([containerView.layer.sublayers containsObject: self.videoPreview]){
        self.videoPreview.frame = containerView.frame;
    }else{
        NSLog(@"Wrong container view");
    }
}

//by Lucio
-(void)startSession
{
    [self.session startRunning];
}

-(void)stopSession
{
    [self.session stopRunning];
}

#pragma mark - video recording 

//by Lucio
-(void)startVideoRecording
{
    //Get the right output path for the video
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

    //get the right orientation
    AVCaptureConnection *videoConnection = nil;
    for ( AVCaptureConnection *connection in [self.movieOutputFile connections] )
    {
        NSLog(@"%@", connection);
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            NSLog(@"%@", port);
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
            }
        }
    }
    if([videoConnection isVideoOrientationSupported])
    {
        [videoConnection setVideoOrientation:self.videoPreview.connection.videoOrientation];
    }
    
    //start recording to file
    [self.movieOutputFile startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

//Lucio
-(void)stopVideoRecording
{
    [self.movieOutputFile stopRecording];
}

#pragma mark -delegate methods AVCaptureFileOutputRecordingDelegate
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

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

#pragma mark - for photo capturing and processing
//by Lucio
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
    [videoConnection setVideoOrientation:self.videoPreview.connection.videoOrientation];
    //requesting a capture
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData* dataForImage = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [self processImage:[[UIImage alloc] initWithData:dataForImage ]];
        [self saveImageToVerbatmAlbum];
    }];
}

#pragma mark - accessory methods

//by Lucio
-(void)saveImageToVerbatmAlbum
{
    CGImageRef img = [self.stillImage CGImage];
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

//Lucio
-(void)processImage:(UIImage*)image
{
    self.stillImage = image;
    [self cropImage];
    
}

-(void)cropImage
{
    UIImage *newImage = self.stillImage;
    
    CGSize itemSize = CGSizeMake(self.stillImage.size.width, self.stillImage.size.height - 100);  //these magic numbers need to be tested on other devices
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, -45.0, self.stillImage.size.width, self.stillImage.size.height);
    [self.stillImage drawInRect:imageRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.stillImage = newImage;
}


@end
