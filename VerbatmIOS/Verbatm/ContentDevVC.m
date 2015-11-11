

//
//  verbatmContentPageViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Analytics.h"

#import "ContentDevVC.h"
#import "CollectionPinchView.h"
#import "CoverPicturePinchView.h"
#import "ContentPageElementScrollView.h"
#import "Durations.h"

#import "EditContentView.h"
#import "EditContentVC.h"

#import "ImagePinchView.h"
#import "Icons.h"

#import "MediaDevVC.h"
#import "MediaSelectTile.h"

#import "GMImagePickerController.h"

#import <QuartzCore/QuartzCore.h>
#import "PinchView.h"

#import "Notifications.h"
#import "MediaSelectTile.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Strings.h"
#import "Styles.h"

#import "UIImage+ImageEffectsAndTransforms.h"
#import "UserSetupParameters.h"
#import "UtilityFunctions.h"
#import "UserPovInProgress.h"
#import "UIView+Effects.h"

#import "VerbatmScrollView.h"
#import "VideoPinchView.h"



@interface ContentDevVC () <UITextFieldDelegate, UIScrollViewDelegate, MediaSelectTileDelegate,
GMImagePickerControllerDelegate, ContentPageElementScrollViewDelegate, ContentDevNavBarDelegate>

#pragma mark Image Manager

@property (strong, nonatomic) PHImageManager *imageManager;
@property (strong, nonatomic) PHVideoRequestOptions *videoRequestOptions;

#pragma mark Pinch Views

//keeps track of ContentPageElementScrollViews
@property (strong, nonatomic) NSMutableArray * pageElementScrollViews;
@property (nonatomic) NSInteger numPinchViews;

#pragma mark Cover photo

// Says whether or not user is currently adding a cover picture
// (used when returning from adding assets)
@property (nonatomic) BOOL addingCoverPicture;
@property (strong, nonatomic) UITapGestureRecognizer* addCoverPictureTapGesture;
@property (strong, nonatomic) CoverPicturePinchView * coverPicView;
@property (strong, nonatomic) UIButton * replaceCoverPhotoButton;

#pragma mark Keyboard related properties
@property (atomic) NSInteger keyboardHeight;

#pragma mark Helpful integer stores
//the index of the first view that is pushed up/down by the pinch/stretch gesture
@property (atomic, strong) NSString * textBeforeNavigationLabel;

#pragma mark undo related properties
@property (atomic, strong) NSUndoManager * tileSwipeViewUndoManager;

#pragma mark Default frame properties

@property (nonatomic) CGSize defaultPageElementScrollViewSize;
@property (nonatomic) CGPoint defaultPinchViewCenter;
@property (nonatomic) float defaultPinchViewRadius;

#pragma mark Text input outlets

@property (weak, atomic) IBOutlet UITextView *firstContentPageTextBox;
@property (strong, atomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;


#pragma mark PanGesture Properties

@property (nonatomic, weak) ContentPageElementScrollView* selectedView_PAN;
@property(nonatomic) CGPoint previousLocationOfTouchPoint_PAN;
//keep track of the starting from of the selected view so that you can easily shift things around
@property (nonatomic) CGRect previousFrameInLongPress;

#pragma mark - Pinch Gesture Related Properties

//tells if pinching is occurring
@property (nonatomic) PinchingMode pinchingMode;

#pragma mark Horizontal pinching

@property (nonatomic, weak) ContentPageElementScrollView * scrollViewOfHorizontalPinching;
@property (nonatomic) NSInteger horizontalPinchDistance;
@property(nonatomic) CGPoint leftTouchPointInHorizontalPinch;
@property (nonatomic) CGPoint rightTouchPointInHorizontalPinch;

#pragma mark Vertical pinching
@property (strong, nonatomic) MediaSelectTile * baseMediaTileSelector;
@property (nonatomic,weak) MediaSelectTile* newlyCreatedMediaTile;
@property (nonatomic,weak) ContentPageElementScrollView * upperPinchScrollView;
@property (nonatomic,weak) ContentPageElementScrollView * lowerPinchScrollView;
@property (nonatomic) CGPoint upperTouchPointInVerticalPinch;
@property(nonatomic) CGPoint lowerTouchPointInVerticalPinch;
// Useful for pinch apart to add media between objects
@property (nonatomic) ContentPageElementScrollView* addMediaBelowView;


//informs our instruction notification if the user has added
//pinch views to the article before
@property (nonatomic) BOOL pinchObject_HasBeenAdded_ForTheFirstTime;
@property (nonatomic) BOOL pinchViewTappedAndClosedForTheFirstTime;

#define WHAT_IS_IT_LIKE_TEXT @"tell your story"

#define CLOSED_ELEMENT_FACTOR (2/5)
#define TITLE_FIELD_Y_OFFSET (CONTENT_DEV_NAV_BAR_OFFSET*2 + NAV_ICON_SIZE)
#define TITLE_FIELD_X_OFFSET 7
#define TITLE_FIELD_HEIGHT 100
#define MAX_TITLE_CHARACTERS 40

#define REPLACE_PHOTO_FRAME_WIDTH 35
#define REPLACE_PHOTO_FRAME_HEIGHT 35

#define REPLACE_PHOTO_YOFFSET 20
#define REPLACE_PHOTO_XsOFFSET 10

#define BASE_MAINSCROLLVIEW_CONTENT_SIZE self.view.frame.size.height + 1

#define COVER_PIC_RADIUS (self.defaultPinchViewRadius * 3.f/4.f)
@end


@implementation ContentDevVC

#pragma mark - Initialization And Instantiation -

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initializeVariables];
	[self addBlurView];
	[self setFrameMainScrollView];
	[self setElementDefaultFrames];
	[self formatNavBar];
	[self setKeyboardAppearance];
	[self setCursorColor];
	[self formatTitleAndCoverPicture];
	[self createBaseSelector];
	[self setUpNotifications];
	self.titleField.delegate = self;
	self.mainScrollView.delegate = self;
}

-(void) initializeVariables {
	self.pinchingMode = PinchingModeNone;
	self.addingCoverPicture = NO;
	self.numPinchViews = 0;
	self.pinchObject_HasBeenAdded_ForTheFirstTime = NO;
	self.addMediaBelowView = nil;
	self.pinchViewTappedAndClosedForTheFirstTime = NO;
}

-(void) addBlurView {
	[self.view createBlurViewOnViewWithStyle:UIBlurEffectStyleLight];
}

-(void) setFrameMainScrollView {
	self.mainScrollView.frame= self.view.frame;
	self.mainScrollView.scrollEnabled = YES;
	self.mainScrollView.bounces = YES;
	//just to give it initial bounce
	self.mainScrollView.contentSize = CGSizeMake(0, BASE_MAINSCROLLVIEW_CONTENT_SIZE);
}


//records the generic frame for any element that is a square and not a pinch view circle,
// as well as the pinch view center and radius
-(void)setElementDefaultFrames {
	self.defaultPageElementScrollViewSize = CGSizeMake(self.view.frame.size.width, ((self.view.frame.size.height*2.f)/5.f));
	self.defaultPinchViewCenter = CGPointMake(self.view.frame.size.width/2.f,
											  self.defaultPageElementScrollViewSize.height/2.f);
	self.defaultPinchViewRadius = (self.defaultPageElementScrollViewSize.height - ELEMENT_OFFSET_DISTANCE)/2.f;
}

-(void) formatNavBar {
	self.navBar.delegate = self;
	[self.mainScrollView addSubview: self.navBar];
}

-(void) createBaseSelector {

	CGRect scrollViewFrame = CGRectMake(0, self.coverPicView.frame.origin.y + self.coverPicView.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.view.frame.size.width, MEDIA_TILE_SELECTOR_HEIGHT+ELEMENT_OFFSET_DISTANCE);

	ContentPageElementScrollView * baseMediaTileSelectorScrollView = [[ContentPageElementScrollView alloc]
																	  initWithFrame:scrollViewFrame
																	  andElement:self.baseMediaTileSelector];

	baseMediaTileSelectorScrollView.scrollEnabled = NO;
	baseMediaTileSelectorScrollView.delegate = self; // scroll view delegate
	baseMediaTileSelectorScrollView.contentPageElementScrollViewDelegate = self;

	[self.mainScrollView addSubview:baseMediaTileSelectorScrollView];
	[self.pageElementScrollViews addObject:baseMediaTileSelectorScrollView];
}

// set keyboard appearance color on all textfields and textviews
-(void) setKeyboardAppearance {
	[[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
}

// set cursor color on all textfields and textviews
-(void) setCursorColor {
	[[UITextField appearance] setTintColor:[UIColor TITLE_TEXT_COLOR]];
}

//sets the textview placeholders' color and text
-(void) formatTitleAndCoverPicture {

	CGRect titleFrame = CGRectMake(TITLE_FIELD_X_OFFSET, TITLE_FIELD_Y_OFFSET,
											   self.view.bounds.size.width - 2*TITLE_FIELD_X_OFFSET,
											   TITLE_FIELD_HEIGHT);
	CGFloat coverPicRadius = COVER_PIC_RADIUS;
	CGRect addCoverPicFrame = CGRectMake(self.view.frame.size.width/2.f - coverPicRadius,
										 titleFrame.origin.y + titleFrame.size.height,
										 coverPicRadius*2, coverPicRadius*2);

	[self formatTitleFieldFromFrame: CGRectMake(0, 0, titleFrame.size.width, titleFrame.size.height/2.f)];

	//Title border
	UIView* titleBorderView = [[UIView alloc] initWithFrame: titleFrame];
	UIImageView* titleBorderImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0,
																				  titleFrame.size.width,
																				  titleFrame.size.height)];
	[titleBorderImageView setImage:[UIImage imageNamed: TITLE_BORDER]];
	titleBorderImageView.contentMode = UIViewContentModeScaleAspectFill;

	[titleBorderView addSubview: titleBorderImageView];
	[titleBorderView addSubview: self.titleField];
	[titleBorderView bringSubviewToFront: self.titleField];
	[self.mainScrollView addSubview: titleBorderView];

	[self setAddCoverPictureViewWithFrame: addCoverPicFrame];
}

-(void) formatTitleFieldFromFrame: (CGRect) frame {
	UIFont* titleFont = [UIFont fontWithName:PLACEHOLDER_FONT size: TITLE_TEXT_SIZE];
	self.titleField = [[UITextField alloc] initWithFrame: frame];
	self.titleField.textAlignment = NSTextAlignmentCenter;
	self.titleField.font = [UIFont fontWithName:TITLE_TEXT_FONT size: TITLE_TEXT_SIZE];
    [self.titleField setTextColor:[UIColor TITLE_TEXT_COLOR]];
	self.titleField.tintColor = [UIColor TITLE_TEXT_COLOR];
	self.titleField.attributedPlaceholder = [[NSAttributedString alloc]
													initWithString: WHAT_IS_IT_LIKE_TEXT
													attributes:@{NSForegroundColorAttributeName: [UIColor TITLE_TEXT_COLOR],
																 NSFontAttributeName : titleFont}];
	[self.titleField resignFirstResponder];
	self.titleField.enabled = YES;
	self.titleField.autocorrectionType = UITextAutocorrectionTypeYes;
	[self.titleField setReturnKeyType:UIReturnKeyDone];
}

-(void) setAddCoverPictureViewWithFrame: (CGRect) frame {
    self.coverPicView = [[CoverPicturePinchView alloc] initWithRadius:COVER_PIC_RADIUS withCenter:CGPointMake(frame.origin.x + frame.size.width/2.f, frame.origin.y + frame.size.width/2.f) andImage:nil];
	self.addCoverPictureTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentGalleryForCoverPic)];
	[self.coverPicView addGestureRecognizer: self.addCoverPictureTapGesture];
	[self.mainScrollView addSubview: self.coverPicView];
}

-(void) setUpNotifications {
	//Tune in to get notifications of keyboard behavior
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillDisappear:)
												 name:UIKeyboardWillHideNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardWillChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged)
												 name:UIDeviceOrientationDidChangeNotification
											   object: [UIDevice currentDevice]];
}

-(UIImage*) getCoverPicture {
	return [self.coverPicView getImage];
}

// Loads pinch views from user defaults
-(void) loadPOVFromUserDefaults {
	NSString* savedTitle = [[UserPovInProgress sharedInstance] title];
	if (savedTitle && savedTitle.length) {
		self.titleField.text = savedTitle;
	}

	UIImage* coverPicture = [[UserPovInProgress sharedInstance] coverPhoto];
	if (coverPicture) {
		[self setCoverPictureImage: coverPicture];
	}

	NSArray* savedPinchViews = [[UserPovInProgress sharedInstance] pinchViews];
	for (PinchView* pinchView in savedPinchViews) {
		[pinchView specifyRadius:self.defaultPinchViewRadius
					   andCenter:self.defaultPinchViewCenter];
		[self newPinchView:pinchView belowView: nil];
	}
}

-(void) coverPicAddedForFirstTime {
	//show replace photo icon after the first time this is tapped
	[self addTapGestureToPinchView:self.coverPicView];
	[self.coverPicView removeGestureRecognizer: self.addCoverPictureTapGesture];
	[self.mainScrollView addSubview:self.replaceCoverPhotoButton];
}

#pragma mark - Nav Bar Delegate Methods -

-(void) backButtonPressed {
	[self.delegate backButtonPressed];
}

-(void) previewButtonPressed {
	[self closeAllOpenCollections];
	[self.delegate previewButtonPressed];
}

#pragma mark - Configure Text Fields -

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.titleField) {
		[[UserPovInProgress sharedInstance] addTitle: textField.text];
	}
}

// if we encounter a newline character return
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if(textField == self.titleField) {
		// enter closes the keyboard
		if ([string isEqualToString:@"\n"]) {
			[textField resignFirstResponder];
			return NO;
		} else if (textField.text.length >= MAX_TITLE_CHARACTERS && string.length > 0)  {
			return NO;
		}
		return YES;
	} else {
		return YES;
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.titleField) {
		[self.titleField resignFirstResponder];
	}
	return YES;
}


#pragma mark - ScrollViews -

//adjusts the contentsize of the main view to the last element
-(void) adjustMainScrollViewContentSize {
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		ContentPageElementScrollView *lastScrollView = (ContentPageElementScrollView *)[self.pageElementScrollViews lastObject];
		float y_Offset = (self.pageElementScrollViews.count == 1 ) ? BASE_MAINSCROLLVIEW_CONTENT_SIZE :lastScrollView.frame.origin.y + lastScrollView.frame.size.height + CONTENT_SIZE_OFFSET;

		self.mainScrollView.contentSize = CGSizeMake(0,y_Offset);
	}];
}

#pragma mark Scroll View actions

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
	if(scrollView == self.mainScrollView) {
		[self showOrHidePullBarBasedOnMainScrollViewScroll];
		return;
	}
	if([scrollView isKindOfClass:[ContentPageElementScrollView class]]) {
		ContentPageElementScrollView* pageElementScrollView = (ContentPageElementScrollView*)scrollView;
		if(pageElementScrollView.collectionIsOpen) {
			return;
		}
		if ([pageElementScrollView isDeleting]) {
			[pageElementScrollView.pageElement markAsDeleting:YES];
		} else {
			[pageElementScrollView.pageElement markAsDeleting:NO];
		}
	}
}

//make sure the object is in the right position
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
				  willDecelerate:(BOOL)decelerate {
	if ([scrollView isKindOfClass:[ContentPageElementScrollView class]]) {
		[self animateScrollViewBackOrToDeleteMode:(ContentPageElementScrollView*)scrollView];
	}
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	if ([scrollView isKindOfClass:[ContentPageElementScrollView class]]) {
		[self animateScrollViewBackOrToDeleteMode:(ContentPageElementScrollView*)scrollView];
	}
}

//check if scroll view has been scrolled enough to delete, and if so delete.
//Otherwise scroll it back
-(void) animateScrollViewBackOrToDeleteMode:(ContentPageElementScrollView*)scrollView {
	if (self.pinchingMode != PinchingModeNone || scrollView.collectionIsOpen){
		return;
	}

	if([scrollView isDeleting]) {
		[scrollView animateToDeleting];
	} else {
		[scrollView animateBackToInitialPosition];
	}
}

-(void) showOrHidePullBarBasedOnMainScrollViewScroll {
	CGPoint translation = [self.mainScrollView.panGestureRecognizer translationInView:self.mainScrollView];
	if(translation.y < 0) {
		[self.delegate showPullBar:NO withTransition:YES];
	}else {
		[self.delegate showPullBar:YES withTransition:YES];
	}
	return;
}

#pragma mark - Content Page Element Scroll View Delegate -
//apply two step deletion
-(void) deleteButtonPressedOnContentPageElementScrollView:(ContentPageElementScrollView*)scrollView {
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Confirm Deletion" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self deleteScrollView: scrollView];
                                                          }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action1];
    [newAlert addAction:action2];
    [self presentViewController:newAlert animated:YES completion:nil];
    
    
    
}


#pragma mark - Deleting scrollview and element -

//Deletes scroll view and the element it contained
-(void) deleteScrollView:(ContentPageElementScrollView*)pageElementScrollView {
	if (![self.pageElementScrollViews containsObject:pageElementScrollView]){
		return;
	}

	//update user defaults if was pinch view
	if ([pageElementScrollView.pageElement isKindOfClass:[PinchView class]]) {
		[[UserPovInProgress sharedInstance] removePinchView:(PinchView*)pageElementScrollView.pageElement];
		self.numPinchViews--;
		if (self.numPinchViews < 1) {
			[self.navBar enablePreviewButton:NO];
		}
	}

	[pageElementScrollView cleanUp];
	[self.pageElementScrollViews removeObject:pageElementScrollView];
	[pageElementScrollView removeFromSuperview];
	[self shiftElementsBelowView: self.coverPicView];

	/* NOT IN USE - register deleted tile for undo
	 NSUInteger index = [self.pageElementScrollViews indexOfObject:scrollView];
 	[self.tileSwipeViewUndoManager registerUndoWithTarget:self selector:@selector(undoTileDelete:) object:@[pageElementScrollView, index]];
	 //show the pullbar so that they can undo
	 [self.delegate showPullBar:YES withTransition:YES];
	 */
}


//Remove keyboard when scrolling
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark - Creating New PinchViews -


// Create a horizontal scrollview displaying a pinch object from a pinchView passed in
- (void) newPinchView:(PinchView *) pinchView belowView:(ContentPageElementScrollView *)upperScrollView {

	if(!pinchView) {
//		NSLog(@"Attempting to add nil pinch view");
		return;
	}

	[[UserPovInProgress sharedInstance] addPinchView:pinchView];
    
	[self addTapGestureToPinchView:pinchView];

	// must be below base media tile selector
	NSInteger index = self.pageElementScrollViews.count-1;

	CGRect newElementScrollViewFrame;
	if(!upperScrollView) {
		newElementScrollViewFrame = CGRectMake(0,self.titleField.frame.origin.y + self.titleField.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
	} else {
		newElementScrollViewFrame = CGRectMake(upperScrollView.frame.origin.x, upperScrollView.frame.origin.y + upperScrollView.frame.size.height, self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
		index = [self.pageElementScrollViews indexOfObject:upperScrollView]+1;
	}
    
	ContentPageElementScrollView *newElementScrollView = [[ContentPageElementScrollView alloc]initWithFrame:newElementScrollViewFrame andElement:pinchView];
	newElementScrollView.delegate = self; //scroll view delegate
	newElementScrollView.contentPageElementScrollViewDelegate = self;

    [self.navBar enablePreviewButton:YES];
	self.numPinchViews++;

	//thread safety
	@synchronized(self) {
		[self.pageElementScrollViews insertObject:newElementScrollView atIndex: index];
	}

    [self.mainScrollView addSubview: newElementScrollView];
    [self shiftElementsBelowView: self.coverPicView];
    
}


#pragma mark - Shift Positions of Elements
//Once view is added- we make sure the views below it are appropriately adjusted
//in position
-(void)shiftElementsBelowView: (UIView *) view {
	if (!view) {
//		NSLog(@"View that elements are being shifted below should not be nil");
		return;
	}
	if(![view isKindOfClass:[ContentPageElementScrollView class]]
	   && ![view isKindOfClass:[CoverPicturePinchView class]]) {
//		NSLog(@"View must be a scroll view or the cover pic view to shift elements below.");
		return;
	}

	NSInteger viewIndex = 0;
	NSInteger firstYCoordinate = view.frame.origin.y + view.frame.size.height;

	//if we are shifting things from somewhere in the middle of the scroll view
	if([self.pageElementScrollViews containsObject:view]) {
		viewIndex = [self.pageElementScrollViews indexOfObject:view]+1;
	}

	//If we must shift everything from the top
	else if ([view isKindOfClass:[CoverPicturePinchView class]]) {
		firstYCoordinate  = firstYCoordinate + ELEMENT_OFFSET_DISTANCE;
	}

	for(NSInteger i = viewIndex; i < [self.pageElementScrollViews count]; i++) {
		ContentPageElementScrollView * currentView = self.pageElementScrollViews[i];

		CGRect frame = CGRectMake(currentView.frame.origin.x, firstYCoordinate,
								  currentView.frame.size.width, currentView.frame.size.height);

		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			currentView.frame = frame;
			//make sure everything is centered
			[currentView centerView];
		}];
		firstYCoordinate+= frame.size.height;
	}

	//make sure the main scroll view can show everything
	[self adjustMainScrollViewContentSize];
}


//Shifts elements above a certain view up by the given difference
-(void) shiftElementsAboveView: (ContentPageElementScrollView *) scrollView withDifference: (NSInteger) difference {
	NSInteger viewIndex = [self.pageElementScrollViews indexOfObject:scrollView];

	if(viewIndex == NSNotFound || viewIndex >= self.pageElementScrollViews.count) {
		return;
	}

	for(NSInteger i = (viewIndex-1); i >= 0; i--) {
		ContentPageElementScrollView * currentView = self.pageElementScrollViews[i];
		CGRect frame = CGRectMake(currentView.frame.origin.x, currentView.frame.origin.y + difference,
								  currentView.frame.size.width, currentView.frame.size.height);

		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			currentView.frame = frame;
		}];
	}

}

//Storing new view to our array of elements
-(void) storeView: (ContentPageElementScrollView*) view inArrayAsBelowView: (UIView*) topView {
	if(!view) {
		NSLog(@"Trying to store nil view");
		return;
	}

	if(![self.pageElementScrollViews containsObject:view]) {
		if(topView && topView != self.titleField) {
			NSInteger index = [self.pageElementScrollViews indexOfObject:topView];
			[self.pageElementScrollViews insertObject:view atIndex:(index+1)];
		}else if(topView == self.titleField) {
			[self.pageElementScrollViews insertObject:view atIndex:0];
		}else {
			[self.pageElementScrollViews addObject:view];
		}
	}
	[self shiftElementsBelowView:topView];
}


#pragma  mark - Handling the KeyBoard -

-(void) orientationChanged {
	//make sure the device is landscape
	if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
		[self removeKeyboardFromScreen];
	} else {
		[self showKeyboard];
	}
}


#pragma Remove Keyboard From Screen
//Iain
-(void) removeKeyboardFromScreen {
	if (self.titleField.isEditing) {
		[self.titleField resignFirstResponder];
	}
}

-(void) showKeyboard {
	if(self.titleField.isEditing) {
		[self.titleField becomeFirstResponder];
	}
}

#pragma mark Keyboard Notifications

//When keyboard appears get its height. This is only neccessary when the keyboard first appears
-(void)keyboardWillShow:(NSNotification *) notification {
	// Get the size of the keyboard.
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	//store the keyboard height for further use
	self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
}

-(void)keyBoardWillChangeFrame: (NSNotification *) notification {
	// Get the size of the keyboard.
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	//store the keyboard height for further use
	self.keyboardHeight = keyboardSize.height;
}


-(void) keyBoardDidShow:(NSNotification *) notification {
}


-(void)keyboardWillDisappear:(NSNotification *) notification {
}

#pragma mark - Pinch Gesture -

#pragma mark  Sensing Pinch

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender {

	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			[self handlePinchGestureBegan:sender];
			break;
		}
		case UIGestureRecognizerStateChanged: {

			if ((self.pinchingMode == PinchingModeVertical ||
                 self.pinchingMode == PinchingModeVertical_Undo)
					   && self.lowerPinchScrollView && self.upperPinchScrollView) {
				[self handleVerticlePinchGestureChanged:sender];
			}
			break;
		}
		case UIGestureRecognizerStateEnded: {
			[self handlePinchingEnded:sender];
			break;
		}
		default: {
			return;
		}
	}
}


//Sanitize objects and values held during pinching. Check if pinches crossed thresholds
// and otherwise rearrange things.
-(void) handlePinchingEnded: (UIPinchGestureRecognizer *)sender {

	self.horizontalPinchDistance = 0;
	self.leftTouchPointInHorizontalPinch = CGPointMake(0, 0);
	self.rightTouchPointInHorizontalPinch = CGPointMake(0, 0);

	if (self.scrollViewOfHorizontalPinching) {
		//collection was not closed
		if (self.scrollViewOfHorizontalPinching.collectionIsOpen) {
			[self.scrollViewOfHorizontalPinching moveOpenCollectionViewsBack];
		}
		self.scrollViewOfHorizontalPinching.scrollEnabled = YES;
		self.scrollViewOfHorizontalPinching = nil;
	} else if (self.newlyCreatedMediaTile) {
		//new media creation has failed
		if(self.newlyCreatedMediaTile.frame.size.height != self.baseMediaTileSelector.frame.size.height){
			[self animateRemoveNewMediaTile];
			return;
		}
		self.newlyCreatedMediaTile = Nil;
	}

	[self shiftElementsBelowView: self.coverPicView];
	self.pinchingMode = PinchingModeNone;
}

-(void) animateRemoveNewMediaTile {
	float originalHeight = self.newlyCreatedMediaTile.frame.size.height;
	[self.pageElementScrollViews removeObject:self.newlyCreatedMediaTile.superview];
	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION/2.f animations:^{
		self.newlyCreatedMediaTile.alpha = 0.f;
		self.newlyCreatedMediaTile.frame = [self getStartFrameForNewMediaTile];
		self.newlyCreatedMediaTile.superview.frame = CGRectMake(0,self.newlyCreatedMediaTile.superview.frame.origin.y + originalHeight/2.f,
																self.newlyCreatedMediaTile.superview.frame.size.width, 0);
		[self.newlyCreatedMediaTile createFramesForButtonWithFrame: self.newlyCreatedMediaTile.frame];
		[self shiftElementsBelowView: self.coverPicView];

	} completion:^(BOOL finished) {
		[self.newlyCreatedMediaTile.superview removeFromSuperview];
		self.newlyCreatedMediaTile = nil;
		self.pinchingMode = PinchingModeNone;
	}];
}

-(void) handlePinchGestureBegan: (UIPinchGestureRecognizer *)sender {
    self.pinchingMode = PinchingModeVertical;
    [self handleVerticlePinchGestureBegan:sender];
}


#pragma mark - Horizontal Pinching

//The gesture is horizontal. Get the scrollView for the list of pinch views open
-(void)handleHorizontalPinchGestureBegan: (UIPinchGestureRecognizer *)sender {

	// Cannot pinch a horizontal view apart
	if(sender.scale > 1) return;

	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
	CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];
	// touch1 is left most pinch
	if(touch1.x > touch2.x) {
		CGPoint temp = touch1;
		touch1 = touch2;
		touch2 = temp;
	}
	CGPoint midpoint = [self findMidPointBetween:touch1 and:touch2];

	self.scrollViewOfHorizontalPinching = [self findElementScrollViewFromPoint:midpoint];
	if(self.scrollViewOfHorizontalPinching) {
		self.leftTouchPointInHorizontalPinch = touch1;
		self.rightTouchPointInHorizontalPinch = touch2;
		self.scrollViewOfHorizontalPinching.scrollEnabled = NO;
		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			self.scrollViewOfHorizontalPinching.contentOffset = CGPointMake(self.scrollViewOfHorizontalPinching.contentSize.width/2
																			- self.scrollViewOfHorizontalPinching.frame.size.width/2,
																			self.scrollViewOfHorizontalPinching.contentOffset.y);
		} completion:^(BOOL finished) {
		}];
	} else {
		self.pinchingMode = PinchingModeNone;
	}
}

//pinching collection objects together
-(void)handleHorizontalPinchGestureChanged:(UIGestureRecognizer *) sender {
	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
	CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];

	// touch1 is left most pinch
	if(touch1.x > touch2.x) {
		CGPoint temp = touch1;
		touch1 = touch2;
		touch2 = temp;
	}

	float leftDifference = touch1.x- self.leftTouchPointInHorizontalPinch.x;
	float rightDifference = touch2.x - self.rightTouchPointInHorizontalPinch.x;
	self.rightTouchPointInHorizontalPinch = touch2;
	self.leftTouchPointInHorizontalPinch = touch1;
	self.horizontalPinchDistance += (leftDifference - rightDifference);

	[self.scrollViewOfHorizontalPinching moveViewsWithTotalDifference:self.horizontalPinchDistance];

	//they have pinched enough to join the objects
	if(self.horizontalPinchDistance >= HORIZONTAL_PINCH_THRESHOLD) {
		[self closeOpenCollectionInScrollView: self.scrollViewOfHorizontalPinching];
		self.pinchingMode = PinchingModeNone;
	}
}

//goes through all scroll views and checks if they have open collections.
//if they do it tells them to close
-(void) closeAllOpenCollections {
	for (ContentPageElementScrollView* scrollView in self.pageElementScrollViews) {
		if(scrollView.collectionIsOpen) {
			[scrollView closeCollection];
		}
	}
}

//checks if scroll view contains an open collection,
//if so shows the pull bar and tells the scroll view to close the collection
-(void)closeOpenCollectionInScrollView:(ContentPageElementScrollView*)openCollectionScrollView {

	if(!openCollectionScrollView.collectionIsOpen) {
		return;
	}
	//make sure the pullbar is showing when things are pinched together
	[self.delegate showPullBar:YES withTransition:YES];
	[openCollectionScrollView closeCollection];
}

#pragma mark - Vertical Pinching

//If it's a verticle pinch- find which media you're pinching together or apart
-(void) handleVerticlePinchGestureBegan: (UIPinchGestureRecognizer *)sender {
	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
	CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];

	if(touch1.y>touch2.y) {
		self.upperTouchPointInVerticalPinch = touch2;
		self.lowerTouchPointInVerticalPinch = touch1;
	}else {
		self.lowerTouchPointInVerticalPinch = touch2;
		self.upperTouchPointInVerticalPinch = touch1;
	}
	
    [self findElementsFromPinchPoint];

	//if it's a pinch apart then create the media tile
	 if(self.upperPinchScrollView && self.lowerPinchScrollView && self.pinchingMode == PinchingModeVertical &&sender.scale > 1) {
		[self createNewMediaTileBetweenPinchViews];
	 }

}

-(void) handleVerticlePinchGestureChanged: (UIPinchGestureRecognizer *)gesture {

    if([gesture numberOfTouches] != 2) return;
    
    CGPoint upperTouch = [gesture locationOfTouch:0 inView:self.mainScrollView];
	CGPoint lowerTouch = [gesture locationOfTouch:1 inView:self.mainScrollView];

	//touch1 is upper touch
	if (lowerTouch.y < upperTouch.y) {
		CGPoint temp = upperTouch;
		upperTouch = lowerTouch;
		lowerTouch = temp;
	}

	float changeInTopViewPosition = [self handleUpperViewFromTouch:upperTouch];
	float changeInBottomViewPosition = [self handleLowerViewFromTouch:lowerTouch];

	//objects are being pinched apart
	if(gesture.scale > 1) {
        if(self.pinchingMode == PinchingModeVertical_Undo){
            
        }else{
            [self handleRevealOfNewMediaViewWithGesture:gesture andChangeInTopViewPosition:changeInTopViewPosition
					  andChangeInBottomViewPosition:changeInBottomViewPosition];
        }
	}
	//objects are being pinched together
	else {
		[self pinchObjectsTogether];
	}
}


//handle the translation of the upper view
//returns change in position of upper view
-(float) handleUpperViewFromTouch: (CGPoint) touch {
	float changeInPosition;
	changeInPosition = touch.y - self.upperTouchPointInVerticalPinch.y;
	self.upperTouchPointInVerticalPinch = touch;
	self.upperPinchScrollView.frame = [self newVerticalTranslationFrameForView:self.upperPinchScrollView andChange:changeInPosition];
	[self shiftElementsAboveView:(ContentPageElementScrollView*)self.upperPinchScrollView withDifference:changeInPosition];
	return changeInPosition;
}

//handle the translation of the lower view
//returns change in position of lower view
-(float) handleLowerViewFromTouch: (CGPoint) touch {
	float changeInPosition;
	changeInPosition = touch.y - self.lowerTouchPointInVerticalPinch.y;
	self.lowerTouchPointInVerticalPinch = touch;
	self.lowerPinchScrollView.frame = [self newVerticalTranslationFrameForView:self.lowerPinchScrollView andChange:changeInPosition];
	[self shiftElementsBelowView:self.lowerPinchScrollView];
	return changeInPosition;
}


//Takes a change in vertical position and constructs the frame for the views new position
-(CGRect) newVerticalTranslationFrameForView: (UIView*)view andChange: (float) changeInPosition {
	CGRect frame= CGRectMake(view.frame.origin.x, view.frame.origin.y+changeInPosition, view.frame.size.width, view.frame.size.height);
	return frame;
}


#pragma mark Pinching Apart two Pinch views, Adding media tile

-(void) createNewMediaTileBetweenPinchViews {
	CGRect frame = [self getStartFrameForNewMediaTile];
	MediaSelectTile * newMediaTile = [[MediaSelectTile alloc]initWithFrame:frame];
	newMediaTile.delegate = self;
	newMediaTile.alpha = 0; //start it off as invisible
	newMediaTile.isBaseSelector = NO;
	[self addMediaTile: newMediaTile underView: self.upperPinchScrollView];
	self.newlyCreatedMediaTile = newMediaTile;
}

-(void) addMediaTile: (MediaSelectTile *) mediaTile underView: (ContentPageElementScrollView *) topView {
	if(!mediaTile) {
//		NSLog(@"Can't add Nil media tile");
		return;
	}
    
	CGRect newMediaTileScrollViewFrame = [self getStartFrameForNewMediaTileScrollViewUnderView:topView];
	ContentPageElementScrollView * newMediaTileScrollView = [[ContentPageElementScrollView alloc]initWithFrame:newMediaTileScrollViewFrame andElement:mediaTile];
	newMediaTileScrollView.delegate = self; // scroll view delegate
	newMediaTileScrollView.contentPageElementScrollViewDelegate = self;
	[self.mainScrollView addSubview:newMediaTileScrollView];
	[self storeView:newMediaTileScrollView inArrayAsBelowView:topView];
}
-(CGRect) getStartFrameForNewMediaTile {
	return CGRectMake(self.baseMediaTileSelector.frame.origin.x + (self.baseMediaTileSelector.frame.size.width/2),0, 0, 0);
}
-(CGRect) getStartFrameForNewMediaTileScrollViewUnderView: (ContentPageElementScrollView *) topView  {
	return CGRectMake(topView.frame.origin.x, topView.frame.origin.y +topView.frame.size.height, self.view.frame.size.width,0);
}

//media tile grows from the center as the gesture expands
-(void) handleRevealOfNewMediaViewWithGesture: (UIPinchGestureRecognizer *)gesture andChangeInTopViewPosition:(float)changeInTopViewPosition andChangeInBottomViewPosition:(float) changeInBottomViewPosition {

	float totalChange = fabs(changeInTopViewPosition) + fabs(changeInBottomViewPosition);
	float widthToHeightRatio = self.baseMediaTileSelector.frame.size.width/self.baseMediaTileSelector.frame.size.height;
	float changeInWidth = widthToHeightRatio * totalChange;
	float mediaTileChangeInHeight = totalChange* (self.baseMediaTileSelector.frame.size.height
												  /self.baseMediaTileSelector.superview.frame.size.height);
	//media tile top is in relation to its superview and should change based on its height
	float mediaTileChangeInTop = mediaTileChangeInHeight * (self.baseMediaTileSelector.frame.origin.y
															/self.baseMediaTileSelector.frame.size.height);
	if(self.newlyCreatedMediaTile.superview.frame.size.height < PINCH_DISTANCE_THRESHOLD_FOR_NEW_MEDIA_TILE_CREATION) {
		//construct new frames for view and personal scroll view
		self.newlyCreatedMediaTile.frame = CGRectMake(self.newlyCreatedMediaTile.frame.origin.x - changeInWidth/2.f,
													  self.newlyCreatedMediaTile.frame.origin.y + mediaTileChangeInTop,
													  self.newlyCreatedMediaTile.frame.size.width + changeInWidth,
													  self.newlyCreatedMediaTile.frame.size.height + mediaTileChangeInHeight);
		//have it gain visibility as it grows
		self.newlyCreatedMediaTile.alpha = self.newlyCreatedMediaTile.frame.size.height/self.baseMediaTileSelector.frame.size.height;
		self.newlyCreatedMediaTile.superview.frame = CGRectMake(self.newlyCreatedMediaTile.superview.frame.origin.x,
																self.newlyCreatedMediaTile.superview.frame.origin.y + changeInTopViewPosition,
																self.newlyCreatedMediaTile.superview.frame.size.width,
																self.newlyCreatedMediaTile.superview.frame.size.height + totalChange);
		[self.newlyCreatedMediaTile createFramesForButtonWithFrame: self.newlyCreatedMediaTile.frame];
		[self.newlyCreatedMediaTile setNeedsDisplay];
	}
	//the distance is enough that we can just animate the rest
	else {
		[self animateNewMediaTileToFinalPosition:gesture andChangeInTopViewPosition:changeInTopViewPosition];
	}
}

-(void) animateNewMediaTileToFinalPosition:(UIPinchGestureRecognizer *)gesture andChangeInTopViewPosition:(float)changeInTopViewPosition {
	gesture.enabled = NO;
	gesture.enabled = YES;
	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{
		self.newlyCreatedMediaTile.frame = self.baseMediaTileSelector.frame;
		self.newlyCreatedMediaTile.alpha = 1; //make it fully visible
		self.newlyCreatedMediaTile.superview.frame = CGRectMake(self.newlyCreatedMediaTile.superview.frame.origin.x,
																self.newlyCreatedMediaTile.superview.frame.origin.y + changeInTopViewPosition,
																self.baseMediaTileSelector.superview.frame.size.width,
																self.baseMediaTileSelector.superview.frame.size.height);
		[self.newlyCreatedMediaTile createFramesForButtonWithFrame: self.newlyCreatedMediaTile.frame];
		[self shiftElementsBelowView: self.coverPicView];
	} completion:^(BOOL finished) {
		[self shiftElementsBelowView: self.coverPicView];
		gesture.enabled = NO;
		gesture.enabled = YES;
		self.pinchingMode = PinchingModeNone;
		[self.newlyCreatedMediaTile createFramesForButtonWithFrame: self.newlyCreatedMediaTile.frame];
		[self.newlyCreatedMediaTile formatButton];
	}];
}
#pragma mark Pinch Apart Failed
//Removes the new view being made and resets page
-(void) clearMediaTile:(MediaSelectTile*)mediaTile {
	[mediaTile.superview removeFromSuperview];
	[self.pageElementScrollViews removeObject:mediaTile.superview];
	[self shiftElementsBelowView: self.coverPicView];
}


#pragma mark Pinching Views together

-(void) pinchObjectsTogether {
	if(!self.upperPinchScrollView || !self.lowerPinchScrollView
	   || ![self sufficientOverlapBetweenPinchedObjects]
	   || ![self.upperPinchScrollView okToPinchWith:self.lowerPinchScrollView]) {
		return;
	}
	self.numPinchViews--;
	PinchView* pinched = [self.upperPinchScrollView pinchWith:self.lowerPinchScrollView];
	[self addTapGestureToPinchView:pinched];
	[self.pageElementScrollViews removeObject:self.lowerPinchScrollView];
	self.lowerPinchScrollView = self.upperPinchScrollView = nil;
	self.pinchingMode = PinchingModeNone;
	[self shiftElementsBelowView: self.coverPicView];
    
	//make sure the pullbar is showing when things are pinched together
	[self.delegate showPullBar:YES withTransition:YES];
    //present swipe to delete notification
    if(![[UserSetupParameters sharedInstance] swipeToDelete_InstructionShown])[self alertSwipeRightToDelete];
}

#pragma mark - Identify views involved in pinch

-(CGPoint) findMidPointBetween: (CGPoint) touch1 and: (CGPoint) touch2 {
	CGPoint midPoint = CGPointZero;
	midPoint.x = (touch1.x + touch2.x)/2;
	midPoint.y = (touch1.y + touch2.y)/2;
	return midPoint;
}

-(ContentPageElementScrollView *)findElementScrollViewFromPoint: (CGPoint) point {

	NSInteger distanceTraveled = 0;
	ContentPageElementScrollView *wantedView;

	//Runs through the view positions to find the first one that passes the touch point
	for (ContentPageElementScrollView * scrollView in self.pageElementScrollViews) {
		if(!distanceTraveled) distanceTraveled = scrollView.frame.origin.y;
		distanceTraveled += scrollView.frame.size.height;
		if(distanceTraveled > point.y) {
			wantedView = scrollView;
			break;
		}
	}
	//Cannot pinch a single pinch view open or close
	if(!wantedView.collectionIsOpen) {
		return nil;
	}
	return wantedView;
}

//Takes a midpoint and a lower touch point and finds the two views that were being interacted with
-(void) findElementsFromPinchPoint {

	self.upperPinchScrollView = [self findPinchViewScrollViewFromUpperPinchPoint:self.upperTouchPointInVerticalPinch andLowerPinchPoint:self.lowerTouchPointInVerticalPinch];
    
	if(!self.upperPinchScrollView) {
		return;
	}
	if([self.upperPinchScrollView.pageElement isKindOfClass:[MediaSelectTile class]]) {
		self.upperPinchScrollView = nil;
		return;
	}

	NSInteger index = [self.pageElementScrollViews indexOfObject:self.upperPinchScrollView];

	if(self.pageElementScrollViews.count > (index+1) && index != NSNotFound && self.pinchingMode != PinchingModeVertical_Undo) {
		self.lowerPinchScrollView = self.pageElementScrollViews[index+1];
    }else if (self.pinchingMode == PinchingModeVertical_Undo){
        //make sure that we're pinching apart a colleciton
        if(![self.upperPinchScrollView.pageElement isKindOfClass:[CollectionPinchView class]]){
            return;
        }
        self.lowerPinchScrollView = [self createPinchApartViews];
    }

	if([self.lowerPinchScrollView.pageElement isKindOfClass:[MediaSelectTile class]]) {
		self.lowerPinchScrollView = nil;
		return;
	}
}



-(ContentPageElementScrollView *)createPinchApartViews {
    
   CollectionPinchView * collectionPv = (CollectionPinchView *)self.upperPinchScrollView.pageElement;
    PinchView * toRemove = [collectionPv.pinchedObjects lastObject];
    CollectionPinchView * pv = [collectionPv unPinchAndRemove:toRemove];
    
    if(pv.pinchedObjects.count == 1){
        PinchView * newpv =  [collectionPv.pinchedObjects lastObject];
        [pv unPinchAndRemove:pv];
        [self.upperPinchScrollView changePageElement:newpv];
    }else{
        [self.upperPinchScrollView changePageElement:pv];
    }
    
    //[[UserPovInProgress sharedInstance] addPinchView:pinchView];
    [self addTapGestureToPinchView:toRemove];
    NSInteger index = [self.pageElementScrollViews indexOfObject:self.upperPinchScrollView] + 1;
    
    CGRect newElementScrollViewFrame= self.upperPinchScrollView.frame;
    ContentPageElementScrollView *newElementScrollView = [[ContentPageElementScrollView alloc]initWithFrame:newElementScrollViewFrame andElement:toRemove];
    newElementScrollView.delegate = self; //scroll view delegate
    newElementScrollView.contentPageElementScrollViewDelegate = self;
    
    [self.navBar enablePreviewButton:YES];
    self.numPinchViews++;
    
    //thread safety
    @synchronized(self) {
        [self.pageElementScrollViews insertObject:newElementScrollView atIndex: index];
    }
    
    [self.mainScrollView addSubview: newElementScrollView];
    //[self shiftElementsBelowView: self.coverPicView];
    
    return newElementScrollView;
}


//Runs through and identifies the pinch view scrollview at that point
-(ContentPageElementScrollView *) findPinchViewScrollViewFromUpperPinchPoint: (CGPoint) upperPinchPoint
                                                          andLowerPinchPoint:(CGPoint) lowerPinchPoint{
	NSInteger distanceTraveled = 0;
	ContentPageElementScrollView * wantedView;
	//Runs through the view positions to find the first one that passes the midpoint- we assume the midpoint is
	for (ContentPageElementScrollView* scrollView in self.pageElementScrollViews) {
		if(distanceTraveled == 0) distanceTraveled = scrollView.frame.origin.y;
		distanceTraveled += scrollView.frame.size.height;
		if(distanceTraveled > upperPinchPoint.y && [scrollView.pageElement isKindOfClass:[PinchView class]]) {
            wantedView = scrollView;
            
            if([self bothPointsInView:wantedView andLowerPoint:lowerPinchPoint]){
                self.pinchingMode = PinchingModeVertical_Undo;
            }
			break;
		}
	}
	return wantedView;
}


-(BOOL) bothPointsInView: (UIView *) view andLowerPoint: (CGPoint) lowerPoint {
    if(lowerPoint.y < (view.frame.origin.y + (self.defaultPinchViewRadius*2))){
        return true;
    }
    return NO;
}


-(BOOL)sufficientOverlapBetweenPinchedObjects {
	if(self.upperPinchScrollView.frame.origin.y+(self.upperPinchScrollView.frame.size.height/2)>= self.lowerPinchScrollView.frame.origin.y){
		return true;
	}
	return false;
}

#pragma mark - Media Tile Delegate -

-(void) addMediaButtonPressedOnTile: (MediaSelectTile *)tile  {
	NSInteger index = [self.pageElementScrollViews indexOfObject: tile.superview] - 1;
	self.addMediaBelowView = index >= 0 ? self.pageElementScrollViews[index] : nil;
	[self presentEfficientGallery];
	if (!tile.isBaseSelector) {
		[self clearMediaTile:tile];
	}
}


#pragma mark - Change position of elements on screen by dragging

// Handle users moving elements around on the screen using long press
- (IBAction)longPressSensed:(UILongPressGestureRecognizer *)sender {

	switch (sender.state) {
		case UIGestureRecognizerStateEnded: {
			[self finishMovingSelectedItem];
			break;
		}
		case UIGestureRecognizerStateBegan: {
			//make sure it's a single finger touch and that there are multiple elements on the screen
			if(self.pageElementScrollViews.count < 1) {
				return;
			}
			[self selectItem:sender];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			[self moveItem:sender];
			break;
		}
		default: {
			return;
		}
	}
}

-(void) selectItem:(UILongPressGestureRecognizer *)sender {
	CGPoint touch = [sender locationOfTouch:0 inView:self.mainScrollView];
	[self findSelectedViewFromTouch:touch];

	//if we didn't find the view then leave
	if (!self.selectedView_PAN) {
		return;
	} else if (self.selectedView_PAN.collectionIsOpen) {
		[self.selectedView_PAN selectItemInOpenCollectionFromTouch:touch];
		if (!self.selectedView_PAN.selectedItem) {
			self.selectedView_PAN = nil;
		}
		return;
	}

	self.previousLocationOfTouchPoint_PAN = touch;
	self.previousFrameInLongPress = self.selectedView_PAN.frame;

	[self.selectedView_PAN.pageElement markAsSelected:YES];
}

// Finds first view that contains location of press and sets it as the selectedView
-(void) findSelectedViewFromTouch:(CGPoint) touch {
	self.selectedView_PAN = nil;

	//make sure touch is not above the first view
	ContentPageElementScrollView * firstView = self.pageElementScrollViews[0];
	if(touch.y < firstView.frame.origin.y) {
		return;
	}

	for (int i=0; i < self.pageElementScrollViews.count; i++) {
		ContentPageElementScrollView * view = self.pageElementScrollViews[i];

		//we stop when we find the first one
		if((view.frame.origin.y + view.frame.size.height) > touch.y) {
			self.selectedView_PAN = self.pageElementScrollViews[i];

			//can't select the base tile selector
			 if (self.selectedView_PAN.pageElement == self.baseMediaTileSelector) {
				self.selectedView_PAN = nil;
				return;
			 }
			[self.mainScrollView bringSubviewToFront:self.selectedView_PAN];
			return;
		}
	}
}

//Moves the frame of the object to the new location
//Then checks if it has moved far enough to be swapped with the object above or below it
-(void) moveItem:(UILongPressGestureRecognizer *)sender {

	CGPoint touch = [sender locationOfTouch:0 inView:self.mainScrollView];

	//if there is no selected item don't do anything
	if (!self.selectedView_PAN) {
		return;
	}
    //checks if this is a selection from an open collections
	if (self.selectedView_PAN.collectionIsOpen) {
		PinchView* unPinched = [self.selectedView_PAN moveSelectedItemFromTouch:touch];
		if (unPinched) {
			[self addUnpinchedItem:unPinched];
			self.previousLocationOfTouchPoint_PAN = touch;
			self.previousFrameInLongPress = self.selectedView_PAN.frame;
			[self.selectedView_PAN.pageElement markAsSelected:YES];
		}
		return;
	}
    
    //find the index of the currently selected scrollview
	NSInteger viewIndex = [self.pageElementScrollViews indexOfObject:self.selectedView_PAN];
	ContentPageElementScrollView* topView = nil;
	ContentPageElementScrollView* bottomView = nil;
    
    //find the view above it
	if(viewIndex !=0) {
		topView  = self.pageElementScrollViews[viewIndex-1];
	}
    //find the view below it
	if (viewIndex+1 < [self.pageElementScrollViews count]) {
		bottomView = self.pageElementScrollViews[viewIndex+1];
	}
    
    //move the selected view up or down by the drag distance of the finger
	NSInteger yDifference  = touch.y - self.previousLocationOfTouchPoint_PAN.y;
	CGRect newFrame = [self newVerticalTranslationFrameForView:self.selectedView_PAN andChange:yDifference];

	// view can't move below bottom media tile
	 if(bottomView && bottomView.pageElement == self.baseMediaTileSelector
	 &&  ((newFrame.origin.y + newFrame.size.height) >= bottomView.frame.origin.y)) {
		return;
	 }

	//move item
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2.f animations:^{
		self.selectedView_PAN.frame = newFrame;
       
	}completion:^(BOOL finished) {
        //is the pinchview above the cover photo?
        if (!topView){
            if([self selctedViewAboveCoverPhoto]){
                if([self.selectedView_PAN.pageElement isKindOfClass:[ImagePinchView class]]){
                    [((ImagePinchView *)self.selectedView_PAN.pageElement) changeWidthTo:
                     COVER_PIC_RADIUS*2];
                }
            }else{
                if([self.selectedView_PAN.pageElement isKindOfClass:[ImagePinchView class]]){
                    
                    [((ImagePinchView *)self.selectedView_PAN.pageElement) changeWidthTo:
                     self.defaultPinchViewRadius*2];
                }
                
            }
        }
    }];

	//swap item if necessary

	//check if object has moved up the halfway mark of the view above it, if so swap them
	if(topView && (newFrame.origin.y + newFrame.size.height/2.f)
	   < (topView.frame.origin.y + topView.frame.size.height)) {
		[self swapWithTopView: topView];
    }
    //check if object has moved down the halfway mark of the view below it, if so swap them
    else if(bottomView && (newFrame.origin.y + newFrame.size.height/2.f) +CENTERING_OFFSET_FOR_TEXT_VIEW
			> bottomView.frame.origin.y) {
		[self swapWithBottomView: bottomView];
	}

	//move the offest of the main scroll view
	[self moveOffsetOfMainScrollViewBasedOnSelectedItem];
	self.previousLocationOfTouchPoint_PAN = touch;
}

-(BOOL)selctedViewAboveCoverPhoto {
	if(self.selectedView_PAN.frame.origin.y >
	   self.titleField.frame.origin.y + self.titleField.frame.size.height &&
	   self.selectedView_PAN.frame.origin.y < self.coverPicView.frame.origin.y +
	   self.coverPicView.frame.size.height * (2.f/4.f)) {
		return true;
	}
	return NO;
}

//swap currently selected item's frame with view above it
-(void) swapWithTopView: (ContentPageElementScrollView*) topView {

	[self swapScrollView:self.selectedView_PAN andScrollView: topView];

	//important that objects may not be the same height
	float heightDiff = self.previousFrameInLongPress.size.height - topView.frame.size.height;
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{

		CGRect potentialFrame = CGRectMake(topView.frame.origin.x, topView.frame.origin.y,
										   self.previousFrameInLongPress.size.width,
										   self.previousFrameInLongPress.size.height);

		topView.frame = CGRectMake(self.previousFrameInLongPress.origin.x,
								   self.previousFrameInLongPress.origin.y + heightDiff,
								   topView.frame.size.width, topView.frame.size.height);
		self.previousFrameInLongPress = potentialFrame;
	}];
}

//swap currently selected item's frame with view below it
-(void) swapWithBottomView: (ContentPageElementScrollView*) bottomView {

	[self swapScrollView: self.selectedView_PAN andScrollView: bottomView];
	//important that objects may not be the same height
	float heightDiff = bottomView.frame.size.height - self.previousFrameInLongPress.size.height;
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{

		CGRect potentialFrame = CGRectMake(bottomView.frame.origin.x,
										   bottomView.frame.origin.y + heightDiff,
										   self.previousFrameInLongPress.size.width,
										   self.previousFrameInLongPress.size.height);

		bottomView.frame = CGRectMake(self.previousFrameInLongPress.origin.x,
									  self.previousFrameInLongPress.origin.y,
									  bottomView.frame.size.width, bottomView.frame.size.height);
		self.previousFrameInLongPress = potentialFrame;
	}];
}

//adjusts offset of main scroll view so selected item is in focus
-(void) moveOffsetOfMainScrollViewBasedOnSelectedItem {
	float newYOffset = 0;
	if (self.mainScrollView.contentOffset.y > self.selectedView_PAN.frame.origin.y - (self.selectedView_PAN.frame.size.height/2.f) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0)) {

		newYOffset = -AUTO_SCROLL_OFFSET;
	} else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_PAN.frame.origin.y + self.selectedView_PAN.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height) {

		newYOffset = AUTO_SCROLL_OFFSET;
	}

	if (newYOffset != 0) {
		CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + newYOffset);
		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			self.mainScrollView.contentOffset = newOffset;
		}];
	}
}

//takes a PinchView that has recently been unpinched and resets its frame
//then adds it to a scroll view either above or below where it was unpinched from
-(void) addUnpinchedItem:(PinchView*)unPinched {
	UIView* upperView;
	NSInteger upperViewIndex = 0;
	if (unPinched.frame.origin.y > self.selectedView_PAN.frame.origin.y) {
		upperView = self.selectedView_PAN;
		upperViewIndex = [self.pageElementScrollViews indexOfObject:self.selectedView_PAN];
	} else {
		upperViewIndex = [self.pageElementScrollViews indexOfObject:self.selectedView_PAN]-1;
		if (upperViewIndex >= 0) {
			upperView = self.pageElementScrollViews[upperViewIndex];
		} else {
			upperView = nil;
		}
	}
	[unPinched revertToInitialFrame];
	[unPinched removeFromSuperview];
	[self newPinchView:unPinched belowView:upperView];
	self.selectedView_PAN = self.pageElementScrollViews[upperViewIndex+1];
}

// If the selected item was a pinch view, deselect it and set its final position in relation to other views
-(void) finishMovingSelectedItem {

	//if we didn't find the view then leave
	if (!self.selectedView_PAN) return;
	if (self.selectedView_PAN.collectionIsOpen) {
		[self.selectedView_PAN finishMovingSelectedItem];
		return;
	}
    
    //make sure the pinch view is in the right position to replace the cover photo
    if([self selctedViewAboveCoverPhoto]){
        //make sure the pinchview is an image
        if([self.selectedView_PAN.pageElement isKindOfClass:[ImagePinchView class]]){
			UIImage* newCoverPhoto = [((ImagePinchView *)self.selectedView_PAN.pageElement) getOriginalImage];
            [self setCoverPictureImage: newCoverPhoto];
            //now delete the selected pinchview
            [self deleteScrollView:self.selectedView_PAN];
        }
        
    }else{
        self.selectedView_PAN.frame = self.previousFrameInLongPress;
    }
	
    if(self.selectedView_PAN)[self.selectedView_PAN.pageElement markAsSelected:NO];
	//sanitize for next run
	self.selectedView_PAN = nil;
	[self shiftElementsBelowView:self.coverPicView];
}

//swaps scroll views in the pageElementScrollView array
-(void) swapScrollView: (ContentPageElementScrollView *) scrollView1 andScrollView: (ContentPageElementScrollView *) scrollView2 {
	NSInteger index1 = [self.pageElementScrollViews indexOfObject: scrollView1];
	NSInteger index2 = [self.pageElementScrollViews indexOfObject: scrollView2];
	[self.pageElementScrollViews replaceObjectAtIndex: index1 withObject: scrollView2];
	[self.pageElementScrollViews replaceObjectAtIndex: index2 withObject: scrollView1];
	if ([scrollView1.pageElement isKindOfClass:[PinchView class]] && [scrollView2.pageElement isKindOfClass:[PinchView class]]) {
		[[UserPovInProgress sharedInstance] swapPinchView:(PinchView*)scrollView1.pageElement andPinchView:(PinchView*)scrollView2.pageElement];
	}
}


#pragma mark- MIC

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	//return supported orientation masks
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- memory handling & stopping all videos -

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	//tune out of nsnotification
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Undo tile swipe

-(void) undoTileDelete: (NSArray *) pageElementScrollViewAndIndex {

	ContentPageElementScrollView * pageElementScrollView = pageElementScrollViewAndIndex[0];
	NSNumber * index = pageElementScrollViewAndIndex[1];

	//update user defaults if was pinch view
	if ([pageElementScrollView.pageElement isKindOfClass:[PinchView class]]) {
		[[UserPovInProgress sharedInstance] addPinchView:(PinchView*)pageElementScrollView.pageElement];
		if (self.numPinchViews < 1) {
			[self.navBar enablePreviewButton:YES];
		}
		self.numPinchViews++;
	}

	[pageElementScrollView.pageElement markAsDeleting:NO];

	[self returnPageElementScrollView:pageElementScrollView toDisplayAtIndex:index.integerValue];
}

-(void) returnPageElementScrollView: (ContentPageElementScrollView *) scrollView toDisplayAtIndex:(NSInteger) index {

	if(index) {
		ContentPageElementScrollView * upperScrollView = self.pageElementScrollViews[(index -1)];
		scrollView.frame = CGRectMake(upperScrollView.frame.origin.x, upperScrollView.frame.origin.y + upperScrollView.frame.size.height,
									  upperScrollView.frame.size.width, upperScrollView.frame.size.height);

	} else {
		scrollView.frame = CGRectMake(0,self.titleField.frame.origin.y + self.titleField.frame.size.height, self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
	}

	[self.pageElementScrollViews insertObject:scrollView atIndex:index];
	[scrollView animateBackToInitialPosition];
	if ([scrollView.pageElement isKindOfClass:[PinchView class]]) {
		[self addTapGestureToPinchView:(PinchView *)[scrollView pageElement]];
	}
	[self.mainScrollView addSubview:scrollView];
	[self shiftElementsBelowView: self.coverPicView];
}


#pragma mark - Sense Tap Gesture -


-(void)addTapGestureToPinchView: (PinchView *) pinchView {
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectTapped:)];
	[pinchView addGestureRecognizer:tap];
	if ([pinchView isKindOfClass:[CollectionPinchView class]]) {
		for (PinchView* childPinchView in [(CollectionPinchView*)pinchView pinchedObjects]) {
			[self addTapGestureToPinchView:childPinchView];
		}
	}
}

-(void) pinchObjectTapped:(UITapGestureRecognizer *) sender {
	//only accept touches from pinch objects
	if(![sender.view isKindOfClass:[PinchView class]]) {
		return;
	}
    
	PinchView * pinchView = (PinchView *)sender.view;
	if([pinchView isKindOfClass:[CollectionPinchView class]]) {
		ContentPageElementScrollView * scrollView = (ContentPageElementScrollView *)pinchView.superview;
		[scrollView openCollection];
        if(![[UserSetupParameters sharedInstance] tapNhold_InstructionShown])[self alertTapNHoldInCollection];
	}else{
		self.openPinchView = pinchView;
		//tap to open an element for viewing or editing
		[self presentEditContentView];
	}
}


#pragma mark - Edit Content View Navigation -

// This should never be called on a collection pinch view - only on image or video
// modally presents the edit content view
-(void) presentEditContentView {
	[self performSegueWithIdentifier:BRING_UP_EDITCONTENT_SEGUE sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:BRING_UP_EDITCONTENT_SEGUE]) {
		EditContentVC *editContentVC =  (EditContentVC *)segue.destinationViewController;
		editContentVC.openPinchView = self.openPinchView;
	}
}

- (IBAction) unwindToContentDevVC: (UIStoryboardSegue *)segue{
	if([segue.identifier isEqualToString:UNWIND_SEGUE_EDIT_CONTENT_VIEW]) {
		self.pinchViewTappedAndClosedForTheFirstTime = YES;
	}
}

#pragma mark - Clean up Content Page -

//we clean up the content page if we press publish or simply want to reset everything
//all the text views are cleared and all the pinch objects are cleared
//all videos in pinch views are stopped
-(void)cleanUp {
	for (ContentPageElementScrollView* scrollView in self.pageElementScrollViews) {
		[scrollView removeFromSuperview];
	}
	[self.pageElementScrollViews removeAllObjects];
	[self.navBar enablePreviewButton:NO];
	[self.mainScrollView setContentOffset:CGPointMake(0, 0)];
	[self adjustMainScrollViewContentSize];
	[self clearTextFields];
    [self clearCoverPhoto];
    [self clearBaseSelcetor];
	[self createBaseSelector];
    [self initializeVariables];
    [[UserPovInProgress sharedInstance] clearPOVInProgress];//now that you have published then we should get rid of all cashed info
}

-(void)clearBaseSelcetor{
    [self.baseMediaTileSelector removeFromSuperview];
    self.baseMediaTileSelector = nil;
}

-(void) clearCoverPhoto {
    [self.coverPicView removeImage];
	[self.coverPicView addGestureRecognizer: self.addCoverPictureTapGesture];
    [self.replaceCoverPhotoButton removeFromSuperview];
    self.replaceCoverPhotoButton = nil;
}

-(void)clearTextFields {
	self.titleField.text =@"";
}


#pragma mark - Gallery + Image picker -

-(void) addImageToStream: (UIImage*) image {
	image = [image scaleImageToSize:[image getSizeForImageWithBounds:self.view.bounds]];
	[self createPinchViewFromImage: image];
}

/*
 Given a PHAsset representing a video and we create a pinch view out of it
 */
-(void) addMediaAssetToStream:(PHAsset *) asset {
	[[PHImageManager defaultManager] requestAVAssetForVideo:asset
													options:self.videoRequestOptions
											  resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [self createPinchViewFromVideoAsset:(AVURLAsset*)videoAsset
																		andPHAssetLocalID: asset.localIdentifier];
												  });
											  }];
}

-(void) presentEfficientGallery {
	GMImagePickerController *picker = [[GMImagePickerController alloc] init];
	picker.delegate = self;
	//Display or not the selection info Toolbar:
	picker.displaySelectionInfoToolbar = YES;

	//Display or not the number of assets in each album:
	picker.displayAlbumsNumberOfAssets = YES;

	//Customize the picker title and prompt (helper message over the title)
	picker.title = GALLERY_PICKER_TITLE;
	picker.customNavigationBarPrompt = GALLERY_CUSTOM_MESSAGE;

	//Customize the number of cols depending on orientation and the inter-item spacing
	picker.colsInPortrait = 3;
	picker.colsInLandscape = 5;
	picker.minimumInteritemSpacing = 2.0;
	[self presentViewController:picker animated:YES completion:nil];
}

-(void) presentGalleryForCoverPic {
	GMImagePickerController * picker = [[GMImagePickerController alloc] init];
	picker.delegate = self;
	[picker setSelectOnlyOneImage: YES];
	//Display or not the selection info Toolbar:
	picker.displaySelectionInfoToolbar = YES;

	//Display or not the number of assets in each album:
	picker.displayAlbumsNumberOfAssets = YES;

	//Customize the picker title and prompt (helper message over the title)
	picker.title = GALLERY_PICKER_TITLE;
	picker.customNavigationBarPrompt = COVERPIC_GALLERY_CUSTOM_MESSAGE;

	//Customize the number of cols depending on orientation and the inter-item spacing
	picker.colsInPortrait = 3;
	picker.colsInLandscape = 5;
	picker.minimumInteritemSpacing = 2.0;

	self.addingCoverPicture = YES;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray{
	[self.delegate showPullBar:YES withTransition:NO];
	if (self.addingCoverPicture) {
		self.addingCoverPicture = NO;
		[self addCoverPictureFromAssetArray: assetArray];
	} else {
		[self presentAssetsAsPinchViews:assetArray];
	}
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
	self.addingCoverPicture = NO;
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
		[self.delegate showPullBar:YES withTransition:NO];
	}];
}

-(void) addCoverPictureFromAssetArray: (NSArray*) assetArray {
	PHAsset* asset = assetArray[0];
	@autoreleasepool {
		[self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI,UIImageOrientation orientation, NSDictionary *info) {

			UIImage* image = [self getImageFromImageData: imageData];
			// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setCoverPictureImage: image];
			});
		}];
	}
}


-(void)setCoverPictureImage:(UIImage *) image{
    [self.coverPicView setNewImage: image];
    [[UserPovInProgress sharedInstance] addCoverPhoto: image];
    //show replace photo icon after the first time cover photo is added
    if(!_replaceCoverPhotoButton){
        [self coverPicAddedForFirstTime];
	}
}

//add assets from picker to our scrollview
-(void )presentAssetsAsPinchViews:(NSArray *)phassets {
	//store local identifiers so we can query the nsassets
	for(PHAsset * asset in phassets) {
		if(asset.mediaType==PHAssetMediaTypeImage) {
			@autoreleasepool {
				[self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
					UIImage* image = [self getImageFromImageData:imageData];
					// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
					dispatch_async(dispatch_get_main_queue(), ^{
						[self createPinchViewFromImage: image];
					});
				}];
			}
		} else if(asset.mediaType==PHAssetMediaTypeVideo) {
			@autoreleasepool {
				[self.imageManager requestAVAssetForVideo:asset options:self.videoRequestOptions
											resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info) {
					// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
					dispatch_async(dispatch_get_main_queue(), ^{
						[self createPinchViewFromVideoAsset: (AVURLAsset*) videoAsset andPHAssetLocalID:asset.localIdentifier];
					});
				}];
			}
		} else if(asset.mediaType==PHAssetMediaTypeAudio) {
			//			NSLog(@"Asset is of audio type, unable to handle.");
			return;
		} else {
			//			NSLog(@"Asset picked of unknown type");
			return;
		}
	}

	//decides whether on what notification to present if any
	if(![[UserSetupParameters sharedInstance] circlesArePages_InstructionShown] &&
	   self.pageElementScrollViews.count == 1 && (phassets.count > 1)) {
		[self alertEachPVIsPage];
        if(![[UserSetupParameters sharedInstance] pinchCircles_InstructionShown]) {
            //wait for a little while before circles are added to the stream
            [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(timerForNoNotification:) userInfo:nil repeats:NO];
        }
	}
}

- (void)timerForNoNotification:(NSTimer *)timer {
    [self alertPinchElementsTogether];
}

-(UIImage*) getImageFromImageData:(NSData*) imageData {
	UIImage* image = [[UIImage alloc] initWithData: imageData];
	image = [image getImageWithOrientationUp];
	image = [image scaleImageToSize:[image getSizeForImageWithBounds:self.view.bounds]];
	return image;
}

-(void) createPinchViewFromImage: (UIImage*) image {
	PinchView* newPinchView = [[ImagePinchView alloc] initWithRadius:self.defaultPinchViewRadius
														  withCenter:self.defaultPinchViewCenter
															andImage:image];
	if (self.addMediaBelowView) {
		[self newPinchView: newPinchView belowView: self.addMediaBelowView];
		self.addMediaBelowView = nil;
	} else {
		[self newPinchView:newPinchView belowView:nil];
	}
}

-(void) createPinchViewFromVideoAsset:(AVURLAsset*) videoAsset andPHAssetLocalID: (NSString*) phAssetLocalId {
	PinchView* newPinchView = [[VideoPinchView alloc] initWithRadius:self.defaultPinchViewRadius
														  withCenter:self.defaultPinchViewCenter
															andVideo: videoAsset
										   andPHAssetLocalIdentifier:phAssetLocalId];

	if (self.addMediaBelowView) {
		[self newPinchView: newPinchView belowView: self.addMediaBelowView];
		self.addMediaBelowView = nil;
	} else {
		[self newPinchView:newPinchView belowView:nil];
	}
}

#pragma mark - Returning Pinch Views -

-(NSArray*) getPinchViews {
	NSMutableArray *pinchViews = [[NSMutableArray alloc]init];
	for(ContentPageElementScrollView* elementScrollView in self.pageElementScrollViews) {
		if ([elementScrollView.pageElement isKindOfClass:[PinchView class]]) {
			[pinchViews addObject:[elementScrollView pageElement]];
		}
	}
	return pinchViews;
}

#pragma mark - Alerts -
/*
 These are all notifications that appear for the user at different points in the app. They only appear once.
 */
-(void)alertEachPVIsPage {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Each circle is a page in your story" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
    [[UserSetupParameters sharedInstance] set_circlesArePages_InstructionAsShown];
}

-(void)alertPinchElementsTogether {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Try pinching circles together!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[[UserSetupParameters sharedInstance] set_pinchCircles_InstructionAsShown];
}

-(void)alertSwipeRightToDelete {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Swipe circles left to delete" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [[UserSetupParameters sharedInstance] set_swipeToDelete_InstructionAsShown];
}

-(void)alertTapNHoldInCollection{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Tap and hold to remove circle" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [[UserSetupParameters sharedInstance] set_tapNhold_InstructionAsShown];
}

#pragma mark - Tap to clear view -

- (IBAction)tapToClearKeyboard:(UITapGestureRecognizer *)sender {
    [self removeKeyboardFromScreen];
}


#pragma mark - Lazy Instantiation

-(PHVideoRequestOptions*) videoRequestOptions {
	if (!_videoRequestOptions) {
		_videoRequestOptions = [PHVideoRequestOptions new];
		_videoRequestOptions.networkAccessAllowed =  YES; //videos won't only be loaded over wifi
		_videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
		_videoRequestOptions.version = PHVideoRequestOptionsVersionCurrent;
	}
	return _videoRequestOptions;
}

-(PHImageManager*) imageManager {
	if (!_imageManager) {
		_imageManager = [[PHImageManager alloc] init];
	}
	return _imageManager;
}

-(MediaSelectTile*) baseMediaTileSelector {
	if (!_baseMediaTileSelector) {
		CGRect frame = CGRectMake(ELEMENT_OFFSET_DISTANCE,
								  ELEMENT_OFFSET_DISTANCE/2.f,
								  self.view.frame.size.width - (ELEMENT_OFFSET_DISTANCE * 2), MEDIA_TILE_SELECTOR_HEIGHT);
		_baseMediaTileSelector= [[MediaSelectTile alloc]initWithFrame:frame];
		_baseMediaTileSelector.isBaseSelector =YES;
		_baseMediaTileSelector.delegate = self;
		[_baseMediaTileSelector createFramesForButtonWithFrame:frame];
		[_baseMediaTileSelector formatButton];
	}
	return _baseMediaTileSelector;
}

-(ContentDevNavBar*) navBar {
	if (!_navBar) {
		_navBar = [[ContentDevNavBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CONTENT_DEV_NAV_BAR_HEIGHT)];
	}
	return _navBar;
}

-(UIButton *)replaceCoverPhotoButton{
    
    if(!_replaceCoverPhotoButton){
        
        _replaceCoverPhotoButton = [[UIButton alloc] initWithFrame:
                                    CGRectMake(self.coverPicView.frame.origin.x +
                                               self.coverPicView.frame.size.width +
                                               REPLACE_PHOTO_XsOFFSET,
                                               self.coverPicView.frame.origin.y + REPLACE_PHOTO_XsOFFSET,
                                               REPLACE_PHOTO_FRAME_WIDTH, REPLACE_PHOTO_FRAME_HEIGHT)];
        
        [_replaceCoverPhotoButton setImage:[UIImage imageNamed: REPLACE_COVER_PHOTO_ICON] forState:UIControlStateNormal];
        [_replaceCoverPhotoButton addTarget:self action:@selector(presentGalleryForCoverPic) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replaceCoverPhotoButton;
}

-(UITextView *) activeTextView {
	if(!_activeTextView)_activeTextView = self.firstContentPageTextBox;
	return _activeTextView;
}

@synthesize pageElementScrollViews = _pageElementScrollViews;

-(NSMutableArray *) pageElementScrollViews {
	if(!_pageElementScrollViews) _pageElementScrollViews = [[NSMutableArray alloc] init];
	return _pageElementScrollViews;
}

-(void) setPageElementScrollViews:(NSMutableArray *)pageElementScrollViews {
	_pageElementScrollViews = pageElementScrollViews;
}


@synthesize tileSwipeViewUndoManager = _tileSwipeViewUndoManager;

//get the undomanager for the main window- use this for the tiles
-(NSUndoManager *) tileSwipeViewUndoManager{
	if(!_tileSwipeViewUndoManager) _tileSwipeViewUndoManager = [self.view.window undoManager];
	return _tileSwipeViewUndoManager;
}

- (void) setTileSwipeViewUndoManager:(NSUndoManager *)tileSwipeViewUndoManager {
	_tileSwipeViewUndoManager = tileSwipeViewUndoManager;
}

@end