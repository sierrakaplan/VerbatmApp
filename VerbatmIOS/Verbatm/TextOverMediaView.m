//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Durations.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "StringsAndAppConstants.h"
#import "TextOverMediaView.h"
#import "UITextView+Utilities.h"
#import "UIImage+ImageEffectsAndTransforms.h"

@interface TextOverMediaView ()

@property (nonatomic, readwrite) BOOL textShowing;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UITextView * textView;
@property (strong,nonatomic) UIImageView* textBackgroundView;

#pragma mark Text properties
@property (nonatomic, readwrite) NSString* text;
@property (nonatomic, readwrite) CGFloat textYPosition;
@property (nonatomic, readwrite) CGFloat textSize;
@property (nonatomic, readwrite) NSTextAlignment textAlignment;
@property (nonatomic, strong, readwrite) UIColor *textColor;

#define BLUR_IMAGE_FILTER 40
@end

@implementation TextOverMediaView

-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage *)image {
	self = [super initWithFrame:frame];
	if (self) {
		[self revertToDefaultTextSettings];
		[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
		[self setImageViewWithImage:image];
	}
	return self;
}

-(void) setImageViewWithImage:(UIImage*) image {
	[self.imageView setImage: image];
	[self addSubview:self.imageView];
}

/* Returns image view with image centered */
-(UIImageView*) getImageViewForImage:(UIImage*) image {
	UIImageView* photoView = [[UIImageView alloc] initWithImage:image];
	photoView.frame = self.bounds;
	photoView.clipsToBounds = YES;
	photoView.contentMode = UIViewContentModeScaleAspectFit;
	return photoView;
}

-(void)changeImageTo:(UIImage *) image{
	[self.imageView setImage:image];
}

#pragma mark - Text View functionality -

-(void) setText:(NSString*)text
andTextYPosition:(CGFloat) textYPosition
   andTextColor:(UIColor*) textColor
andTextAlignment:(NSTextAlignment) textAlignment
	andTextSize:(CGFloat) textSize {
	if(!text.length) return;
	self.textYPosition = textYPosition;
	self.textColor = textColor;
	self.textAlignment = textAlignment;
	self.textSize = textSize;
	self.textView.frame = CGRectOffset(self.textView.frame, 0.f, self.textView.frame.origin.y - textYPosition);
	[self changeText: text];
}

-(void) revertToDefaultTextSettings {
	self.text = @"";
	self.textYPosition = 0.f;
	self.textSize = TEXT_PAGE_VIEW_DEFAULT_FONT_SIZE;
	self.textAlignment = NSTextAlignmentLeft;
	self.textColor = [UIColor TEXT_PAGE_VIEW_DEFAULT_COLOR];
}

-(void)changeText:(NSString *) text{
	[self.textView setText:text];
	[self resizeTextView];
}

- (BOOL) changeTextViewYPos: (CGFloat) yDiff {
	CGRect newFrame = CGRectOffset(self.textView.frame, 0.f, yDiff);
	if (newFrame.origin.y > 0.f
		&& ((newFrame.origin.y + newFrame.size.height)
			< (self.frame.size.height - (CIRCLE_RADIUS * 2)))) {
		self.textView.frame = newFrame;
		self.textYPosition = newFrame.origin.y;
		return YES;
	}
	return NO;
}

-(void) animateTextViewToYPos: (CGFloat) tempYPos {
	[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
		self.textView.frame = CGRectOffset(self.textView.frame, 0.f,
										   tempYPos - self.textView.frame.origin.y);
	}];
}

-(void) addTextViewGestureRecognizer: (UIGestureRecognizer*)gestureRecognizer {
	[self.textView addGestureRecognizer:gestureRecognizer];
}

/* Adds or removes text view */
-(void)showText: (BOOL) show {
	if (show) {
		if (!self.textShowing){
			[self addSubview:self.textView];
			[self bringSubviewToFront:self.textView];
		}
	} else {
		if (!self.textShowing) return;
		[self.textView removeFromSuperview];
	}
	self.textShowing = !self.textShowing;
}

-(BOOL) pointInTextView: (CGPoint)point withBuffer: (CGFloat)buffer {
	return point.y > self.textView.frame.origin.y - buffer
		&& point.y < self.textView.frame.origin.y + self.textView.frame.size.height + buffer;
}

#pragma mark - Change text properties -

-(void) setTextViewEditable:(BOOL)editable {
	self.textView.editable = editable;
}

-(void) setTextViewDelegate:(id<UITextViewDelegate>)textViewDelegate {
	self.textView.delegate = textViewDelegate;
}

-(void) setTextViewKeyboardToolbar:(UIView*)toolbar {
	self.textView.inputAccessoryView = toolbar;
}

-(void) setTextViewFirstResponder:(BOOL)firstResponder {
	if (firstResponder && !self.textView.isFirstResponder)
		[self.textView becomeFirstResponder];
	else if (self.textView.isFirstResponder)
		[self.textView resignFirstResponder];
}

/* Resizes text view based on content height. Only resizes to a height larger than the default. */
-(void) resizeTextView {
	CGFloat contentHeight = [self.textView measureContentHeight];
	float height = (TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT < contentHeight) ? contentHeight : TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT;
	self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,
									 self.textView.frame.size.width, height);
	self.textBackgroundView.frame = CGRectMake(0.f, 0.f, self.textView.frame.size.width, self.textView.frame.size.height);
}

-(void) increaseTextSize {

}

-(void) decreaseTextSize {

}

#pragma mark - Lazy Instantiation -

-(UIImageView*) imageView {
	if (!_imageView) {
		_imageView = [[UIImageView alloc] initWithFrame: self.bounds];
		_imageView.clipsToBounds = YES;
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
	}
	return _imageView;
}

-(UITextView*) textView {
	if (!_textView) {
		CGRect textViewFrame = CGRectMake(self.textYPosition, TEXT_VIEW_OVER_MEDIA_Y_OFFSET,
										  self.frame.size.width, TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT);
		_textView = [[UITextView alloc] initWithFrame: textViewFrame];
		[_textView setFont:[UIFont fontWithName:TEXT_PAGE_VIEW_DEFAULT_FONT size:self.textSize]];
		_textView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
		_textView.textColor = self.textColor;
		_textView.tintColor = self.textColor;
		_textView.keyboardAppearance = UIKeyboardAppearanceDark;
		_textView.scrollEnabled = NO;
		_textView.editable = NO;
		_textView.selectable = NO;
	}
	return _textView;
}

@end

