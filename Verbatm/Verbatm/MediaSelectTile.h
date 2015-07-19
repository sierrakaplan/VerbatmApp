//
//  verbatmCustomMediaSelectTile.h
//  Verbatm
//
//  Created by Iain Usiri on 9/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaSelectTile;

@protocol MediaSelectTileDelegate <NSObject>
@required
-(void) addTextViewButtonPressedAsBaseView: (BOOL) isBaseView; //tells the delegate that the add text button is clicked
-(void) addMultiMediaButtonPressedAsBaseView: (BOOL) isBaseView fromView: (MediaSelectTile *) tile;//tells the delgate that the add media button is clicked
@end

@interface MediaSelectTile : UIView
    @property (strong, nonatomic) UIScrollView * mainScrollView; //expecting the view to be on a scroll view
    -(void) createFramesForButtonsWithFrame: (CGRect) frame; //edit the frames of buttons in the views
    @property (strong, nonatomic) id<MediaSelectTileDelegate> delegate;
    @property (nonatomic) BOOL baseSelector; //tells if it is the last view in the scrollview
    @property (readonly, nonatomic) BOOL optionSelected;
    @property (nonatomic)   BOOL dashed;//tells you if the view is in dashed mode
    -(void) returnToButtonView;// brings back the buttons from the dashed view
@end
