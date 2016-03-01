//
//  VideoDownloadManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoDownloadManager.h"
@import Foundation;

@interface VideoDownloadManager ()
@property(nonatomic) NSMutableDictionary * videoAssetList;
@property(nonatomic) NSNumber * counter;
@end


@implementation VideoDownloadManager
+(instancetype)sharedInstance{
    static VideoDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VideoDownloadManager alloc] init];
        sharedInstance.counter = [NSNumber numberWithInt:0];
    });
    return sharedInstance;
}


-(BOOL)containsEntryForUrl:(NSURL *) url{
    if( [self.videoAssetList objectForKey:url.absoluteString] ){
        return true;
    }
    return false;
}

-(AVPlayerItem *) getVideoForUrl:(NSString *) urlString{
    
    
    NSString *finalUrlString = [self.videoAssetList objectForKey:urlString];
    
    
//    NSData * videoData =   [self.memoryCache objectForKey:urlString];
//    
//    if(videoData){
//        NSString *dataString = [[NSString alloc] initWithData:videoData encoding:NSUTF8StringEncoding];
//        NSURL *movieURL = [NSURL URLWithString:dataString];
//        return [AVPlayerItem playerItemWithURL:movieURL];
//    }else{
    
    if(finalUrlString){
        AVPlayerItem * player = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:finalUrlString]];
        if(player){
            return player;
        }else{
            AVPlayerItem * avAsset = [self.videoAssetList objectForKey:urlString];
            [self.videoAssetList removeObjectForKey:urlString];
            return avAsset;
        }
    }
    //}
    return  nil;
}



-(void)prepareVideoFromURL_synchronous: (NSURL*) url {
    if (url) {
        
          [self downloadVideo:url];
        
//        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
//        NSArray *keys     =  @[@"playable"];
//        
//        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
//            [self.videoAssetList setObject:[AVPlayerItem playerItemWithAsset:asset]forKey:url.absoluteString];
//
//        }];
    }
}

-(void)prepareVideoFromAsset_synchronous: (NSArray *) urlArray {
    if (urlArray) {
//        NSURL * firstUrl =[urlArray firstObject];
//        AVAsset * asset = [self fuseAssets:urlArray];
//        NSArray *keys     = @[@"playable"];
//        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
//            [self.videoAssetList setObject:[AVPlayerItem playerItemWithAsset:asset]forKey:firstUrl.absoluteString];
//        }];
    }
}




-(void)downloadVideo:(NSURL *) url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSData *downloadedData = [NSData dataWithContentsOfURL:url];
        
        if ( downloadedData && (downloadedData.bytes > 0)) {
           
            //  STORE IN FILESYSTEM
            NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *file = [cachesDirectory stringByAppendingPathComponent:[[self.counter stringValue] stringByAppendingString:@"test.mov"]];
            [downloadedData writeToFile:file atomically:YES];
            [self.videoAssetList setObject:file forKey:url.absoluteString];
            int value = [self.counter intValue];
            self.counter = [NSNumber numberWithInt:value+1];
            
        }
        
        // NOW YOU CAN CREATE AN AVASSET OR UIIMAGE FROM THE FILE OR DATA
    });
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
