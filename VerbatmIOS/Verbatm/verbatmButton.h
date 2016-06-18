//
//  verbatmButton.h
//  Verbatm
//
//  Created by Iain Usiri on 6/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 */

typedef enum
{
    ButtonSelected = 1,
    ButtonNotSelected =0
    
} ButtonSelectionState;

@interface verbatmButton : UIButton

@property (nonatomic) ButtonSelectionState buttonInSelectedState;
//sets the image for the unselected image as the default background
-(void) storeBackgroundImage:(UIImage *) image forState:(ButtonSelectionState) state;
-(void)switchState;

@end
