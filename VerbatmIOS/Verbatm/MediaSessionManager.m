//
//  verbatmAVCaptureSession.m
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "Durations.h"
#import "MediaSessionManager.h"
#import "StringsAndAppConstants.h"
#import "UIImage+ImageEffectsAndTransforms.h"

@interface MediaSessionManager() <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureDeviceInput* videoInput;
@property (strong, nonatomic) AVCaptureDeviceInput* audioInput;
@property (strong, nonatomic) AVCaptureMovieFileOutput * movieOutputFile;
@property (strong) AVCaptureStillImageOutput* stillImageOutput;
@property (strong, nonatomic) PHAssetCollection* verbatmAlbum;


#define N_FRAMES_PER_SECOND 24
#define BITRATE 1098
#define VIDEO_RESOLUTION 480
#define IMAGE_RESOLUTION 640

#define VERBATM_ALBUM_PREVIOUSLY_CREATED_KEY @"verbatm_album_previously_created"

@end


@implementation MediaSessionManager
@synthesize session = _session;


-(instancetype)initSessionWithView:(UIView*)containerView {

	if((self = [super init])) {
		[self initializeVerbatmAlbum];
		[self initializeSession];

		// setup preview
		self.videoPreview = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
		self.videoPreview.frame = containerView.frame;
		self.videoPreview.videoGravity =  AVLayerVideoGravityResizeAspectFill;
		[containerView.layer addSublayer: self.videoPreview];

		//start the session running
		[self.session startRunning];
	}
	return self;
}

#pragma mark - Initialize Session -

// set up the capture session with video and audio inputs, and video and still image outputs
-(void) initializeSession {
	self.session = [[AVCaptureSession alloc]init];
	self.session.sessionPreset = AVCaptureSessionPresetHigh;
	[self setupSessionInputs];
	[self setupSessionOutputs];
}

//Adds video and audio inputs to the session
-(void) setupSessionInputs {
	//Getting video
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if([videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [videoDevice lockForConfiguration:nil]){
		[videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
		[videoDevice unlockForConfiguration];
	}
	NSError* error = nil;
	self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice: videoDevice error:&error];
	if(error){
		return;
	}

	//Getting audio
	AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
	if (!self.videoInput || !self.audioInput) {
		[[Crashlytics sharedInstance] recordError: error];
		return;
	}

	//adding video and audio inputs
	[self.session addInput: self.videoInput];
	[self.session addInput: self.audioInput];
}

/*Directs the output of the still image of the session to the stillImageOutput file
 */
-(void) setupSessionOutputs {
	[self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
	NSDictionary* stillImageOutputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:
											  AVVideoCodecJPEG, AVVideoCodecKey,
											  nil];
	[self.stillImageOutput setOutputSettings: stillImageOutputSettings];
	[self.session addOutput: self.stillImageOutput];

	[self setMovieOutputFile: [[AVCaptureMovieFileOutput alloc] init]];

	int32_t framesPerSecond = N_FRAMES_PER_SECOND;
	int64_t numSeconds = MAX_VID_SECONDS * N_FRAMES_PER_SECOND;
	CMTime maxDuration = CMTimeMake(numSeconds, framesPerSecond);
	_movieOutputFile.maxRecordedDuration = maxDuration;
	[self.session addOutput: self.movieOutputFile];
}

/* NOT IN USE
 
 NSDictionary* videoOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
 AVVideoCodecH264, AVVideoCodecKey,
 [NSNumber numberWithInteger: VIDEO_RESOLUTION], AVVideoWidthKey,
 [NSNumber numberWithInteger: VIDEO_RESOLUTION], AVVideoHeightKey,
 AVVideoScalingModeResizeAspectFill, AVVideoScalingModeKey,
 [[NSDictionary alloc] initWithObjectsAndKeys:
 [NSNumber numberWithInteger: BITRATE], AVVideoAverageBitRateKey,
 nil], AVVideoCompressionPropertiesKey,
 nil];
 */

#pragma mark - Verbatm Album Setup -

// Checks if the Verbatm album has ever been created before (in user defaults) and if it hasn't,
// creates and stores it. If it has, gets it and stores it.
-(void) initializeVerbatmAlbum {
	if (![[NSUserDefaults standardUserDefaults] boolForKey: VERBATM_ALBUM_PREVIOUSLY_CREATED_KEY]) {
		[self createVerbatmAlbum];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:VERBATM_ALBUM_PREVIOUSLY_CREATED_KEY];
	} else {
		[self getVerbatmAlbum];
	}
}

// creates a Verbatm Album in the PHPhotoLibrary
-(void)createVerbatmAlbum {
	__block PHObjectPlaceholder *albumPlaceholder;
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		PHAssetCollectionChangeRequest* changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:VERBATM_ALBUM_NAME];
		albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		if (success) {
			PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumPlaceholder.localIdentifier] options:nil];
			self.verbatmAlbum = fetchResult.firstObject;
		} else {
			[[Crashlytics sharedInstance] recordError: error];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:VERBATM_ALBUM_PREVIOUSLY_CREATED_KEY];
		}
	}];
}

// lists all albums and finds the one named Verbatm, then saves it
-(void) getVerbatmAlbum {
	PHFetchResult* assetCollectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
																						 subtype:PHAssetCollectionSubtypeAlbumRegular
																						 options:nil];
	[assetCollectionFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection* album, NSUInteger idx, BOOL *stop) {
		if ([album.localizedTitle isEqualToString:VERBATM_ALBUM_NAME]) {
			*stop = YES;
			self.verbatmAlbum = album;
		}
	}];
	if (self.verbatmAlbum == nil) {
		[self createVerbatmAlbum];
	}
}

#pragma mark - Start and Stop Session -

-(void)startSession {
	[self.session startRunning];
}

-(void)stopSession {
	[self.session stopRunning];
}

-(void) rerunSession {
	[self.session startRunning];
}

#pragma mark - Capture Image -

-(void)captureImage {
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
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection: videoConnection
													   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		if(!error) {
            @autoreleasepool {
                NSData* dataForImage = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage* capturedImage = [[UIImage alloc] initWithData: dataForImage];
                capturedImage = [capturedImage getImageWithOrientationUp];
                [self.delegate capturedImage: capturedImage];
                [self saveAssetFromImage:capturedImage orVideoFile:nil];
            }
		} else {
			[[Crashlytics sharedInstance] recordError: error];
		}
	}];
}

#pragma mark - Record Video -

-(void)startVideoRecordingInOrientation:(UIDeviceOrientation)startOrientation {
	NSString *movieOutput = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mp4"];
	NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:movieOutput];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// Remove previous file at this path
	if ([fileManager fileExistsAtPath:movieOutput]) {
		NSError *error;
		if (![fileManager removeItemAtPath:movieOutput error:&error]) {
			[[Crashlytics sharedInstance] recordError: error];
			return;
		}
	}

	//start recording to file
	[self.movieOutputFile startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

-(void)stopVideoRecording {
	[self.movieOutputFile stopRecording];
}

#pragma mark AVCaptureFileOutputRecordingDelegate Delegate methods

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
	[self saveAssetFromImage:nil orVideoFile:outputFileURL];
}

#pragma mark - Save Asset -

// Pass nil for the other one you're not saving
-(void) saveAssetFromImage: (UIImage*) image orVideoFile: (NSURL*) outputFileURL {
	__block PHObjectPlaceholder *assetPlaceholder;
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		PHAssetChangeRequest* assetChangeRequest;
		if (image) {
			assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage: image];
		} else {
			assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL: outputFileURL];
		}
		PHAssetCollectionChangeRequest* collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.verbatmAlbum];
		assetPlaceholder = [assetChangeRequest placeholderForCreatedAsset];
		[collectionChangeRequest addAssets:@[assetPlaceholder]];
	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		if (success) {
			PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetPlaceholder.localIdentifier] options:nil];
			PHAsset* savedAsset = fetchResult.firstObject;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delegate didFinishSavingMediaToAsset:savedAsset];
			});
		} else {
			[[Crashlytics sharedInstance] recordError: error];
		}
	}];
}

#pragma mark - Customize Session (focus, zoom, orientation, flash, etc.) -

-(void) focusAtPoint:(CGPoint)viewCoordinates {
	AVCaptureDevice *currentDevice = [[self videoInput] device];

	CGPoint point = [self.videoPreview captureDevicePointOfInterestForPoint:viewCoordinates];

	if([currentDevice isFocusPointOfInterestSupported] && [currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
		NSError *error = nil;
		[currentDevice lockForConfiguration:&error];
		if(!error){
			[currentDevice setFocusPointOfInterest:point];
			[currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
			[currentDevice unlockForConfiguration];
		}
	}
}

- (void) zoomPreviewWithScale:(float)effectiveScale {
	if ([self.videoInput.device respondsToSelector:@selector(setVideoZoomFactor:)]
		&& self.videoInput.device.activeFormat.videoMaxZoomFactor >= effectiveScale) {
		if ([self.videoInput.device lockForConfiguration:nil]) {
			[self.videoInput.device setVideoZoomFactor:effectiveScale];
			[self.videoInput.device unlockForConfiguration];
		}
	}
}

-(void) switchCameraOrientation {
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

	if(newCamera == nil){
		[self.session addInput:currentVideoInput];
		return;
	}
	//add the new video
	AVCaptureDeviceInput* newInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
	[self.session addInput:newInput];

	//commit the changes made
	[self.session commitConfiguration];
}

-(void) toggleFlash {

	//indicate changes are going to be made
	[self.session beginConfiguration];

	AVCaptureInput* currentVideoInput = [self.session.inputs firstObject];
	currentVideoInput = ([((AVCaptureDeviceInput*)currentVideoInput).device hasMediaType:AVMediaTypeVideo])? currentVideoInput : [self.session.inputs lastObject];
	if(((AVCaptureDeviceInput*)currentVideoInput).device.hasFlash && [((AVCaptureDeviceInput*)currentVideoInput).device lockForConfiguration:nil] ){
		((AVCaptureDeviceInput*)currentVideoInput).device.flashMode = (((AVCaptureDeviceInput*)currentVideoInput).device.flashActive)? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
		[((AVCaptureDeviceInput*)currentVideoInput).device unlockForConfiguration];
	} else {
//		NSLog(@"Video device does not have flash settings");
	}
	[self.session commitConfiguration];
}

//finds the camera orientation for front or back
-(AVCaptureDevice*)getCameraWithOrientation:(NSInteger)orientation {
	NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for(AVCaptureDevice* device in devices){
		if([device position] == orientation){
			return device;
		}
	}
	return nil;
}

//set the preview session to the the bounds of the view
-(void)setToFrameOfView:(UIView*)containerView {
	if([containerView.layer.sublayers containsObject: self.videoPreview]){
		self.videoPreview.frame = containerView.frame;
	}
}

@end
