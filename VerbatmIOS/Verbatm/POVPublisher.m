//
//  Uploader.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVPublisher.h"
#import "PinchView.h"

@implementation POVPublisher

+(void) publishPOVFromPinchViews: (NSArray*) pinchViews {
	//Make Verbatm POV object, store all pages in it

	//TODO: Go through pinch objects and save each image and video! (Get url from server and upload it to that url)
	for (PinchView* pinchView in pinchViews) {
		[self sortPinchView:pinchView];
	}
}

+(void)sortPinchView:(PinchView*)pinchView {

	if(pinchView.containsText){
		//		TODO: self.text = [pinchObject getText];
	}

	if(pinchView.containsImage) {
		NSArray* photos = [pinchView getPhotos];
//		for (UIImage* image in photos) {
//			Photo* photo = [[Photo alloc]initWithData:UIImagePNGRepresentation(image) withCaption:nil andName:nil atLocation:nil];
//			[photo setObject: self forKey:PAGE_PHOTO_RELATIONSHIP];
//			[photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//				if(succeeded){
//					NSLog(@"Photo for page saved");
//				}else{
//					NSLog(@"Photo for page did not save");
//				}
//			}];
//		}

	}

	if(pinchView.containsVideo) {
		NSArray* videos = [pinchView getVideos];
//		for (AVURLAsset* videoAsset in videos) {
//			//TODO(sierra): This should not happen on main thread
//			NSData* videoData = [self dataFromAVURLAsset:videoAsset];
//			Video* video = [[Video alloc] initWithData:videoData withCaption:nil andName:nil atLocation:nil];
//			[video setObject:self forKey:PAGE_VIDEO_RELATIONSHIP];
//			[video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//				if(succeeded){
//					NSLog(@"Video for page saved");
//				}else{
//					NSLog(@"Video for page did not save");
//				}
//			}];
//		}
	}
}

@end
