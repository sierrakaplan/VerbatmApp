//
//  customPullBarView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	Pull bar that transitions between the deck and the camera view.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>

@protocol ContentDevPullBarDelegate <NSObject>

// If in menu mode
-(void) cameraButtonPressed;
// If in pull down mode
-(void) pullDownButtonPressed;

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

// causes the pull down arrow to pulse until pressed
-(void) pulsePullDown;

@end
