//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "AVETypeAnalyzer.h"

#import "BaseArticleViewingExperience.h"

#import "CollectionPinchView.h"

#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

#import "ImagePinchView.h"


#import "Page.h"
#import "POVLoadManager.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "PinchView.h"
#import <PromiseKit/PromiseKit.h>

#import "TextAVE.h"

#import "UtilityFunctions.h"

#import "VideoPinchView.h"
#import "VideoAVE.h"

@interface AVETypeAnalyzer()

@property(nonatomic, strong) NSMutableArray* results;

#define GET_VIDEO_URI @"https://verbatmapp.appspot.com/serveVideo"
#define BLOBKEYSTRING_KEY @"blob-key"

@end


@implementation AVETypeAnalyzer

@synthesize results = _results;

-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame {
	for(PinchView* pinchView in pinchViews) {
		//there are some issue where a messed up p_obj arrives
		if(!(pinchView.containsImage || pinchView.containsVideo)) {
//			NSLog(@"Pinch view says it has no type of media in it.");
			continue;
		}

		[self getAVEFromPinchView:pinchView withFrame:frame];
	}

	return self.results;
}

-(NSMutableArray*) getAVESFromPages: (NSArray*) pages withFrame: (CGRect) frame {
	for (Page* page in pages) {
		AVEType type;

		if (page.images.count && page.videos.count) {
			type = AVETypePhotoVideo;
		} else if (page.images.count) {
			type = AVETypePhoto;
		} else if(page.videos.count) {
			type = AVETypeVideo;
		}

		[self getUIImagesFromPage: page].then(^(NSArray* images) {
			BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame:frame andText:nil andPhotos:images andVideos:[self getVideosFromPage: page] andAVEType:type];
			[self.results addObject:textAndOtherMediaAVE];
		});
	}
	return self.results;
}

-(AnyPromise*) getAVEFromPage: (Page*) page withFrame: (CGRect) frame {
	AVEType type;
	if (page.images.count && page.videos.count) {
		type = AVETypePhotoVideo;
	} else if (page.images.count) {
		type = AVETypePhoto;
	} else if(page.videos.count) {
		type = AVETypeVideo;
	}
	return [self getUIImagesFromPage: page].then(^(NSArray* imagesAndText) {
		BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame: frame andText:nil andPhotos:imagesAndText andVideos:[self getVideosFromPage: page] andAVEType:type];
		return textAndOtherMediaAVE;
	});
}

-(AnyPromise*) getUIImagesFromPage: (Page*) page {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
	for (GTLVerbatmAppImage* image in page.images) {
		AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedDataFromURL: [NSURL URLWithString:image.servingUrl]];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	return PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		NSMutableArray* uiImages = [[NSMutableArray alloc] init];
		for (int i = 0; i < results.count; i++) {
			NSData* imageData = results[i];
			GTLVerbatmAppImage* gtlImage = page.images[i];
			UIImage* uiImage = [UIImage imageWithData:imageData];
			if (!gtlImage.text) {
				gtlImage.text = @"";
			}
			if (!gtlImage.textYPosition) {
				gtlImage.textYPosition = [NSNumber numberWithFloat: 0.f];
			} 
			[uiImages addObject: @[uiImage, gtlImage.text, gtlImage.textYPosition]];
		}
		return uiImages;
	});
}

-(NSArray*) getVideosFromPage: (Page*) page {
	NSMutableArray* videoURLs = [[NSMutableArray alloc] init];
	for (GTLVerbatmAppVideo* video in page.videos) {
		NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
		NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: video.blobKeyString];
		components.queryItems = @[blobKey];
//		NSLog(@"Requesting blobstore video with url: %@", components.URL.absoluteString);
		if (!video.text) {
			video.text = @"";
		}
		if (!video.textYPosition) {
			video.textYPosition = [NSNumber numberWithFloat: 0.f];
		}
		[videoURLs addObject: @[components.URL, video.text, video.textYPosition]];
	}
	return videoURLs;
}

-(void) getAVEFromPinchView: (PinchView*) pinchView withFrame: (CGRect) frame {
	AVEType type;
	if (pinchView.containsImage && pinchView.containsVideo) {
		type = AVETypePhotoVideo;
	} else if (pinchView.containsImage) {
		type = AVETypePhoto;
	} else if(pinchView.containsVideo) {
		type = AVETypeVideo;
	}
    switch (type) {
        case AVETypePhoto: {
            PhotoAVE * photoAve;
            if([pinchView isKindOfClass:[CollectionPinchView class]]){
                
                photoAve = [[PhotoAVE alloc] initWithFrame:frame andPhotoArray:nil
                                                          orPinchview:((CollectionPinchView *)pinchView).pinchedObjects
                                             isSubViewOfPhotoVideoAve:NO];
                
            }else {
                photoAve = [[PhotoAVE alloc] initWithFrame:frame andPhotoArray:nil
                                                          orPinchview:[NSMutableArray arrayWithObject:pinchView]
                                             isSubViewOfPhotoVideoAve:NO];
            }
            
            [self.results addObject:photoAve];
            
            break;
        }
        case AVETypeVideo: {
//            VideoAVE *videoAve = [[VideoAVE alloc] initWithFrame:frame andVideoArray:videos];
//            [self addSubview: videoAve];
//            self.subAVE = videoAve;
            break;
        }
        case AVETypePhotoVideo: {
//            PhotoVideoAVE *photoVideoAVE = [[PhotoVideoAVE alloc] initWithFrame:frame andPhotos:photos andVideos:videos];
//            [self addSubview: photoVideoAVE];
//            self.subAVE = photoVideoAVE;
            break;
        }
        default: {
            break;
        }
    }
}




#pragma  mark - Lazy Instantiation

-(NSMutableArray*) results {
	if (!_results) {
		_results =  [[NSMutableArray alloc] init];
	}
	return _results;
}

@end
