//
//  PageViewingExperience.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/1/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	This is the base class for all page views.
//

#import "Icons.h"

#import "LoadingIndicator.h"

#import <UIKit/UIKit.h>

@interface PageViewingExperience : UIView

@property (nonatomic) NSInteger indexInPost;
@property (nonatomic) BOOL inPreviewMode;
@property (nonatomic) BOOL currentlyOnScreen;
@property (nonatomic) BOOL hasLoadedMedia;
@property (nonatomic) LoadingIndicator *customActivityIndicator;

// to be overriden in subclasses
-(void)onScreen;

-(void)offScreen;

-(void)almostOnScreen;

@end
