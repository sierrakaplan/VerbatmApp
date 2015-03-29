//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_Analyzer.h"
#import "verbatmCustomImageView.h"
#import "verbatmCustomPinchView.h"
#import "v_videoview.h"
#import "v_textview.h"
#import "v_photoVideoText.h"
#import "v_multiplePhotoVideo.h"
#import "v_multiVidTextPhoto.h"
#import "v_textVideo.h"
#import "verbatmPhotoVideoAve.h"
#import "v_multiplePhoto.h"

//PS REMEMBER TO SET AUTO RESIZING SUBVIEWS FOR THE CLASSES OF PINCHED OBJECTS
@interface v_Analyzer()
@property(nonatomic, strong)NSMutableArray* results;
@property(strong, nonatomic) NSMutableArray* pinchedObjects;
@property(nonatomic) CGRect preferedFrame;
@end
@implementation v_Analyzer
@synthesize pinchedObjects = _pinchedObjects;
@synthesize preferedFrame = _preferedFrame;
@synthesize results = _results;

-(NSMutableArray*)processPinchedObjectsFromArray:(NSMutableArray*)arr withFrame:(CGRect)frame
{
    _pinchedObjects = arr;
    _preferedFrame = frame;
    _results = [[NSMutableArray alloc]init];
    for(verbatmCustomPinchView* p_obj in _pinchedObjects){
        if(![p_obj isCollection]){
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

-(void)handleSingleMedia:(verbatmCustomPinchView*)p_obj
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    if(p_obj.inDataFormat){
        arr = (p_obj.there_is_picture)? [p_obj getPhotos] : [p_obj getVideos];
    }else{
        NSMutableArray* mediaArr = [p_obj mediaObjects];
        for(UIView* view in mediaArr){
            if([view isKindOfClass:[verbatmCustomImageView class]]){
                if(p_obj.there_is_picture){
                    [arr addObject:((verbatmCustomImageView*)view).image];
                }else{
                    [arr addObject: ((verbatmCustomImageView*)view).asset /*[self getDataFromAsset:((verbatmCustomImageView*)view).asset]*/];
                }
            }
        }
    }
    if(p_obj.there_is_picture)
    {
        v_multiplePhoto* imageView = [[v_multiplePhoto alloc]initWithFrame:_preferedFrame andPhotoArray:arr];       //[imageView addTapGesture];
        [_results addObject:imageView];
    }else if(p_obj.there_is_text){
        v_textview* textView = [[v_textview alloc]initWithFrame:_preferedFrame];
        [textView setTextViewText: [p_obj getTextFromPinchObject]];
        [_results addObject:textView];
    }else{
        v_videoview* vidView = [[v_videoview alloc]initWithFrame:_preferedFrame andAssets:arr];
        [_results addObject:vidView];
    }
}


-(void)handleTwoMedia:(verbatmCustomPinchView*)p_obj
{
   
    if(p_obj.inDataFormat)
    {
        NSMutableArray * photos = [p_obj getPhotos];
        NSMutableArray * videos = [p_obj getVideos];
        if(p_obj.there_is_text)
        {
            if(photos.count)//it's text photo
            {
                v_textPhoto * tp = [[v_textPhoto alloc] initWithFrame:self.preferedFrame andImage:photos.firstObject andText:[p_obj getTextFromPinchObject]];
                [self.results addObject:tp];
            }else//it's text video
            {
                v_textVideo * tv = [[v_textVideo alloc] initWithFrame:self.preferedFrame andAssets:videos andText:[p_obj getTextFromPinchObject]];
                [self.results addObject:tv];
            }
        }else//it's photo video
        {
            if(photos.count > 1)
            {
                v_multiplePhotoVideo * pv = [[v_multiplePhotoVideo alloc]initWithFrame:self.preferedFrame Photos:photos andVideos:videos];
                [self.results addObject:pv];
            }else
            {
                verbatmPhotoVideoAve * pv = [[verbatmPhotoVideoAve alloc] initWithFrame:self.preferedFrame Image:photos.firstObject andVideo:videos];
                [self.results addObject:pv];
            }
        }
    }else
    {
        NSMutableArray* media = [p_obj mediaObjects];
        if(p_obj.there_is_text)
        {
            NSString* text = [p_obj getTextFromPinchObject];
            if(p_obj.there_is_picture)
            {
                if(media.count == 2){
                    UIImage* image;
                    for(id view in media){
                        if([view isKindOfClass:[verbatmCustomImageView class]]){
                            image = ((verbatmCustomImageView*)view).image;
                        }
                    }
                    v_textPhoto* tp = [[v_textPhoto alloc] initWithFrame:_preferedFrame andImage:image andText:text];
                    [tp addSwipeGesture];
                    [_results addObject:tp];
                }else
                {
                    //not sure- what to do with text and multiple photos
//                    NSMutableArray* assets = [[NSMutableArray alloc]init];
//                    for(id view in media){
//                        if([view isKindOfClass:[verbatmCustomImageView class]]){
//                            [assets addObject: ((verbatmCustomImageView*)view).asset];
//                        }
//                    }
//                    v_multiVidTextPhoto* mvpt = [[v_multiVidTextPhoto alloc]initWithFrame:self.pre Photos:<#(NSMutableArray *)#> andVideos:<#(NSArray *)#> andText:<#(NSString *)#>];
//                    [_results addObject:mvpt];
                }
            }else{
                NSMutableArray* assets = [[NSMutableArray alloc]init];
                for(id view in media){
                    if([view isKindOfClass:[verbatmCustomImageView class]]){
                        [assets addObject: [ self getDataFromAsset:((verbatmCustomImageView*)view).asset]
                         ];
                    }
                }
                v_textVideo* tv = [[v_textVideo alloc]initWithFrame:_preferedFrame andAssets:assets andText:text];
                [tv addSwipeGesture];
                [_results addObject:tv];
            }
        }else{
            NSMutableArray* Vdata = [[NSMutableArray alloc]init];
            if(media.count == 2){
                UIImage* image;
                for(verbatmCustomImageView* view in media){
                    if(view.isVideo){
                        [Vdata insertObject:[self getDataFromAsset:view.asset] atIndex:0];
                    }else{
                        image = view.image;
                    }
                }
                verbatmPhotoVideoAve * pv = [[verbatmPhotoVideoAve alloc] initWithFrame:self.preferedFrame Image:image andVideo:Vdata];
                //remember to add the long presss gesture in the supeview part.
                [_results addObject:pv];
            }else{
                NSMutableArray * parray= [[NSMutableArray alloc] init];
                for(verbatmCustomImageView* view in media)
                {
                    if(view.isVideo)
                    {
                        [Vdata addObject:[self getDataFromAsset:view.asset]];
                        
                    }else
                    {
                        [parray addObject:view];
                    }
                }
                v_multiplePhotoVideo* mpv = [[v_multiplePhotoVideo alloc] initWithFrame:self.preferedFrame Photos:[self getUIImage:parray] andVideos:Vdata];
                [_results addObject:mpv];
            }
        }
    }
}


//give it an array of custom image views it gives you back uiimages
-(NSMutableArray *) getUIImage: (NSMutableArray *) array
{
    
    NSMutableArray * parray = [[NSMutableArray alloc] init];
    
    for(verbatmCustomImageView * imageV  in array)
    {
        [parray addObject:imageV.image];
    }
    
    return parray;
}

-(void)handleThreeMedia:(verbatmCustomPinchView*)p_obj
{
    NSString* text = [p_obj getTextFromPinchObject];
    if(p_obj.inDataFormat){
        NSMutableArray* videos = [p_obj getVideos];
        NSMutableArray* photos = [p_obj getPhotos];
        if(videos.count + photos.count == 2){
            v_photoVideoText* pvt = [[v_photoVideoText alloc] initWithFrame:_preferedFrame forImage: (UIImage*)[photos firstObject] andText:text andVideo:[videos firstObject]];
            [_results addObject:pvt];
        }else{
            v_multiVidTextPhoto* mvtp = [[v_multiVidTextPhoto alloc]initWithFrame:_preferedFrame Photos:photos andVideos:videos andText:text];
            [_results addObject:mvtp];
        }
    }else{
        NSMutableArray* media = [p_obj mediaObjects];
        if(media.count == 3){
            UIImage* image;
            NSData* vidData;
            for(int i = 0; i < 3; i++){
                if([[media objectAtIndex:i] isKindOfClass:[UITextView class]]){
                    continue;
                }
                verbatmCustomImageView* imgView = [media objectAtIndex:i];
                if(imgView.isVideo){
                    vidData = [self getDataFromAsset:imgView.asset];
                }else{
                    image = imgView.image;
                }
            }
            v_photoVideoText* pvt = [[v_photoVideoText alloc] initWithFrame:_preferedFrame forImage:image andText:text andVideo:vidData];
            [_results addObject:pvt];
        }else{
            NSMutableArray* photos = [[NSMutableArray alloc]init];
            NSMutableArray* videos = [[NSMutableArray alloc]init];
            NSUInteger count  = media.count;
            for(int i = 0; i < count; i++){
                if([[media objectAtIndex:i] isKindOfClass:[UITextView class]]){
                    continue;
                }
                verbatmCustomImageView* imgView = [media objectAtIndex:i];
                if(imgView.isVideo){
                    [videos addObject: [self getDataFromAsset:imgView.asset]];
                }else{
                    [photos addObject:imgView.image];
                }
            }
            v_multiVidTextPhoto* mvtp = [[v_multiVidTextPhoto alloc]initWithFrame:_preferedFrame Photos:photos andVideos:videos andText:text];
            [_results addObject:mvtp];
            [_results addObject:mvtp];
        }
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
