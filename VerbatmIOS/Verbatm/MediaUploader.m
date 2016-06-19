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

#import <AFNetworking/AFNetworking.h>

@interface MediaUploader()

//@property (nonatomic, strong) ASIFormDataRequest *formData;
//@property (nonatomic, strong) MediaUploadCompletionBlock completionBlock;

@property (nonatomic, strong) AFHTTPSessionManager *operationManager;

@end

@implementation MediaUploader

//@synthesize formData;

//-(instancetype) initWithImage:(NSData*)imageData andUri: (NSString*)uri {
//	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];
//	[self.formData setData:imageData
//			  withFileName:@"defaultImage.png"
//			andContentType:@"image/png"
//					forKey:@"defaultImage"];
//	[self.formData setDelegate:self];
//	[self.formData setUploadProgressDelegate:self];
//	[self.formData setTimeOutSeconds: 60];
//	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: IMAGE_PROGRESS_UNITS-1];
//
//	return self;
//}
////Maybe could do this with Promise NSURLConnection?
//-(instancetype) initWithVideoData: (NSData*)videoData  andUri: (NSString*)uri {
//	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];
//
//	[self.formData setData:videoData
//			  withFileName:@"defaultVideo.mp4"
//			andContentType:@"video/mp4"
//					forKey:@"defaultVideo"];
//	[self.formData setDelegate:self];
//	[self.formData setUploadProgressDelegate:self];
//	// Needs to be long in order to allow long videos to upload
//	[self.formData setTimeOutSeconds: 300];
//	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: VIDEO_PROGRESS_UNITS-1];
//
//	return self;
//}

-(instancetype) init {
	self.operationManager = [AFHTTPSessionManager manager];
	self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
	return self;
}

//-(AnyPromise*) startUpload {
//	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
//		[self startWithCompletionHandler: ^(NSError* error, NSString* responseURL) {
//			if (error) {
//				resolve(error);
//			} else {
//				resolve(responseURL);
//			}
//		}];
//	}];
//
//	return promise;
//}
//
//-(void) startWithCompletionHandler:(MediaUploadCompletionBlock) completionBlock {
//	self.completionBlock = completionBlock;
//	[self.formData startAsynchronous];
//}

//#pragma mark Delegate methods
//
//- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        if ([request totalBytesSent] > 0) {
//            float progressAmount = ((float)[request totalBytesSent]/(float)[request postLength]);
//            NSInteger newProgressUnits = (NSInteger)(progressAmount*(float)self.mediaUploadProgress.totalUnitCount);
//            if (newProgressUnits != self.mediaUploadProgress.completedUnitCount) {
//                [[PublishingProgressManager sharedInstance] mediaSavingProgressed:(newProgressUnits - self.mediaUploadProgress.completedUnitCount)];
//                self.mediaUploadProgress.completedUnitCount = newProgressUnits;
//                NSLog(@"media upload progress: %ld out of %ld", (long)newProgressUnits, (long)self.mediaUploadProgress.totalUnitCount);
//            }
//        }
//    });
//}
//
//-(void) requestFinished:(ASIHTTPRequest *)request {
//	//The response string is a blobkeystring and an imagesservice servingurl for image
//	NSString* responseString = [request responseString];
//	if (!responseString.length) {
//		[self requestFailed:request];
//	} else {
//		[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
//		self.completionBlock(nil, responseString);
//	}
//}
//
//-(void) requestFailed:(ASIHTTPRequest *)request {
//	NSError *error = [request error];
//	[[Crashlytics sharedInstance] recordError: error];
//	[[PublishingProgressManager sharedInstance] savingMediaFailedWithError:error];
//	[self.mediaUploadProgress cancel];
//	self.completionBlock(error, nil);
//}

#pragma mark - NSURLSESSION -

-(AnyPromise*) uploadVideoWithUrl:(NSURL*)videoURL andUri:(NSString*)uri {
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: VIDEO_PROGRESS_UNITS-1];
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		self.operationManager = [AFHTTPSessionManager manager];
		self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
		[self.operationManager POST:uri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull multipartFormData) {
			NSError *error;
			if (![multipartFormData appendPartWithFileURL:videoURL name:@"defaultVideo" fileName:@"defaultVideo.mp4" mimeType:@"video/mp4" error:&error]) {
				NSLog(@"error appending part: %@", error);
				[self savingMediaFailed:error];
				resolve(error);
			}
		} progress:^(NSProgress * _Nonnull uploadProgress) {
			float progressAmount = ((float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
			NSInteger newProgressUnits = (NSInteger)(progressAmount*(float)self.mediaUploadProgress.totalUnitCount);
			if (newProgressUnits != self.mediaUploadProgress.completedUnitCount) {
				[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(newProgressUnits - self.mediaUploadProgress.completedUnitCount)];
				self.mediaUploadProgress.completedUnitCount = newProgressUnits;
				NSLog(@"media upload progress: %ld out of %ld", (long)newProgressUnits, (long)self.mediaUploadProgress.totalUnitCount);
			}
		} success:^(NSURLSessionDataTask * _Nonnull task, NSData* responseData) {
			[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(self.mediaUploadProgress.totalUnitCount - self.mediaUploadProgress.completedUnitCount)];
			[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
			NSLog(@"Video published!");
			NSString *response = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
			resolve(response);
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[self savingMediaFailed: error];
			resolve(error);
		}];

	}];

	return promise;
}

-(AnyPromise*) uploadImageWithData:(NSData*)imageData andUri:(NSString*)uri {
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: IMAGE_PROGRESS_UNITS-1];
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.operationManager POST:uri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull multipartFormData) {
			[multipartFormData appendPartWithFileData:imageData name:@"defaultImage" fileName:@"defaultImage.png" mimeType:@"image/png"];
		} progress:^(NSProgress * _Nonnull uploadProgress) {
			float progressAmount = ((float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
			NSInteger newProgressUnits = (NSInteger)(progressAmount*(float)self.mediaUploadProgress.totalUnitCount);
			if (newProgressUnits != self.mediaUploadProgress.completedUnitCount) {
				[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(newProgressUnits - self.mediaUploadProgress.completedUnitCount)];
				self.mediaUploadProgress.completedUnitCount = newProgressUnits;
				NSLog(@"media upload progress: %ld out of %ld", (long)newProgressUnits, (long)self.mediaUploadProgress.totalUnitCount);
			}
		} success:^(NSURLSessionDataTask * _Nonnull task, NSData* responseData) {
			[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(self.mediaUploadProgress.totalUnitCount - self.mediaUploadProgress.completedUnitCount)];
			[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
			NSLog(@"Image published!");
			NSString *response = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
			resolve(response);
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[self savingMediaFailed: error];
			resolve(error);
		}];

	}];

	return promise;
}

-(void) savingMediaFailed:(NSError*)error {
	[[Crashlytics sharedInstance] recordError: error];
	[[PublishingProgressManager sharedInstance] savingMediaFailedWithError:error];
	[self.mediaUploadProgress cancel];
}


@end
