//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "AVETypeAnalyzer.h"
#import "PinchView.h"
#import "CollectionPinchView.h"
#import "TextPinchView.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"
#import "VideoAVE.h"
#import "TextAVE.h"
#import "MultiplePhotoVideoAVE.h"
#import "BaseArticleViewingExperience.h"

//PS REMEMBER TO SET AUTO RESIZING SUBVIEWS FOR THE CLASSES OF PINCHED OBJECTS
@interface AVETypeAnalyzer()

@property(nonatomic, strong) NSMutableArray* results;
@property(nonatomic) CGRect preferredFrame;
@end
@implementation AVETypeAnalyzer
@synthesize preferredFrame = _preferredFrame;
@synthesize results = _results;

-(NSMutableArray*)processPinchedObjectsFromArray:(NSMutableArray*)pinchedObjects withFrame:(CGRect)frame {

	self.preferredFrame = frame;
	self.results = [[NSMutableArray alloc]init];
	for(PinchView* pinchView in pinchedObjects) {

		//there are some issue where a messed up p_obj arrives
		if(!(pinchView.containsImage || pinchView.containsText || pinchView.containsVideo)) {
			NSLog(@"Pinch view says it has no type of media in it.");
			continue;
		}

		[self handleAVES:pinchView];
	}

	return self.results;
}

-(void) handleAVES: (PinchView*) pinchView {

	if([pinchView isKindOfClass:[TextPinchView class]]) {
		TextAVE* textAVE = [[TextAVE alloc]initWithFrame:self.preferredFrame andText:[pinchView getText]];
		[self.results addObject:textAVE];
		return;
	}

	AVEType type;

	if (pinchView.containsImage && pinchView.containsVideo) {
		type = AVETypePhotoVideo;
	} else if (pinchView.containsImage) {
		type = AVETypePhoto;
	} else if(pinchView.containsVideo) {
		type = AVETypeVideo;
	}

	BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame:self.preferredFrame andText:[pinchView getText] andPhotos:[pinchView getPhotos] andVideos:[pinchView getVideos] andAVEType:type];
	[self.results addObject:textAndOtherMediaAVE];
}

-(void) handlePhotoVideo:(PinchView*)pinchView {

	MultiplePhotoVideoAVE* multiPhotoVideoAVE = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferredFrame andPhotos:[pinchView getPhotos] andVideos:[pinchView getVideos]];
	[multiPhotoVideoAVE mutePlayer];
	[self.results addObject:multiPhotoVideoAVE];
}


//give it an array of image views it gives you back uiimages
-(NSMutableArray *) getUIImage: (NSMutableArray *) array {

	NSMutableArray * parray = [[NSMutableArray alloc] init];

	for(UIImageView * imageView  in array) {
		[parray addObject:imageView.image];
	}

	return parray;
}


-(NSData*)getDataFromAsset:(ALAsset*)asset
{
	ALAssetRepresentation *rep = [asset defaultRepresentation];
	Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
	NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length: (unsigned long)rep.size error:nil];
	return [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
}
@end
