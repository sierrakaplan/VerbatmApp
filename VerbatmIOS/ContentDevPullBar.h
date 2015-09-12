//
//  customPullBarView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>

@protocol ContentDevPullBarDelegate <NSObject>

-(void) backButtonPressed;
-(void) previewButtonPressed;
// If in menu mode
-(void) cameraButtonPressed;
// If in pull down mode
-(void) pullDownButtonPressed;
-(void) galleryButtonPressed;

@end

@interface ContentDevPullBar : UIView <UIGestureRecognizerDelegate>

typedef NS_ENUM(NSInteger, PullBarMode) {
	PullBarModePullDown,
	PullBarModeMenu
};

@property (nonatomic, strong) id<ContentDevPullBarDelegate> delegate;
// Can be in either pull down mode or menu mode depending on if it's at the top or bottom
@property (nonatomic) PullBarMode mode;

-(void)switchToMode: (PullBarMode) mode;
-(void) enablePreviewInMenuMode: (BOOL) enable;

@end
