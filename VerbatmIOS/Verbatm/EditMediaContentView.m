//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Durations.h"
#import "EditMediaContentView.h"

#import "Icons.h"
#import "ImagePinchView.h"

#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "Styles.h"

#import "TextOverMediaView.h"

#import "VerbatmKeyboardToolBar.h"

@interface EditMediaContentView () <KeyboardToolBarDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TextOverMediaView * textAndImageView;

#pragma mark FilteredPhotos
@property (nonatomic, strong) NSMutableArray * filteredImages;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic, strong) UIButton * textCreationButton;

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
/* Stores frame for text view that user has set so that it can be 
 restored after keyboard goes away */
@property (nonatomic) CGRect userSetFrame;

/* Only want to prepare videos once, otherwise just play them */
@property (nonatomic) BOOL videoHasBeenPrepared;


#define HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE 11
#define TOUCH_BUFFER 20
#define DIAGONAL_THRESHOLD 600

@property (nonatomic) NSMutableArray * videoAssets;

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
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];


	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardWillChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];
}

#pragma mark - Text View -

-(void)createTextCreationButton {
	[self.textCreationButton setImage:[UIImage imageNamed:CREATE_TEXT_ICON] forState:UIControlStateNormal];
	self.textCreationButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

	[self.textCreationButton addTarget:self action:@selector(editText) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.textCreationButton];
	[self bringSubviewToFront:self.textCreationButton];
	[self addLongPress];
}

// long press does the same thing as text button
-(void) addLongPress {
	UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editText)];
	longPressRecognizer.minimumPressDuration = 0.1;
	[self addGestureRecognizer:longPressRecognizer];
}

-(void) editText {
	if(![self.textAndImageView textShowing]) {
		[self setText:@"" andTextViewYPosition: TEXT_VIEW_OVER_MEDIA_Y_OFFSET];
	}
	[self.textAndImageView.textView becomeFirstResponder];
}

-(void) setText: (NSString*) text andTextViewYPosition: (CGFloat) yPosition {
	self.textAndImageView.textView.editable = YES;
	[self.textAndImageView setText:text];
	[self.textAndImageView.textView setFrame: CGRectMake(self.textAndImageView.textView.frame.origin.x, yPosition,
														 self.textAndImageView.textView.frame.size.width,
														 self.textAndImageView.textView.frame.size.height)];
	[self.textAndImageView showText:YES];
	[self.textAndImageView.textView setDelegate:self];
	[self.textAndImageView resizeTextView];
	[self addToolBarToView];
}

#pragma mark - Keyboard ToolBar -

//creates a toolbar to add onto the keyboard
-(void)addToolBarToView {
	CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	[toolBar setDelegate:self];
	self.textAndImageView.textView.inputAccessoryView = toolBar;
}

#pragma mark - Return text and text y position -

-(NSString*) getText {
	return [self.textAndImageView.textView text];
}

-(NSNumber*) getTextYPosition {
	return [NSNumber numberWithFloat: self.textAndImageView.textView.frame.origin.y];
}

#pragma mark Text view content changed

//User has edited the text view somehow so we adjust its size
- (void)textViewDidChange:(UITextView *)textView {
	[self.textAndImageView resizeTextView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{

	[self.delegate textIsEditing];

	self.userSetFrame = textView.frame;
	if((textView.frame.origin.y + textView.frame.size.height) > (self.frame.size.height - self.keyboardHeight - TEXT_TOOLBAR_HEIGHT)){
		[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
			self.textAndImageView.textView.frame = CGRectMake(0,TEXT_VIEW_OVER_MEDIA_Y_OFFSET,
															  self.textAndImageView.textView.frame.size.width,
															  self.textAndImageView.textView.frame.size.height);
		}];
	}
}

//todo: delete or put back
-(void)textViewDidEndEditing:(UITextView *)textView{
	//	if(self.textAndImageView.textView.frame.origin.y != self.userSetFrame.origin.y){
	//		[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
	//			self.textAndImageView.textView.frame = self.userSetFrame;
	//		}];
	//	}
}

/* Enforces word limit */
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
	NSString *trimmedText = [newText stringByReplacingOccurrencesOfString:@" " withString:@""];

	if (newText.length - trimmedText.length > TEXT_WORD_LIMIT) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark Keyboard Notifications

/* Gets keyboard height the first time it appears */
-(void)keyboardWillShow:(NSNotification *) notification {
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	self.keyboardHeight = keyboardSize.height;
}

/* Change size of keyboard when keyboard frame changes */
-(void)keyBoardWillChangeFrame: (NSNotification *) notification {
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	self.keyboardHeight = keyboardSize.height;
}

#pragma mark - Image or Video View -

-(void) displayVideo: (NSMutableArray *) videoAssetArray {
	if(self.videoView)[self.videoView stopVideo];
	self.videoView = [[VideoPlayerView alloc]init];
	self.videoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:self.videoView];
	[self bringSubviewToFront:self.videoView];
	self.videoView.repeatsVideo = YES;
	self.videoAssets = videoAssetArray;
}

-(void)displayImages: (NSMutableArray*) filteredImages atIndex:(NSInteger)index {
	self.imageIndex = index;

	self.textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.bounds
															andImage:filteredImages[index]
															 andText:@"" andTextYPosition:TEXT_VIEW_OVER_MEDIA_Y_OFFSET];
	self.filteredImages = filteredImages;
	[self addSubview: self.textAndImageView];
	[self addPanGestures];
	[self createTextCreationButton];
}

#pragma mark Filters

-(void)changeFilteredImageLeft{
	if (self.imageIndex >= ([self.filteredImages count]-1)) {
		self.imageIndex = -1;
	}
	self.imageIndex = self.imageIndex+1;
	[self.textAndImageView changeImageTo:self.filteredImages[self.imageIndex]];

	[self updatePinchView];

}

-(void)changeFilteredImageRight{
	if (self.imageIndex <= 0) {
		self.imageIndex = [self.filteredImages count];
	}
	self.imageIndex = self.imageIndex-1;
	[self.textAndImageView changeImageTo:self.filteredImages[self.imageIndex]];
	[self updatePinchView];

}

-(NSInteger) getFilteredImageIndex {
	return self.imageIndex;
}

#pragma mark - Keyboard toolbar delegate methods -

-(void) textColorChangedToBlack:(BOOL)black {
	if (black) {
		//todo:[self.textAndImageView]
	} else {

	}
}

-(void) textSizeIncreased {

}

-(void) textSizeDecreased {

}

-(void) leftAlignButtonPressed {

}

-(void) centerAlignButtonPressed {

}

-(void) rightAlignButtonPressed {

}

-(void) doneButtonPressed {
	if([self.textAndImageView.textView.text isEqualToString:@""]) {
		[self.textAndImageView showText:NO];
	}
	[self removeKeyboard];
}

#pragma mark - Exit view

-(void) addTapGestureToMainView {
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyboard)];
	[self addGestureRecognizer:tap];
}

-(void) removeKeyboard {
	//if the keyboard is up then remove it
	if(self.textAndImageView.textView.isFirstResponder){
		[self.textAndImageView.textView resignFirstResponder];
	}
	[self.delegate textDoneEditing];
}
//called before removing the view
//clears up video content
//saves pinchview content as well
-(void)exitingECV{
	[self updatePinchView];
	if(self.videoView)[self.videoView stopVideo];

	if([self.pinchView isKindOfClass:[SingleMediaAndTextPinchView class]]){
		((SingleMediaAndTextPinchView *)self.pinchView).text = self.textAndImageView.textView.text;
		NSNumber * yoffset = [NSNumber numberWithFloat:self.textAndImageView.textView.frame.origin.y];
		((SingleMediaAndTextPinchView *)self.pinchView).textYPosition = yoffset;
	}

}

//updates the content in the pinchview after things are changed
-(void)updatePinchView{
	//save pinchview content
	if([self.pinchView isKindOfClass:[ImagePinchView class]]){
		[((ImagePinchView *)self.pinchView) changeImageToFilterIndex:self.imageIndex];
	}
}

#pragma maro - Adjust text position -

/* Adds pan gestures for adding filters to images and changing text position */
-(void) addPanGestures {
	UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	panGesture.minimumNumberOfTouches = 1;
	panGesture.maximumNumberOfTouches = 1;
	[self addGestureRecognizer:panGesture];
	[self.povViewMasterScrollView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
	self.povViewMasterScrollView.panGestureRecognizer.delegate = self;
	panGesture.delegate = self;

	UIPanGestureRecognizer * textViewpanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanTextView:)];
	textViewpanGesture.minimumNumberOfTouches = 1;
	textViewpanGesture.maximumNumberOfTouches = 1;
	[self.textAndImageView.textView addGestureRecognizer:textViewpanGesture];
}

/* Handles pan gesture which could be horizontal to add a filter to an image,
   or vertical to change text position */
-(void) didPan:(UIGestureRecognizer *) sender{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			if (sender.numberOfTouches < 1) return;
			self.panStartLocation = [sender locationOfTouch:0 inView:self];
			//todo: add back? remove keyboard on pan?
			//                if(self.textAndImageView.textView.isFirstResponder) {
			//					[self removeKeyboard];
			//				}
			self.gestureActionJustStarted = YES;
			break;
		case UIGestureRecognizerStateChanged:{
			if (sender.numberOfTouches < 1) return;
			CGPoint location = [sender locationOfTouch:0 inView:self];
			if(self.gestureActionJustStarted){
				[self checkGestureDirection: location];
				self.gestureActionJustStarted = NO;
			}

			if(self.isHorizontalPan && !self.filterSwitched ) {
				float horizontalDiff = location.x - self.panStartLocation.x;
				self.horizontalPanDistance += horizontalDiff;
				//checks if the horizontal pan gone long enough for a "swipe" to change filter
				if((fabs(self.horizontalPanDistance) >= HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE)){
					if(self.horizontalPanDistance < 0){
						[self changeFilteredImageLeft];
					}else{
						[self changeFilteredImageRight];
					}
					self.filterSwitched = YES;
				}

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

/* Handles pan gesture on text by moving text to new position */
-(void) didPanTextView:(UIGestureRecognizer *) sender{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			if (sender.numberOfTouches < 1) return;
			self.textViewPanStartLocation = [sender locationOfTouch:0 inView:self.textAndImageView];
			self.gestureActionJustStarted = YES;

			break;

		case UIGestureRecognizerStateChanged:{
			CGPoint location = [sender locationOfTouch:0 inView:self.textAndImageView];
			CGFloat verticalDiff = location.y - self.textViewPanStartLocation.y;

			if([self textViewTranslationInBounds:verticalDiff]){
				CGRect newTVFrame = CGRectOffset(self.textAndImageView.textView.frame, 0, verticalDiff);

				if((newTVFrame.origin.y + newTVFrame.size.height) <
				   (self.textAndImageView.frame.size.height - ((CIRCLE_RADIUS)*2))){
					self.textAndImageView.textView.frame = newTVFrame;
				}

			}
			self.textViewPanStartLocation = location;
			break;
		}
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			break;
		}
		default:
			break;
	}
}

#pragma mark - Gesture Recognizer Delegate methods -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return !self.isHorizontalPan;
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

/* Check if the text view move is legal (within bounds) */
-(BOOL)textViewTranslationInBounds:(CGFloat) diff{
	return ((self.textAndImageView.textView.frame.origin.y + diff) > 0.f) &&
	((self.textAndImageView.textView.frame.origin.y + self.textAndImageView.textView.frame.size.height + diff) <
	 self.frame.size.height);
}

/* Check if the touch is on the text view */
-(BOOL) touchInTextViewBounds:(CGPoint) touch {
	return (touch.y > self.textAndImageView.textView.frame.origin.y - TOUCH_BUFFER &&
			touch.y < self.textAndImageView.textView.frame.origin.y +
			self.textAndImageView.textView.frame.size.height + TOUCH_BUFFER);
}

-(void)offScreen {
	[self.videoView stopVideo];
	self.videoHasBeenPrepared = NO;
}

-(void)onScreen {
	if(!self.videoHasBeenPrepared){
		[self.videoView prepareVideoFromArray:self.videoAssets];
		[self.videoView playVideo];
	}else{
		[self.videoView playVideo];
		self.videoHasBeenPrepared = YES;
	}
}

-(void)almostOnScreen {
	if(self.videoAssets){
		[self.videoView stopVideo];
		[self.videoView prepareVideoFromArray:self.videoAssets];
	}
	self.videoHasBeenPrepared = YES;
}

#pragma mark - Lazy Instantiation -

-(UIButton *)textCreationButton{
	if(!_textCreationButton) {
		CGRect buttonFrame = CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET - EXIT_CV_BUTTON_WIDTH,
										self.frame.size.height - EXIT_CV_BUTTON_WIDTH - EXIT_CV_BUTTON_WALL_OFFSET,
										EXIT_CV_BUTTON_WIDTH,
										EXIT_CV_BUTTON_WIDTH);
		_textCreationButton = [[UIButton alloc] initWithFrame:buttonFrame];
	}
	return _textCreationButton;
}

@end