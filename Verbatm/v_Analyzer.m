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
#import "v_photoVideo.h"

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
    NSMutableArray* mediaArr = [p_obj mediaObjects];
    for(UIView* view in mediaArr){
        if([view isKindOfClass:[verbatmCustomImageView class]]){
            [arr addObject: ((verbatmCustomImageView*)view).asset];
        }
    }
    if(p_obj.there_is_picture){
        v_multiplePhotoVideo* imageView = [[v_multiplePhotoVideo alloc]initWithFrame:_preferedFrame andMedia:arr];
        [imageView addTapGesture];
        [_results addObject:imageView];
    }else if(p_obj.there_is_text){
        v_textview* textView = [[v_textview alloc]initWithFrame:_preferedFrame];
        [textView setTextViewText: [p_obj getTextFromPinchObject]];
        [_results addObject:textView];
    }else{
        v_videoview* vidView = [[v_videoview alloc]initWithFrame:_preferedFrame andAssets:arr];
        //[vidView showPlayBackIcons];
        [_results addObject:vidView];
    }
}

-(void)handleTwoMedia:(verbatmCustomPinchView*)p_obj
{
    NSMutableArray* media = [p_obj mediaObjects];
    if(p_obj.there_is_text){
        NSString* text = [p_obj getTextFromPinchObject];
        if(p_obj.there_is_picture){
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
            }else{
                NSMutableArray* assets = [[NSMutableArray alloc]init];
                for(id view in media){
                    if([view isKindOfClass:[verbatmCustomImageView class]]){
                        [assets addObject: ((verbatmCustomImageView*)view).asset];
                    }
                }
                v_multiVidTextPhoto* mvpt = [[v_multiVidTextPhoto alloc]initWithFrame:_preferedFrame andMedia:assets andText:text];
                [mvpt addSwipeGesture];
                [mvpt addTapGesture];
                [_results addObject:mvpt];
            }
        }else{
            NSMutableArray* assets = [[NSMutableArray alloc]init];
            for(id view in media){
                if([view isKindOfClass:[verbatmCustomImageView class]]){
                    [assets addObject: ((verbatmCustomImageView*)view).asset];
                }
            }
            v_textVideo* tv = [[v_textVideo alloc]initWithFrame:_preferedFrame andAssets:assets andText:text];
            [_results addObject:tv];
        }
    }else{
        NSMutableArray* assets = [[NSMutableArray alloc]init];
        if(media.count == 2){
            UIImage* image;
            for(verbatmCustomImageView* view in media){
                if(view.isVideo){
                    [assets insertObject:view.asset atIndex:0];
                }else{
                    image = view.image;
                }
            }
            v_photoVideo* pv = [[v_photoVideo alloc]initWithFrame:_preferedFrame Assets:assets andImage:image];
            //remember to add the long presss gesture in the supeview part.
            [_results addObject:pv];
        }else{
            for(verbatmCustomImageView* view in media){
                if(view.isVideo){
                    [assets insertObject:view.asset atIndex:0];
                }else{
                    [assets addObject:view.asset];
                }
            }
            v_multiplePhotoVideo* mpv = [[v_multiplePhotoVideo alloc] initWithFrame:_preferedFrame andMedia:assets];
            [mpv addTapGesture];
            [_results addObject:mpv];
        }
    }
}

-(void)handleThreeMedia:(verbatmCustomPinchView*)p_obj
{
    NSMutableArray* media = [p_obj mediaObjects];
    NSMutableArray* assets = [[NSMutableArray alloc]init];
    NSString* text = [p_obj getTextFromPinchObject];
    if(media.count == 3){
        UIImage* image;
        for(int i = 0; i < 3; i++){
            if([[media objectAtIndex:i] isKindOfClass:[UITextView class]]){
                continue;
            }
            verbatmCustomImageView* imgView = [media objectAtIndex:i];
            if(imgView.isVideo){
                [assets addObject:imgView.asset];
            }else{
                image = imgView.image;
            }
        }
        v_photoVideoText* pvt = [[v_photoVideoText alloc]initWithFrame:_preferedFrame forImage:image andText:text andAssets:assets];
        [pvt createGestures];
        [_results addObject:pvt];
    }else{
        int count  = media.count;
        for(int i = 0; i < count; i++){
            if([[media objectAtIndex:i] isKindOfClass:[UITextView class]]){
                continue;
            }
            verbatmCustomImageView* imgView = [media objectAtIndex:i];
            if(imgView.isVideo){
                [assets insertObject:imgView.asset atIndex:0];
            }else{
                [assets addObject:imgView.asset];
            }
        }
        v_multiVidTextPhoto* mvtp = [[v_multiVidTextPhoto alloc]initWithFrame:_preferedFrame andMedia:assets andText:text];
        [mvtp addTapGesture];
        [mvtp addSwipeGesture];
        [_results addObject:mvtp];
    }
}
@end
