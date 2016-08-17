//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"

#import "Durations.h"
#import "EditMediaContentView.h"

#import "Icons.h"
#import "ImagePinchView.h"

#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "Styles.h"

#import "TextOverMediaView.h"
#import "TextPinchView.h"

#import "VerbatmKeyboardToolBar.h"

#import "UserSetupParameters.h"
#import "UITextView+Utilities.h"

@interface EditMediaContentView () <KeyboardToolBarDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

//keyboard that appears when the user has text on the screen
@property (nonatomic) VerbatmKeyboardToolBar *permanentOnScreenKeyboard;

@property (nonatomic, strong) TextOverMediaView *textAndImageView;
@property (nonatomic) UITapGestureRecognizer *editTextGesture;

@property (nonatomic) UIImageView *swipeInstructionView;

#pragma mark FilteredPhotos
@property (nonatomic, strong) UIImage *image;

@property (nonatomic) CGPoint  panStartLocation;

@property (nonatomic) CGPoint  textViewPanStartLocation;

@property (nonatomic) CGFloat horizontalPanDistance;
@property (nonatomic) BOOL isHorizontalPan;

/* Stores if filter has been changed in order to preserve state on exit */
@property (nonatomic) BOOL filterSwitched;

/* Sentinel to check direction of gesture the first time a
 gesture state changed event is recorded */
@property (nonatomic) BOOL gestureActionJustStarted;

@property (nonatomic) NSInteger keyboardHeight;

// Stores y position of text view after user set it before keyboard appears
@property (nonatomic) CGFloat userSetYPos;

/* Only want to prepare videos once, otherwise just play them */
@property (nonatomic) BOOL videoHasBeenPrepared;

@property (nonatomic) BOOL textViewBeingEdited;

//is half screen for photo video ave
@property (nonatomic) BOOL isAtHalfScreen;

@property (nonatomic) BOOL isRepositioningPhoto;

@property (nonatomic) UIPanGestureRecognizer * textViewPanGesture;

#define HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE 11
#define TOUCH_BUFFER 20
#define DIAGONAL_THRESHOLD 600


#define SWIPE_NOTIFICATON_WIDTH 300.f

@property (nonatomic) UIImage * currentTextAVEBackground;

@end

@implementation EditMediaContentView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor PAGE_BACKGROUND_COLOR];
		[self registerForKeyboardNotifications];
	}
	return self;
}

-(void)registerForKeyboardNotifications{
	//Tune in to get notifications of keyboard behavior
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardWillChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];
}

#pragma mark - Text View -

-(void) editText {
	[self.textAndImageView showText: YES];
	[self.textAndImageView setTextViewFirstResponder: YES];
}

-(void) setText:(NSString *)text
andTextYPosition:(CGFloat)yPosition
   andTextColorBlack:(BOOL)textColorBlack
andTextAlignment:(NSTextAlignment)textAlignment
	andTextSize:(CGFloat)textSize andFontName:(NSString *)fontName {

	[self.textAndImageView setText: text
				  andTextYPosition: yPosition
					  andTextColorBlack: textColorBlack
				  andTextAlignment: textAlignment
					   andTextSize: textSize andFontName:fontName];
	// Move text if half screen
	if (self.isAtHalfScreen) {
		CGFloat contentHeight = [self.textAndImageView.textView measureContentHeight];
		if ((yPosition + contentHeight) > (self.frame.size.height - TEXT_TOOLBAR_HEIGHT)) {
			[self.textAndImageView changeTextViewYPos: 0.f];
		}
	}
	[self.textAndImageView setTextViewEditable:YES];
	[self.textAndImageView showText:YES];
	__weak EditMediaContentView * weakSelf = self;
	[self.textAndImageView setTextViewDelegate:weakSelf];
}

#pragma mark - Keyboard ToolBar -

//creates a toolbar to add onto the keyboard
-(void)addToolBarToViewWithTextColorBlack:(BOOL)textColorBlack {
	CGRect toolBarFrame = CGRectMake(0.f, 0.f, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	BOOL onTextAve = [self.pinchView isKindOfClass:[TextPinchView class]];
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame
                                                                  andTextColorBlack: textColorBlack
																		isOnTextAve:onTextAve
															  isOnScreenPermanently:NO];
	[toolBar setDelegate:self];
	[self.textAndImageView setTextViewKeyboardToolbar:toolBar];

	// add toolbar to screen permanently
	if(!self.permanentOnScreenKeyboard && self.textAndImageView) {
		toolBarFrame.origin.y = self.frame.size.height - TEXT_TOOLBAR_HEIGHT;
		toolBarFrame.size.height = TEXT_TOOLBAR_HEIGHT;
		self.permanentOnScreenKeyboard = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame
																	 andTextColorBlack:textColorBlack
																		   isOnTextAve:onTextAve
																 isOnScreenPermanently:YES];
		[self.permanentOnScreenKeyboard setDelegate:self];
		[self addSubview:self.permanentOnScreenKeyboard];
	} else if (self.textAndImageView) {
		[self addSubview:self.permanentOnScreenKeyboard];
	}
}

-(void) showTextToolbar:(BOOL)show {
	if (show) {
		[self addToolBarToViewWithTextColorBlack:NO];
	} else {
		[self removeScreenToolbar];
	}
}

#pragma mark - Text view content changed -

/* User has edited the text view somehow so we adjust its size */
- (void)textViewDidChange:(UITextView *)textView {
	[self moveTextView:textView afterEdit: NO];
}

- (void)textViewDidBeginEditing: (UITextView *)textView {
	[self.delegate textIsEditing];
    self.textViewBeingEdited = YES;
	[self.textAndImageView.textView setScrollEnabled:YES];
	[self.textAndImageView.textView setUserInteractionEnabled:YES];
	[self.textAndImageView removeGestureRecognizer: self.editTextGesture];
	[self enableMainScrollView:NO];
	self.userSetYPos = textView.frame.origin.y;
    [self.textAndImageView.textView removeGestureRecognizer:self.textViewPanGesture];
	[self moveTextView:textView afterEdit: NO];
	[self removeScreenToolbar];
}

-(void) enableMainScrollView: (BOOL)enable {
	UIView *mainScrollView = self.superview.superview;
	if (![mainScrollView isKindOfClass:[UIScrollView class]]) {
		mainScrollView = mainScrollView.superview;
	}
	[((UIScrollView*)mainScrollView) setScrollEnabled: enable];
}

-(void)removeScreenToolbar {
	if(self.permanentOnScreenKeyboard) {
		[self.permanentOnScreenKeyboard removeFromSuperview];
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    self.textViewBeingEdited = NO;
	[self moveTextView:textView afterEdit:YES];
	[self.textAndImageView.textView setUserInteractionEnabled:NO];
	[self enableMainScrollView: YES];
	[self.textAndImageView addGestureRecognizer: self.editTextGesture];
	[self.textAndImageView addGestureRecognizer: self.textViewPanGesture];
	UIView *mainScrollView = self.superview.superview;
	if (![mainScrollView isKindOfClass:[UIScrollView class]]) {
		mainScrollView = mainScrollView.superview;
	}
	[((UIScrollView*)mainScrollView) setScrollEnabled:YES];
}

/* Enforces word limit */
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
	if (newText.length > TEXT_AVE_CHARACTER_LIMIT) {
		return NO;
	} else {
		return YES;
	}
}

// If afterEdit, moves TextView to the position it should be after user finishes editing
// (ensuring it's on screen based on new contentHeight)
// If not afterEdit, text is still being edited so positions text with last line above keyboard
// if text is not already above it
-(void) moveTextView:(UITextView *)textView afterEdit:(BOOL)after {

	CGFloat contentHeight = [textView measureContentHeight];
	CGRect newFrame;
	CGFloat yPos = 0.f;

	if (after) {
		CGFloat heightDiff = (self.userSetYPos + contentHeight) - (self.frame.size.height - TEXT_TOOLBAR_HEIGHT);
		yPos = self.userSetYPos;
		if (heightDiff > 0) yPos = self.userSetYPos - heightDiff;
		if (yPos < 0.f) yPos = 0.f;
		CGFloat height = self.frame.size.height - yPos;
		height = contentHeight < height ? contentHeight : height;
		newFrame = CGRectMake(TEXT_VIEW_X_OFFSET, yPos, self.frame.size.width, height);
		self.textAndImageView.textYPosition = yPos;
	} else {
		CGFloat heightWithKeyboard = self.isAtHalfScreen ? self.frame.size.height : (self.frame.size.height - self.keyboardHeight);
		yPos = self.userSetYPos;
		CGFloat heightDiff = (self.userSetYPos + contentHeight) - heightWithKeyboard;
		if (heightDiff > 0) {
			yPos = yPos - heightDiff;
			if (yPos < 0) yPos = 0;
			[textView setContentOffset:CGPointMake(0.f, contentHeight - textView.bounds.size.height) animated:YES];
		}
		newFrame = CGRectMake(TEXT_VIEW_X_OFFSET, yPos, self.frame.size.width, heightWithKeyboard - yPos);
	}

	[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
		[textView setFrame:newFrame];
	}completion:^(BOOL finished) {
		if(finished) {
			[textView setHidden:NO];
		}
	}];
}

#pragma mark Keyboard Notifications

/* Gets keyboard height the first time it appears */
-(void)keyboardDidShow:(NSNotification *) notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardHeight = keyboardSize.height;
}

-(void)keyboardDidHide:(NSNotification *) notification {
	[self addToolBarToViewWithTextColorBlack:NO];
}

/* Change size of keyboard when keyboard frame changes */
-(void)keyBoardWillChangeFrame: (NSNotification *) notification {
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	self.keyboardHeight = keyboardSize.height;
}

#pragma mark - Image or Video View -

-(void) displayVideo {
	if(self.videoView)[self.videoView stopVideo];
	self.videoView = [[VideoPlayerView alloc]init];
	self.videoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:self.videoView];
	[self bringSubviewToFront:self.videoView];
	self.videoView.repeatsVideo = YES;
}

-(void) prepareVideoFromAsset: (AVAsset *)videoAsset {
	self.videoAsset = videoAsset;
	[self.videoView prepareVideoFromAsset:videoAsset];
}

-(void)displayImage:(UIImage*)image isHalfScreen:(BOOL)isHalfScreen withContentOffset:(CGPoint) contentOffset {
	self.image = image;
    self.isAtHalfScreen = isHalfScreen;
	BOOL onTextAve = [self.pinchView isKindOfClass:[TextPinchView class]];
	self.textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.bounds
															andImage:image andContentOffset:contentOffset
														  forTextAVE:onTextAve];

	[self addSubview: self.textAndImageView];
	[self addTextViewGestures];

//	todo: bring back filters
//    if(![[UserSetupParameters sharedInstance ] checkAndSetFilterInstructionShown]){
//        [self presentUserInstructionForFilterSwipe];
//    }
//
//	if (![[UserSetupParameters sharedInstance] checkAndSetAddTextInstructionShown]) {
//		todo:
//		[self presentAddTextInstruction];
//	}
}

//todo: bring back filters?
-(void)changeImageTo: (UIImage *)image {
	self.image = image;
	[self.textAndImageView changeImageTo: image];
}

-(void)presentUserInstructionForFilterSwipe {
    
    self.swipeInstructionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipe_to_add_filter"]];
    
    CGFloat width = SWIPE_NOTIFICATON_WIDTH;
    CGFloat height =  width * (82.f/527.f);
    
    self.swipeInstructionView.frame = CGRectMake((self.frame.size.width/2.f) - (width/2.f), (self.frame.size.height/2.f) - (height/2.f), width,height);
    
    [self addSubview:self.swipeInstructionView];
    [self bringSubviewToFront:self.swipeInstructionView];
    
    [UIView animateWithDuration:6.f animations:^{
        self.swipeInstructionView.alpha = 0.f;
    }completion:^(BOOL finished) {
        [self.swipeInstructionView removeFromSuperview];
    }];
    
}

#pragma mark Filters

//-(void)changeFilteredImageLeft{
//	if (self.imageIndex >= ([self.filteredImages count]-1)) {
//		self.imageIndex = -1;
//	}
//	self.imageIndex = self.imageIndex+1;
//	[self.textAndImageView changeImageTo:self.filteredImages[self.imageIndex]];
//
//}
//
//-(void)changeFilteredImageRight {
//	if (self.imageIndex <= 0) {
//		self.imageIndex = [self.filteredImages count];
//	}
//	self.imageIndex = self.imageIndex-1;
//	[self.textAndImageView changeImageTo:self.filteredImages[self.imageIndex]];
//}

#pragma mark - Keyboard toolbar delegate methods -

-(void)keyboardButtonPressed {
	[self.delegate textIsEditing];
    [self editText];
}

-(void)changeTextBackgroundToImage:(NSString *) backgroundImageName{
    ((TextPinchView *) self.pinchView).imageName = backgroundImageName;
    self.currentTextAVEBackground = [UIImage imageNamed:backgroundImageName];
    [self.textAndImageView changeImageTo:self.currentTextAVEBackground ];
}

-(void) textColorChangedToBlack:(BOOL)black {
	if (black) {
		[self.textAndImageView changeTextColor:[UIColor blackColor]];
	} else {
		[self.textAndImageView changeTextColor:[UIColor whiteColor]];
	}
}
-(void)changeTextToFont:(NSString *)fontName{
    [self.textAndImageView.textView setFont:[UIFont fontWithName:fontName size:self.textAndImageView.textView.font.pointSize]];
}

-(void) textSizeIncreased {
	[self.textAndImageView increaseTextSize];
}

-(void) textSizeDecreased {
	[self.textAndImageView decreaseTextSize];
}

-(void) leftAlignButtonPressed {
	[self.textAndImageView changeTextAlignment:NSTextAlignmentLeft];
}

-(void) centerAlignButtonPressed {
	[self.textAndImageView changeTextAlignment:NSTextAlignmentCenter];
}

-(void) rightAlignButtonPressed {
	[self.textAndImageView changeTextAlignment:NSTextAlignmentRight];
}

-(void)repositionPhotoSelected {
	[self.textAndImageView startRepositioningPhoto];
	self.isRepositioningPhoto = YES;
}

-(void)repositionPhotoUnSelected {
	[self.textAndImageView endRepositioningPhoto];
	self.isRepositioningPhoto = NO;
}

-(void) doneButtonPressed {
	if([[self.textAndImageView getText] isEqualToString:@""]) {
		[self.textAndImageView showText:NO];
	}
	[self removeKeyboard];
}

#pragma maro - Pan gestures -

// Add gestures related to text/image view
-(void) addTextViewGestures {
	UIPanGestureRecognizer *moveImageGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	moveImageGesture.delegate = self;
	[self.textAndImageView addGestureRecognizer: moveImageGesture];

	self.editTextGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardButtonPressed)];
	self.editTextGesture.delegate = self;
	[self.textAndImageView addGestureRecognizer: self.editTextGesture];

	[self.textAndImageView addGestureRecognizer:self.textViewPanGesture];
}

/* Handles pan gesture which could be horizontal to add a filter to an image,
 or vertical to change text position */
-(void) didPan:(UIGestureRecognizer *) sender{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			if (sender.numberOfTouches < 1) return;
			self.panStartLocation = [sender locationOfTouch:0 inView:self];
			self.gestureActionJustStarted = YES;
			break;
		case UIGestureRecognizerStateChanged:{
			if (sender.numberOfTouches < 1) return;
			CGPoint location = [sender locationOfTouch:0 inView:self];
			if(self.gestureActionJustStarted){
				[self checkGestureDirection: location];
				self.gestureActionJustStarted = NO;
			}

			if (self.isRepositioningPhoto) {
				[self repositionPhoto: location];
			} else if(self.isHorizontalPan && !self.filterSwitched) {
				//todo: filters?
//				float horizontalDiff = location.x - self.panStartLocation.x;
//				self.horizontalPanDistance += horizontalDiff;
//				//checks if the horizontal pan gone long enough for a "swipe" to change filter
//				if((fabs(self.horizontalPanDistance) >= HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE)){
//					if(self.horizontalPanDistance < 0){
//						[self changeFilteredImageLeft];
//					}else{
//						[self changeFilteredImageRight];
//					}
//					self.filterSwitched = YES;
//				}
			}

			self.panStartLocation = location;
			break;
		}
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			self.horizontalPanDistance = 0.f;
			self.isHorizontalPan = NO;
			self.filterSwitched = NO;
			break;
		}
		default:
			break;
	}
}

-(void) repositionPhoto: (CGPoint) location {
	CGFloat xDiff = location.x - self.panStartLocation.x;
	CGFloat yDiff = location.y - self.panStartLocation.y;
	[self.textAndImageView moveImageX:xDiff andY:yDiff];
}

/* Handles pan gesture on text by moving text to new position */
-(void) didPanTextView:(UIGestureRecognizer *) sender{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			if (sender.numberOfTouches < 1 ||
                self.textViewBeingEdited) return;
            
			self.textViewPanStartLocation = [sender locationOfTouch:0 inView:self.textAndImageView];
			if (!CGRectContainsPoint(self.textAndImageView.textView.frame, self.textViewPanStartLocation)) {
				sender.enabled = NO;
				sender.enabled = YES;
				return;
			}
			[self enableMainScrollView:NO];
			self.gestureActionJustStarted = YES;

			break;

		case UIGestureRecognizerStateChanged:{
            if(self.textViewBeingEdited) return;
            
			CGPoint location = [sender locationOfTouch:0 inView:self.textAndImageView];
			CGFloat verticalDiff = location.y - self.textViewPanStartLocation.y;
			[self.textAndImageView changeTextViewYPosByDiff: verticalDiff];
			self.textViewPanStartLocation = location;
			break;
		}
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			[self enableMainScrollView:YES];
			break;
		}
		default:
			break;
	}
}

#pragma mark - Gesture Recognizer Delegate methods -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
		&& [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		return !self.isHorizontalPan;
	}
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		if ([touch.view isDescendantOfView:self.textAndImageView.textView]) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	if (gestureRecognizer == self.povViewMasterScrollView.panGestureRecognizer){
		return YES;
	}
	return NO;
}

-(void) checkGestureDirection: (CGPoint) location {
	self.isHorizontalPan = ((fabs(location.y - self.panStartLocation.y) < fabs(location.x - self.panStartLocation.x))
							&& fabs(location.y - self.panStartLocation.y) <= DIAGONAL_THRESHOLD); //prevent diagonal swipes
}

#pragma mark - Exit view -

-(void) addTapGestureToMainView {
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyboard)];
	[self addGestureRecognizer:tap];
}

-(void) removeKeyboard {
	[self.textAndImageView setTextViewFirstResponder: NO];
	[self.delegate textDoneEditing];
}

/* Clears video content and saves pinch view info */
-(void) exiting {
	[self updatePinchView];
	if(self.videoView)[self.videoView stopVideo];
}

//updates the content in the pinchview after things are changed
-(void) updatePinchView {
	if (!self.textAndImageView) return;
    if([self.pinchView isKindOfClass:[TextPinchView class]]){
        [((TextPinchView *)self.pinchView) putNewImage:self.currentTextAVEBackground];
    }else if([self.pinchView isKindOfClass:[ImagePinchView class]]) {
//		[((ImagePinchView *)self.pinchView) changeImageToFilterIndex:self.imageIndex];
		((ImagePinchView *)self.pinchView).imageContentOffset = [self.textAndImageView getImageOffset];
	}
	if([self.pinchView isKindOfClass:[SingleMediaAndTextPinchView class]]){
		SingleMediaAndTextPinchView *mediaAndTextPinchView = (SingleMediaAndTextPinchView *)self.pinchView;
		mediaAndTextPinchView.text = [self.textAndImageView getText];
		mediaAndTextPinchView.textYPosition = [NSNumber numberWithFloat:self.textAndImageView.textYPosition];
		mediaAndTextPinchView.textColor = self.textAndImageView.textView.textColor;
		mediaAndTextPinchView.textSize = [NSNumber numberWithFloat:self.textAndImageView.textSize];
		mediaAndTextPinchView.textAlignment = [NSNumber numberWithInteger:self.textAndImageView.textAlignment];
		mediaAndTextPinchView.fontName = self.textAndImageView.textView.font.fontName;
	}
}

#pragma mark - On/Offscreen -

-(void)offScreen {
	[self exiting];
	self.videoHasBeenPrepared = NO;
    if([self.pinchView isKindOfClass:[SingleMediaAndTextPinchView class]]){
        [self.textAndImageView.textView resignFirstResponder];
    }
}

-(void)onScreen {
    if([self.pinchView isKindOfClass:[TextPinchView class]] && self.textAndImageView) {
		[self.textAndImageView setTextViewFirstResponder: [self.textAndImageView.textView.text isEqualToString:@""]];
    } else {
        if(!self.videoHasBeenPrepared){
            [self.videoView prepareVideoFromAsset:self.videoAsset];
            [self.videoView playVideo];
        }else{
            [self.videoView playVideo];
            self.videoHasBeenPrepared = YES;
        }
    }
}

-(void)almostOnScreen {
	if(self.videoAsset){
		[self.videoView stopVideo];
		[self.videoView prepareVideoFromAsset:self.videoAsset];
	}
	self.videoHasBeenPrepared = YES;
}

#pragma mark - Lazy Instantiation -

-(UIPanGestureRecognizer *)textViewPanGesture{
    if(!_textViewPanGesture){
        UIPanGestureRecognizer * textViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanTextView:)];
        textViewPanGesture.minimumNumberOfTouches = 1;
        textViewPanGesture.maximumNumberOfTouches = 1;
		textViewPanGesture.delegate = self;
        _textViewPanGesture = textViewPanGesture;
    }
    return _textViewPanGesture;
}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end