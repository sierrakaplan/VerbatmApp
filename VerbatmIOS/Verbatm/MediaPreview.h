//
//  mediaPreview.h
//  Verbatm
//
//  Created by Iain Usiri on 8/22/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MediaPreview : UIView
-(void)setAsset:(ALAsset *) asset;
@end
