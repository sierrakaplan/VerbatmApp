//
//  verbatmAVCaptureSession.h
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol MediaSessionManagerDelegate<NSObject>
@optional
//notifies any one conforming to the protocol that an asset has been saved.
-(void)didFinishSavingMediaToAsset:(ALAsset*)asset;
@end
@interface MediaSessionManager : NSObject


-(instancetype)initSessionWithView:(UIView*)containerView;
-(void)focusAtPoint:(CGPoint)viewCoordinates;
- (void) zoomPreviewWithScale:(float)effectiveScale;
-(void)captureImage:(BOOL)halfScreen;
-(void)startVideoRecordingInOrientation:(UIDeviceOrientation)startOrientation;
-(void)stopVideoRecording;
-(void)setSessionOrientationToOrientation:(UIDeviceOrientation)orientation;
-(void)setToFrameOfView:(UIView*)containerView;
-(void)switchVideoFace;
-(void)switchFlash;
-(void)startSession;
-(void)stopSession;
-(void) rerunSession;
@property(strong, nonatomic) NSURL* outputurl;
@property (nonatomic, strong) id <MediaSessionManagerDelegate> delegate;
@property (nonatomic, strong) UIImage* stillImage;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* videoPreview;
@end
