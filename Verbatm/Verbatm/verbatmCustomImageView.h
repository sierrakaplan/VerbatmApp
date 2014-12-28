//
//  verbatmCustomImageView.h
//  Verbatm
//
//  Created by Iain Usiri on 11/25/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface verbatmCustomImageView : UIImageView <NSCoding>
@property(strong, nonatomic) ALAsset* asset;
@property (nonatomic)BOOL isVideo;
@property (nonatomic) BOOL selected;
@end
