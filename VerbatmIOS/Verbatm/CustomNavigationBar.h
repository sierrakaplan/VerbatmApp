//
//  ContentDevNavBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Custom navigation bar for situations where a uinavigationcontroller doesn't make sense
//

#import <UIKit/UIKit.h>

@protocol CustomNavigationBarDelegate <NSObject>

@optional
-(void) leftButtonPressed;
-(void) middleButtonPressed;
-(void) rightButtonPressed;

@end

@interface CustomNavigationBar : UIView

@property (nonatomic, weak) id<CustomNavigationBarDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame andBackgroundColor: (UIColor*) backgroundColor;

-(void) createLeftButtonWithTitle: (NSString*) title orImage: (UIImage*) image;
-(void) createMiddleButtonWithTitle: (NSString*) title orImage: (UIImage*) image;
-(void) createRightButtonWithTitle: (NSString*) title orImage: (UIImage*) image;
-(void) createMiddleButtonWithTitle: (NSString*) title blackText:(BOOL) isBlack largeSize:(BOOL) largeSize;
@end
