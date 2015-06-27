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

@interface v_multiplePhotoVideo : UIView
//If there is a video to be added make that the first object of the array.
-(id)initWithFrame:(CGRect)frame Photos:(NSMutableArray*)photos andVideos:(NSArray*)videos;
//-(void)addTapGesture;
-(void)mutePlayer;
-(void)enableSound;
-(void)offScreen;
-(void)onScreen;
@end
