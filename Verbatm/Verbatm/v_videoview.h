//
//  v_videoview.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface v_videoview : UIView
-(void)showPlayBackIcons;
//note that the video list can be alasset or nsdata
-(id)initWithFrame:(CGRect)frame andAssets:(NSArray*)videoList;
-(void)mutePlayer;
-(void)enableSound;
-(void)onScreen;
-(void)offScreen;
@end
