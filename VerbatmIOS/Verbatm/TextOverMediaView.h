//
//  photoVideoWrapperViewForText.h
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

//	TextOverMediaView takes care of displaying and editing text over an image or a video, within a Page.

#import <UIKit/UIKit.h>

@interface TextOverMediaView : UIView

@property (nonatomic, readonly) BOOL textShowing;

@property (nonatomic, readonly) CGFloat textYPosition;
@property (nonatomic, readonly) CGFloat textSize;
@property (nonatomic, readonly) NSTextAlignment textAlignment;
@property (nonatomic, strong, readonly) UIColor *textColor;

-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage*)image;

-(void) setText:(NSString *)text
andTextYPosition:(CGFloat) textYPosition
   andTextColor:(UIColor *) textColor
andTextAlignment:(NSTextAlignment) textAlignment
	andTextSize:(CGFloat) textSize;

-(void) revertToDefaultTextSettings;

-(void) changeImageTo:(UIImage *)image;

-(void) changeText:(NSString *)text;

-(NSString *) getText;

/* Changes y position of textView, if it is legal (within bounds */
-(BOOL) changeTextViewYPos: (CGFloat) yDiff;

/* Animates text view to new frame. Does not store new frame information (not permanent) */
-(void) animateTextViewToYPos: (CGFloat) tempYPos;

-(void) changeTextColor:(UIColor *)textColor;

-(void) changeTextAlignment:(NSTextAlignment)textAlignment;

-(void) increaseTextSize;

-(void) decreaseTextSize;

-(void) addTextViewGestureRecognizer: (UIGestureRecognizer*)gestureRecognizer;

-(void) setTextViewEditable:(BOOL)editable;

-(void) setTextViewDelegate:(id<UITextViewDelegate>)textViewDelegate;

-(void) setTextViewKeyboardToolbar:(UIView*)toolbar;

-(void) setTextViewFirstResponder:(BOOL)firstResponder;

/* Changes text view height based on content height */
-(void) resizeTextView;

/* Adds or removes text view */
-(void) showText: (BOOL) show;

-(BOOL) pointInTextView: (CGPoint)point withBuffer: (CGFloat)buffer;

@end
