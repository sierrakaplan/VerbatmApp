//
//  POVScrollView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Displays a list of POV objects on a scroll view (hack for demo day)

#import <UIKit/UIKit.h>

@interface POVScrollView : UIScrollView

@property (nonatomic) BOOL feedScrollView;

-(void) displayPOVs: (NSArray*)povs;

-(void) clearPOVs;

-(void) playPOVOnScreen;

-(void) headerShowing: (BOOL) showing;

//moves the tap/share bar up and down over the tab bar
-(void) shiftOnScreenPOVLikeShareBar:(BOOL) down;

@end
