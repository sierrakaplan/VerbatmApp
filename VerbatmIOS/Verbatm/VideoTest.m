
//
//  VideoTest.m
//  Verbatm
//
//  Created by Iain Usiri on 2/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoTest.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoTest ()
@property (nonatomic) AVPlayerLayer * playerLayer;
@end
@implementation VideoTest



-(void)viewDidLoad{
      NSString *urlToDownload = @"https://verbatmapp.appspot.com/serveVideo?blob-key=AMIfv95RylxxCp1IGVGDwqxa1eESVZi5Ue3PDHNVsvuHXSvkkwZwVdWSvlBNzvawPfUy_X1qb3H3djj5z3SK0WcmELH0_UBHW252cXEkOjPU9Bp0vc9Sc7KGyQ1_-rs5-hqxzj_ClS8xsG9ATFJ51GIL3EP5EB6ayA";
    [self playVideo:urlToDownload];
}


-(void)playVideo:(NSString *) path {
    NSLog(@"about to stream");
    AVPlayer * player =  [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]]];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    // Create an AVPlayerLayer using the player
    if(self.playerLayer)[self.playerLayer removeFromSuperlayer];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = self.view.bounds;
    self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    [self.playerLayer removeAllAnimations];
    [self.view.layer addSublayer:self.playerLayer];
    [player play];

}

-(void)DownloadVideo {
    //download the file in a seperate thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSString *urlToDownload = @"https://verbatmapp.appspot.com/serveVideo?blob-key=AMIfv95RylxxCp1IGVGDwqxa1eESVZi5Ue3PDHNVsvuHXSvkkwZwVdWSvlBNzvawPfUy_X1qb3H3djj5z3SK0WcmELH0_UBHW252cXEkOjPU9Bp0vc9Sc7KGyQ1_-rs5-hqxzj_ClS8xsG9ATFJ51GIL3EP5EB6ayA";
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !");
                [self playVideo:filePath];
            });
        }
        
    });
}
@end
