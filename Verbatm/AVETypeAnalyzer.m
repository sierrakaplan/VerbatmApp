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
#import "TextAndOtherAves.h"

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
	_pinchedObjects = arr;
	_preferredFrame = frame;
	_results = [[NSMutableArray alloc]init];
	for(PinchView* pinchView in _pinchedObjects)
	{
		//there are some issue where a messed up p_obj arrives
		if(!(pinchView.containsPicture || pinchView.containsText || pinchView.containsVideo))continue;
		if(![pinchView isCollection])
		{
			[self handleSingleMedia:pinchView];
			continue;
		}
		if(pinchView.containsPicture && pinchView.containsText && pinchView.containsVideo){
			[self handleThreeMedia:pinchView];
			continue;
		}
		[self handleTwoMedia:pinchView];
	}

	return _results;
}

-(void)handleSingleMedia:(PinchView*)p_obj
{
	NSMutableArray *arr = [[NSMutableArray alloc]init];

	arr = (p_obj.containsPicture)? [p_obj getPhotos] : [p_obj getVideos];

	if(p_obj.containsPicture)
	{
		//multiple photo and single photo call the same class
		MultiplePhotoAVE* imageView = [[MultiplePhotoAVE alloc]initWithFrame:_preferredFrame andPhotoArray:arr];

		[_results addObject:imageView];

	}else if(p_obj.containsText)
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


-(void)handleTwoMedia:(PinchView*)p_obj {

	NSMutableArray * photos = [p_obj getPhotos];
	NSMutableArray * videos = [p_obj getVideos];
	if(p_obj.containsText)
	{
		//it's text photo
		if(photos.count)
		{
            TextAndOtherAves * textViewAndPhoto = [[TextAndOtherAves alloc] initWithFrame:self.preferredFrame text:[p_obj getTextFromPinchObject] aveType:AVETypePhoto aveMedia:photos];
			[self.results addObject:textViewAndPhoto];

        }else{
			
            TextAndOtherAves * textViewAndVideo = [[TextAndOtherAves alloc] initWithFrame:self.preferredFrame text:[p_obj getTextFromPinchObject] aveType:AVETypeVideo aveMedia:videos];
            [self.results addObject:textViewAndVideo];
		}
	//it's photo video
	} else {
		if(photos.count > 1) {
			MultiplePhotoVideoAVE * pv = [[MultiplePhotoVideoAVE alloc]initWithFrame:self.preferredFrame Photos:photos andVideos:videos];
			[pv mutePlayer];
			[self.results addObject:pv];

		} else {

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
    TextAndOtherAves * textViewAndPhoto = [[TextAndOtherAves alloc] initWithFrame:self.preferredFrame text:[p_obj getTextFromPinchObject] aveType:AVETypePhotoVideo aveMedia:combined];
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
