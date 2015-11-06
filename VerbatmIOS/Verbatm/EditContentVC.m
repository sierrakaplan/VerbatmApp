//
//  EditContentVC.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CoverPicturePinchView.h"
#import "Durations.h"

#import "EditContentVC.h"
#import "Icons.h"
#import "ImagePinchView.h"
#import "NoAnimationUnwindSegue.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "Styles.h"

#import "TextOverMediaView.h"

#import "UserSetupParameters.h"
#import "UserPovInProgress.h"

#import "VideoPinchView.h"
#import "VerbatmKeyboardToolBar.h"

@interface EditContentVC() <KeyboardToolBarDelegate, UITextViewDelegate>

@property (nonatomic, strong) TextOverMediaView* textAndImageView;
@property (nonatomic, strong) VideoPlayerView * videoView;
@property (strong, nonatomic) UIButton * exitButton;

#pragma mark FilteredPhotos
@property (nonatomic, weak) NSArray * filteredImages;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic, strong) UIButton * textCreationButton;

#pragma mark Pan Gesture
@property (nonatomic) CGPoint panStartLocation;
@property (nonatomic) CGFloat horizontalPanDistance;
@property (nonatomic) BOOL isHorizontalPan;
@property (nonatomic) NSInteger keyboardHeight;

//keeps the frame the user set from panning so can revert after keyboard goes away
@property (nonatomic) CGRect userSetFrame;

#define HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE 11
#define TOUCH_BUFFER 20

@end

@implementation EditContentVC

-(void)viewDidLoad {
	self.view.backgroundColor = [UIColor AVE_BACKGROUND_COLOR];
	[self registerForKeyboardNotifications];
    [self createEditContentViewFromPinchView];
	[self createTextCreationButton];
    [self createExitButton];
	[self addTapGestureToMainView];
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

// This should never be called on a collection pinch view, only on text, image, or video
-(void) createEditContentViewFromPinchView {
	if(self.openPinchView.containsImage) {
		ImagePinchView* imagePinchView = (ImagePinchView*) self.openPinchView;
		[self displayImages:[imagePinchView filteredImages] atIndex:[imagePinchView filterImageIndex]];
	} else { // pinch view contains video
		[self displayVideo:[(VideoPinchView*)self.openPinchView video]];
	}
	if (![self.openPinchView isKindOfClass:[CoverPicturePinchView class]]) {
		if (self.openPinchView.text && self.openPinchView.text.length) {
			[self setText:self.openPinchView.text andTextViewYPosition:self.openPinchView.textYPosition.floatValue];
		}
	}
    if(![[UserSetupParameters sharedInstance] filter_InstructionShown] && [self.openPinchView isKindOfClass:[ImagePinchView class]]) {
		[self alertAddFilter];
	}
}

-(void)createExitButton{
    self.exitButton = [[UIButton alloc] initWithFrame:
                       CGRectMake(EXIT_CV_BUTTON_WALL_OFFSET, EXIT_CV_BUTTON_WALL_OFFSET,
                                  EXIT_CV_BUTTON_WIDTH, EXIT_CV_BUTTON_HEIGHT)];
    [self.exitButton setImage:[UIImage imageNamed:DONE_CHECKMARK] forState:UIControlStateNormal];
	[self.exitButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.exitButton addTarget:self action:@selector(exitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
    [self.view bringSubviewToFront:self.exitButton];
}

-(void)alertAddFilter {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Swipe left to add a filter!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [[UserSetupParameters sharedInstance] set_filter_InstructionAsShown];
}

#pragma mark - Text View -

-(void)createTextCreationButton {
	[self.textCreationButton setImage:[UIImage imageNamed:CREATE_TEXT_ICON] forState:UIControlStateNormal];
	[self.textCreationButton addTarget:self action:@selector(editText) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.textCreationButton];
	[self addLongPress];
}

// long press does the same thing as text button
-(void) addLongPress {
	UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editText)];
	longPressRecognizer.minimumPressDuration = 0.1;
	[self.view addGestureRecognizer:longPressRecognizer];
}

-(void) editText {
	if(![self.textAndImageView textShowing]) {
		[self setText:@"" andTextViewYPosition: TEXT_VIEW_OVER_MEDIA_Y_OFFSET];
	}
	[self.textAndImageView.textView becomeFirstResponder];
}

-(void) setText: (NSString*) text andTextViewYPosition: (CGFloat) yPosition {
	self.textAndImageView.textView.editable = YES;
	self.textAndImageView.textView.text = text;
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
	CGRect toolBarFrame = CGRectMake(0, self.view.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.view.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	[toolBar setDelegate:self];
	self.textAndImageView.textView.inputAccessoryView = toolBar;
}

#pragma mark Keyboard ToolBar Delegate methods

-(void) doneButtonPressed {
	if([self.textAndImageView.textView.text isEqualToString:@""]){
		//remove text view from screen
		[self.textAndImageView showText:NO];
	}
	[self.textAndImageView.textView resignFirstResponder];
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
	self.userSetFrame = textView.frame;
	if((textView.frame.origin.y + textView.frame.size.height) > (self.view.frame.size.height - self.keyboardHeight - TEXT_TOOLBAR_HEIGHT)){
		[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
			self.textAndImageView.textView.frame = CGRectMake(0, (self.view.frame.size.height - self.keyboardHeight -
																  TEXT_TOOLBAR_HEIGHT - textView.frame.size.height),
															  self.textAndImageView.textView.frame.size.width,
															  self.textAndImageView.textView.frame.size.height);
		}];
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView{
	if(self.textAndImageView.textView.frame.origin.y != self.userSetFrame.origin.y){
		[UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
			self.textAndImageView.textView.frame = self.userSetFrame;
		}];
	}
}

// enforce word limit
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
	NSString *trimmedText = [newText stringByReplacingOccurrencesOfString:@" " withString:@""];

	if (newText.length - trimmedText.length > TEXT_WORD_LIMIT) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Keyboard Notifications -

//When keyboard appears get its height. This is only neccessary when the keyboard first appears
-(void)keyboardWillShow:(NSNotification *) notification {
	// Get the size of the keyboard.
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	//store the keyboard height for further use
	self.keyboardHeight = keyboardSize.height;
}

-(void)keyBoardWillChangeFrame: (NSNotification *) notification {
	// Get the size of the keyboard.
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	//store the keyboard height for further use
	self.keyboardHeight = keyboardSize.height;
}

#pragma mark - Image or Video View -

-(void) displayVideo: (AVAsset*) videoAsset {
	self.videoView = [[VideoPlayerView alloc]init];
	self.videoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:self.videoView];
	[self.videoView prepareVideoFromAsset_synchronous:videoAsset];
	[self.videoView playVideo];
	[self.videoView repeatVideoOnEnd:YES];
}

-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index {
	self.filteredImages = filteredImages;
	self.imageIndex = index;
	self.textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.view.bounds andImage:self.filteredImages[self.imageIndex]
															 andText:@"" andTextYPosition:TEXT_VIEW_OVER_MEDIA_Y_OFFSET];
	[self.view addSubview: self.textAndImageView];
	[self addPanGesture];
}

#pragma mark Filters

-(void)changeFilteredImageLeft{
	if (self.imageIndex >= ([self.filteredImages count]-1)) {
		self.imageIndex = -1;
	}
	self.imageIndex = self.imageIndex+1;
	[self.textAndImageView.imageView setImage:self.filteredImages[self.imageIndex]];
}

-(void)changeFilteredImageRight{
	if (self.imageIndex <= 0) {
		self.imageIndex = [self.filteredImages count];
	}
	self.imageIndex = self.imageIndex-1;
	[self.textAndImageView.imageView setImage:self.filteredImages[self.imageIndex]];
}

-(NSInteger) getFilteredImageIndex {
	return self.imageIndex;
}


#pragma mark - Exit view controller -

-(void)exitButtonClicked:(UIButton*) sender{
	[self exitViewController];
}

-(void)viewTapped:(UITapGestureRecognizer*) sender {
	//if the keyboard is up then remove it
	if(self.textAndImageView.textView.isFirstResponder){
		[self.textAndImageView.textView resignFirstResponder];
	} else {
		[self exitViewController];
	}
}

-(void) exitViewController{
	//if the keyboard is up then remove it
	if(self.textAndImageView.textView.isFirstResponder){
		[self.textAndImageView.textView resignFirstResponder];
	}

	if(self.openPinchView.containsImage) {
		ImagePinchView* imagePinchView = (ImagePinchView*) self.openPinchView;
		NSInteger filterImageIndex =  [self getFilteredImageIndex];
		[imagePinchView changeImageToFilterIndex: filterImageIndex];
		[self.videoView stopVideo];
		// add text
		((ImagePinchView *) self.openPinchView).text = [self getText];
		((ImagePinchView *) self.openPinchView).textYPosition = [self getTextYPosition];
	}
	if(self.openPinchView.containsVideo) {
		if(self.videoView)[self.videoView stopVideo];
		((VideoPinchView *) self.openPinchView).text = [self getText];
		((VideoPinchView *) self.openPinchView).textYPosition = [self getTextYPosition];
	}
	[[UserPovInProgress sharedInstance] updatePinchView: self.openPinchView];
	[self dismissViewControllerAnimated:NO completion:^{
		// do nothing
	}];
}

-(void) addTapGestureToMainView {
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
	[self.view addGestureRecognizer:tap];
}

#pragma maro - Pan Gesture (filters + text move) -

-(void) addPanGesture {
	UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	panGesture.minimumNumberOfTouches = 1;
	panGesture.maximumNumberOfTouches = 1;
	[self.view addGestureRecognizer:panGesture];
}

-(void) didPan:(UIGestureRecognizer *) sender{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			if (sender.numberOfTouches < 1) return;
			self.panStartLocation = [sender locationOfTouch:0 inView:self.view];
			if(self.textAndImageView.textView.isFirstResponder) {
				[self.textAndImageView.textView resignFirstResponder];
			}
			break;
		case UIGestureRecognizerStateChanged:{
			if (sender.numberOfTouches < 1) return;
			CGPoint location = [sender locationOfTouch:0 inView:self.view];
			[self checkGestureDirection: location];
			if(self.isHorizontalPan) {
				float horizontalDiff = location.x - self.panStartLocation.x;
				self.horizontalPanDistance += horizontalDiff;
				//has the horizontal pan gone long enough for a "swipe" to change filter
				if(fabs(self.horizontalPanDistance) >= HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE){
					if(self.horizontalPanDistance < 0){
						[self changeFilteredImageLeft];
					}else{
						[self changeFilteredImageRight];
					}
					// Cancel the rest of gesture
					sender.enabled = NO;
					sender.enabled = YES;
				}
			} else {
				float verticalDiff = location.y - self.panStartLocation.y;
				if([self touchInTextViewBounds: location]){
					if([self textViewTranslationInBounds: verticalDiff]){
						self.textAndImageView.textView.frame = CGRectOffset(self.textAndImageView.textView.frame, 0, verticalDiff);
					}
				} else{
					sender.enabled = NO;
					sender.enabled = YES;
				}
			}
			self.panStartLocation = location;
			break;
		}
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			self.horizontalPanDistance = 0.f;
			break;
		}
		default:
			break;
	}
}

// set if gesture is horizontal or not (vertical)
-(void) checkGestureDirection: (CGPoint) location {
	self.isHorizontalPan = ((fabs(location.y - self.panStartLocation.y) < fabs(location.x - self.panStartLocation.x))
							&& fabs(location.y - self.panStartLocation.y) <= 9); //prevent diagonal swipes
}

// check if the text view move is legal (within bounds)
-(BOOL)textViewTranslationInBounds:(float) diff{
	return ((self.textAndImageView.textView.frame.origin.y + diff) > 0.f) &&
	((self.textAndImageView.textView.frame.origin.y + self.textAndImageView.textView.frame.size.height + diff) <
	 self.view.frame.size.height /*- (CIRCLE_RADIUS*2 + SLIDE_THRESHOLD //we have remove this to test what it's like to have text at the very bottom)*/);
}

// check if the touch is on the text view
-(BOOL) touchInTextViewBounds:(CGPoint) touch {
	return (touch.y > self.textAndImageView.textView.frame.origin.y - TOUCH_BUFFER &&
			touch.y < self.textAndImageView.textView.frame.origin.y +
			self.textAndImageView.textView.frame.size.height + TOUCH_BUFFER);
}

#pragma mark - Lazy Instantiation -

-(UIButton *)textCreationButton{
	if(!_textCreationButton){
		_textCreationButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
																		 EXIT_CV_BUTTON_WIDTH,
																		 self.view.frame.size.height - EXIT_CV_BUTTON_WIDTH -
																		 EXIT_CV_BUTTON_WALL_OFFSET,
																		 EXIT_CV_BUTTON_WIDTH,
																		 EXIT_CV_BUTTON_WIDTH)];
	}
	return _textCreationButton;
}

@end
