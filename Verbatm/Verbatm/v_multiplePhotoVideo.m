
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "v_multiplePhotoVideo.h"
#import "v_videoview.h"

@interface v_multiplePhotoVideo()
@property (strong, nonatomic) NSMutableArray* frames;
@property (nonatomic) CGRect chosenFrame;
@property (nonatomic, strong) v_videoview* videoView;
#define x_ratio 3
#define y_ratio 4
@end
@implementation v_multiplePhotoVideo

-(id)initWithFrame:(CGRect)frame andMedia:(NSMutableArray*)media
{
    if((self = [super initWithFrame:frame])){
        self.frames = [[NSMutableArray alloc] init];
        NSMutableArray* vidAssets = [self getVideoAssets:media];
        int numFrames = (int)media.count + ((vidAssets.count)? 1 : 0);
        [self getMediaFrames: numFrames andFrame:self.bounds]; //adding one to account for videos
        [self renderPhotos:media andVideos:vidAssets];
    }
    return self;
}

/*
 *This function returns the number of media counting all videos as one medium
 */
-(NSMutableArray*)getVideoAssets:(NSMutableArray*)media
{
    NSMutableArray* vids = [[NSMutableArray alloc]init];
    while(YES){
        ALAsset* asset = (ALAsset*)[media firstObject];
        if([[asset valueForProperty: ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
            [media removeObject:asset];
            [vids addObject:asset];
        }else{
            break;
        }
    }
    return vids;
}


-(void)renderPhotos:(NSMutableArray*)media andVideos:(NSMutableArray*)videos
{
    if(videos.count){
        CGRect biggestFrame;
        int largestAreaSoFar = 0;
        for(id frame in self.frames){
            CGRect this_frame = [frame CGRectValue];
            if((this_frame.size.width*this_frame.size.height) > largestAreaSoFar){
                largestAreaSoFar = (this_frame.size.width*this_frame.size.height);
                biggestFrame = this_frame;
            }
        }
        [self.frames removeObject:[NSValue valueWithCGRect:biggestFrame]];
        self.videoView = [[v_videoview alloc]initWithFrame:biggestFrame andAssets:videos];
        [self addSubview: self.videoView];
        [self bringSubviewToFront: self.videoView];
    }
    int i = 0;
    for(id frame in self.frames){
        CGRect this_frame = [frame CGRectValue];
         ALAssetRepresentation *assetRepresentation = [[media objectAtIndex:i] defaultRepresentation];
        UIImageView* imageview = [[UIImageView alloc] initWithFrame: this_frame];
        UIImage* image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                              scale:[assetRepresentation scale]
                                        orientation:UIImageOrientationUp];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.image = image;
        [self addSubview:imageview];
        imageview.layer.masksToBounds = YES;
        imageview.userInteractionEnabled = YES;
        i++;
    }
}

-(void)addTapGesture
{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlarge:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

/*
 *sets the image tapped to occupy all of the available screen
 */
-(void)enlarge:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self];
    UIView* imageView = (UIView*)[self hitTest:point withEvent:nil];
    if(CGRectEqualToRect(imageView.frame,self.frame)){
        [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = self.chosenFrame;
            AVPlayerLayer* layer = [imageView.layer.sublayers firstObject];
            if(layer){
                layer.frame = imageView.bounds;
            }
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.chosenFrame = imageView.frame;
            imageView.frame = self.frame;
            [self bringSubviewToFront: imageView];
            AVPlayerLayer* layer = [imageView.layer.sublayers firstObject];
            if(layer){
                layer.frame = imageView.bounds;
            }
        }];
    }
}

-(void)getMediaFrames:(int)numMedia andFrame:(CGRect)frame
{
    if(numMedia < 2){
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        return;
    }
    if(frame.size.width > frame.size.height){  //choose vertical split
        int randDivisor = (numMedia == 2)? numMedia : x_ratio;
        int chooseRandomSide = (arc4random() % 2)? 1 : randDivisor - 1;
        CGRect frame1 = CGRectMake(frame.origin.x, frame.origin.y, (frame.size.width*chooseRandomSide/randDivisor), frame.size.height);
        CGRect frame2 = CGRectMake(frame.origin.x + frame1.size.width, frame.origin.y, frame.size.width - frame1.size.width, frame.size.height);
        int firstNumMedia = ceil((float)numMedia/randDivisor);
        int seconNumMedia = numMedia - firstNumMedia;
        BOOL frame1Bigger = (frame1.size.width*frame1.size.height) > (frame2.size.width*frame2.size.height);
        [self getMediaFrames: (frame1Bigger)? seconNumMedia : firstNumMedia andFrame:frame1];
        [self getMediaFrames:(frame1Bigger)? firstNumMedia  : seconNumMedia andFrame:frame2];
    }else{
        int randDivisor = (numMedia == 2)? numMedia : y_ratio;
        int chooseRandomSide = (arc4random() % 2)? 1 : randDivisor - 1;
        CGRect frame1 = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, (frame.size.height*chooseRandomSide/randDivisor));
        CGRect frame2 = CGRectMake(frame.origin.x, frame.origin.y + frame1.size.height, frame.size.width, frame.size.height - frame1.size.height);
        int firstNumMedia = ceil((float)numMedia/randDivisor);
        int seconNumMedia = numMedia - firstNumMedia;
        BOOL frame1Bigger = (frame1.size.width*frame1.size.height) > (frame2.size.width*frame2.size.height);
        [self getMediaFrames: (frame1Bigger)? seconNumMedia : firstNumMedia andFrame:frame1];
        [self getMediaFrames:(frame1Bigger)? firstNumMedia  : seconNumMedia andFrame:frame2];
    }
}

-(void)enableSound
{
    [self.videoView enableSound];
}

-(void)mutePlayer
{
    [self.videoView mutePlayer];
}
@end
