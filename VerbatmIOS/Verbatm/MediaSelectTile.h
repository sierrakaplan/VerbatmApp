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
@required

-(void) addMediaButtonPressedOnTile: (MediaSelectTile*) tile;
-(void) deleteMediaTile;
@end

@interface MediaSelectTile : UIView<ContentDevElementDelegate>

@property (strong, nonatomic) UIScrollView * mainScrollView;
-(void) createFramesForButtonWithFrame: (CGRect) frame;
-(void) formatButton;
@property (strong, nonatomic) id<MediaSelectTileDelegate> delegate;
// Tells if it is the base media selector tile (last in scroll view)
@property (nonatomic) BOOL isBaseSelector;
@property (readonly, nonatomic) BOOL optionSelected;

@end
