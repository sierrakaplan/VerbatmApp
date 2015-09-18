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
#import "GTLVerbatmAppImage.h"
#import "MediaLoader.h"
#import "TextPinchView.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"
#import "VideoAVE.h"
#import "TextAVE.h"
#import "Page.h"
#import "PhotoVideoAVE.h"
#import "BaseArticleViewingExperience.h"
#import "Video.h"

@interface AVETypeAnalyzer()

@property(nonatomic, strong) NSMutableArray* results;
@property(nonatomic) CGRect preferredFrame;
@property (strong, nonatomic) MediaLoader* mediaLoader;

@end


@implementation AVETypeAnalyzer

@synthesize preferredFrame = _preferredFrame;
@synthesize results = _results;

-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame {
	self.preferredFrame = frame;
	for(PinchView* pinchView in pinchViews) {
		//there are some issue where a messed up p_obj arrives
		if(!(pinchView.containsImage || pinchView.containsText || pinchView.containsVideo)) {
			NSLog(@"Pinch view says it has no type of media in it.");
			continue;
		}

		[self getAVEFromPinchView:pinchView];
	}

	return self.results;
}

-(NSMutableArray*) getAVESFromPages: (NSArray*) pages withFrame: (CGRect) frame {
	self.preferredFrame = frame;
	for (Page* page in pages) {
		AVEType type;

		if (page.images.count && page.videos.count) {
			type = AVETypePhotoVideo;
		} else if (page.images.count) {
			type = AVETypePhoto;
		} else if(page.videos.count) {
			type = AVETypeVideo;
			continue;
		}

		BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame:self.preferredFrame andText:nil andPhotos:[self getUIImagesFromPage: page] andVideos:[self getVideosFromPage: page] andAVEType:type];
		[self.results addObject:textAndOtherMediaAVE];
	}
	return self.results;
}

-(NSArray*) getUIImagesFromPage: (Page*) page {
	NSMutableArray* uiImages = [[NSMutableArray alloc] init];
	for (GTLVerbatmAppImage* image in page.images) {
		//TODO: do this in background
		UIImage* uiImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: image.servingUrl]]];
		[uiImages addObject: uiImage];
	}
	return uiImages;
}

-(NSArray*) getVideosFromPage: (Page*) page {
	NSMutableArray* videoURLs = [[NSMutableArray alloc] init];
	for (Video* video in page.videos) {
		[videoURLs addObject: video.blobStoreResourceURL];
	}
	return videoURLs;
}

-(void) getAVEFromPinchView: (PinchView*) pinchView {

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


#pragma  mark - Lazy Instantiation

-(NSMutableArray*) results {
	if (!_results) {
		_results =  [[NSMutableArray alloc] init];
	}
	return _results;
}

@end
