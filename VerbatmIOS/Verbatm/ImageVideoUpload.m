//
//  ImageVideoUpload.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ImageVideoUpload.h"

@implementation ImageVideoUpload

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

	return self;
}

-(instancetype) initWithVideoData: (NSData*)videoData  andUri: (NSString*)uri {

// TODO: somewhere else
//	NSURL *fileURL = nil;
//	AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset: videoAsset
//																		   presetName:AVAssetExportPresetHighestQuality];
//
//	exportSession.outputURL = fileURL;
//
//	[exportSession exportAsynchronouslyWithCompletionHandler:^{
//		NSData* videoData = [NSData dataWithContentsOfURL: fileURL];
//		NSLog(@"AVAsset saved to NSData.");
//			  }];

	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];

	[self.formData setData:videoData
			  withFileName:@"defaultVideo.mov"
			andContentType:@"video/quicktime"
					forKey:@"defaultVideo"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];

	return self;
}

-(void) startUpload {

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
	NSLog(@"upload finished");
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"error %@", error);
}


@end
