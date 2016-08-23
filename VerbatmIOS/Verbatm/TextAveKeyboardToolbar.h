//
//  VerbatmKeyboardToolBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextAveKeyboardToolbarDelegate <NSObject>

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

-(void) repositionPhotoSelected;
-(void) repositionPhotoUnSelected;


@optional

-(void)keyboardButtonPressed;

@end



@interface TextAveKeyboardToolbar : UIView

@property (nonatomic, weak) id<TextAveKeyboardToolbarDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame andTextColorBlack:(BOOL)textColorBlack
				 isOnTextAve:(BOOL)onTextAve isOnScreenPermanently:(BOOL) onScreen;

@end
