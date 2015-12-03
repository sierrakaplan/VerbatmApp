//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "SizesAndPositions.h"
#import "Styles.h"
#import "StringsAndAppConstants.h"
#import "TextOverMediaView.h"
#import "UITextView+Utilities.h"
#import "UIImage+ImageEffectsAndTransforms.h"
@interface TextOverMediaView ()

@property (nonatomic, readwrite) BOOL textShowing;
@property (strong,nonatomic) UIImageView* ourBlurView;

#define BLUR_IMAGE_FILTER 40
@end

@implementation TextOverMediaView

-(instancetype) initWithFrame:(CGRect)frame andImage: (UIImage*) image andText: (NSString*) text andTextYPosition: (CGFloat) textYPosition {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor AVE_BACKGROUND_COLOR]];
		[self.imageView setImage: image];
        [self setImageViewWithImage:image];
        [self addSubview:self.imageView];
        if(text.length){
            [self.textView setText: text];
            [self.textView setFrame: CGRectMake(self.textView.frame.origin.x,
                                                    textYPosition, self.textView.frame.size.width,
                                                    self.textView.frame.size.height)];
        }
		[self resizeTextView];
	}
	return self;
}

// IMAGE BLUR
-(void) setImageViewWithImage:(UIImage*) image {
    self.ourBlurView = [image getBlurImageViewWithFilterLevel:BLUR_IMAGE_FILTER andFrame:self.bounds];
    [self addSubview:self.ourBlurView];
}


// returns image view with image centered
-(UIImageView*) getImageViewForImage:(UIImage*) image {
    UIImageView* photoView = [[UIImageView alloc] initWithImage:image];
    photoView.frame = self.bounds;
    photoView.clipsToBounds = YES;
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    return photoView;
}

-(void)setText:(NSString *) text{
    [self.textView setText:text];
    [self resizeTextView];
}

-(void) showText: (BOOL) show {
	if (show) {
        if (!self.textShowing){
            [self addSubview:self.textView];
            [self bringSubviewToFront:self.textView];
        }
	} else {
		if (!self.textShowing) return; // already hidden
		[self.textView removeFromSuperview];
	}
	self.textShowing = !self.textShowing;
}


-(void)changeImageTo:(UIImage *) image{
    [self.ourBlurView setImage:[image blurredImageWithFilterLevel:BLUR_IMAGE_FILTER]];
    [self.imageView setImage:image];
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
		CGRect textViewFrame = CGRectMake(0.f, TEXT_VIEW_OVER_MEDIA_Y_OFFSET, self.frame.size.width, TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT);
		_textView = [[UITextView alloc] initWithFrame: textViewFrame];
		[_textView setFont:[UIFont fontWithName:TEXT_AVE_FONT size:TEXT_AVE_FONT_SIZE]];
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

@end
