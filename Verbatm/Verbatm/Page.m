//
//  Page.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Page.h"
#import "verbatmCustomImageView.h"
#include "verbatmCustomPinchView+reconstructFromDownload.h"
#import "Photo.h"
#import "Video.h"

@interface Page() <PFSubclassing>

@property(strong, nonatomic) NSString* text;
@property (readwrite,nonatomic) BOOL there_is_text;
@property (readwrite, nonatomic) BOOL there_is_video;
@property (readwrite, nonatomic) BOOL there_is_picture;

#define PAGE_PHOTO_RELATIONSHIP @"pagePhotoRelation"
#define PAGE_VIDEO_RELATIONSHIP @"pageVideoRelation"
@end

@implementation Page
@dynamic text;
@dynamic there_is_picture;
@dynamic there_is_text;
@dynamic there_is_video;

#pragma mark - Methods required for subclassing PFObject.

-(instancetype)initWithPinchObject:(verbatmCustomPinchView*)p_view
{
    if((self = [super init])){
        [self sortPinchObject:p_view];
    }
    return self;
}


-(void)sortPinchObject:(verbatmCustomPinchView*)pinchObject
{
    NSMutableArray* media = [pinchObject mediaObjects];
    if((self.there_is_text = pinchObject.there_is_text)){
        self.text = [pinchObject getTextFromPinchObject];
    }
    self.there_is_picture = pinchObject.there_is_picture;
    self.there_is_video = pinchObject.there_is_video;
    if(self.there_is_video || self.there_is_picture){
        for(UIView* view in media){
            if([view isKindOfClass:[verbatmCustomImageView class]]){
                if(((verbatmCustomImageView*)view).isVideo){
                    Video* video = [[Video alloc]initWithData:[self dataFromAsset:((verbatmCustomImageView*)view).asset] withCaption:nil andName:nil atLocation:nil];
                    [video setObject:self forKey:PAGE_VIDEO_RELATIONSHIP];
                    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            NSLog(@"Video for page saved");
                        }else{
                            NSLog(@"Video for page did not save");
                        }
                    }];
                }else{
                    Photo* photo = [[Photo alloc]initWithData:[self dataFromAsset:((verbatmCustomImageView*)view).asset] withCaption:nil andName:nil atLocation:nil];
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
        }
    }
}

//This method blocks//
/*This method returns the media that make up the page. Index 0 of the array always contains the text of the page: this is nil if the there_is_text boolean of the page is false. Index 1 contains an array of all the videos of the page; the array has the videos as NSData.
 Index 2 has an array of the photos of the page each of which is a UIImage.
 */
-(NSMutableArray*)getMedia
{
    NSMutableArray* media = [[NSMutableArray alloc] init];
    [media addObject:self.text];
    
    NSArray* videos = [self getVideos];
    NSMutableArray* videoData = [[NSMutableArray alloc]init];
    for(Video* vid in videos){
        [videoData addObject: [vid getVideoData]];
    }
    
    NSArray* photoQueries = [self getPhotos];
    NSMutableArray* photos = [[NSMutableArray alloc]init];
    for(Photo* photo in photoQueries){
        [photos addObject:[photo getPhoto]];
    }
    
    [media  addObject: videoData];
    [media addObject: photos];
    return media;
}

#pragma mark - getting objects from the page
-(NSString*)getText
{
    return self.text;
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

-(verbatmCustomPinchView*)getPinchObjectWithRadius:(float)radius andCenter:(CGPoint)center
{
    NSArray* videos = [self getVideos];
    NSMutableArray* videoData = [[NSMutableArray alloc]init];
    for(Video* vid in videos){
        [videoData addObject: [vid getVideoData]];
    }
    
    NSArray* photoQueries = [self getPhotos];
    NSMutableArray* photos = [[NSMutableArray alloc]init];
    for(Photo* photo in photoQueries){
        [photos addObject:[photo getPhoto]];
    }
    
    return [[verbatmCustomPinchView alloc] initWithRadius:radius withCenter:center Images:photos videoData:videoData andText:self.text];
}

-(NSArray*)getVideos
{
    PFQuery* videoQuery = [PFQuery queryWithClassName:@"Video"];
    [videoQuery whereKey:PAGE_VIDEO_RELATIONSHIP equalTo: self];
    return [videoQuery findObjects];
}

-(NSArray*)getPhotos
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
