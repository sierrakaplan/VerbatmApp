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
#import "VerbatmImageView.h"

@protocol verbatmGalleryHandlerDelegate <NSObject>
//Called when image is swiped down. delegate handles animation
-(void)didSelectImageView:(VerbatmImageView*)imageView ;
@end

@interface verbatmGalleryHandler: NSObject <UIScrollViewDelegate, UIGestureRecognizerDelegate>
- (verbatmGalleryHandler *)initWithView:(UIView*)view;
- (void)presentGallery;
-(void)dismissGallery;
-(void)returnToGallery:(VerbatmImageView*)view;
-(void)addMediaToGallery:(ALAsset*)asset;
@property (nonatomic, strong) id<verbatmGalleryHandlerDelegate> customDelegate;
@property (nonatomic) BOOL isRaised;

@end

//to do : gallery has to be updated during multiple usage