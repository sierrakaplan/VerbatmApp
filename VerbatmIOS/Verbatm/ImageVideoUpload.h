//
//  ImageVideoUpload.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ASIFormDataRequest.h"

@interface ImageVideoUpload : NSObject

	@property (nonatomic, strong) ASIFormDataRequest *formData;
	@property (nonatomic, assign) float progress;

	-(instancetype) initWithImage: (UIImage*)img andUri: (NSString*)uri;
	-(instancetype) initWithVideoData: (NSData*)videoData  andUri: (NSString*)uri;
	-(void) startUpload;

@end
