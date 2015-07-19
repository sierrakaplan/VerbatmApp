//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Analyzer.h"
#import "VerbatmImageView.h"
#import "PinchView.h"
#import "VideoAVE.h"
#import "TextAVE.h"
#import "MultiplePhotoVideoAVE.h"
#import "MultiplePhotoAVE.h"
#import "TextAndOtherAves.h"
#import "constants.h"

//PS REMEMBER TO SET AUTO RESIZING SUBVIEWS FOR THE CLASSES OF PINCHED OBJECTS
@interface Analyzer()
@property(nonatomic, strong)NSMutableArray* results;
@property(strong, nonatomic) NSMutableArray* pinchedObjects;
@property(nonatomic) CGRect preferredFrame;
@end
@implementation Analyzer
@synthesize pinchedObjects = _pinchedObjects;
@synthesize preferredFrame = _preferredFrame;
@synthesize results = _results;

-(NSMutableArray*)processPinchedObjectsFromArray:(NSMutableArray*)arr withFrame:(CGRect)frame
{
	_pinchedObjects = arr;
	_preferredFrame = frame;
	_results = [[NSMutableArray alloc]init];
	for(PinchView* p_obj in _pinchedObjects)
	{
		//there are some issue where a messed up p_obj arrives
		if(!(p_obj.there_is_picture || p_obj.there_is_text || p_obj.there_is_video))continue;
		if(![p_obj isCollection])
		{
			[self handleSingleMedia:p_obj];
			continue;
		}
		if(p_obj.there_is_picture && p_obj.there_is_text && p_obj.there_is_video){
			[self handleThreeMedia:p_obj];
			continue;
		}
		[self handleTwoMedia:p_obj];
	}

	return _results;
}

-(void)handleSingleMedia:(PinchView*)p_obj
{
	NSMutableArray *arr = [[NSMutableArray alloc]init];

	arr = (p_obj.there_is_picture)? [p_obj getPhotos] : [p_obj getVideos];

	if(p_obj.there_is_picture)
	{
		//multiple photo and single photo call the same class
		MultiplePhotoAVE* imageView = [[MultiplePhotoAVE alloc]initWithFrame:_preferredFrame andPhotoArray:arr];

		[_results addObject:imageView];

	}else if(p_obj.there_is_text)
	{
		TextAVE* textView = [[TextAVE alloc]initWithFrame:_preferredFrame];
		[textView setTextViewText: [p_obj getTextFromPinchObject]];
		[_results addObject:textView];
	}else{
		VideoAVE* vidView = [[VideoAVE alloc]initWithFrame:_preferredFrame andAssets:arr];
		[vidView muteVideo];
		[_results addObject:vidView];
	}
}


-(void)handleTwoMedia:(PinchView*)p_obj
{

	NSMutableArray * photos = [p_obj getPhotos];
	NSMutableArray * videos = [p_obj getVideos];
	if(p_obj.there_is_text)
	{
		if(photos.count)//it's text photo
		{
            TextAndOtherAves * textViewAndPhoto = [[TextAndOtherAves alloc] initWithFrame:self.preferredFrame text:[p_obj getTextFromPinchObject] aveType:PHOTO_AVE aveMedia:photos];
            [textViewAndPhoto addGestureToView];
			[self.results addObject:textViewAndPhoto];
		}else//it's text video
		{
			
            TextAndOtherAves * textViewAndPhoto = [[TextAndOtherAves alloc] initWithFrame:self.preferredFrame text:[p_obj getTextFromPinchObject] aveType:VIDEO_AVE aveMedia:videos];
            [textViewAndPhoto addGestureToView];
            [self.results addObject:textViewAndPhoto];
		}
	}else//it's photo video
	{
		if(photos.count > 1)
		{
			MultiplePhotoVideoAVE * pv = [[MultiplePhotoVideoAVE alloc]initWithFrame:self.preferredFrame Photos:photos andVideos:videos];
			[pv mutePlayer];
			[self.results addObject:pv];
		}else
		{

			MultiplePhotoVideoAVE* mpv = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferredFrame Photos:photos andVideos:videos];
			[mpv mutePlayer];
			[self.results addObject:mpv];
		}
	}
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

-(void)handleThreeMedia:(PinchView*)p_obj
{
    NSMutableArray * combined = [NSMutableArray arrayWithArray:[p_obj getVideos]];
    [combined addObjectsFromArray:[p_obj getPhotos]];
    TextAndOtherAves * textViewAndPhoto = [[TextAndOtherAves alloc] initWithFrame:self.preferredFrame text:[p_obj getTextFromPinchObject] aveType:PHOTO_VIDEO_AVE aveMedia:combined];
    [textViewAndPhoto addGestureToView];
    [self.results addObject:textViewAndPhoto];
}


-(NSData*)getDataFromAsset:(ALAsset*)asset
{
	ALAssetRepresentation *rep = [asset defaultRepresentation];
	Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
	NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length: (unsigned long)rep.size error:nil];
	return [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
}
@end
