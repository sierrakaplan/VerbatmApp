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
#import "PhotoVideoTextAVE.h"
#import "MultiplePhotoVideoAVE.h"
#import "MultiVidTextPhotoAVE.h"
#import "TextVideoAVE.h"
#import "PhotoVideoAVE.h"
#import "MultiplePhotoAVE.h"
#import "MultiPhotoTextAVE.h"

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
			TextPhotoAVE * tp = [[TextPhotoAVE alloc] initWithFrame:self.preferredFrame andImage:photos.firstObject andText:[p_obj getTextFromPinchObject]];
			[tp addSwipeGesture];
			[self.results addObject:tp];
		}else//it's text video
		{
			TextVideoAVE * textVideoAVE = [[TextVideoAVE alloc] initWithFrame:self.preferredFrame andAssets:videos andText:[p_obj getTextFromPinchObject]];
			[textVideoAVE muteVideo];
			[textVideoAVE addSwipeGesture];
			[self.results addObject:textVideoAVE];
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
	NSString* text = [p_obj getTextFromPinchObject];
	//	if(p_obj.inDataFormat)
	//	{
	NSMutableArray* videos = [p_obj getVideos];
	NSMutableArray* photos = [p_obj getPhotos];
	if(videos.count + photos.count == 2){
		PhotoVideoTextAVE* pvt = [[PhotoVideoTextAVE alloc] initWithFrame:_preferredFrame forImageData: (NSData*)[photos firstObject] andText:text andVideo:[videos firstObject]];
		[pvt addSwipeGesture];
		[_results addObject:pvt];
	}else{
		MultiVidTextPhotoAVE* mvtp = [[MultiVidTextPhotoAVE alloc]initWithFrame:_preferredFrame Photos:photos andVideos:videos andText:text];
		[mvtp addSwipeGesture];
		[_results addObject:mvtp];
	}

}


-(NSData*)getDataFromAsset:(ALAsset*)asset
{
	ALAssetRepresentation *rep = [asset defaultRepresentation];
	Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
	NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length: (unsigned long)rep.size error:nil];
	return [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
}
@end
