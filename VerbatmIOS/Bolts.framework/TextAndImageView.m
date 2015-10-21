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
#import "UITextView+Utilities.h"

@interface TextAndImageView ()

@property (nonatomic, readwrite) BOOL textShowing;

@end

@implementation TextAndImageView

-(instancetype) initWithFrame:(CGRect)frame andImage: (UIImage*) image andText: (NSString*) text andTextYPosition: (CGFloat) textYPosition {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor whiteColor]];
		[self.imageView setImage: image];
        [self addSubview:self.imageView];
        //[self setImageViewWithImage:image];
		[self.textView setText: text];
		[self.textView setFrame: CGRectMake(self.textView.frame.origin.x,
											textYPosition, self.textView.frame.size.width,
											self.textView.frame.size.height)];
		[self resizeTextView];
	}
	return self;
}

//
//-(void) setImageViewWithImage:(UIImage*) image {
//    //scale image
//    CGSize imageSize = [UIEffects getSizeForImage:image andBounds:self.bounds];
//    image = [UIEffects scaleImage:image toSize:imageSize];
//    UIView* imageContainerView = [[UIView alloc] initWithFrame:self.bounds];
//    [imageContainerView setBackgroundColor:[UIColor blackColor]];
//    UIImageView* photoView = [self getImageViewForImage:image];
//    UIImageView* blurPhotoView = [UIEffects getBlurImageViewForImage:image withFrame:self.bounds];
//    [imageContainerView addSubview:blurPhotoView];
//    [imageContainerView addSubview:photoView];
//    [self addSubview:imageContainerView];
//}
//
//
//// returns image view with image centered
//-(UIImageView*) getImageViewForImage:(UIImage*) image {
//    UIImageView* photoView = [[UIImageView alloc] initWithImage:image];
//    photoView.frame = self.bounds;
//    photoView.clipsToBounds = YES;
//    photoView.contentMode = UIViewContentModeScaleAspectFit;
//    return photoView;
//}

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

//Calculate the appropriate bounds for the text view
//We only return a frame that is larger than the default frame size
-(void) resizeTextView {
	CGFloat contentHeight = [self.textView measureContentHeight];
	float height = (TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT < contentHeight) ? contentHeight : TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT;
	self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, height);
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
