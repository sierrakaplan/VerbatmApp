//
//  verbatmCustomPinchView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 11/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomPinchView.h"

@interface verbatmCustomPinchView()
@property (strong, nonatomic) IBOutlet verbatmCustomPinchView *background;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewer;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property(nonatomic) CGPoint center;
@property (strong, nonatomic) NSMutableArray* media;
@property (readwrite,nonatomic) BOOL there_is_text;
@property (readwrite, nonatomic) BOOL there_is_video;
@property (readwrite, nonatomic) BOOL there_is_picture;


#define MEDIA_TYPE_TEXT @"TEXT"
#define MEDIA_TYPE_VIDEO @"VIDEO"
#define MEDIA_TYPE_PHOTO @"PHOTO"
#define TIME_TO_ANIMATE 0.01
#define SHADOW_OFFSET_FACTOR 10
#define DIVISION_FACTOR_FOR_THREE 3
#define DIVISION_FACTOR_FOR_TWO 2

@end

@implementation verbatmCustomPinchView

//Lucio
//Instantiates an instance of the custom view without any media types inputted
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andMedia:(id)medium
{
    if((self = [super init])){
        //set up the properties
        self.background.center = center;
        CGRect frame = CGRectMake(center.x - radius, center.y - radius, radius, radius);
        self.background.frame = frame;
        self.background.layer.cornerRadius = radius/2;
        self.background.center = self.center;
        self.background.autoresizesSubviews = YES; // This makes sure that moving the background canvas moves all the associated subviews too.
        //create the shadow or lensing effect
        self.background.layer.shadowPath = [UIBezierPath bezierPathWithRect: self.background.bounds].CGPath;
        self.background.layer.shadowOffset = CGSizeMake(radius/SHADOW_OFFSET_FACTOR, radius/SHADOW_OFFSET_FACTOR);
        self.background.layer.shadowColor = [UIColor grayColor].CGColor;
        self.background.layer.masksToBounds = NO;
        
        //initialize arrays
        self.media = [[NSMutableArray alloc]init];
        
        //add Medium to the list of media
        if([medium isKindOfClass: [UITextView class]]){
            [self.media addObject: medium];
             self.there_is_text = YES;
        }else if([medium isKindOfClass: [UIImageView class]]){
            [self.media addObject: medium];
            self.there_is_picture = YES;
        }else{
            [self.media addObject: medium];
            self.there_is_video = YES;
        }
        [self renderMedia];
    }
    return self;
}


//Lucio
//adds a text to the custom view
-(void)addTextToCurrentMedia:(UITextView*)textview
{
    [self.media addObject:textview];
    self.there_is_text = YES;
}

//Lucio
//adds a video to the custom view
-(void)addVideoToCurrentMedia:(ALAsset*)video
{
    [self.media addObject: video];
    self.there_is_video = YES;
}

//Lucio
//adds a picture to the custom view
-(void)addPictureToCurrentMedia:(UIImageView*)imageview
{
    [self.media addObject: imageview];
    self.there_is_picture = YES;
}

//Lucio.
//moves the view by a delta relative to the center.
-(void)move:(CGPoint)delta
{
    __weak verbatmCustomPinchView* weak_self = self;
    [UIView animateWithDuration:TIME_TO_ANIMATE animations:^{
        CGPoint currentCenter = weak_self.background.center;
        weak_self.background.center = CGPointMake(currentCenter.x + delta.x, currentCenter.y + delta.y);
    } completion:^(BOOL finished) {
        weak_self.center = self.background.center;
    }];
}


//This renders the pinch object unto the screen in terms of the dynamics of the
//way it should look
-(void)renderMedia
{
    if(self.there_is_video && self.there_is_text && self.there_is_picture) [self renderThreeViews];
    if( [self thereIsOnlyOneMedium]) [self renderSingleView];
    [self displayMedia];
}

//This renders a single view on the pinch object
-(void)renderSingleView
{
    if(self.there_is_text) self.textField.frame = self.background.frame;
    else if(self.there_is_video) self.videoImageView.frame = self.background.frame;
    else self.imageViewer.frame = self.background.frame;
}

//this renders two media in a vertical split view kind of way on the pinch object.
-(void)renderTwoMedia
{
    CGRect frame1 = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO , self.background.frame.size.height);
    CGRect frame2 = CGRectMake(self.background.frame.origin.x + self.imageViewer.frame.size.width, self.background.frame.origin.y, self.background.frame.size.width - self.imageViewer.frame.size.width, self.background.frame.size.height);
    if(self.there_is_text){
        if(self.there_is_picture){
            self.textField.frame = frame1;
            self.imageViewer.frame = frame2;
        }else{
            self.textField.frame = frame1;
            self.videoImageView.frame = frame2;
        }
    }else{
        self.imageViewer.frame = frame1;
        self.videoImageView.frame = frame2;
    }
}
       

//This renders three views on the pinch view object.
-(void)renderThreeViews
{
    //computation to determine the relative positions of each of the views
    self.textField.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.background.frame.size.height/DIVISION_FACTOR_FOR_THREE);
    self.imageViewer.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y + self.textField.frame.size.height, self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO, self.background.frame.size.height - self.textField.frame.size.height);
    self.videoImageView.frame = CGRectMake(self.background.frame.origin.x + self.imageViewer.frame.size.width, self.imageViewer.frame.origin.y , self.background.frame.size.width - self.imageViewer.frame.size.width, self.imageViewer.frame.size.width);
    //displaying the latest information on the pinchview object.
    self.textField.text = @"";
}

//This function displays the media on the view.
-(void)displayMedia
{
    for(id object in self.media){
        if([object isKindOfClass: [UITextView class]]){
            [self.textField.text stringByAppendingString: ((UITextView*)object).text];
        }else if([object isKindOfClass: [UIImageView class]]){
            [self.imageViewer setImage:[(UIImageView*)object image]];
        }else{
            ALAssetRepresentation *assetRepresentation = [(ALAsset*)object defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                                 scale:[assetRepresentation scale]
                                           orientation:UIImageOrientationUp];
            [self.videoImageView setImage:image];
        }
    }
}
       
       
//This merges two verbatm pinch objects into one. 
+(verbatmCustomPinchView*)pinchTogether:(NSMutableArray*)to_be_merged
{
    if(to_be_merged.count < 2) return nil;
    verbatmCustomPinchView* result = (verbatmCustomPinchView*)[to_be_merged firstObject];
    for(verbatmCustomPinchView* pinchObject in to_be_merged){
        [result.media addObjectsFromArray: pinchObject.media];
        result.there_is_picture = (result.there_is_picture)? result.there_is_picture : pinchObject.there_is_picture;
        result.there_is_text = (result.there_is_text)? result.there_is_text : pinchObject.there_is_text;
        result.there_is_video = (result.there_is_video)? result.there_is_video : pinchObject.there_is_video;
    }
    to_be_merged = nil;
    [result renderMedia];
    return result;
}

//keeping this just in case
-(BOOL)thereIsOnlyOneMedium
{
    if(self.there_is_text && self.there_is_video && self.there_is_picture) return false;
    if(self.there_is_picture && self.there_is_text)return false;
    if(self.there_is_text && self.there_is_video) return false;
    if(self.there_is_video && self.there_is_picture) return false;
    return  self.there_is_picture || self.there_is_text || self.there_is_video;
}


//this function pulls a pinch object apart into the componenent media.
//It returns an array of pinch objects
+(NSMutableArray*)openCollection:(verbatmCustomPinchView*)to_be_seperated
{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for(id object in to_be_seperated.media){
        verbatmCustomPinchView* result = [[verbatmCustomPinchView alloc]initWithRadius: to_be_seperated.background.frame.size.width withCenter:to_be_seperated.center andMedia:object];
        [arr addObject: result];
    }
    return arr;
}

//Pinches apart two media that were previously pinched together.
//The function returns null if the object to be pinched apart does not actually consist
//of more than one media object.
+(NSMutableArray*)pinchApart:(verbatmCustomPinchView*)to_be_pinched_apart
{
    if(to_be_pinched_apart.media.count < 2)return nil;
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    verbatmCustomPinchView* result = [[verbatmCustomPinchView alloc]initWithRadius: to_be_pinched_apart.background.frame.size.width withCenter:to_be_pinched_apart.center andMedia: [to_be_pinched_apart.media lastObject]];
    [to_be_pinched_apart.media removeObject: [to_be_pinched_apart.media lastObject]];
    [arr addObject:to_be_pinched_apart];
    [arr addObject: result];
    return arr;
}
@end
