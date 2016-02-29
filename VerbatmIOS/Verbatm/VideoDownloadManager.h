//
//  VideoDownloadManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoDownloadManager : NSObject

    +(instancetype)sharedInstance;
    -(void)prepareVideoFromURL_synchronous: (NSURL*) url;
    -(void)prepareVideoFromAsset_synchronous: (NSArray *) urlArray;
    //removes reference to the playr item
    -(AVPlayerItem *) getVideoForUrl:(NSString *) urlString;

@end
