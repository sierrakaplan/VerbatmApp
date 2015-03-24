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
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded){
                NSLog(@"Could not save this page");
            }
        }];
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
                    [self setObject:video forKey:PAGE_VIDEO_RELATIONSHIP];
                    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            NSLog(@"Video for page saved");
                        }else{
                            NSLog(@"Video for page did not save");
                        }
                    }];
                }else{
                    Photo* photo = [[Photo alloc]initWithData:[self dataFromAsset:((verbatmCustomImageView*)view).asset] withCaption:nil andName:nil atLocation:nil];
                    [self setObject:photo forKey:PAGE_PHOTO_RELATIONSHIP];
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

//This method should be called on a seperate thread
-(verbatmCustomPinchView*)pinchObjectFromPage:(Page*)page
{
    PFQuery* videoQuery = [PFQuery queryWithClassName:@"Video"];
    [videoQuery whereKey:PAGE_VIDEO_RELATIONSHIP equalTo:page];
    NSArray* videos = [videoQuery findObjects];
    
    PFQuery* photoQuery = [PFQuery queryWithClassName:@"Photo"];
    [photoQuery whereKey:PAGE_PHOTO_RELATIONSHIP equalTo:page];
    NSArray* photos = [photoQuery findObjects];
    
    
    //continue to reconstruct the pinch object
    verbatmCustomPinchView* result;// = (verbatmCustomPinchView*)[NSKeyedUnarchiver unarchiveObjectWithData: [self.pinchObjectFile getData]];
    return result;
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
        Byte *buffer = (Byte*)malloc(assetRepresentation.size);
        //do a bit of error checking on this later
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length:assetRepresentation.size error:nil];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    return data;
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
