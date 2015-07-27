//
//  VerbatmImageScrollView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerbatmImageScrollView : UIScrollView

//can pass in array of NSData or UIImage to render photos
-(void)renderPhotos:(NSArray*)photos withBlurBackground:(BOOL)withBackground;
-(void) adjustContentSize;
-(void) setImageHeights;

@end
