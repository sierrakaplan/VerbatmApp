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

-(void) downloadURL: (NSURL*) url;

-(AVPlayerItem *) getVideoForUrl:(NSString *) urlString;

//check if there is an entry for this url
//if it's a list give the first entry
-(BOOL)containsEntryForUrl:(NSURL *) url;

@end
