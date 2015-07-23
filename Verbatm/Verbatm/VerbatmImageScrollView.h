//
//  VerbatmImageScrollView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerbatmImageScrollView : UIScrollView

-(void) renderPhotos:(NSArray*)photos;
-(void) adjustContentSize;
-(void) setImageHeights;

@end
