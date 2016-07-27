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

@property (nonatomic, strong) AFHTTPSessionManager *operationManager;

@end

@implementation MediaUploader

-(instancetype) init {
	self.operationManager = [AFHTTPSessionManager manager];
	self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
	return self;
}

-(AnyPromise*) uploadVideoWithUrl:(NSURL*)videoURL andUri:(NSString*)uri {
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: VIDEO_PROGRESS_UNITS];
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		self.operationManager = [AFHTTPSessionManager manager];
		self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
		[self.operationManager POST:uri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull multipartFormData) {
			NSError *error;
			if (![multipartFormData appendPartWithFileURL:videoURL name:@"defaultVideo" fileName:videoURL.lastPathComponent mimeType:@"video/quicktime" error:&error]) {
				[self savingMediaFailed:error];
				resolve(error);
			}
		} progress:^(NSProgress * _Nonnull uploadProgress) {
			float progressAmount = ((float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
			NSInteger newProgressUnits = (NSInteger)(progressAmount*(float)self.mediaUploadProgress.totalUnitCount);
			if (newProgressUnits != self.mediaUploadProgress.completedUnitCount) {
				[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(NSInteger)(newProgressUnits - self.mediaUploadProgress.completedUnitCount)];
				self.mediaUploadProgress.completedUnitCount = newProgressUnits;
				NSLog(@"media upload progress: %ld out of %ld", (long)newProgressUnits, (long)self.mediaUploadProgress.totalUnitCount);
			}
		} success:^(NSURLSessionDataTask * _Nonnull task, NSData* responseData) {
			[[PublishingProgressManager sharedInstance] mediaSavingProgressed:(NSInteger)(self.mediaUploadProgress.totalUnitCount - self.mediaUploadProgress.completedUnitCount)];
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

-(AnyPromise*) uploadImageWithName:(NSString*)fileName andData:(NSData*)imageData andUri:(NSString*)uri {
	self.mediaUploadProgress = [NSProgress progressWithTotalUnitCount: IMAGE_PROGRESS_UNITS];
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.operationManager POST:uri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull multipartFormData) {
			[multipartFormData appendPartWithFileData:imageData name:@"defaultImage" fileName:fileName mimeType:@"image/png"];
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
