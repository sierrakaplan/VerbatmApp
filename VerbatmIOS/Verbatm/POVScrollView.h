//
//  POVScrollView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Displays a list of POV objects on a scroll view (hack for demo day)

#import <UIKit/UIKit.h>
#import "PovInfo.h"
@protocol POVScrollViewDelegate <NSObject>
-(void) povLikeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo;
-(void) povshareButtonSelectedForPOVInfo:(PovInfo *) povInfo;
@end



@interface POVScrollView : UIScrollView



@property(nonatomic) id< POVScrollViewDelegate > customDelegate;

@property (nonatomic) BOOL feedScrollView;

-(void) displayPOVs: (NSArray*)povs;

-(void) clearPOVs;

-(void) playPOVOnScreen;

-(void) headerShowing: (BOOL) showing;

//moves the tap/share bar up and down over the tab bar
-(void) shiftOnScreenPOVLikeShareBar:(BOOL) down;

@end
