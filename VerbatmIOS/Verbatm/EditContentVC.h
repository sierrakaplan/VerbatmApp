//
//  EditContentVC.h
//  Verbatm
//
//  Created by Iain Usiri on 9/12/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchView.h"

@interface EditContentVC : UIViewController

@property (strong, nonatomic) SingleMediaAndTextPinchView* openPinchView;

// Pinch views in a collection - NOT IN USE NOW -
@property (strong, nonatomic) NSArray* openPinchViews;
@property (nonatomic) NSInteger indexTapped;

@end
