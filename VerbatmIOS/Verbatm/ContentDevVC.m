

//
//  verbatmContentPageViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "ContentDevVC.h"
#import "CollectionPinchView.h"
#import "CoverPicturePinchView.h"
#import "ContentPageElementScrollView.h"
#import "CoverPicturePV.h"
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

#import "UIEffects.h"
#import "UserSetupParameters.h"

#import "UserPinchViews.h"
#import "VerbatmScrollView.h"
#import "VideoPinchView.h"



@interface ContentDevVC () < UITextFieldDelegate,UIScrollViewDelegate, MediaSelectTileDelegate,
GMImagePickerControllerDelegate, ContentSVDelegate>


// Says whether or not user is currently adding a cover picture
// (used when returning from adding assets)
@property (nonatomic) BOOL addingCoverPicture;
@property (strong, nonatomic) CoverPicturePV * coverPicView;

@property (strong, nonatomic) UIButton * replaceCoverPhotoButton;

@property (strong, nonatomic, readwrite) NSMutableArray * pageElementScrollViews;
@property (nonatomic) NSInteger numPinchViews;

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
@property (nonatomic) BOOL photoTappedOpenForTheFirstTime;

#define CLOSED_ELEMENT_FACTOR (2/5)
#define WHAT_IS_IT_LIKE_OFFSET 15
#define WHAT_IS_IT_LIKE_HEIGHT 50

#define REPLACE_PHOTO_FRAME_WIDTH 80
#define REPLACE_PHOTO_FRAME_HEIGHT 80

#define REPLACE_PHOTO_YOFFSET 20 //distance of replacePhoto y postion vs the y postion of the coverphoto
#define REPLACE_PHOTO_XsOFFSET 20 //distance of replacePhoto x postion vs the x postion of the coverphoto

#define BASE_MAINSCROLLVIEW_CONTENT_SIZE self.view.frame.size.height + 1
@end


@implementation ContentDevVC

#pragma mark - Initialization And Instantiation -

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initializeVariables];
	[self addBlurView];
	[self setFrameMainScrollView];
	[self setElementDefaultFrames];
	[self setKeyboardAppearance];
	[self setCursorColor];
	[self formatTitleAndCoverPicture];
	//TODO:	[self createBaseSelector];
	[self setUpNotifications];
	[self setDelegates];
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
	[UIEffects createBlurViewOnView:self.view withStyle:UIBlurEffectStyleLight];
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
	self.defaultPinchViewCenter = CGPointMake((2*DELETE_ICON_OFFSET) + DELETE_ICON_WIDTH + (self.view.frame.size.width/2.f),
											  self.defaultPageElementScrollViewSize.height/2);
	self.defaultPinchViewRadius = (self.defaultPageElementScrollViewSize.height - ELEMENT_OFFSET_DISTANCE)/2.f;
}

-(void) createBaseSelector {

	//make sure we don't create another one when we return from image picking
	if(_baseMediaTileSelector) return;

	CGRect scrollViewFrame = CGRectMake(0, self.coverPicView.frame.origin.y + self.coverPicView.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.view.frame.size.width, MEDIA_TILE_SELECTOR_HEIGHT+ELEMENT_OFFSET_DISTANCE);

	CGRect frame = CGRectMake((2*DELETE_ICON_OFFSET) + DELETE_ICON_WIDTH + ELEMENT_OFFSET_DISTANCE,
							  ELEMENT_OFFSET_DISTANCE/2.f,
							  self.view.frame.size.width - (ELEMENT_OFFSET_DISTANCE * 2), MEDIA_TILE_SELECTOR_HEIGHT);
	self.baseMediaTileSelector= [[MediaSelectTile alloc]initWithFrame:frame];
	self.baseMediaTileSelector.isBaseSelector =YES;
	self.baseMediaTileSelector.delegate = self;
	[self.baseMediaTileSelector createFramesForButtonWithFrame:frame];
	[self.baseMediaTileSelector formatButton];

	ContentPageElementScrollView * baseMediaTileSelectorScrollView = [[ContentPageElementScrollView alloc]
																	  initWithFrame:scrollViewFrame
																	  andElement:self.baseMediaTileSelector];

	baseMediaTileSelectorScrollView.scrollEnabled = NO;
	baseMediaTileSelectorScrollView.delegate = self;

	[self.mainScrollView addSubview:baseMediaTileSelectorScrollView];
	[self.pageElementScrollViews addObject:baseMediaTileSelectorScrollView];
}

// set keyboard appearance color on all textfields and textviews
-(void) setKeyboardAppearance {
	[[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
}

// set cursor color on all textfields and textviews
-(void) setCursorColor {
	[[UITextField appearance] setTintColor:[UIColor WHAT_IS_IT_LIKE_COLOR]];
}

//sets the textview placeholders' color and text
-(void) formatTitleAndCoverPicture {

	CGRect whatIsItLikeLabelFrame = CGRectMake(WHAT_IS_IT_LIKE_OFFSET, WHAT_IS_IT_LIKE_OFFSET,
											   self.view.bounds.size.width - 2*WHAT_IS_IT_LIKE_OFFSET,
											   WHAT_IS_IT_LIKE_HEIGHT);
	CGRect whatIsItLikeFieldFrame = CGRectMake(WHAT_IS_IT_LIKE_OFFSET, whatIsItLikeLabelFrame.origin.y + whatIsItLikeLabelFrame.size.height,
											   self.view.bounds.size.width - 2*WHAT_IS_IT_LIKE_OFFSET,
											   WHAT_IS_IT_LIKE_HEIGHT*2);

	CGFloat coverPicRadius = self.defaultPinchViewRadius * 3.f/4.f;
	CGRect addCoverPicFrame = CGRectMake(self.view.frame.size.width/2.f - coverPicRadius,
										 whatIsItLikeFieldFrame.origin.y + whatIsItLikeFieldFrame.size.height,
										 coverPicRadius*2, coverPicRadius*2);

	[self formatWhatIsItLikeLabelFromFrame: whatIsItLikeLabelFrame];
	[self formatWhatIsItLikeFieldFromFrame: CGRectMake(0, 0, whatIsItLikeFieldFrame.size.width, whatIsItLikeFieldFrame.size.height/2.f)];

	//Field border
	UIView* borderView = [[UIView alloc] initWithFrame: whatIsItLikeFieldFrame];
	UIImageView* borderImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0,
																				  whatIsItLikeFieldFrame.size.width,
																				  whatIsItLikeFieldFrame.size.height)];
	[borderImageView setImage:[UIImage imageNamed: WHAT_IS_IT_LIKE_BORDER]];
	borderImageView.contentMode = UIViewContentModeScaleAspectFill;

	[borderView addSubview:borderImageView];
	[borderView addSubview:self.whatIsItLikeField];
	[borderView bringSubviewToFront:self.whatIsItLikeField];
	[self.mainScrollView addSubview: self.whatIsItLikeLabel];
	[self.mainScrollView addSubview: borderView];

	[self setAddCoverPictureViewWithFrame: addCoverPicFrame];
}

-(void) formatWhatIsItLikeLabelFromFrame: (CGRect) frame {
	UIFont* labelFont = [UIFont fontWithName:DEFAULT_FONT size: WHAT_IS_IT_LIKE_LABEL_TEXT_SIZE];
	self.whatIsItLikeLabel = [[UILabel alloc] initWithFrame: frame];
	self.whatIsItLikeLabel.text = @"what is it like to be ...";
	self.whatIsItLikeLabel.textAlignment = NSTextAlignmentLeft;
	self.whatIsItLikeLabel.font = labelFont;
	self.whatIsItLikeLabel.textColor = [UIColor WHAT_IS_IT_LIKE_COLOR];
}

-(void) formatWhatIsItLikeFieldFromFrame: (CGRect) frame {
	UIFont* whatIsItLikeFieldFont = [UIFont fontWithName:PLACEHOLDER_FONT size: WHAT_IS_IT_LIKE_FIELD_TEXT_SIZE];
	self.whatIsItLikeField = [[UITextField alloc] initWithFrame: frame];
	self.whatIsItLikeField.textAlignment = NSTextAlignmentCenter;
	self.whatIsItLikeField.font = [UIFont fontWithName:TITLE_TEXT_FONT size: WHAT_IS_IT_LIKE_FIELD_TEXT_SIZE];
    [self.whatIsItLikeField setTextColor:[UIColor TELL_YOUR_STORY_COLOR]];
	self.whatIsItLikeField.tintColor = [UIColor TELL_YOUR_STORY_COLOR];
	self.whatIsItLikeField.attributedPlaceholder = [[NSAttributedString alloc]
													initWithString: @"tell your story"
													attributes:@{NSForegroundColorAttributeName: [UIColor TELL_YOUR_STORY_COLOR],
																 NSFontAttributeName : whatIsItLikeFieldFont}];
	[self.whatIsItLikeField resignFirstResponder];
	self.whatIsItLikeField.enabled = YES;
	self.whatIsItLikeField.autocorrectionType = UITextAutocorrectionTypeYes;
	[self.whatIsItLikeField setReturnKeyType:UIReturnKeyDone];
}

-(void) setAddCoverPictureViewWithFrame: (CGRect) frame {
	//self.coverPicView = [[CoverPicturePV alloc] initWithFrame:frame];
    self.coverPicView = [[CoverPicturePV alloc] initWithRadius:frame.size.width/2.f withCenter:CGPointMake(frame.origin.x + frame.size.width/2.f, frame.origin.y + frame.size.width/2.f) andImage:nil];
    
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCoverPictureTapped)];
	[self.coverPicView addGestureRecognizer: tapGesture];
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


-(void) setDelegates {
	self.whatIsItLikeField.delegate = self;
	self.mainScrollView.delegate = self;
}

-(UIImage*) getCoverPicture {
	return [self.coverPicView getImage];
}

// Loads pinch views from user defaults
-(void) loadPinchViews {
	NSArray* savedPinchViews = [[UserPinchViews sharedInstance] pinchViews];
	for (PinchView* pinchView in savedPinchViews) {
		[pinchView specifyRadius:self.defaultPinchViewRadius
					   andCenter:self.defaultPinchViewCenter];
		[self newPinchView:pinchView belowView: nil];
	}
}

#pragma mark - Configure Text Fields -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	//S@nwiches shouldn't have any spaces between them
	if([string isEqualToString:@" "]  && textField != self.whatIsItLikeField) return NO;
	return YES;
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.whatIsItLikeField) {
		[self.whatIsItLikeField resignFirstResponder];
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

-(void) showOrHidePullBarBasedOnMainScrollViewScroll {
	CGPoint translation = [self.mainScrollView.panGestureRecognizer translationInView:self.mainScrollView];
	if(translation.y < 0) {
		[self.changePullBarDelegate showPullBar:NO withTransition:YES];
	}else {
		[self.changePullBarDelegate showPullBar:YES withTransition:YES];
	}
	return;
}


#pragma mark Deleting scrollview and element
////make sure the object is in the right position
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
//				  willDecelerate:(BOOL)decelerate {
//	if ([scrollView isKindOfClass:[ContentPageElementScrollView class]]) {
//		[self deleteOrAnimateBackScrollView:(ContentPageElementScrollView*)scrollView];
//	}
//}
//
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//	if ([scrollView isKindOfClass:[ContentPageElementScrollView class]]) {
//		[self deleteOrAnimateBackScrollView:(ContentPageElementScrollView*)scrollView];
//	}
//}
//
////check if scroll view has been scrolled enough to delete, and if so delete.
////Otherwise scroll it back
//-(void) deleteOrAnimateBackScrollView:(ContentPageElementScrollView*)scrollView {
//    return;//temp
//
//    if (self.pinchingMode != PinchingModeNone || scrollView.collectionIsOpen){
//		return;
//	}
//
//	if([scrollView isDeleting]) {
//		[scrollView animateOffScreen];
//		[self deleteScrollView:scrollView];
//	} else {
//		[scrollView animateBackToInitialPosition];
//	}
//}


-(void)contentPageScrollViewShouldDelete:(ContentPageElementScrollView*)scrollView {
	[self deleteScrollView:scrollView];
}


//Deletes scroll view and the element it contained
-(void) deleteScrollView:(ContentPageElementScrollView*)scrollView {
	if (![self.pageElementScrollViews containsObject:scrollView]){
		return;
	}

	NSUInteger index = [self.pageElementScrollViews indexOfObject:scrollView];
	[scrollView removeFromSuperview];
	[self.pageElementScrollViews removeObject:scrollView];
	[self shiftElementsBelowView: self.coverPicView];
	//register deleted tile
	[self registerDeletedTile:scrollView withIndex:[NSNumber numberWithUnsignedLong:index]];
}


//Remove keyboard when scrolling
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark - Creating New Views -
// Create a horizontal scrollview displaying a pinch object from a pinchView passed in
- (void) newPinchView:(PinchView *) pinchView belowView:(ContentPageElementScrollView *)upperScrollView {

	if(!pinchView) {
		NSLog(@"Attempting to add nil pinch view");
		return;
	}

	[[UserPinchViews sharedInstance] addPinchView:pinchView];
	[self addTapGestureToPinchView:pinchView];

	// must be below base media tile selector
//TODO when there is media tile	NSInteger index = self.pageElementScrollViews.count-1;
	NSInteger index = self.pageElementScrollViews.count;

	CGRect newElementScrollViewFrame;
	if(!upperScrollView) {
		newElementScrollViewFrame = CGRectMake(0,self.whatIsItLikeField.frame.origin.y + self.whatIsItLikeField.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
	} else {
		newElementScrollViewFrame = CGRectMake(upperScrollView.frame.origin.x, upperScrollView.frame.origin.y + upperScrollView.frame.size.height, upperScrollView.frame.size.width, upperScrollView.frame.size.height);
		index = [self.pageElementScrollViews indexOfObject:upperScrollView]+1;
	}
	ContentPageElementScrollView *newElementScrollView = [[ContentPageElementScrollView alloc]initWithFrame:newElementScrollViewFrame andElement:pinchView];
	newElementScrollView.delegate = self;
	newElementScrollView.customDelegate = self;

    [self.changePullBarDelegate canPreview:YES];
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
-(void)shiftElementsBelowView: (UIView *) view
{
	if (!view) {
		NSLog(@"View that elements are being shifted below should not be nil");
		return;
	}
	if(![view isKindOfClass:[ContentPageElementScrollView class]]
	   && ![view isKindOfClass:[CoverPicturePV class]]) {
		NSLog(@"View must be a scroll view or the cover pic view to shift elements below.");
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
		if(topView && topView != self.whatIsItLikeField) {
			NSInteger index = [self.pageElementScrollViews indexOfObject:topView];
			[self.pageElementScrollViews insertObject:view atIndex:(index+1)];
		}else if(topView == self.whatIsItLikeField) {
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
	if (self.whatIsItLikeField.isEditing) {
		[self.whatIsItLikeField resignFirstResponder];
	}
	if (self.openEditContentView) {
		[self.openEditContentView.textView resignFirstResponder];
	}
}

-(void) showKeyboard {
	if(self.whatIsItLikeField.isEditing) {
		[self.whatIsItLikeField becomeFirstResponder];
	}
	if (self.openEditContentView) {
		[self.openEditContentView.textView becomeFirstResponder];
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

	[self.openEditContentView adjustFrameOfTextViewForGap: (self.view.frame.size.height - ( self.keyboardHeight + self.pullBarHeight))];
}


-(void) keyBoardDidShow:(NSNotification *) notification {

	[self.openEditContentView adjustFrameOfTextViewForGap: (self.view.frame.size.height - ( self.keyboardHeight + self.pullBarHeight))];
}


-(void)keyboardWillDisappear:(NSNotification *) notification {
	[self.openEditContentView adjustFrameOfTextViewForGap: 0];
}

#pragma mark - Pinch Gesture -

#pragma mark  Sensing Pinch

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender {

	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			if([sender numberOfTouches] != 2 ) {
				return;
			}

			//sometimes people will rest their hands on the screen so make sure the textviews are selectable
			for (UIView * element in self.mainScrollView.pageElements) {
				if([element isKindOfClass:[UITextView class]]) {
					((UITextView *)element).selectable = YES;
				}
			}
			[self handlePinchGestureBegan:sender];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			if([sender numberOfTouches] != 2 ) {
				return;
			}

			if((self.pinchingMode == PinchingModeHorizontal)
			   && self.scrollViewOfHorizontalPinching && sender.scale < 1) {
				[self handleHorizontalPinchGestureChanged:sender];

			} else if ((self.pinchingMode == PinchingModeVertical)
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

	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
	CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];

	int xDifference = fabs(touch1.x -touch2.x);
	int yDifference = fabs(touch1.y -touch2.y);
	//figure out if it's a horizontal pinch or vertical pinch
	if(xDifference > yDifference) {
		self.pinchingMode = PinchingModeHorizontal;
		[self handleHorizontalPinchGestureBegan:sender];
	}else {
		//you can pinch together two things if there aren't two
		if(self.pageElementScrollViews.count < 2) return;
		self.pinchingMode = PinchingModeVertical;
		[self handleVerticlePinchGestureBegan:sender];
	}

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
	[self.changePullBarDelegate showPullBar:YES withTransition:YES];
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
	 if(self.upperPinchScrollView && self.lowerPinchScrollView && sender.scale > 1) {
		[self createNewMediaTileBetweenPinchViews];
	 }

}

-(void) handleVerticlePinchGestureChanged: (UIPinchGestureRecognizer *)gesture {
	if (!([gesture numberOfTouches] == 2)) {
		return;
	}

	CGPoint touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
	CGPoint touch2 = [gesture locationOfTouch:1 inView:self.mainScrollView];

	//touch1 is upper touch
	if (touch2.y < touch1.y) {
		CGPoint temp = touch1;
		touch1 = touch2;
		touch2 = temp;
	}

	float changeInTopViewPosition = [self handleUpperViewFromTouch:touch1];
	float changeInBottomViewPosition = [self handleLowerViewFromTouch:touch2];

	//objects are being pinched apart
	if(gesture.scale > 1) {
		[self handleRevealOfNewMediaViewWithGesture:gesture andChangeInTopViewPosition:changeInTopViewPosition
					  andChangeInBottomViewPosition:changeInBottomViewPosition];
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
	MediaSelectTile* newMediaTile = [[MediaSelectTile alloc]initWithFrame:frame];
	newMediaTile.delegate = self;
	newMediaTile.alpha = 0; //start it off as invisible
	newMediaTile.isBaseSelector = NO;
	[self addMediaTile: newMediaTile underView: self.upperPinchScrollView];
	self.newlyCreatedMediaTile = newMediaTile;
}

-(void) addMediaTile: (MediaSelectTile *) mediaTile underView: (ContentPageElementScrollView *) topView {
	if(!mediaTile) {
		NSLog(@"Can't add Nil media tile");
		return;
	}
	CGRect newMediaTileScrollViewFrame = [self getStartFrameForNewMediaTileScrollViewUnderView:topView];
	ContentPageElementScrollView * newMediaTileScrollView = [[ContentPageElementScrollView alloc]initWithFrame:newMediaTileScrollViewFrame andElement:mediaTile];
	newMediaTileScrollView.delegate = self;
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
	[self.changePullBarDelegate showPullBar:YES withTransition:YES];
    //present swipe to delete notification
    if([UserSetupParameters swipeToDelete_InstructionShown])[self alertSwipeRightToDelete];
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

	self.upperPinchScrollView = [self findPinchViewScrollViewFromPinchPoint:self.upperTouchPointInVerticalPinch];
	if(!self.upperPinchScrollView) {
		return;
	}
	if([self.upperPinchScrollView.pageElement isKindOfClass:[MediaSelectTile class]]) {
		self.upperPinchScrollView = nil;
		return;
	}

	NSInteger index = [self.pageElementScrollViews indexOfObject:self.upperPinchScrollView];

	if(self.pageElementScrollViews.count > (index+1) && index != NSNotFound) {
		self.lowerPinchScrollView = self.pageElementScrollViews[index+1];
	}

	if([self.lowerPinchScrollView.pageElement isKindOfClass:[MediaSelectTile class]]) {
		self.lowerPinchScrollView = nil;
		return;
	}
}


//Runs through and identifies the pinch view scrollview at that point
-(ContentPageElementScrollView *) findPinchViewScrollViewFromPinchPoint: (CGPoint) pinchPoint {
	NSInteger distanceTraveled = 0;
	ContentPageElementScrollView * wantedView;
	//Runs through the view positions to find the first one that passes the midpoint- we assume the midpoint is
	for (ContentPageElementScrollView* scrollView in self.pageElementScrollViews) {
		if(distanceTraveled == 0) distanceTraveled = scrollView.frame.origin.y;
		distanceTraveled += scrollView.frame.size.height;
		if(distanceTraveled > pinchPoint.y && [scrollView.pageElement isKindOfClass:[PinchView class]]) {
			wantedView = scrollView;
			break;
		}
	}
	return wantedView;
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

#pragma  mark - Add cover picture -

-(void) addCoverPictureTapped {
	[self presentGalleryForCoverPic];
    //show replace photo icon after the first time this is tapped
    if(!_replaceCoverPhotoButton){
        [self addTapGestureToPinchView:self.coverPicView];
        [self.mainScrollView addSubview:self.replaceCoverPhotoButton];
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
			if(self.pageElementScrollViews.count < 1 || [sender numberOfTouches] != 1) {
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

	NSInteger viewIndex = [self.pageElementScrollViews indexOfObject:self.selectedView_PAN];
	ContentPageElementScrollView* topView = nil;
	ContentPageElementScrollView* bottomView = nil;

	if(viewIndex !=0) {
		topView  = self.pageElementScrollViews[viewIndex-1];
	}
	if (viewIndex+1 < [self.pageElementScrollViews count]) {
		bottomView = self.pageElementScrollViews[viewIndex+1];
	}

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

	self.selectedView_PAN.frame = self.previousFrameInLongPress;

	[self.selectedView_PAN.pageElement markAsSelected:NO];

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
}


#pragma mark- MIC

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	//return supported orientation masks
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- memory handling & stopping all videos -

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	[self stopAllVideos];
}

-(void) stopAllVideos {
	for (ContentPageElementScrollView* scrollView in self.pageElementScrollViews) {
		if([scrollView.pageElement isKindOfClass:[VideoPinchView class]]) {
			[[(VideoPinchView*)scrollView.pageElement videoView] stopVideo];
		} else if([scrollView.pageElement isKindOfClass:[CollectionPinchView class]]) {
			[[(CollectionPinchView*)scrollView.pageElement videoView] stopVideo];
		}
	}
}


- (void)dealloc
{
	//tune out of nsnotification
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Undo implementation -

-(void) registerDeletedTile: (ContentPageElementScrollView *) tile withIndex: (NSNumber *) index {
	//make sure there is something to delete
	if(!tile) return;
	[tile removeFromSuperview];

	//update user defaults if was pinch view
	if ([tile.pageElement isKindOfClass:[PinchView class]]) {
		[[UserPinchViews sharedInstance] removePinchView:(PinchView*)tile.pageElement];
		self.numPinchViews--;
		if (self.numPinchViews < 1) {
			[self.changePullBarDelegate canPreview:NO];
		}
	}

	//ungray out undo if previously was grayed out
	if (![self.tileSwipeViewUndoManager canUndo]) {
		//		[self.changePullBarDelegate canUndo:YES];
	}
	[self.tileSwipeViewUndoManager registerUndoWithTarget:self selector:@selector(undoTileDelete:) object:@[tile, index]];
	//show the pullbar so that they can undo
	[self.changePullBarDelegate showPullBar:YES withTransition:YES];
}

-(void)undoTileDeleteSwipe {
	[self.tileSwipeViewUndoManager undo];
	if(![self.tileSwipeViewUndoManager canUndo]) {
		//		[self.changePullBarDelegate canUndo:NO];
	}
}


#pragma mark Undo tile swipe

-(void) undoTileDelete: (NSArray *) tileAndInfo {
	ContentPageElementScrollView * tile = tileAndInfo[0];
	NSNumber * index = tileAndInfo[1];

	//update user defaults if was pinch view
	if ([tile.pageElement isKindOfClass:[PinchView class]]) {
		[[UserPinchViews sharedInstance] addPinchView:(PinchView*)tile.pageElement];
		if (self.numPinchViews < 1) {
			[self.changePullBarDelegate canPreview:YES];
		}
		self.numPinchViews++;
	}

	[tile.pageElement markAsDeleting:NO];

	[self returnView:tile toDisplayAtIndex:index.integerValue];
}

-(void)returnView: (ContentPageElementScrollView *) scrollView toDisplayAtIndex:(NSInteger) index {

	if(index) {
		ContentPageElementScrollView * upperScrollView = self.pageElementScrollViews[(index -1)];
		scrollView.frame = CGRectMake(upperScrollView.frame.origin.x, upperScrollView.frame.origin.y + upperScrollView.frame.size.height,
									  upperScrollView.frame.size.width, upperScrollView.frame.size.height);

	} else {
		scrollView.frame = CGRectMake(0,self.whatIsItLikeField.frame.origin.y + self.whatIsItLikeField.frame.size.height, self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
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
        if([UserSetupParameters tapNhold_InstructionShown])[self alertTapNHoldInCollection];
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
		EditContentVC *vc =  (EditContentVC *)segue.destinationViewController;
		vc.pinchView = self.openPinchView;
		vc.photoTappedOpenForTheFirstTime = self.pinchViewTappedAndClosedForTheFirstTime;
	}
}

- (IBAction) unwindSegue: (UIStoryboardSegue *)segue{
	if([segue.identifier isEqualToString:UNWIND_SEGUE_EDIT_CONTENT_VIEW]) {
		EditContentVC *editContentVC = (EditContentVC *)segue.sourceViewController;
		if(self.openPinchView.containsImage) {
			[(ImagePinchView*)self.openPinchView changeImageToFilterIndex: editContentVC.filterImageIndex];
		}
		[editContentVC.openEditContentView.videoView stopVideo];
		self.pinchViewTappedAndClosedForTheFirstTime = YES;
	}
}

#pragma mark - Clean up Content Page -

//we clean up the content page if we press publish or simply want to reset everything
//all the text views are cleared and all the pinch objects are cleared
//all videos in pinch views are stopped
-(void)cleanUp {
	for (ContentPageElementScrollView* scrollView in self.pageElementScrollViews) {
		if([scrollView.pageElement isKindOfClass:[VideoPinchView class]]) {
			[[(VideoPinchView*)scrollView.pageElement videoView] stopVideo];
		} else if([scrollView.pageElement isKindOfClass:[CollectionPinchView class]]) {
			[[(CollectionPinchView*)scrollView.pageElement videoView] stopVideo];
		}
		[scrollView removeFromSuperview];
	}
	[self.pageElementScrollViews removeAllObjects];
	[self.changePullBarDelegate canPreview:NO];
	[self.mainScrollView setContentOffset:CGPointMake(0, 0)];
	[self adjustMainScrollViewContentSize];
	[self clearTextFields];
    [self clearCoverPhoto];
//TODO:	[self createBaseSelector];
}

-(void) clearCoverPhoto {
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCoverPictureTapped)];
    [self.coverPicView addGestureRecognizer: tapGesture];
    [self.coverPicView removeImage];
    [self.replaceCoverPhotoButton removeFromSuperview];
    self.replaceCoverPhotoButton = nil;
}

-(void)clearTextFields {
	self.whatIsItLikeField.text =@"";
}


#pragma mark - Gallery + Image picker -

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

-(void) createPinchViewFromAsset:(id)asset {
	PinchView* newPinchView;
	if([asset isKindOfClass:[AVAsset class]] || [asset isKindOfClass:[NSURL class]]) {
		newPinchView = [[VideoPinchView alloc] initWithRadius:self.defaultPinchViewRadius withCenter:self.defaultPinchViewCenter andVideo:asset];
	} else if([asset isKindOfClass:[NSData class]]) {
		UIImage* image = [[UIImage alloc] initWithData:(NSData*)asset];
		image = [UIEffects fixOrientation:image];
		image = [UIEffects scaleImage:image toSize:[UIEffects getSizeForImage:image andBounds:self.view.bounds]];
		newPinchView = [[ImagePinchView alloc] initWithRadius:self.defaultPinchViewRadius withCenter:self.defaultPinchViewCenter andImage:image];
	}
	if (newPinchView) {
        [self newPinchView:newPinchView belowView:nil];
	}
}

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray {
	[self.changePullBarDelegate showPullBar:YES withTransition:NO];
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
		if (self.addingCoverPicture) {
			self.addingCoverPicture = NO;
			[self addCoverPictureFromAssetArray: assetArray];
		} else {
			[self presentAssetsAsPinchViews:assetArray];
		}
	}];
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
    self.openPinchView = nil;
    self.addingCoverPicture = NO;
}

-(void) addCoverPictureFromAssetArray: (NSArray*) assetArray {
	PHAsset* asset = assetArray[0];
	PHImageManager * iman = [[PHImageManager alloc] init];
    @autoreleasepool {
        [iman requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            // RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage* image = [[UIImage alloc] initWithData: imageData];
                image = [UIEffects fixOrientation:image];
                [self.coverPicView setNewImageWith: image];
            });
        }];
    }
}

//add assets from picker to our scrollview
-(void )presentAssetsAsPinchViews:(NSArray *)phassets {
	PHImageManager * iman = [[PHImageManager alloc] init];
	//store local identifiers so we can querry the nsassets
	for(PHAsset * asset in phassets) {
		if(asset.mediaType==PHAssetMediaTypeImage) {
			[iman requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
				// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
				dispatch_async(dispatch_get_main_queue(), ^{
					[self createPinchViewFromImageData: imageData];
				});
			}];
		} else if(asset.mediaType==PHAssetMediaTypeVideo) {
			[iman requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
				if (![asset isKindOfClass:[AVURLAsset class]]) {
					NSLog(@"Issue with video not in AVURLAsset form");
					return;
				}
				// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
				dispatch_async(dispatch_get_main_queue(), ^{
					[self createPinchViewFromVideoAsset: (AVURLAsset*) asset];
				});
			}];
		} else if(asset.mediaType==PHAssetMediaTypeAudio) {
			NSLog(@"Asset is of audio type, unable to handle.");
			return;
		} else {
			NSLog(@"Asset picked of unknown type");
			return;
		}
	}

	//decides whether on what notification to present if any
	if(![UserSetupParameters circlesArePages_InstructionShown] &&
	   !self.pageElementScrollViews.count) {
		[self alertEachPVIsPage];

	}else if(![UserSetupParameters pinchCircles_InstructionShown] &&
			 (self.pageElementScrollViews.count > 1)) {
		[self alertPinchElementsTogether];
	}
}

    
-(void) createPinchViewFromImageData:(NSData*) imageData {
	UIImage* image = [[UIImage alloc] initWithData: imageData];
	image = [UIEffects fixOrientation:image];
	image = [UIEffects scaleImage:image toSize:[UIEffects getSizeForImage:image andBounds:self.view.bounds]];
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

-(void) createPinchViewFromVideoAsset:(AVURLAsset*) videoAsset {
	PinchView* newPinchView = [[VideoPinchView alloc] initWithRadius:self.defaultPinchViewRadius
														  withCenter:self.defaultPinchViewCenter
															andVideo: videoAsset];
	if (self.addMediaBelowView) {
		[self newPinchView: newPinchView belowView: self.addMediaBelowView];
		self.addMediaBelowView = nil;
	} else {
		[self newPinchView:newPinchView belowView:nil];
	}
}


#pragma mark - Alerts -
/*
 These are all notifications that appear for the user at different points in the app. They only appear once.
 */
-(void)alertEachPVIsPage {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Each circle is a page in your story" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[UserSetupParameters set_circlesArePages_InstructionAsShown];
}

-(void)alertPinchElementsTogether {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Try pinching circles together!!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[UserSetupParameters set_pinchCircles_InstructionAsShown];
}

-(void)alertSwipeRightToDelete {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Swipe circles right to delete" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [UserSetupParameters set_swipeToDelete_InstructionAsShown];
}

-(void)alertTapNHoldInCollection{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Tap and hold to remove circle" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [UserSetupParameters set_tapNhold_InstructionAsShown];
}

#pragma mark -Tap to clear view-
- (IBAction)tapToClearKeyboard:(UITapGestureRecognizer *)sender {
    [self removeKeyboardFromScreen];
}


#pragma mark - Lazy Instantiation

-(UIButton *)replaceCoverPhotoButton{
    
    if(!_replaceCoverPhotoButton){
        
        _replaceCoverPhotoButton = [[UIButton alloc] initWithFrame:
                                    CGRectMake(self.coverPicView.frame.origin.x +
                                               self.coverPicView.frame.size.width +
                                               
                                               REPLACE_PHOTO_XsOFFSET,
                                               self.coverPicView.frame.origin.y + REPLACE_PHOTO_XsOFFSET,
                                               REPLACE_PHOTO_FRAME_WIDTH, REPLACE_PHOTO_FRAME_HEIGHT)];
        
        [_replaceCoverPhotoButton setImage:[UIImage imageNamed:@"replacePhotoIcon"] forState:UIControlStateNormal];
        [_replaceCoverPhotoButton addTarget:self action:@selector(addCoverPictureTapped) forControlEvents:UIControlEventTouchUpInside];

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