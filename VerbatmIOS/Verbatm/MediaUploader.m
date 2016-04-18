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
#import "AFNetworking/AFHTTPSessionManager.h"
#import "AFNetworking/AFNetworking.h"

@interface MediaUploader()

@property (nonatomic, strong) ASIFormDataRequest *formData;
@property (nonatomic, strong) MediaUploadCompletionBlock completionBlock;

@end

@implementation MediaUploader

@synthesize formData;

-(instancetype) initWithImage:(NSData*)imageData andUri: (NSString*)uri {
	NSLog(@"Image size is : %.2f KB",(float)imageData.length/1024.0f);
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
		NSLog(@"Successfully uploaded media!");
		[self.mediaUploadProgress setCompletedUnitCount: self.mediaUploadProgress.totalUnitCount];
		responseString = [responseString stringByAppendingString:@"=s0"];
		self.completionBlock(nil, responseString);
	}
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"error uploading media%@", error.description);
	[[PublishingProgressManager sharedInstance] savingMediaFailed];
	[self.mediaUploadProgress cancel];
	self.completionBlock(error, nil);
}

/* NOT IN USE */
+(AnyPromise *) uploadImageData: (NSData*) imageData toUri: (NSString*) uri {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {

		NSLog(@"Image size is : %.2f KB",(float)imageData.length/1024.0f);
		AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:uri]];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		//		NSDictionary *parameters = @{};//@{@"username": @"", @"password" : @""};
		AFHTTPRequestOperation *op = [manager POST:uri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> afFormData) {
			//do not put image inside parameters dictionary as I did, but append it!
			[afFormData appendPartWithFileData:imageData name:@"defaultImage" fileName:@"defaultImage.png" mimeType:@"image/png"];

		} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
			[[PublishingProgressManager sharedInstance] mediaSavingProgressed:IMAGE_PROGRESS_UNITS-1];
			NSString *responseURL = [operation responseString];
			[responseURL stringByAppendingString:@"=s0"];
			resolve (responseURL);
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@ ***** %@", operation.responseString, error);
			resolve (error);
		}];
		op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
		[op start];

	}];
	return promise;
}

@end
