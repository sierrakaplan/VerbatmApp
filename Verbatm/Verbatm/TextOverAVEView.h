//
//  TextOverAve.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextOverAVEView : UIView

//allows scrolling to be enabled and disabled on textview while running
//Scrolling disabled by default
-(void) enableScrollingWithIndicator:(BOOL)showsIndicator;
-(void) disableScrolling;
-(BOOL) scrollingAllowed;

-(float) getHeightOfText;
-(void) setText:(NSString*)text;

@end
