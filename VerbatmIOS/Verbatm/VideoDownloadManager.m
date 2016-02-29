//
//  VideoDownloadManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoDownloadManager.h"

@interface VideoDownloadManager ()
@property(nonatomic) NSMutableDictionary * videoAssetList;
@end


@implementation VideoDownloadManager
+(instancetype)sharedInstance{
    static VideoDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VideoDownloadManager alloc] init];
    });
    return sharedInstance;
}

-(AVPlayerItem *) getVideoForUrl:(NSString *) urlString{
     AVPlayerItem * avAsset = [self.videoAssetList objectForKey:urlString];
    [self.videoAssetList removeObjectForKey:urlString];
     return avAsset;
}
-(void)prepareVideoFromURL_synchronous: (NSURL*) url {
    if (url) {
        [self.videoAssetList setObject:[AVPlayerItem playerItemWithURL: url] forKey:url.absoluteString];
    }
}

-(void)prepareVideoFromAsset_synchronous: (NSArray *) urlArray {
    if (urlArray) {
        [self.videoAssetList setObject:[AVPlayerItem playerItemWithAsset:[self fuseAssets:urlArray]] forKey:[urlArray firstObject]];
    }
}

-(AVMutableComposition*)fuseAssets:(NSArray*)videoList {
    //if the mix exists don't runt this expensive function
    AVMutableComposition* mix = [AVMutableComposition composition];
    
    //create a composition to hold the joined assets
    AVMutableCompositionTrack* videoTrack = [mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioTrack = [mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextClipStartTime = kCMTimeZero;
    NSError* error;
    for(id asset in videoList) {
        AVURLAsset * videoAsset;
        if([asset isKindOfClass:[NSURL class]]){
            videoAsset = [AVURLAsset assetWithURL:asset];
        } else {
            videoAsset = asset;
        }
        
        NSArray * videoTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        if(videoTrackArray.count){
            AVAssetTrack* this_video_track = [videoTrackArray objectAtIndex:0];
            [videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:this_video_track atTime:nextClipStartTime error: &error]; //insert the video
            videoTrack.preferredTransform = this_video_track.preferredTransform;
            
            NSArray * audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
            if(audioTrackArray.count){
                AVAssetTrack* this_audio_track = [audioTrackArray objectAtIndex:0];
                videoTrack.preferredTransform = this_video_track.preferredTransform;
                if(this_audio_track != nil) {
                    [audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:this_audio_track atTime:nextClipStartTime error:&error];
                }
            }
        }
        nextClipStartTime = CMTimeAdd(nextClipStartTime, videoAsset.duration);
    }
    return mix;
}


-(NSMutableDictionary *) videoAssetList {
    if(!_videoAssetList)_videoAssetList = [[NSMutableDictionary alloc] init];
    return _videoAssetList;
}


@end
