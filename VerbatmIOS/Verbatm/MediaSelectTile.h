//
//  verbatmCustomMediaSelectTile.h
//  Verbatm
//
//  Created by Iain Usiri on 9/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentDevVC.h"

@class MediaSelectTile;

@protocol MediaSelectTileDelegate <NSObject>

-(void) cameraButtonPressedOnTile: (MediaSelectTile*) tile;
-(void) galleryButtonPressedOnTile: (MediaSelectTile*) tile;
-(void) textButtonPressedOnTile:(MediaSelectTile*) tile;
@end

@interface MediaSelectTile : UIView<ContentDevElementDelegate>

@property (weak, nonatomic) id<MediaSelectTileDelegate> delegate;
@property (strong, nonatomic) UIScrollView * mainScrollView;
// Tells if it is the base media selector tile (last in scroll view)
@property (nonatomic) BOOL isBaseSelector;

// buttons
@property (nonatomic, strong) UIButton* galleryButton;
@property (nonatomic, strong) UIButton* cameraButton;
@property (nonatomic, strong) UIButton* textButton;

// Resizes buttons from different base frame (of the tile)
-(void) createFramesForButtonsWithFrame: (CGRect) frame;

// Animates adding background and shadow to buttons
-(void) buttonGlow;

-(void) enableGalleryButton:(BOOL)enable;
-(void) enableCameraButton:(BOOL)enable;
-(void) enableTextButton:(BOOL)enable;

@end
