//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "SizesAndPositions.h"
#import "Styles.h"
#import "TextAndImageView.h"

@interface TextAndImageView ()

@property (nonatomic, readwrite) BOOL textShowing;

@end

@implementation TextAndImageView

-(instancetype) initWithFrame:(CGRect)frame andImage: (UIImage*) image andText: (NSString*) text andTextYPosition: (CGFloat) textYPosition {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor whiteColor]];
		[self.imageView setImage: image];
		[self addSubview: self.imageView];
		[self.textView setText: text];
		[self.textView setFrame: CGRectOffset(self.textView.frame, 0.f, textYPosition)];
	}
	return self;
}

-(void) showText: (BOOL) show {
	if (show) {
		if (self.textShowing) return; // already showing
		[self addSubview:self.textView];
		[self bringSubviewToFront:self.textView];
	} else {
		if (!self.textShowing) return; // already hidden
		[self.textView removeFromSuperview];
	}
	self.textShowing = !self.textShowing;
}

#pragma mark - Lazy Instantiation -

-(UIImageView*) imageView {
	if (!_imageView) {
		_imageView = [[UIImageView alloc] initWithFrame: self.bounds];
		_imageView.clipsToBounds = YES;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _imageView;
}

-(UITextView*) textView {
	if (!_textView) {
		CGRect textViewFrame = CGRectMake(0.f, 0.f, self.frame.size.width, TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT);
		_textView = [[UITextView alloc] initWithFrame: textViewFrame];
		[_textView setFont:[UIFont fontWithName:DEFAULT_FONT size:TEXT_AVE_FONT_SIZE]];
		_textView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];

		//TEXT_SCROLLVIEW_BACKGROUND_COLOR
		_textView.textColor = [UIColor TEXT_AVE_COLOR];
		_textView.tintColor = [UIColor TEXT_AVE_COLOR];

		//ensure keyboard is black
		_textView.keyboardAppearance = UIKeyboardAppearanceDark;
		_textView.scrollEnabled = NO;
		_textView.editable = NO;
	}
	return _textView;
}

//Formats a textview to the appropriate settings
-(void) formatTextView: (UITextView *) textView {

}

@end
