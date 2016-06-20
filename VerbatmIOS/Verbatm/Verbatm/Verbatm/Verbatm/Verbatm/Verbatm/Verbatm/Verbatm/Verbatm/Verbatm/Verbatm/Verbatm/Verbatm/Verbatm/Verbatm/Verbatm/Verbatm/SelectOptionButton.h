//
//  SelectOptionButton.h
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "SelectSharingOption.h"

/*
 This button toggles between selected and not selected when
 tapped by the user. It is our version of a check box button.
 To be used in menus where the user needs to select and option.
 */


@interface SelectOptionButton : UIButton
//tells you if the user has selected the button
//setting this toggles the color of the button
@property (nonatomic) BOOL buttonSelected;
//what sharing option this button represents
@property (nonatomic) ShareOptions buttonSharingOption;
//points to the object the button is meant to be
//associated with
@property (nonatomic) id associatedObject;
@end
