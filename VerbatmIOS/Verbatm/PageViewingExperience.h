//
//  PageViewingExperience.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/1/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	This is the base class for all page views.
//

#import <UIKit/UIKit.h>

@interface PageViewingExperience : UIView

@property (nonatomic) BOOL inPreviewMode;

// to be overriden in subclasses
-(void)onScreen;

-(void)offScreen;

-(void)almostOnScreen;

@end
