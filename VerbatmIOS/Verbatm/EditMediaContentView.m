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

@interface EditMediaContentView () <KeyboardToolBarDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

//keyboard that appears when the user has text on the screen
@property (nonatomic) VerbatmKeyboardToolBar * permanentOnScreenKeyboard;

@property (nonatomic, strong) TextOverMediaView * textAndImageView;

@property (nonatomic) UIImageView * swipeInstructionView;

#pragma mark FilteredPhotos
@property (nonatomic, strong) NSArray * filteredImages;
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
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];


	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardWillChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

#pragma mark - Text View -

-(void)createTextCreationButton {
	[self.textAndImageView setTextViewEditable:YES];
	[self.textAndImageView showText:YES];
    __weak EditMediaContentView * weakSelf = self;
	[self.textAndImageView setTextViewDelegate:weakSelf];
    	[self.textCreationButton setImage:[UIImage imageNamed:CREATE_TEXT_ICON] forState:UIControlStateNormal];
	self.textCreationButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.textCreationButton addTarget:self action:@selector(editText) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.textCreationButton];
	[self bringSubviewToFront:self.textCreationButton];
	
}

-(void)clearTextCreationButton{
    if(self.textCreationButton){
        [self.textCreationButton removeFromSuperview];
        self.textCreationButton = nil;
    }
}

/* long press does the same thing as edit text button */
-(void) addLongPress {
	UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editText)];
	longPressRecognizer.minimumPressDuration = 0.1;
	longPressRecognizer.delegate = self;
	[self addGestureRecognizer:longPressRecognizer];
}

-(void) editText {
	[self.textAndImageView showText: YES];
	[self.textAndImageView setTextViewFirstResponder: YES];
}

-(void) setText:(NSString *)text
andTextYPosition:(CGFloat)yPosition
   andTextColorBlack:(BOOL)textColorBlack
andTextAlignment:(NSTextAlignment)textAlignment
	andTextSize:(CGFloat)textSize andFontName:(NSString *)fontName {
    
	[self addToolBarToViewWithTextColorBlack:textColorBlack];

	[self.textAndImageView setText: text
				  andTextYPosition: yPosition
					  andTextColorBlack: textColorBlack
				  andTextAlignment: textAlignment
					   andTextSize: textSize andFontName:fontName];
    [self createScreenToolBar];
}

#pragma mark - Keyboard ToolBar -

//creates a toolbar to add onto the keyboard
-(void)addToolBarToViewWithTextColorBlack:(BOOL)textColorBlack {
	CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT,
									 self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame
                                                                  andTextColorBlack: textColorBlack isOnTextAve:[self.pinchView isKindOfClass:[TextPinchView class]]];
	[toolBar setDelegate:self];
	[self.textAndImageView setTextViewKeyboardToolbar:toolBar];
}

-(void)createScreenToolBar{
    if(!self.permanentOnScreenKeyboard && self.textAndImageView &&
       ![self.textAndImageView.textView.text isEqualToString:@""]){
        
        [self clearTextCreationButton];
        
        BOOL textColorBlack =NO;
        CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT,
                                         self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
        self.permanentOnScreenKeyboard = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame
                                                                      andTextColorBlack: textColorBlack isOnTextAve:[self.pinchView isKindOfClass:[TextPinchView class]]];
        [self.permanentOnScreenKeyboard setDelegate:self];
        [self addSubview:self.permanentOnScreenKeyboard];
        [self.permanentOnScreenKeyboard presentKeyboardButton];
    }else{
        [self createTextCreationButton];
    }
}


-(void)removeScreenToolbar{
    if(self.permanentOnScreenKeyboard){
        [self.permanentOnScreenKeyboard removeFromSuperview];
        self.permanentOnScreenKeyboard = nil;
    }
    [self clearTextCreationButton];
}


#pragma mark - Text view content changed -

/* User has edited the text view somehow so we adjust its size */
- (void)textViewDidChange:(UITextView *)textView {
	[self.textAndImageView resizeTextView];
}

- (void)textViewDidBeginEditing: (UITextView *)textView{
	[self.delegate textIsEditing];
	self.userSetFrame = textView.frame;
	if((textView.frame.origin.y + textView.frame.size.height)
	   > (self.frame.size.height - self.keyboardHeight - TEXT_TOOLBAR_HEIGHT)) {
		[self.textAndImageView animateTextViewToYPos: TEXT_VIEW_OVER_MEDIA_Y_OFFSET];
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView {
	if(textView.frame.origin.y != self.userSetFrame.origin.y){
		[self.textAndImageView animateTextViewToYPos: self.userSetFrame.origin.y];
	}
    [self removeScreenToolbar];
    [self createScreenToolBar];
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

-(void) keyBoardWillHide:(NSNotification*)notification {
    
}


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

-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index {
	self.imageIndex = index;
	self.textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.bounds
															andImage:filteredImages[index]];
	self.filteredImages = filteredImages;
	[self addSubview: self.textAndImageView];
	[self addPanGestures];
	[self createTextCreationButton];
    [self addLongPress];

	//todo: bring back filters
//    if(![[UserSetupParameters sharedInstance ] checkAndSetFilterInstructionShown]){
//        [self presentUserInstructionForFilterSwipe];
//    }

	if (![[UserSetupParameters sharedInstance] checkAndSetAddTextInstructionShown]) {
		//todo:
//		[self presentAddTextInstruction];
	}
}

//todo: bring back filters?
-(void)changeImageTo: (UIImage *) image {
	self.filteredImages = @[image];
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

-(void)changeFilteredImageLeft{
	if (self.imageIndex >= ([self.filteredImages count]-1)) {
		self.imageIndex = -1;
	}
	self.imageIndex = self.imageIndex+1;
	[self.textAndImageView changeImageTo:self.filteredImages[self.imageIndex]];

}

-(void)changeFilteredImageRight {
	if (self.imageIndex <= 0) {
		self.imageIndex = [self.filteredImages count];
	}
	self.imageIndex = self.imageIndex-1;
	[self.textAndImageView changeImageTo:self.filteredImages[self.imageIndex]];
}

#pragma mark - Keyboard toolbar delegate methods -

-(void)keyboardButtonPressed{
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




-(void) doneButtonPressed {
	if([[self.textAndImageView getText] isEqualToString:@""]) {
		[self.textAndImageView showText:NO];
	}
	[self removeKeyboard];
}

#pragma maro - Pan gestures -

/* Adds pan gestures for adding filters to images and changing text position */
-(void) addPanGestures {
    //needed for filters
    
    //	UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
//	panGesture.minimumNumberOfTouches = 1;
//	panGesture.maximumNumberOfTouches = 1;
//	[self addGestureRecognizer:panGesture];
//	[self.povViewMasterScrollView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
//	self.povViewMasterScrollView.panGestureRecognizer.delegate = self;
//	panGesture.delegate = self;

	UIPanGestureRecognizer * textViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanTextView:)];
	textViewPanGesture.minimumNumberOfTouches = 1;
	textViewPanGesture.maximumNumberOfTouches = 1;
	[self.textAndImageView addTextViewGestureRecognizer:textViewPanGesture];
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
			[self.textAndImageView changeTextViewYPos: verticalDiff];
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
	if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
		if ([self.textAndImageView.textView isFirstResponder]) { //keyboard is up
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

//updates the content in the pinchview after things are changed
-(void) updatePinchView {
    if([self.pinchView isKindOfClass:[TextPinchView class]]){
        [((TextPinchView *)self.pinchView) putNewImage:self.currentTextAVEBackground];
    }else if([self.pinchView isKindOfClass:[ImagePinchView class]]){
		[((ImagePinchView *)self.pinchView) changeImageToFilterIndex:self.imageIndex];
	}
}

#pragma mark - On/Offscreen -

-(void)offScreen {
	[self exiting];
	self.videoHasBeenPrepared = NO;
    if([self.pinchView isKindOfClass:[TextPinchView class]]){
        [self.textAndImageView.textView resignFirstResponder];
    }
}

-(void)onScreen {
    
    if([self.pinchView isKindOfClass:[TextPinchView class]] &&
       [self.textAndImageView.textView.text isEqualToString:@""]){
        [self.textAndImageView.textView becomeFirstResponder];
    }else{
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

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end