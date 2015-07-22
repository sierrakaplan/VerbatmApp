//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "AVETypeAnalyzer.h"
#import "VerbatmImageView.h"
#import "PinchView.h"
#import "VideoAVE.h"
#import "TextAVE.h"
#import "MultiplePhotoVideoAVE.h"
#import "MultiplePhotoAVE.h"
#import "TextAndOtherMediaAVE.h"

//PS REMEMBER TO SET AUTO RESIZING SUBVIEWS FOR THE CLASSES OF PINCHED OBJECTS
@interface AVETypeAnalyzer()
@property(nonatomic, strong)NSMutableArray* results;
@property(strong, nonatomic) NSMutableArray* pinchedObjects;
@property(nonatomic) CGRect preferredFrame;
@end
@implementation AVETypeAnalyzer
@synthesize pinchedObjects = _pinchedObjects;
@synthesize preferredFrame = _preferredFrame;
@synthesize results = _results;

-(NSMutableArray*)processPinchedObjectsFromArray:(NSMutableArray*)arr withFrame:(CGRect)frame
{
	self.pinchedObjects = arr;
	self.preferredFrame = frame;
	self.results = [[NSMutableArray alloc]init];
	for(PinchView* pinchView in self.pinchedObjects)
	{
		//there are some issue where a messed up p_obj arrives
		if(!(pinchView.containsPhoto || pinchView.containsText || pinchView.containsVideo)) {
			NSLog(@"Pinch view says it has no type of media in it.");
			continue;
		}

		if (pinchView.containsText) {
			[self handleTextAVES:pinchView];
		} else if (pinchView.containsPhoto && pinchView.containsVideo) {
			[self handlePhotoVideo:pinchView];
		} else if (pinchView.containsPhoto) {
			MultiplePhotoAVE* photoAVE = [[MultiplePhotoAVE alloc]initWithFrame:self.preferredFrame andPhotoArray:[pinchView getPhotos]];
			[self.results addObject:photoAVE];
		} else if (pinchView.containsVideo) {
			VideoAVE* videoAVE = [[VideoAVE alloc]initWithFrame:self.preferredFrame andVideoAssetArray:[pinchView getVideos]];
			[videoAVE muteVideo];
			[self.results addObject:videoAVE];
		}
	}

	return self.results;
}

-(void) handleTextAVES: (PinchView*) pinchView {
	NSString* text = [pinchView getText];
	AVEType type;

	if (pinchView.containsPhoto && pinchView.containsVideo) {
		type = AVETypePhotoVideo;

	} else if (pinchView.containsPhoto) {
		type = AVETypePhoto;

	} else if(pinchView.containsVideo) {
		type = AVETypeVideo;

	} else {
		TextAVE* textAVE = [[TextAVE alloc]initWithFrame:self.preferredFrame];
		[textAVE setTextViewText: text];
		[self.results addObject:textAVE];
		return;
	}
	TextAndOtherMediaAVE * textAndOtherMediaAVE = [[TextAndOtherMediaAVE alloc] initWithFrame:self.preferredFrame andText:text andPhotos:[pinchView getPhotos] andVideos:[pinchView getVideos] andAVEType:type];
	[self.results addObject:textAndOtherMediaAVE];
}

-(void) handlePhotoVideo:(PinchView*)pinchView {

	MultiplePhotoVideoAVE* multiPhotoVideoAVE = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferredFrame andPhotos:[pinchView getPhotos] andVideos:[pinchView getVideos]];
	[multiPhotoVideoAVE mutePlayer];
	[self.results addObject:multiPhotoVideoAVE];
}


//give it an array of custom image views it gives you back uiimages
-(NSMutableArray *) getUIImage: (NSMutableArray *) array
{

	NSMutableArray * parray = [[NSMutableArray alloc] init];

	for(VerbatmImageView * imageV  in array)
	{
		[parray addObject:imageV.image];
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
