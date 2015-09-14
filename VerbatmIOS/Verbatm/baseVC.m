//
//  baseVC.m
//  Verbatm
//
//  Created by Iain Usiri on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/*
 The function of the VC is to
 maintain basic functionality that every VC in the verbatm app should have.
 all VC's inherit from here.
 */
#import "baseVC.h"

@implementation baseVC
-(NSUInteger) supportedInterfaceOrientations {
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
}
@end
