//
//  VideoDownloadManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoDownloadManager.h"
#import "UtilityFunctions.h"
@import Foundation;

@interface VideoDownloadManager ()
@property(nonatomic) NSMutableDictionary * videoAssetList;
@property (nonatomic) NSMutableSet * urlsBeingDownloaded;
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
    return  nil;
}

-(void) downloadURL: (NSURL*) url {
	if (url && ![self.videoAssetList objectForKey:url.absoluteString] &&
		![self.urlsBeingDownloaded containsObject:url.absoluteString]) {
		[self downloadVideo: url];
	}
}

-(void)downloadVideo:(NSURL *) url {
    [self.urlsBeingDownloaded addObject:url.absoluteString];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSError * error = nil;
        
        NSData *downloadedData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
        
        if (!error && downloadedData && (downloadedData.bytes > 0)) {
            //  STORE IN FILESYSTEM
            NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *pathString = [[url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByAppendingString:@".mp4"];
            
            NSString *file = [cachesDirectory stringByAppendingPathComponent:pathString];
            //decompress data before writing
            [[UtilityFunctions gzipInflate:downloadedData] writeToFile:file atomically:YES];
            [self.videoAssetList setObject:file forKey:url.absoluteString];
            int value = [self.counter intValue];
            self.counter = [NSNumber numberWithInt:value+1];
        }
    });
}

//-(AVMutableComposition*) fuseAssets:(NSArray*) videoList {
//	if (self.fusedVideoAsset) return self.fusedVideoAsset;
//	self.fusedVideoAsset = [AVMutableComposition composition]; //create a composition to hold the joined assets
//	AVMutableCompositionTrack* videoTrack = [self.fusedVideoAsset addMutableTrackWithMediaType:AVMediaTypeVideo
//																			  preferredTrackID:kCMPersistentTrackID_Invalid];
//	AVMutableCompositionTrack* audioTrack = [self.fusedVideoAsset addMutableTrackWithMediaType:AVMediaTypeAudio
//																			  preferredTrackID:kCMPersistentTrackID_Invalid];
//	CMTime nextClipStartTime = kCMTimeZero;
//	NSError* error;
//	for(id asset in videoList) {
//		AVURLAsset * videoAsset;
//		if([asset isKindOfClass:[NSURL class]]) {
//			videoAsset = [AVURLAsset assetWithURL:asset];
//		} else {
//			videoAsset = asset;
//		}
//		NSArray * videoTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
//		if(!videoTrackArray.count) continue;
//
//		AVAssetTrack* currentVideoTrack = [videoTrackArray objectAtIndex:0];
//		[videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentVideoTrack atTime:nextClipStartTime error: &error];
//		videoTrack.preferredTransform = currentVideoTrack.preferredTransform;
//		nextClipStartTime = CMTimeAdd(nextClipStartTime, videoAsset.duration);
//
//		NSArray * audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
//		if(!audioTrackArray.count) continue;
//		AVAssetTrack* currentAudioTrack = [audioTrackArray objectAtIndex:0];
//		audioTrack.preferredTransform = currentAudioTrack.preferredTransform;
//		[audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentAudioTrack atTime:nextClipStartTime error:&error];
//	}
//	if (error) {
//		NSLog(@"Error fusing video assets: %@", error.description);
//	}
//	return self.fusedVideoAsset;
//}

-(NSMutableSet *)urlsBeingDownloaded{
    if(!_urlsBeingDownloaded) _urlsBeingDownloaded = [[NSMutableSet alloc] init];
    return _urlsBeingDownloaded;
    
}

-(NSMutableDictionary *) videoAssetList {
    if(!_videoAssetList)_videoAssetList = [[NSMutableDictionary alloc] init];
    return _videoAssetList;
}


@end
