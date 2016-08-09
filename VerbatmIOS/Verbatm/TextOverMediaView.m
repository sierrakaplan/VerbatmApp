//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Durations.h"
#import "Icons.h"
#import "GridView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "StringsAndAppConstants.h"
#import "TextOverMediaView.h"
#import "UITextView+Utilities.h"
#import "UIImage+ImageEffectsAndTransforms.h"
#import "UtilityFunctions.h"

@interface TextOverMediaView ()

@property (nonatomic) BOOL onTextAve;
@property (nonatomic, readwrite) BOOL textShowing;
@property (nonatomic) GridView *repositionPhotoGrid;
@property (nonatomic) UIScrollView *repositionPhotoScrollView;

#pragma mark Text properties

@property (nonatomic, readwrite) CGFloat textSize;
@property (nonatomic, readwrite) NSTextAlignment textAlignment;
@property (nonatomic, readwrite) BOOL blackTextColor;

#define DEFAULT_TEXT_VIEW_FRAME CGRectMake(TEXT_VIEW_X_OFFSET, self.textYPosition, self.frame.size.width - TEXT_VIEW_X_OFFSET*2, TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT)

@end

@implementation TextOverMediaView

// For published view
-(instancetype) initWithFrame:(CGRect)frame andImageURL:(NSURL*)imageUrl
			   withSmallImage: (UIImage*)smallImage asSmall:(BOOL) small {
	self = [self initWithFrame:frame];
	if (self) {
		[self addSubview: self.textView];
		[self.imageView setImage: smallImage];

		// Load large image
		if (!small) {
			NSString *imageURI = [UtilityFunctions addSuffixToPhotoUrl:imageUrl.absoluteString forSize: LARGE_IMAGE_SIZE];
			imageUrl = [NSURL URLWithString: imageURI];
            __weak TextOverMediaView *weakSelf = self;
			[[UtilityFunctions sharedInstance] loadCachedPhotoDataFromURL:imageUrl].then(^(NSData* largeImageData) {
//				NSLog(@"Image size is : %.2f KB",(float)largeImageData.length/1024.0f);
				UIImage *image = [UIImage imageWithData:largeImageData];
				[weakSelf.imageView setImage: image];
			});
		}
	}
	return self;
}

// For preview mode
-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage *)image
			 andContentOffset:(CGPoint)contentOffset forTextAVE:(BOOL)onTextAve {
	self = [self initWithFrame: frame];
	if (self) {
		[self addSubview: self.textView];
		self.onTextAve = onTextAve;
		if (!self.onTextAve) {
			self.repositionPhotoScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
			self.repositionPhotoScrollView.scrollEnabled = NO;
			self.repositionPhotoScrollView.showsVerticalScrollIndicator = NO;
			self.repositionPhotoScrollView.showsHorizontalScrollIndicator = NO;
			[self.imageView removeFromSuperview];
			[self.repositionPhotoScrollView addSubview:self.imageView];
			[self setRepositionImageScrollViewFromImage: image];
			self.repositionPhotoScrollView.contentOffset = contentOffset;
			[self insertSubview:self.repositionPhotoScrollView belowSubview:self.textView];

			self.repositionPhotoGrid = [[GridView alloc] initWithFrame:self.bounds];
			[self addSubview:self.repositionPhotoGrid];
			self.repositionPhotoGrid.hidden = YES;
		} else {
			[self.imageView setImage: image];
		}
	}
	return self;
}

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self revertToDefaultTextSettings];
        [self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
	}
	return self;
}

-(void)changeImageTo:(UIImage *) image {
	if (self.repositionPhotoScrollView) {
		[self setRepositionImageScrollViewFromImage: image];
	} else {
		[self.imageView setImage: image];
	}
}

-(void) setRepositionImageScrollViewFromImage: (UIImage *) image {
	CGSize imageSize = image.size;
	if (imageSize.width < self.frame.size.width) imageSize.width = self.frame.size.width;
	if (imageSize.height < self.frame.size.height) imageSize.height = self.frame.size.height;
	self.repositionPhotoScrollView.contentSize = imageSize;
	self.imageView.frame = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
	[self.imageView setImage: image];
}

-(void)startRepositioningPhoto {
	[self.repositionPhotoGrid setHidden:NO];
	[self.textView setHidden:YES];
}

-(void)endRepositioningPhoto {
	[self.repositionPhotoGrid setHidden:YES];
	[self.textView setHidden:NO];
}

-(CGPoint)getImageOffset {
	CGPoint contentOffset = self.repositionPhotoScrollView.contentOffset;
	return contentOffset;
}

-(void) moveImageX:(CGFloat)xDiff andY:(CGFloat)yDiff {
	CGPoint oldContentOffset = self.repositionPhotoScrollView.contentOffset;

	CGFloat newX = oldContentOffset.x - xDiff;
	if (newX < 0) newX = 0;
	CGFloat xMax = self.repositionPhotoScrollView.contentSize.width - self.bounds.size.width;
	if (newX > xMax) {
		newX = xMax;
	}

	CGFloat newY = oldContentOffset.y - yDiff;
	if (newY < 0) newY = 0;
	CGFloat yMax = self.repositionPhotoScrollView.contentSize.height - self.bounds.size.height;
	if (newY > yMax) {
		newY = yMax;
	}

	self.repositionPhotoScrollView.contentOffset = CGPointMake(newX, newY);
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
	[self resizeTextView];
	[self bringSubviewToFront:self.textView];
}

-(NSString *) getText {
	return self.textView.text;
}

- (void) changeTextViewYPosByDiff: (CGFloat) yDiff {
	CGRect newFrame = CGRectOffset(self.textView.frame, 0.f, yDiff);
	[self changeTextViewYPos: newFrame.origin.y];
}

-(void) changeTextViewYPos: (CGFloat) newYPos {
	CGFloat contentHeight = [self.textView measureContentHeight];
	if ((newYPos + contentHeight) > (self.frame.size.height - TEXT_TOOLBAR_HEIGHT)) {
		newYPos = self.frame.size.height - TEXT_TOOLBAR_HEIGHT - contentHeight;
	}
	if (newYPos < 0.f) {
		newYPos = 0.f;
	}
	CGRect newFrame = self.textView.frame;
	newFrame.origin.y = newYPos;
	self.textView.frame = newFrame;
	self.textYPosition = newYPos;
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
	CGFloat contentHeight = [self.textView measureContentHeight];
	CGSize textViewSize = CGSizeMake(self.textView.frame.size.width, contentHeight);
	self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,
									 textViewSize.width, textViewSize.height);
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
		[self.textView setHidden: NO];
		[self bringSubviewToFront:self.textView];
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
	if (firstResponder) {
		[self.textView.inputAccessoryView removeFromSuperview];
		[self.textView becomeFirstResponder];
	} else if (self.textView.isFirstResponder) {
		[self.textView resignFirstResponder];
	}
}

/* Resizes text view based on content height. Only resizes to a height larger than the default. */
-(void) resizeTextView {
	CGFloat contentHeight = [self.textView measureContentHeight];
	float height = (TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT < contentHeight) ? contentHeight : TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT;
    
    
    
	self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,
									 self.textView.frame.size.width, height);
}

#pragma mark - Lazy Instantiation -

-(UIImageView*) imageView {
	if (!_imageView) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame: self.bounds];
		[self insertSubview:imageView belowSubview:self.textView];
		_imageView = imageView;
		_imageView.clipsToBounds = YES;
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
	}
	return _imageView;
}

-(UITextView*) textView {
	if (!_textView) {
		_textView = [[UITextView alloc] initWithFrame: DEFAULT_TEXT_VIEW_FRAME];
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

