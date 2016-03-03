//
//  BaseAVE.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/1/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	This is the base class that all other ArticleViewingExperience's inherit from
//

#import <UIKit/UIKit.h>

@interface ArticleViewingExperience : UIView

@property (nonatomic) BOOL inPreviewMode;

// to be overriden in subclasses
-(void)onScreen;

-(void)offScreen;

-(void)almostOnScreen;

@end
