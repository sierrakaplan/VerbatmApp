//
//  v_multiplePhotoVideo.h
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@class VideoAVE;

@interface PhotoVideoAVE : UIView

@property (strong, nonatomic) VideoAVE *videoView;

//Photos are array of UIImage and videos are array of AVassets or NSURl
-(id)initWithFrame:(CGRect)frame andPhotos:(NSArray*)photos andVideos:(NSArray*)videos;
//-(void)addTapGesture;

-(void)mutePlayer;

-(void)enableSound;

-(void)offScreen;

-(void)onScreen;

-(void)almostOnScreen;
@end
