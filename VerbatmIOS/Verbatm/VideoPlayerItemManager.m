//
//  VideoPlayerItemManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoPlayerItemManager.h"

@interface VideoPlayerItemManager ()
@property(nonatomic) NSMutableDictionary * videoPlayerItems;//key is url and value is AVPlayerItem
@end


@implementation VideoPlayerItemManager


+(instancetype)sharedInstance{
    static VideoPlayerItemManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VideoPlayerItemManager alloc] init];
    });
    return sharedInstance;
}


-(NSMutableDictionary *) videoPlayerItems {
    if(!_videoPlayerItems )_videoPlayerItems = [[NSMutableDictionary alloc] init];
    return _videoPlayerItems;
}
@end


