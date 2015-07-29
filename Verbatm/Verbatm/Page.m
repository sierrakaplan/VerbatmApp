//
//  Page.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Page.h"
#include "verbatmCustomPinchView+reconstructFromDownload.h"
#import "TextPinchView.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"
#import "CollectionPinchView.h"
#import "Photo.h"
#import "Video.h"
#import "Article.h"

@interface Page() <PFSubclassing>

@property(strong, nonatomic) NSString* text;
@property (readwrite,nonatomic) BOOL containsText;
@property (readwrite, nonatomic) BOOL containsVideo;
@property (readwrite, nonatomic) BOOL containsImage;
@property (readwrite,nonatomic) NSInteger pagePosition;//indexed from 0 tells you the position of the page in the article

#define PAGE_PHOTO_RELATIONSHIP @"pagePhotoRelation"
#define PAGE_VIDEO_RELATIONSHIP @"pageVideoRelation"
#define ARTICLE_COLUMN @"Article"

@end

@implementation Page
@dynamic text;
@dynamic containsImage;
@dynamic containsText;
@dynamic containsVideo;
@dynamic pagePosition;

#pragma mark - Methods required for subclassing PFObject.

-(instancetype)initWithPinchObject:(PinchView*)pinchView Article: (Article *) article andPageNumber:(NSInteger) position
{
    if((self = [super init]))
    {
        self[ARTICLE_COLUMN] = article;
        self.pagePosition = position;
        [self sortPinchObject:pinchView];
    }
    return self;
}


-(void)sortPinchObject:(PinchView*)pinchObject {

    if((self.containsText = pinchObject.containsText)){
        self.text = [pinchObject getText];
    }
    self.containsImage = pinchObject.containsImage;
    self.containsVideo = pinchObject.containsVideo;

	if(self.containsImage) {
		NSArray* photos = [pinchObject getPhotos];
		for (UIImage* image in photos) {
			Photo* photo = [[Photo alloc]initWithData:UIImagePNGRepresentation(image) withCaption:nil andName:nil atLocation:nil];
			[photo setObject: self forKey:PAGE_PHOTO_RELATIONSHIP];
			[photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if(succeeded){
					NSLog(@"Photo for page saved");
				}else{
					NSLog(@"Photo for page did not save");
				}
			}];
		}
	}

    if(self.containsVideo) {
		NSArray* videos = [pinchObject getVideos];
		for (AVURLAsset* videoAsset in videos) {
			//TODO(sierra): This should not happen on main thread
			NSData* videoData = [self dataFromAVURLAsset:videoAsset];
			Video* video = [[Video alloc] initWithData:videoData withCaption:nil andName:nil atLocation:nil];
			[video setObject:self forKey:PAGE_VIDEO_RELATIONSHIP];
			[video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if(succeeded){
					NSLog(@"Video for page saved");
				}else{
					NSLog(@"Video for page did not save");
				}
			}];
		}
	}
}

-(NSInteger) numTypesOfMedia {
	return (self.containsText ? 1 : 0)
	+ (self.containsImage ? 1 : 0)
	+ (self.containsVideo ? 1 : 0);
}

//returns mutable array of NSData* objects
-(NSMutableArray*)getPhotos {
	NSArray* photoQueries = [self getPhotosQuery];
	NSMutableArray* photos = [[NSMutableArray alloc]init];
	for(Photo* photo in photoQueries){
		[photos addObject:[photo getPhoto]];
	}
	return photos;
}

//returns mutable array of AVURLAsset* objects
-(NSMutableArray*)getVideos {
	NSArray* videosQuery = [self getVideosQuery];
	NSMutableArray* videos = [[NSMutableArray alloc]init];
	for(Video* vid in videosQuery){
		[videos addObject: [vid getVideoUrl]];
	}
	return videos;
}

#pragma mark - getting objects from the page
-(NSString*)getText {
    return self.text;
}

-(NSData*) dataFromAVURLAsset: (AVURLAsset*) asset {
	return [NSData dataWithContentsOfURL:asset.URL];
}

-(NSData*)dataFromAsset:(ALAsset*)asset
{
    NSData* data = nil;
    if(asset){
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc((unsigned long)assetRepresentation.size);
        //do a bit of error checking on this later
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length: (unsigned long)assetRepresentation.size error:nil];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    return data;
}

-(PinchView*)getPinchObjectWithRadius:(float)radius andCenter:(CGPoint)center {

	NSMutableArray* pinchViews = [[NSMutableArray alloc] init];

	if (self.containsText) {
		TextPinchView* textPinchView = [[TextPinchView alloc] initWithRadius:radius withCenter:center andText:self.text];
		[pinchViews addObject:textPinchView];
	}

	if (self.containsImage) {
		for (NSData* imageData in [self getPhotos]) {
			UIImage* image = [UIImage imageWithData:imageData];
			ImagePinchView* imagePinchView = [[ImagePinchView alloc] initWithRadius:radius withCenter:center andImage:image];
			[pinchViews addObject:imagePinchView];
		}
	}

	if (self.containsVideo) {
		for (id video in [self getVideos]) {
			VideoPinchView* videoPinchView = [[VideoPinchView alloc] initWithRadius:radius withCenter:center andVideo:video];
			[pinchViews addObject:videoPinchView];
		}
	}

	if ([pinchViews count] > 1) {
		return [[CollectionPinchView alloc] initWithRadius:radius withCenter:center andPinchViews:pinchViews];
	} else if([pinchViews count] > 0) {
		return [pinchViews firstObject];
	} else {
		NSLog(@"Error: This page contains no pinch views");
		return Nil;
	}
}

-(NSArray*)getVideosQuery
{
    PFQuery* videoQuery = [PFQuery queryWithClassName:@"Video"];
    [videoQuery whereKey:PAGE_VIDEO_RELATIONSHIP equalTo: self];
    return [videoQuery findObjects];
}

-(NSArray*)getPhotosQuery
{
    PFQuery* photoQuery = [PFQuery queryWithClassName:@"Photo"];
    [photoQuery whereKey:PAGE_PHOTO_RELATIONSHIP equalTo: self];
    return [photoQuery findObjects];
}

#pragma mark - required methods for subclassing PFObject -

+(void)load{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"Page";
}
@end
