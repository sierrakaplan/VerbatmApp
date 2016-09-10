//
//  verbatmAVCaptureSession.h
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@import Photos;

@protocol MediaSessionManagerDelegate<NSObject>
@optional

-(void)capturedImage: (UIImage*) image;
//notifies any one conforming to the protocol that an asset has been saved.
-(void)didFinishSavingMediaToAsset:(PHAsset*)asset;

@end
@interface MediaSessionManager : NSObject
//Checks if permissions have been given
+(BOOL)adkMediaPermissionsAllowed;
//check if the user has been actively prompted for permissions
+(BOOL)adKMediaPermissionActivelyDenied;

//prompt user for permission
+(void)askUserForADKPermissionsWithCompletiongBlock:(void(^)(BOOL)) block;


-(instancetype)initSessionWithView:(UIView*)containerView;
-(void)focusAtPoint:(CGPoint)viewCoordinates;
- (void) zoomPreviewWithScale:(float)effectiveScale;
-(void)captureImage;
-(void)startVideoRecordingInOrientation:(UIDeviceOrientation)startOrientation;
-(void)stopVideoRecording;
-(void)setToFrameOfView:(UIView*)containerView;

-(void) switchCameraOrientation;
-(void) toggleFlash;

-(void)startSession;
-(void)stopSession;
-(void) rerunSession;

@property(strong, nonatomic) NSURL* outputurl;
@property (nonatomic, weak) id <MediaSessionManagerDelegate> delegate;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* videoPreview;


@end




