//
//  Page.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Page.h"
#import "verbatmCustomImageView.h"
#import "Photo.h"
#import "Video.h"

@interface Page()
@property(strong, nonatomic) NSMutableArray* media;

@property(strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSData* pinchData; //this is the memory inefficient quick fix..will need to work on reconstructing pinch object from page by modifying pinch object class.
@end
@implementation Page
@synthesize media = _media;
@synthesize there_is_picture = _there_is_picture; //advised by Iain not to use @synthesize...work on this later.
@synthesize there_is_text = _there_is_text;
@synthesize there_is_video = _there_is_video;
@synthesize text = _text;
@synthesize pinchData = _pinchData;
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
    NSMutableArray* media = [pinchObject mediaObjects];\
    if((_there_is_text = pinchObject.there_is_text)){
        _text = [pinchObject getTextFromPinchObject];
    }
    _there_is_picture = pinchObject.there_is_picture;
    _there_is_video = pinchObject.there_is_video;
    if(_there_is_video || _there_is_picture){
        for(verbatmCustomImageView* view in media){
            if(view.isVideo){
                Video* video = [[Video alloc]initWithData:[self dataFromAsset:view.asset] withCaption:nil andName:nil atLocation:nil];
                [_media addObject: video];
            }else{
                Photo* photo = [[Photo alloc]initWithData:[self dataFromAsset:view.asset] withCaption:nil andName:nil atLocation:nil];
                [_media addObject: photo];
            }
        }
    }
    _pinchData = [NSKeyedArchiver archivedDataWithRootObject:pinchObject];
}

-(verbatmCustomPinchView*)pinchObjectFromPage:(Page*)page
{
    verbatmCustomPinchView* result = (verbatmCustomPinchView*)[NSKeyedUnarchiver unarchiveObjectWithData: _pinchData];
    return result;
}

#pragma mark - getting objects from the page
-(NSString*)getText
{
    return _text;
}

-(NSMutableArray*)getMediaObjects
{
    return _media;
}

-(NSData*)dataFromAsset:(ALAsset*)asset
{
    NSData* data = nil;
    if(asset){
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(assetRepresentation.size);
        //do a bit of error checking on this later
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length:assetRepresentation.size error:nil];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    return data;
}

#pragma mark - required methods for subclassing PFObject -
+(NSString *)parseClassName
{
    return @"Page";
}

+(void)load{
    [self registerSubclass];
}

@end
