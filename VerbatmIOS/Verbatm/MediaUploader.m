//
//  ImageVideoUpload.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "MediaUploader.h"


@interface MediaUploader()

@property (nonatomic, strong) ASIFormDataRequest *formData;
@property (strong, nonatomic) MediaUploadCompletionBlock completionBlock;

@end


@implementation MediaUploader

@synthesize formData, progress;

-(instancetype) initWithImage:(UIImage*)img andUri: (NSString*)uri {

	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];

	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];

	[self.formData setData:imageData
			  withFileName:@"defaultImage.png"
			andContentType:@"image/png"
					forKey:@"defaultImage"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];
	// Needs to be long in order to allow long videos to upload
	[self.formData setTimeOutSeconds: 180];

	return self;
}

//Maybe could do this with Promise NSURLConnection?
-(instancetype) initWithVideoData: (NSData*)videoData  andUri: (NSString*)uri {

	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];

	[self.formData setData:videoData
			  withFileName:@"defaultVideo.mov"
			andContentType:@"video/mp4"
					forKey:@"defaultVideo"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];

	return self;
}

-(PMKPromise*) startUpload {

	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
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

#pragma mark Upload Progress Tracking

- (void)request:(ASIHTTPRequest *)theRequest didSendBytes:(long long)newLength {

	if ([theRequest totalBytesSent] > 0) {
		float progressAmount = (float) ([theRequest totalBytesSent]/[theRequest postLength]);
		self.progress = progressAmount;
	}
}

-(void) requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"upload media finished");
	//The response string is a blobkey string for video and an imagesservice servingurl for image
	NSString* responseString = [request responseString];
	self.completionBlock(nil, responseString);
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"error uploading media%@", error);
	self.completionBlock(error, nil);
}


@end
