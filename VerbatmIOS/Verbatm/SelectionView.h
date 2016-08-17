//
//  ChannelSelectionTitleView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectOptionButton.h"
/*
 This is simply the view that holds the name, logo and seleciton button 
 for a share option.
 We only use it to store a referene to the selction button that it's related to.
 */

@interface SelectionView : UIView

@property (nonatomic) SelectOptionButton * shareOptionButton;

@end
