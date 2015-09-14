//
//  BlobstoreUploader.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/12/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "BlobstoreUploader.h"
#import "ASIHTTPRequest.h"
#import "MediaUploader.h"

@interface BlobstoreUploader()

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSData* videoData;

@end

@implementation BlobstoreUploader

-(void) uploadImage: (UIImage*) image {
	self.videoData = nil;
	self.image = image;
	[self getUploadURI];
}

-(void) uploadVideo: (NSData*) videoData {
	self.image = nil;
	self.videoData = videoData;
	[self getUploadURI];
}

-(void) getUploadURI {

	NSURL *uri = [NSURL URLWithString:@"https://verbatmapp.appspot.com/media/createUploadURI"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:uri];
	[request setDelegate:self];
	[request startAsynchronous];
}

-(void) requestFinished:(ASIHTTPRequest *)request {

	MediaUploader * mediaUpload;
	NSString *uri = (NSString*)[request responseData];
	if (self.image) {
		mediaUpload = [[MediaUploader alloc] initWithImage:self.image andUri:uri];
	} else if (self.videoData) {
		mediaUpload = [[MediaUploader alloc] initWithVideoData:self.videoData andUri:uri];
	} else {
		return;
	}

	[mediaUpload startUpload];
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"Error getting URI for media: %@", error.description);
}

@end
