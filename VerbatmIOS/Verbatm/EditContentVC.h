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
@property (nonatomic, strong) PinchView * pinchView;
@property (nonatomic) NSInteger filterImageIndex;
@property (nonatomic) BOOL photoTappedOpenForTheFirstTime;
@property (strong, nonatomic) EditContentView * openEditContentView;
@end
