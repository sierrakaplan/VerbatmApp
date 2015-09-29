//
//  ContentDevNavBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Static bar on the content dev vc that contains the back button and preview
//

#import <UIKit/UIKit.h>

@protocol ContentDevNavBarDelegate <NSObject>

-(void) backButtonPressed;
-(void) previewButtonPressed;

@end

@interface ContentDevNavBar : UIView

@property (nonatomic, strong) id<ContentDevNavBarDelegate> delegate;

-(void) enablePreviewButton: (BOOL) enable;

@end
