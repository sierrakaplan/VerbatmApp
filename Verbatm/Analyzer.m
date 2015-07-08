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
@property(nonatomic) CGRect preferedFrame;
@end
@implementation Analyzer
@synthesize pinchedObjects = _pinchedObjects;
@synthesize preferedFrame = _preferedFrame;
@synthesize results = _results;

-(NSMutableArray*)processPinchedObjectsFromArray:(NSMutableArray*)arr withFrame:(CGRect)frame
{
    _pinchedObjects = arr;
    _preferedFrame = frame;
    _results = [[NSMutableArray alloc]init];
    for(PinchView* p_obj in _pinchedObjects)
    {
        //there are some issue where a messed up p_obj arrives
        if(!p_obj.there_is_picture && !p_obj.there_is_text && !p_obj.there_is_video)continue;
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
    if(p_obj.inDataFormat)
    {
        arr = (p_obj.there_is_picture)? [p_obj getPhotos] : [p_obj getVideos];
    }else{
        NSMutableArray* mediaArr = [p_obj mediaObjects];
        for(UIView* view in mediaArr){
            if([view isKindOfClass:[VerbatmImageView class]]){
                if(p_obj.there_is_picture)
                {
                    [arr addObject:((VerbatmImageView*)view).image];
                }else
                {

                    [arr addObject:[self getDataFromAsset:((VerbatmImageView*)view).asset]];
                }
            }
        }
    }
    
    if(p_obj.there_is_picture)
    {
        //multiple photo and single photo call the same class
        MultiplePhotoAVE* imageView = [[MultiplePhotoAVE alloc]initWithFrame:_preferedFrame andPhotoArray:arr];
        
        [_results addObject:imageView];
        
    }else if(p_obj.there_is_text)
    {
        TextAVE* textView = [[TextAVE alloc]initWithFrame:_preferedFrame];
        [textView setTextViewText: [p_obj getTextFromPinchObject]];
        [_results addObject:textView];
    }else{
        VideoAVE* vidView = [[VideoAVE alloc]initWithFrame:_preferedFrame andAssets:arr];
        [vidView mutePlayer];
        [_results addObject:vidView];
    }
}


-(void)handleTwoMedia:(PinchView*)p_obj
{
   
    if(p_obj.inDataFormat)
    {
        NSMutableArray * photos = [p_obj getPhotos];
        NSMutableArray * videos = [p_obj getVideos];
        if(p_obj.there_is_text)
        {
            if(photos.count)//it's text photo
            {
                TextPhotoAVE * tp = [[TextPhotoAVE alloc] initWithFrame:self.preferedFrame andImage:photos.firstObject andText:[p_obj getTextFromPinchObject]];
                [tp addSwipeGesture];
                [self.results addObject:tp];
            }else//it's text video
            {
                TextVideoAVE * tv = [[TextVideoAVE alloc] initWithFrame:self.preferedFrame andAssets:videos andText:[p_obj getTextFromPinchObject]];
                [tv mutePlayer];
                [tv addSwipeGesture];
                [self.results addObject:tv];
            }
        }else//it's photo video
        {
            if(photos.count > 1)
            {
                MultiplePhotoVideoAVE * pv = [[MultiplePhotoVideoAVE alloc]initWithFrame:self.preferedFrame Photos:photos andVideos:videos];
                [pv mutePlayer];
                [self.results addObject:pv];
            }else
            {
                
                MultiplePhotoVideoAVE* mpv = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferedFrame Photos:photos andVideos:videos];
                [mpv mutePlayer];
                [self.results addObject:mpv];
                
//                verbatmPhotoVideoAve * pv = [[verbatmPhotoVideoAve alloc] initWithFrame:self.preferedFrame Image:photos.firstObject andVideo:videos];
//                [pv addGesturesToVideoView];
//                [pv mute];
//                [self.results addObject:pv];
            }
        }
    }else
    {
        NSMutableArray* media = [p_obj mediaObjects];
        if(p_obj.there_is_text)
        {
            NSString* text = [p_obj getTextFromPinchObject];
            if(p_obj.there_is_picture)//text photo
            {
                if(media.count == 2){
                    UIImage* image;
                    for(id view in media){
                        if([view isKindOfClass:[VerbatmImageView class]]){
                            image = ((VerbatmImageView*)view).image;
                        }
                    }
                    TextPhotoAVE* tp = [[TextPhotoAVE alloc] initWithFrame:_preferedFrame andImage:image andText:text];
                    [tp addSwipeGesture];
                    [_results addObject:tp];
                }else//multiple photo and text
                {
                    //not sure- what to do with text and multiple photos
                    NSMutableArray* assets = [[NSMutableArray alloc]init];
                    for(id view in media){
                        if([view isKindOfClass:[VerbatmImageView class]]){
                            [assets addObject: ((VerbatmImageView*)view).image];
                        }
                    }
                    
                    //we have compbined multiple photo with multiple photo and text
                    MultiplePhotoAVE* mvpt = [[MultiplePhotoAVE alloc]initWithFrame:self.preferedFrame andAssets:assets andText:text];
                    [mvpt addSwipeGesture];
                    [_results addObject:mvpt];
                }
            }else{//text video
                NSMutableArray* assets = [[NSMutableArray alloc]init];
                for(id view in media){
                    if([view isKindOfClass:[VerbatmImageView class]])
                    {
                        [assets addObject: ((VerbatmImageView*)view).asset];
                    }
                }
                TextVideoAVE* tv = [[TextVideoAVE alloc]initWithFrame:_preferedFrame andAssets:assets andText:text];
                [tv mutePlayer];
                [tv addSwipeGesture];
                [_results addObject:tv];
            }
        }else{
            NSMutableArray* Vdata = [[NSMutableArray alloc]init];
            if(media.count == 2)//photo video
            {
                UIImage* image;
                for(VerbatmImageView* view in media){
                    if(view.isVideo){
                        [Vdata insertObject:[self getDataFromAsset:view.asset] atIndex:0];
                    }else{
                        image = view.image;
                    }
                }
                
                MultiplePhotoVideoAVE* mpv = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferedFrame Photos:@[image] andVideos:Vdata];
                [mpv mutePlayer];
                [self.results addObject:mpv];
                
//                verbatmPhotoVideoAve * pv = [[verbatmPhotoVideoAve alloc] initWithFrame:self.preferedFrame Image:image andVideo:Vdata];
//                [_results addObject:pv];
//                [pv mute];
            }else{//multiple photo and video
                NSMutableArray * parray= [[NSMutableArray alloc] init];
                for(VerbatmImageView* view in media)
                {
                    if(view.isVideo)
                    {
                        [Vdata addObject:[self getDataFromAsset:view.asset]];
                        
                    }else
                    {
                        [parray addObject:view];
                    }
                }
                
                if(parray.count ==1)//there is one photo && many videos
                {
                    MultiplePhotoVideoAVE* mpv = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferedFrame Photos:parray andVideos:Vdata];
                    [mpv mutePlayer];
                    [self.results addObject:mpv];
                    
//                    verbatmCustomImageView * pic = [parray firstObject];
//                    verbatmPhotoVideoAve * pv = [[verbatmPhotoVideoAve alloc] initWithFrame:self.preferedFrame Image:pic.image andVideo:Vdata];
//                    [_results addObject:pv];
//                    [pv mute];
                }else//there are many photos and some/one video(s)
                {
                
                    MultiplePhotoVideoAVE* mpv = [[MultiplePhotoVideoAVE alloc] initWithFrame:self.preferedFrame Photos:[self getUIImage:parray] andVideos:Vdata];
                    [mpv mutePlayer];
                    [_results addObject:mpv];
                }
            }
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
    if(p_obj.inDataFormat)
    {
        NSMutableArray* videos = [p_obj getVideos];
        NSMutableArray* photos = [p_obj getPhotos];
        if(videos.count + photos.count == 2){
            PhotoVideoTextAVE* pvt = [[PhotoVideoTextAVE alloc] initWithFrame:_preferedFrame forImage: (UIImage*)[photos firstObject] andText:text andVideo:[videos firstObject]];
            [pvt addSwipeGesture];
            [_results addObject:pvt];
        }else{
            MultiVidTextPhotoAVE* mvtp = [[MultiVidTextPhotoAVE alloc]initWithFrame:_preferedFrame Photos:photos andVideos:videos andText:text];
            [mvtp addSwipeGesture];
            [_results addObject:mvtp];
        }
    }else{
        NSMutableArray* media = [p_obj mediaObjects];
        if(media.count == 3)
        {
            UIImage* image;
            NSData* vidData;
            for(int i = 0; i < 3; i++)
            {
                if([[media objectAtIndex:i] isKindOfClass:[UITextView class]])continue;
                
                VerbatmImageView* imgView = [media objectAtIndex:i];
                if(imgView.isVideo)
                {
                    vidData = [self getDataFromAsset:imgView.asset];
                }else
                {
                    image = imgView.image;
                }
            }
            PhotoVideoTextAVE* pvt = [[PhotoVideoTextAVE alloc] initWithFrame:_preferedFrame forImage:image andText:text andVideo:@[vidData]];
            [pvt addSwipeGesture];
            [_results addObject:pvt];
            
        }else{
            NSMutableArray* photos = [[NSMutableArray alloc]init];
            NSMutableArray* videos = [[NSMutableArray alloc]init];
            NSUInteger count  = media.count;
            for(int i = 0; i < count; i++){
                if([[media objectAtIndex:i] isKindOfClass:[UITextView class]]){
                    continue;
                }
                VerbatmImageView* imgView = [media objectAtIndex:i];
                if(imgView.isVideo){
                    [videos addObject: [self getDataFromAsset:imgView.asset]];
                }else{
                    [photos addObject:imgView.image];
                }
            }
            
            if(photos.count ==1)//this way we know that we have onepicture but a lot of videos
            {
                PhotoVideoTextAVE* pvt = [[PhotoVideoTextAVE alloc] initWithFrame:_preferedFrame forImage:[photos firstObject] andText:text andVideo:videos];
                [pvt addSwipeGesture];
                [_results addObject:pvt];
            }else
            {
                MultiVidTextPhotoAVE* mvtp = [[MultiVidTextPhotoAVE alloc]initWithFrame:_preferedFrame Photos:photos andVideos:videos andText:text];
                [mvtp addSwipeGesture];
                [_results addObject:mvtp];
            }
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
