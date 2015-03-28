//
//  verbatmPhotoVideoAve.h
//  Verbatm
//
//  Created by Iain Usiri on 2/23/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "verbatmCustomImageView.h"

@interface verbatmPhotoVideoAve : UIView
-(instancetype) initWithFrame:(CGRect)frame Image: (UIImage *) image andVideo: (NSArray *) video;
-(void) mute;
-(void) unmute;
@end
