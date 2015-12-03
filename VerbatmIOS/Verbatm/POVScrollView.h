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

-(void) displayPOVs: (NSArray*)povs;

-(void) clearPOVs;

-(void)playPOVOnScreen;

@end
