//
//  ImageVideoUpload.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "MediaUploader.h"
#import "PostPublisher.h"
#import "Notifications.h"
#import "PublishingProgressManager.h"
#import <PromiseKit/PromiseKit.h>

@interface MediaUploader() <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) ASIFormDataRequest *formData;
@property (nonatomic, strong) MediaUploadCompletionBlock completionBlock;

@end

@implementation MediaUploader

@synthesize formData;

-(instancetype) initWithImage:(NSData*)imageData andUri: (NSString*)uri {
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
			  withFileName:@"defaultVideo.mp4"
			andContentType:@"video/mp4"
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
		[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
		self.completionBlock(nil, responseString);
	}
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	[[Crashlytics sharedInstance] recordError: error];
	[[PublishingProgressManager sharedInstance] savingMediaFailedWithError:error];
	[self.mediaUploadProgress cancel];
	self.completionBlock(error, nil);
}

#pragma mark - NSURLSESSION -

-(AnyPromise*) uploadVideoWithUrl:(NSURL*)videoURL andUri:(NSString*)uri {
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: VIDEO_PROGRESS_UNITS-1];
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		//Prepare upload request
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:uri]];
		[request setHTTPMethod:@"PUT"];
		[request setValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
		[request setValue:[NSString stringWithFormat:@"attachment; filename=defaultVideo.mp4"] forHTTPHeaderField:@"Content-Disposition"];
		[request setValue:@"defaultVideo.mp4" forHTTPHeaderField:@"fileName"];

		//todo: make all publishing happen on same session
		NSURLSession* session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
		NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromFile:videoURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (error) {
				resolve(error);
			} else {
				[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
				resolve([[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSISOLatin1StringEncoding]);
			}
		}];
		[task resume];
	}];

	return promise;
}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
	totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

	float progressAmount = ((float)totalBytesSent/(float)totalBytesExpectedToSend);
	NSInteger newProgressUnits = (NSInteger)(progressAmount*(float)self.mediaUploadProgress.totalUnitCount);
	if (newProgressUnits != self.mediaUploadProgress.completedUnitCount) {
		[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(newProgressUnits - self.mediaUploadProgress.completedUnitCount)];
		self.mediaUploadProgress.completedUnitCount = newProgressUnits;
		NSLog(@"media upload progress: %ld out of %ld", (long)newProgressUnits, (long)self.mediaUploadProgress.totalUnitCount);
	}
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
	NSURLResponse *response = task.response;
	if (error || !response) {
		[[Crashlytics sharedInstance] recordError: error];
		[[PublishingProgressManager sharedInstance] savingMediaFailedWithError:error];
		[self.mediaUploadProgress cancel];
		self.completionBlock(error, nil);
		return;
	}
	//todo: let something know it finished?
}

@end
