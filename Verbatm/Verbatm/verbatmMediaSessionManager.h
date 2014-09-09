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

@interface verbatmMediaSessionManager : NSObject

-(instancetype)initSessionWithView:(UIView*)containerView;
-(void)captureImage;
-(void)startVideoRecording;
-(void)stopVideoRecording;
-(void)setSessionOrientationToDeviceOrientation;
-(void)setToFrameOfView:(UIView*)containerView;
-(void)switchVideoFace;
-(void)switchFlash;
-(void)startSession;
-(void)stopSession;
@end
