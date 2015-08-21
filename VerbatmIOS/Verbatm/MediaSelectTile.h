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
-(void) textButtonPressedOnTile: (MediaSelectTile*) tile;
-(void) multiMediaButtonPressedOnTile: (MediaSelectTile*) tile;

@end

@interface MediaSelectTile : UIView<ContentDevElementDelegate>

    @property (strong, nonatomic) UIScrollView * mainScrollView;
-(void) createFramesForButtonsWithFrame: (CGRect) frame;
-(void) formatButtons;
    @property (strong, nonatomic) id<MediaSelectTileDelegate> delegate;
	// Tells if it is the base media selector tile (last in scroll view)
    @property (nonatomic) BOOL isBaseSelector;
    @property (readonly, nonatomic) BOOL optionSelected;
@end
