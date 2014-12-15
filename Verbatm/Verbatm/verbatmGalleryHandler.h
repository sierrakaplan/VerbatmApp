//
//  verbatmGalleryHandler.h
//  Verbatm
//
//  Created by Iain Usiri on 9/12/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "verbatmCustomImageView.h"

@protocol verbatmGalleryHandlerDelegate <NSObject>
//Called when image is swiped down. delegate handles animation
-(void)didSelectImageView:(verbatmCustomImageView*)imageView ;
@end

@interface verbatmGalleryHandler: NSObject <UIScrollViewDelegate, UIGestureRecognizerDelegate>
- (verbatmGalleryHandler *)initWithView:(UIView*)view;
- (void)presentGallery;
-(void)dismissGallery;
-(void)returnToGallery:(verbatmCustomImageView*)view;
-(void)addMediaToGallery:(ALAsset*)asset;
@property (nonatomic, strong) id<verbatmGalleryHandlerDelegate> customDelegate;

@end

//to do : gallery has to be updated during multiple usage