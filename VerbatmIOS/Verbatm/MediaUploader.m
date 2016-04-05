//
//  ImageVideoUpload.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "MediaUploader.h"
#import "PostPublisher.h"
#import "Notifications.h"
#import "PublishingProgressManager.h"

@interface MediaUploader()

@property (nonatomic, strong) ASIFormDataRequest *formData;
@property (nonatomic, strong) MediaUploadCompletionBlock completionBlock;

@end

@implementation MediaUploader

@synthesize formData;

-(instancetype) initWithImage:(UIImage*)img andUri: (NSString*)uri {
	NSData *imageData = UIImagePNGRepresentation(img);

	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];
	[self.formData setData:imageData
			  withFileName:@"defaultImage.png"
			andContentType:@"image/png"
					forKey:@"defaultImage"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];
	[self.formData setTimeOutSeconds: 60];
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: IMAGE_PROGRESS_UNITS-1];

	return self;
}

//Maybe could do this with Promise NSURLConnection?
-(instancetype) initWithVideoData: (NSData*)videoData  andUri: (NSString*)uri {
	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];

	[self.formData setData:videoData
			  withFileName:@"defaultVideo.mov"
			andContentType:@"video/quicktime"
					forKey:@"defaultVideo"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];
	// Needs to be long in order to allow long videos to upload
	[self.formData setTimeOutSeconds: 300];
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: VIDEO_PROGRESS_UNITS-1];

	return self;
}

-(long long) getPostLength {
	return [self.formData postLength];
}

-(AnyPromise*) startUpload {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self startWithCompletionHandler: ^(NSError* error, NSString* responseURL) {
			if (error) {
				resolve(error);
			} else {
				resolve(responseURL);
			}
		}];
	}];

	return promise;
}

-(void) startWithCompletionHandler:(MediaUploadCompletionBlock) completionBlock {
	self.completionBlock = completionBlock;
	[self.formData startAsynchronous];
}

#pragma mark Delegate methods

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([request totalBytesSent] > 0) {
            float progressAmount = ((float)[request totalBytesSent]/(float)[request postLength]);
            NSInteger newProgressUnits = (NSInteger)(progressAmount*(float)self.mediaUploadProgress.totalUnitCount);
            if (newProgressUnits != self.mediaUploadProgress.completedUnitCount) {
                [[PublishingProgressManager sharedInstance] mediaSavingProgressed:(newProgressUnits - self.mediaUploadProgress.completedUnitCount)];
                self.mediaUploadProgress.completedUnitCount = newProgressUnits;
                NSLog(@"media upload progress: %ld out of %ld", (long)newProgressUnits, (long)self.mediaUploadProgress.totalUnitCount);
            }
        }
    });
}

-(void) requestFinished:(ASIHTTPRequest *)request {
	//The response string is a blobkeystring and an imagesservice servingurl for image
	NSString* responseString = [request responseString];
	if (!responseString.length) {
		[self requestFailed:request];
	} else {
		NSLog(@"Successfully uploaded media!");
		[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
		self.completionBlock(nil, responseString);
	}
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"error uploading media%@", error);
	[[PublishingProgressManager sharedInstance] savingMediaFailed];
	[self.mediaUploadProgress cancel];
	self.completionBlock(error, nil);
}


@end
