//
//  verbatmPhotoVideoAve.h
//  Verbatm
//
//  Created by Iain Usiri on 2/23/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerbatmImageView.h"

@interface PhotoVideoAVE : UIView
-(instancetype) initWithFrame:(CGRect)frame Image: (UIImage *) image andVideo: (NSArray *) video;
-(void)addGesturesToVideoView;
-(void) mute;
-(void) unmute;
-(void)offScreen;
-(void)onScreen;
@end
