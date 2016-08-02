//
//  VerbatmKeyboardToolBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KeyboardToolBarDelegate <NSObject>

/* If black, text color changed to black, else changed to white */
-(void) textColorChangedToBlack:(BOOL)black;
-(void) textSizeIncreased;
-(void) textSizeDecreased;
-(void) leftAlignButtonPressed;
-(void) centerAlignButtonPressed;
-(void) rightAlignButtonPressed;
-(void) doneButtonPressed;

-(void)changeTextToFont:(NSString *)fontName;
-(void)changeTextBackgroundToImage:(NSString *) backgroundImageName;

@optional
-(void)keyboardButtonPressed;

@end



@interface VerbatmKeyboardToolBar : UIView

@property (nonatomic, weak) id<KeyboardToolBarDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame andTextColorBlack:(BOOL)textColorBlack
				 isOnTextAve:(BOOL)onTextAve isOnScreenPermanently:(BOOL) onScreen;

@end
