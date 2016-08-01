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
#import "UtilityFunctions.h"
#import "GridView.h"

@interface TextOverMediaView ()

@property (nonatomic, readwrite) BOOL textShowing;
@property (nonatomic) UIScrollView * photoResizeScrollView;
#pragma mark Text properties

@property (nonatomic, readwrite) CGFloat textYPosition;
@property (nonatomic, readwrite) CGFloat textSize;
@property (nonatomic, readwrite) NSTextAlignment textAlignment;
@property (nonatomic, readwrite) BOOL blackTextColor;

@property (nonatomic) GridView * repositionPhotoGrid;

#define DEFAULT_TEXT_VIEW_FRAME CGRectMake(TEXT_VIEW_X_OFFSET, self.textYPosition, self.frame.size.width - TEXT_VIEW_X_OFFSET*2, self.frame.size.height)

@end

@implementation TextOverMediaView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self revertToDefaultTextSettings];
		[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
	}

	return self;
}

-(instancetype) initWithFrame:(CGRect)frame andImageURL:(NSURL*)imageUrl
			   withSmallImage: (UIImage*)smallImage asSmall:(BOOL) small {
	self = [self initWithFrame:frame];
	if (self) {
		UIImage *croppedImage = smallImage;
		if (small) {
			croppedImage = [smallImage imageByScalingAndCroppingForSize: CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
		}
		[self.imageView setImage: croppedImage];

		// Load large image cropped
		if (!small) {
			NSString *imageURI = [UtilityFunctions addSuffixToPhotoUrl:imageUrl.absoluteString forSize: LARGE_IMAGE_SIZE];
			imageUrl = [NSURL URLWithString: imageURI];
            __weak TextOverMediaView *weakSelf = self;
			[[UtilityFunctions sharedInstance] loadCachedPhotoDataFromURL:imageUrl].then(^(NSData* largeImageData) {
				// Only display larger data if less than 1000 KB
				if (largeImageData.length / 1024.f < 1000) {
					UIImage *image = [UIImage imageWithData:largeImageData];
					[weakSelf.imageView setImage: image];
				} else {
					NSLog(@"Image too big");
				}
			});
		}
	}
	return self;
}

-(instancetype) initWithFrame:(CGRect)frame andImage: (UIImage *)image {
	self = [self initWithFrame: frame];
	if (self) {
        [self changeImageTo:image];
	}
	return self;
}



-(void)startRepositioningPhoto{
    if(!self.repositionPhotoGrid){
        self.repositionPhotoGrid = [[GridView alloc] initWithFrame:self.bounds];
        [self addSubview:self.repositionPhotoGrid];
        [self.textView setHidden:YES];
    }
}

-(void)endRepositioningPhoto{
    if(self.repositionPhotoGrid){
        [self.repositionPhotoGrid removeFromSuperview];
        self.repositionPhotoGrid = nil;
        [self.textView setHidden:NO];
    }
}

/* Returns image view with image centered */
-(UIImageView*) getImageViewForImage:(UIImage*) image {
	UIImageView* photoView = [[UIImageView alloc] initWithImage:image];
	photoView.frame = self.bounds;
	photoView.clipsToBounds = YES;
	photoView.contentMode = UIViewContentModeScaleAspectFit;
	return photoView;
}

-(void)changeImageTo:(UIImage *) image {
//    CGSize  newSize = [UtilityFunctions getScreenFrameForImage:image];
//    [self.imageView setFrame:CGRectMake(0.f, 0.f, newSize.height, newSize.height)];
    [self.imageView setImage: image];
    //[self.photoResizeScrollView setContentSize:newSize];
}

#pragma mark - Text View functionality -

-(void) setText:(NSString *)text
andTextYPosition:(CGFloat) textYPosition
andTextColorBlack:(BOOL) textColorBlack
andTextAlignment:(NSTextAlignment) textAlignment
    andTextSize:(CGFloat) textSize andFontName:(NSString *) fontName{
    UIColor *textColor = textColorBlack ? [UIColor blackColor] : [UIColor whiteColor];
    [self changeTextColor:textColor];
    if(!text.length) return;

	self.textYPosition = textYPosition;
	self.textView.frame = DEFAULT_TEXT_VIEW_FRAME;
    [self changeTextAlignment: textAlignment];

	self.textSize = textSize;
    
    [self.textView setFont:[UIFont fontWithName:fontName size:self.textSize]];
    
	[self changeText: text];
   
}

-(void) revertToDefaultTextSettings {
	[self changeText:@""];

	self.textYPosition = TEXT_VIEW_OVER_MEDIA_Y_OFFSET;
	self.textView.frame = DEFAULT_TEXT_VIEW_FRAME;
    [self.textView setBackgroundColor:[UIColor clearColor]];

	self.textSize = TEXT_PAGE_VIEW_DEFAULT_FONT_SIZE;
	[self.textView setFont:[UIFont fontWithName:TEXT_PAGE_VIEW_DEFAULT_FONT size:self.textSize]];

	[self changeTextAlignment: NSTextAlignmentLeft];
	[self changeTextColor:[UIColor TEXT_PAGE_VIEW_DEFAULT_COLOR]];
}

-(void)changeText:(NSString *) text{
	[self.textView setText:text];
	[self bringSubviewToFront:self.textView];
}

-(NSString *)getText {
	return self.textView.text;
}

- (BOOL) changeTextViewYPos: (CGFloat) yPos {
	CGRect tempFrame = CGRectMake(self.textView.frame.origin.x, yPos,
								  self.textView.frame.size.width, self.textView.frame.size.height);
    self.textView.frame = tempFrame;
	self.textYPosition = yPos;
    return YES;
}

-(void) animateTextViewToYPos: (CGFloat) yPos {
	self.textYPosition = yPos;
	CGRect tempFrame = CGRectMake(self.textView.frame.origin.x, yPos,
								  self.textView.frame.size.width, self.textView.frame.size.height);
    __weak TextOverMediaView * weakSelf = self;
	[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
		if(weakSelf)weakSelf.textView.frame = tempFrame;
	}];
}

-(void) changeTextColor:(UIColor *)textColor {
	self.textView.textColor = textColor;
	self.textView.tintColor = textColor;
	if([self.textView isFirstResponder]) {
		[self.textView resignFirstResponder];
		[self.textView becomeFirstResponder];
	}
}

-(void) changeTextAlignment:(NSTextAlignment)textAlignment {
	self.textAlignment = textAlignment;
	[self.textView setTextAlignment:textAlignment];
}

-(void) increaseTextSize {
	self.textSize += 2;
	if (self.textSize > TEXT_PAGE_VIEW_MAX_FONT_SIZE) self.textSize = TEXT_PAGE_VIEW_MAX_FONT_SIZE;
	[self.textView setFont:[UIFont fontWithName:self.textView.font.fontName size:self.textSize]];
}

-(void) decreaseTextSize {
	self.textSize -= 2;
	if (self.textSize < TEXT_PAGE_VIEW_MIN_FONT_SIZE) self.textSize = TEXT_PAGE_VIEW_MIN_FONT_SIZE;
	[self.textView setFont:[UIFont fontWithName:self.textView.font.fontName size:self.textSize]];
}

-(void) addTextViewGestureRecognizer: (UIGestureRecognizer*)gestureRecognizer {
	[self.textView addGestureRecognizer:gestureRecognizer];
}

/* Adds or removes text view */
-(void)showText: (BOOL) show {
	if (show) {
		if (self.textView.isHidden){
			[self.textView setHidden: NO];
			[self bringSubviewToFront:self.textView];
		}
	} else {
		if (!self.textShowing) return;
		[self.textView setHidden:YES];
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
	if (firstResponder)
		[self.textView becomeFirstResponder];
	else if (self.textView.isFirstResponder)
		[self.textView resignFirstResponder];
}

#pragma mark - Lazy Instantiation -


-(UIScrollView *)photoResizeScrollView{
    if(!_photoResizeScrollView){
        _photoResizeScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _photoResizeScrollView.scrollEnabled = YES;
        [_photoResizeScrollView setBounces:NO];
        _photoResizeScrollView.minimumZoomScale = 1.0;
        _photoResizeScrollView.zoomScale = 0.1;
        [self insertSubview:_photoResizeScrollView belowSubview:self.textView];
    }
    return _photoResizeScrollView;
}

-(UIImageView*) imageView {
	if (!_imageView) {
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.photoResizeScrollView addSubview:_imageView];
		_imageView.clipsToBounds = YES;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _imageView;
}

-(UITextView*) textView {
	if (!_textView) {
		CGRect textViewFrame = DEFAULT_TEXT_VIEW_FRAME;
		UITextView *textView = [[UITextView alloc] initWithFrame: textViewFrame];
		[self addSubview:textView];
		_textView = textView;
		_textView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
		_textView.keyboardAppearance = UIKeyboardAppearanceLight;
		_textView.scrollEnabled = YES;
		_textView.editable = NO;
		_textView.selectable = NO;
		[_textView setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
	}
	return _textView;
}

-(void)dealloc{
    _imageView.image = nil;
    _imageView = nil;
}

@end

