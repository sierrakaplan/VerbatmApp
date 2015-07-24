

//
//  verbatmContentPageViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "ContentDevVC.h"
#import "MediaDevVC.h"
#import <QuartzCore/QuartzCore.h>
#import "VerbatmUITextView.h"
#import "MediaSelectTile.h"
#import "VerbatmScrollView.h"
#import "UIEffects.h"
#import "PinchView.h"
#import "VerbatmImageView.h"
#import "EditContentView.h"
#import "GMImagePickerController.h"
#import "Notifications.h"
#import "SizesAndPositions.h"
#import "Durations.h"
#import "Strings.h"
#import "Styles.h"

@interface ContentDevVC () < UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,MediaSelectTileDelegate,GMImagePickerControllerDelegate>

#pragma mark Keyboard related properties
@property (atomic) NSInteger keyboardHeight;

#pragma mark Helpful integer stores
//the index of the first view that is pushed up/down by the pinch/stretch gesture
@property (atomic) NSInteger index;
@property (atomic, strong) NSString * textBeforeNavigationLabel;

#pragma mark undo related properties
@property (atomic, strong) NSUndoManager * tileSwipeViewUndoManager;

#pragma mark Default frame properties

//each element is on a horizontal "personal" scrollview
@property (nonatomic) CGPoint defaultElementPersonalScrollViewContentOffset;
@property (nonatomic) CGSize defaultElementPersonalScrollViewContentSize;
@property (nonatomic) CGSize defaultElementFrame;
@property (nonatomic) CGPoint defaultElementCenter;
@property (nonatomic) float defaultElementRadius;

//@property (nonatomic) CGPoint defaultElementCenter;
//@property (strong, nonatomic) NSNumber * defaultElementRadius;
//@property (nonatomic) CGSize defaultElementFrame;

#pragma mark Display manipulation outlets

@property (weak, nonatomic) IBOutlet UIScrollView *personalScrollViewOfFirstContentPageTextBox;
@property (weak, nonatomic) IBOutlet UILabel *wordsLeftLabel;

#pragma mark TextView related properties

//position of caret on screen relative to scrollview origin
@property (nonatomic) CGRect caretPosition;

#pragma mark Helpful integer stores

//number of words left in the article
@property (nonatomic) NSInteger numberOfWordsLeft;

#pragma mark Text input outlets

@property (weak, atomic) IBOutlet VerbatmUITextView *firstContentPageTextBox;
@property (strong, atomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, atomic) MediaSelectTile * baseMediaTileSelector;


#pragma mark PanGesture Properties

@property (atomic, strong) UIView<ContentDevElementDelegate>* selectedView_PAN;
@property(nonatomic) CGPoint startLocationOfTouchPoint_PAN;
//keep track of the starting from of the selected view so that you can easily shift things around
@property (nonatomic) CGRect originalFrameBeforeLongPress;
//keep track of the frame the selected view could take so that we can easily shift
@property (nonatomic) CGRect potentialFrameAfterLongPress;

@property (nonatomic, strong) EditContentView * openEditContentView;
@property (nonatomic, strong) PinchView * openImagePinchView;
@property (nonatomic, strong) NSString * filter;


#pragma mark - Pinch Gesture Related Properties

//tells if pinching is occurring
@property (nonatomic) PinchingMode pinchingMode;

#pragma mark Horizontal pinching
@property (nonatomic, strong) UIScrollView * scrollViewOfHorizontalPinching;
@property (nonatomic) NSInteger horizontalPinchDistance;
@property(nonatomic) CGPoint leftTouchPointInHorizontalPinch;
@property (nonatomic) CGPoint rightTouchPointInHorizontalPinch;

#pragma mark Vertical pinching
@property (nonatomic,strong) UIView * upperPinchView;
@property (nonatomic,strong) UIView * lowerPinchView;
@property (nonatomic) CGPoint upperTouchPointInVerticalPinch;
@property(nonatomic) CGPoint lowerTouchPointInVerticalPinch;
@property (nonatomic,strong) MediaSelectTile* newlyCreatedMediaTile;


#define CLOSED_ELEMENT_FACTOR (2/5)
#define MAX_WORD_LIMIT 350

#define LEFT_DELETE_OFFSET (self.view.frame.size.width/2)
#define RIGHT_DELETE_OFFSET (self.view.frame.size.width*(4/3))

@end


@implementation ContentDevVC

#pragma mark - Initialization And Instantiation -

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self addBlurView];
	[self setPlaceholderColors];

	[self setElementDefaultFrames];

	[self createBaseSelector];
	[self centerViews];
	[self configureViews];
	[self setUpNotifications];
	[self setDelegates];
	self.pinchingMode = PinchingModeNone;
}

-(void) addBlurView {
	[UIEffects createBlurViewOnView:self.view];
}

-(void) centerViews
{
	NSInteger middle = self.view.frame.size.width/2;
	//@ sign
	self.sandwichAtLabel.frame = CGRectMake(middle - self.sandwichAtLabel.frame.size.width/2, self.sandwichAtLabel.frame.origin.y, self.sandwichAtLabel.frame.size.width, self.sandwichAtLabel.frame.size.height);
	//the space to the left and to the write of the @ label
	NSInteger spaceLeft = (self.view.frame.size.width - self.sandwichAtLabel.frame.size.width)/2;

	//s@ndwiches
	self.sandwichWhat.frame = CGRectMake((spaceLeft/2)-(self.sandwichWhat.frame.size.width/2), self.sandwichWhat.frame.origin.y, self.sandwichWhat.frame.size.width, self.sandwichWhat.frame.size.height);
	float centerLeft = self.sandwichWhat.frame.origin.x + self.sandwichWhat.frame.size.width/2.0 - self.dotsLeft.frame.size.width/2.0;
	self.dotsLeft.frame = CGRectMake(centerLeft, self.sandwichWhat.frame.origin.y + self.sandwichWhat.frame.size.height, self.dotsLeft.frame.size.width, self.dotsLeft.frame.size.height);

	self.sandwichWhere.frame = CGRectMake(((self.sandwichAtLabel.frame.origin.x + self.sandwichAtLabel.frame.size.width)+(spaceLeft/2))-(self.sandwichWhere.frame.size.width/2), self.sandwichWhere.frame.origin.y, self.sandwichWhere.frame.size.width, self.sandwichWhere.frame.size.height);
	float centerRight = self.sandwichWhere.frame.origin.x + self.sandwichWhere.frame.size.width/2.0 - self.dotsRight.frame.size.width/2.0;
	self.dotsRight.frame = CGRectMake(centerRight, self.sandwichWhere.frame.origin.y + self.sandwichWhere.frame.size.height, self.dotsRight.frame.size.width, self.dotsRight.frame.size.height);

	//article title
	self.articleTitleField.frame = CGRectMake(middle - (self.articleTitleField.frame.size.width/2), self.articleTitleField.frame.origin.y, self.articleTitleField.frame.size.width, self.articleTitleField.frame.size.height);
}

-(void) setFrameMainScrollView {
	self.mainScrollView.frame= self.view.frame;
}

//sets the textview placeholders' color and text
-(void) setPlaceholderColors {

	UIColor *color = [UIColor whiteColor];
	UIFont* sandwichPlaceholderFont = [UIFont fontWithName:PLACEHOLDER_FONT size:SANDWICH_PLACEHOLDER_SIZE];
	UIFont* titlePlaceholderFont = [UIFont fontWithName:PLACEHOLDER_FONT size:TITLE_PLACEHOLDER_SIZE];

	// attempt to set placeholder using attributed placeholder selector
	if ([self.sandwichWhat respondsToSelector:@selector(setAttributedPlaceholder:)]
		&& [self.sandwichWhere respondsToSelector:@selector(setAttributedPlaceholder:)]
		&& [self.articleTitleField respondsToSelector:@selector(setAttributedPlaceholder:)]) {

		self.sandwichWhat.attributedPlaceholder = [[NSAttributedString alloc]
												   initWithString:self.sandwichWhat.placeholder
												   attributes:@{NSForegroundColorAttributeName: color,
																NSFontAttributeName : sandwichPlaceholderFont}];

		self.sandwichWhere.attributedPlaceholder = [[NSAttributedString alloc]
													initWithString:self.sandwichWhere.placeholder
													attributes:@{NSForegroundColorAttributeName: color,
																 NSFontAttributeName : sandwichPlaceholderFont}];

		self.articleTitleField.attributedPlaceholder = [[NSAttributedString alloc]
														initWithString:self.articleTitleField.placeholder
														attributes:@{NSForegroundColorAttributeName: color,
																	 NSFontAttributeName : titlePlaceholderFont}];
	} else {
		NSLog(PLACEHOLDER_SELECTOR_FAILED_ERROR_MESSAGE);
		// TODO: Add fall-back code to set placeholder color.
	}
}

//records the generic frame for any element that is a square and not a pinch view circle
//and its scrollview.
-(void)setElementDefaultFrames {
	//set the content offset for the personal scrollview
	self.defaultElementPersonalScrollViewContentOffset = CGPointMake(self.view.frame.size.width, 0);
	self.defaultElementPersonalScrollViewContentSize = CGSizeMake(self.view.frame.size.width * 3, 0);

	self.defaultElementFrame = CGSizeMake(self.view.frame.size.width, ((self.view.frame.size.height*2.f)/5.f));

	self.defaultElementCenter = CGPointMake((self.defaultElementPersonalScrollViewContentSize.width/2.f), self.defaultElementFrame.height/2);

	self.defaultElementRadius = (self.defaultElementFrame.height - ELEMENT_OFFSET_DISTANCE)/2.f;

}

-(void) createBaseSelector {

	//make sure we don't create another one when we return from image picking
	if(_baseMediaTileSelector)return;
	CGRect frame = CGRectMake(self.view.frame.size.width + ELEMENT_OFFSET_DISTANCE,
							  ELEMENT_OFFSET_DISTANCE/2,
							  self.view.frame.size.width - (ELEMENT_OFFSET_DISTANCE * 2), MEDIA_TILE_SELECTOR_HEIGHT);
	self.baseMediaTileSelector= [[MediaSelectTile alloc]initWithFrame:frame];
	self.baseMediaTileSelector.isBaseSelector =YES;
	self.baseMediaTileSelector.delegate = self;
	[self.baseMediaTileSelector createFramesForButtonsWithFrame:frame];

	UIScrollView * scrollview = [[UIScrollView alloc]init];
	scrollview.frame = CGRectMake(0, self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.view.frame.size.width, (self.view.frame.size.height/5)+ELEMENT_OFFSET_DISTANCE);

	scrollview.contentSize = self.defaultElementPersonalScrollViewContentSize;
	scrollview.contentOffset = self.defaultElementPersonalScrollViewContentOffset;
	scrollview.pagingEnabled = NO;
	scrollview.scrollEnabled = NO;
	scrollview.showsHorizontalScrollIndicator = NO;
	scrollview.delegate = self;
	[scrollview addSubview:self.baseMediaTileSelector];
	[self.mainScrollView addSubview:scrollview];
	[self.pageElements addObject:self.baseMediaTileSelector];

	for (int i =0; i< scrollview.subviews.count; i++) {
		if([scrollview.subviews[i] isMemberOfClass:[UIImageView class]])
		{
			[scrollview.subviews[i] removeFromSuperview];
		}
	}
}

//Set up views
-(void) configureViews {
	[self setFrameMainScrollView];
	[self setKeyboardAppearance];
	[self setCursorColor];
}

// set cursor color on all textfields and textviews
-(void) setCursorColor {
	[[UITextField appearance] setTintColor:[UIColor CONTENT_DEV_CURSOR_COLOR]];
}

// set keyboard appearance color on all textfields and textviews
-(void) setKeyboardAppearance {
	[[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
}

-(void) setUpNotifications
{
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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeKeyboardFromScreen) name:UIDeviceOrientationDidChangeNotification object: [UIDevice currentDevice]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoTileDeleteSwipe:) name:NOTIFICATION_UNDO object: nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyBoardWillChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pauseAllVideos)
												 name:NOTIFICATION_PAUSE_VIDEOS
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playVideos)
												 name:NOTIFICATION_PLAY_VIDEOS
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(cleanUpNotification)
												 name:NOTIFICATION_CLEAR_CONTENTPAGE
											   object:nil];
}


-(void) setDelegates
{
	//Set delgates for textviews
	self.sandwichWhat.delegate = self;
	self.sandwichWhere.delegate = self;
	self.articleTitleField.delegate = self;
	self.mainScrollView.delegate = self;

}

#pragma mark - Lazy Instantiation

-(NSInteger) numberOfWordsLeft
{
	if(!_numberOfWordsLeft) _numberOfWordsLeft = MAX_WORD_LIMIT;
	return  _numberOfWordsLeft;
}

-(VerbatmUITextView *) activeTextView
{
	if(!_activeTextView)_activeTextView = self.firstContentPageTextBox;
	return _activeTextView;
}

@synthesize pageElements = _pageElements;

-(NSMutableArray *) pageElements
{
	if(!_pageElements) _pageElements = [[NSMutableArray alloc] init];
	return _pageElements;
}

- (void) setPageElements:(NSMutableArray *)pageElements {
	_pageElements = pageElements;
}


@synthesize pinchViewScrollViews = _pinchViewScrollViews;

-(NSMutableArray *) pinchViewScrollViews
{
	if(!_pinchViewScrollViews) _pinchViewScrollViews = [[NSMutableArray alloc] init];
	return _pinchViewScrollViews;
}

- (void) setPinchViewScrollViews:(NSMutableArray *)pinchViewScrollViews {
	_pinchViewScrollViews = pinchViewScrollViews;
}


@synthesize baseMediaTileSelector = _baseMediaTileSelector;

-(MediaSelectTile *) baseMediaTileSelector
{
	if(!_baseMediaTileSelector) _baseMediaTileSelector = [[MediaSelectTile alloc]init];
	return _baseMediaTileSelector;
}

- (void) setBaseMediaTileSelector: (MediaSelectTile *) baseMediaTileSelector
{
	_baseMediaTileSelector = baseMediaTileSelector;
}

@synthesize tileSwipeViewUndoManager = _tileSwipeViewUndoManager;

//get the undomanager for the main window- use this for the tiles
-(NSUndoManager *) tileSwipeViewUndoManager
{
	if(!_tileSwipeViewUndoManager) _tileSwipeViewUndoManager = [self.view.window undoManager];
	return _tileSwipeViewUndoManager;
}

- (void) setTileSwipeViewUndoManager:(NSUndoManager *)tileSwipeViewUndoManager {
	_tileSwipeViewUndoManager = tileSwipeViewUndoManager;
}



#pragma mark - Configure Text Fields -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	//S@nwiches shouldn't have any spaces between them
	if([string isEqualToString:@" "]  && textField != self.articleTitleField) return NO;
	return YES;
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.sandwichWhat) {
		if([self.sandwichWhere.text isEqualToString:@""]) {
			[self.sandwichWhere becomeFirstResponder];
		}else {
			[self.sandwichWhat resignFirstResponder];
		}
	}else if(textField == self.sandwichWhere) {
		[self.sandwichWhere resignFirstResponder];

	}else if(textField == self.articleTitleField) {
		[self.articleTitleField resignFirstResponder];
	}

	return YES;
}


#pragma mark Text Entered

//User has edited the text view somehow so we recount the words in the view. And adjust its size
- (void)textViewDidChange:(UITextView *)textView {
	[self editWordCount];
}

//Update the stored position of the carret within the textview it's in
-(void) updateCaretPositionInView: (VerbatmUITextView *) view {
	self.caretPosition = [view caretRectForPosition:view.selectedTextRange.end];
}

//Counts the words in the content page
-(void) editWordCount {
	self.numberOfWordsLeft = MAX_WORD_LIMIT - [self countWordsInContentPage];
	self.wordsLeftLabel.text = [NSString stringWithFormat:@"Words: %ld ", (long)self.numberOfWordsLeft];
}

//Counts the number of words that are in the page
-(NSInteger) countWordsInContentPage {
	NSUInteger words = 0;
	for(id object in self.pageElements) {
		if([object isKindOfClass:[UITextView class]]) {

			NSString * string = ((UITextView *) object).text;
			NSArray * string_array = [string componentsSeparatedByString: @" "];
			words += [string_array count];

			//Make sure to discount blanks in the array
			for (NSString * string in string_array) {
				if([string isEqualToString:@""] && words != 0) words--;
			}
			//make sure that the last word is complete by having a space after it
			if(![[string_array lastObject] isEqualToString:@""]) words --;
		} else if([object isKindOfClass:[PinchView class]]&& ((PinchView *)object).containsText) {
			NSString * string = [((PinchView *) object) getText];
			NSArray * string_array = [string componentsSeparatedByString: @" "];
			words += [string_array count];

			//Make sure to discount blanks in the array
			for (NSString * string in string_array) {
				if([string isEqualToString:@""] && words != 0) words--;
			}

			//make sure that the last word is complete by having a space after it
			if(![[string_array lastObject] isEqualToString:@""]) words --;
		}
	}
	return words;
}


#pragma mark - ScrollViews -

//adjusts the contentsize of the main view to the last element
-(void) adjustMainScrollViewContentSize
{
	UIScrollView * Sv = (UIScrollView *)[[self.pageElements lastObject] superview];
	self.mainScrollView.contentSize = CGSizeMake(0, Sv.frame.origin.y + Sv.frame.size.height + CONTENT_SIZE_OFFSET);
}

#pragma mark Scroll View actions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if(scrollView == self.mainScrollView) {
		[self showOrHidePullBarBasedOnMainScrollViewScroll];
		return;
		// is open collection
	} else if(scrollView.subviews.count > 1) {
		return;
	}

	// scrollView has a pinch view or a media tile

	if([[scrollView.subviews firstObject] conformsToProtocol:@protocol(ContentDevElementDelegate)]) {

		if(scrollView.contentOffset.x > self.defaultElementPersonalScrollViewContentOffset.x + PINCH_VIEW_DELETING_THRESHOLD || scrollView.contentOffset.x < self.defaultElementPersonalScrollViewContentOffset.x - PINCH_VIEW_DELETING_THRESHOLD){
			if(scrollView.contentOffset.x >3) {
				[(UIView<ContentDevElementDelegate>*)[scrollView.subviews firstObject] markAsDeleting:YES];
			}
		} else {
			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^ {
				[(UIView<ContentDevElementDelegate>*)[scrollView.subviews firstObject] markAsDeleting:NO];
			}];
		}
	}

}

-(void) showOrHidePullBarBasedOnMainScrollViewScroll {
	CGPoint translation = [self.mainScrollView.panGestureRecognizer translationInView:self.mainScrollView];

	if(translation.y < 0) {
		[self hidePullBarWithTransition:YES];
	}else {
		[self showPullBarWithTransition:YES];
	}
	return;
}

//make sure the object is in the right position
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
				  willDecelerate:(BOOL)decelerate {

	if(scrollView == self.mainScrollView) {
		return;
	}

	//if the delete swipe wasn't far enough then return the pinch object to the middle
	if((scrollView.contentOffset.x > LEFT_DELETE_OFFSET || scrollView.contentOffset.x < RIGHT_DELETE_OFFSET) && scrollView.subviews.count == 1) {
		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
		}];
	}

}


//called when the tile is scrolled - we see if the offset has changed
//if so we remove the view
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;

	// not the main vertical scrollbar,
	//or a scrollview with an open collection (can't swipe away anything)
	if (scrollView == self.mainScrollView || scrollView.subviews.count > 1){
		return;
	}

	MediaSelectTile * tile= Nil;
	if([[scrollView.subviews firstObject] isKindOfClass:[MediaSelectTile class]]) {
		tile = [scrollView.subviews firstObject];
	}

	if((!tile || !tile.isBaseSelector) &&
	   (self.pinchingMode == PinchingModeNone) && [self.pageElements count] >1 ) {

		//If the view is scrolled left/right and not centered
		if(scrollView.contentOffset.x != self.defaultElementPersonalScrollViewContentOffset.x) {

			//remove swiped view from mainscrollview
			//it is the only subview in this scrollview
			UIView * view = [scrollView.subviews firstObject];
			NSUInteger index = [self.pageElements indexOfObject:view];
			[scrollView removeFromSuperview];
			[self.pageElements removeObject:view];

			//if it was the top element then shift everything below
			[self shiftElementsBelowView:self.articleTitleField];

			//register deleted tile
			[self deletedTile:view withIndex:[NSNumber numberWithUnsignedLong:index]];
		}

	}else { //return the view to it's old position
		[UIView animateWithDuration:0.7 animations:^ {
			scrollView.contentOffset = self.defaultElementPersonalScrollViewContentOffset;
		}];
	}
}

//Remove keyboard when scrolling
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark - Creating New Views -

- (PinchView *) newPinchObjectBelowView:(UIView *)upperView fromView: (UIView *) view isTextView: (BOOL) isText {
	PinchView * pinchView=nil;
	NSMutableArray *media = [[NSMutableArray alloc]init];

	if(isText) {
		UITextView * textView = [[UITextView alloc]init];
		[media addObject: textView];

	} else if (view) {
		[media addObject: view];
	}

	pinchView = [[PinchView alloc] initWithRadius:self.defaultElementRadius withCenter:self.defaultElementCenter andMedia:media];

	if (pinchView) {
		[self newPinchObjectBelowView:upperView withPinchView:pinchView];
	}
	return pinchView;
}


- (PinchView *) newPinchObjectBelowView:(UIView *)upperView fromData: (id) data {
	PinchView * pinchView=nil;
	if(data) {
		NSMutableArray *media = [[NSMutableArray alloc]init];
		[media addObject: data];

		pinchView = [[PinchView alloc] initWithRadius:self.defaultElementRadius withCenter:self.defaultElementCenter andMedia:media];

	}
	if (pinchView) {
		[self newPinchObjectBelowView:upperView withPinchView:pinchView];
	}
	return pinchView;
}

// Create a horizontal scrollview displaying a pinch object from a pinchView passed in
- (void) newPinchObjectBelowView:(UIView *)upperView withPinchView: (PinchView *) pinchView {
	//thread safety
	NSLock  * lock =[[NSLock alloc] init];
	[lock lock];

	[self addTapGestureToView:pinchView];
	UIScrollView *newElementScrollView = [[UIScrollView alloc]init];
	[self formatNewElementScrollView:newElementScrollView];

	if(!upperView) {
		newElementScrollView.frame = CGRectMake(0,self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height, self.defaultElementFrame.width, self.defaultElementFrame.height);
		[self.pageElements insertObject:pinchView atIndex:0];

	}else{
		NSInteger index = [self.pageElements indexOfObject:upperView];
		UIScrollView * upperViewScrollView = (UIScrollView *)upperView.superview;

		newElementScrollView.frame = CGRectMake(upperViewScrollView.frame.origin.x, upperViewScrollView.frame.origin.y+upperViewScrollView.frame.size.height, upperViewScrollView.frame.size.width, upperViewScrollView.frame.size.height);
		[self.pageElements insertObject:pinchView atIndex:index+1];
	}

	self.index ++;//makes it that the next image is below this image just added

	[lock unlock];
	[newElementScrollView addSubview:pinchView];
	[self.mainScrollView addSubview:newElementScrollView];
	[self.pinchViewScrollViews addObject:newElementScrollView];
	[self shiftElementsBelowView:self.articleTitleField];


	//TODO: imageview's get added for some reason- so this is a quick patch that removes the views
	//don't want. The bug should be reexamined
	for (int i = 0; i < newElementScrollView.subviews.count; i++) {
		if(![newElementScrollView.subviews[i] isKindOfClass:[PinchView class]])[newElementScrollView.subviews[i] removeFromSuperview];
	}
}


//Takes two views and places one below the other with a scroll view
//Only called if the view is multimedia - not for textView!
-(void) addView:(UIView *) view underView: (UIView *) topView {

	if(!view) {
		NSLog(@"View being added should not be nil");
		return;
	}
	//create frame for the personal scrollview of the new text view
	UIScrollView * newElementPersonalScrollView = [[UIScrollView alloc]init];

	if(topView == self.articleTitleField) {
		newElementPersonalScrollView.frame = CGRectMake(0,self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.defaultElementFrame.width, self.defaultElementFrame.height);

	} else {
		newElementPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultElementFrame.width, self.defaultElementFrame.height);
	}

	newElementPersonalScrollView.delegate = self;
	[self.mainScrollView addSubview:newElementPersonalScrollView];
	[newElementPersonalScrollView addSubview:view];

	//snap the view to the top of the screen
	if(![view isKindOfClass:[MediaSelectTile class]])[self snapToTopView:view];

	//store the new view in our array
	[self storeView:view inArrayAsBelowView:topView];

	//reposition views on screen
	[self shiftElementsBelowView:view];
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

	//if we are shifting things from somewhere in the middle of the scroll view
	if([self.pageElements containsObject:view]) {

		NSInteger view_index = [self.pageElements indexOfObject:view];
		NSInteger firstYCoordinate  = view.superview.frame.origin.y + view.superview.frame.size.height;

		for(NSInteger i = (view_index+1); i < [self.pageElements count]; i++) {
			UIView * currentView = self.pageElements[i];

			CGRect frame = CGRectMake(currentView.superview.frame.origin.x, firstYCoordinate, self.view.frame.size.width,currentView.frame.size.height+ELEMENT_OFFSET_DISTANCE);

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
				currentView.superview.frame = frame;
			}];

			firstYCoordinate+= frame.size.height;
		}
	}
	//If we must shift everything from the top - we pass in the text field
	else if ([view isMemberOfClass:[UITextField class]]) {

		NSInteger firstYCoordinate  = view.frame.origin.y + view.frame.size.height + ELEMENT_OFFSET_DISTANCE;

		for(NSInteger i = 0; i < [self.pageElements count]; i++) {
			UIView * currentView = self.pageElements[i];

			CGRect frame = CGRectMake(currentView.superview.frame.origin.x, firstYCoordinate, self.defaultElementFrame.width, currentView.frame.size.height+ELEMENT_OFFSET_DISTANCE);

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
				currentView.superview.frame = frame;
			}];
			firstYCoordinate+= frame.size.height;
		}
	}

	//make sure the main scroll view can show everything
	[self adjustMainScrollViewContentSize];
}


//Shifts elements above a certain view up by the given difference
-(void) shiftElementsAboveView: (UIView *) view withDifference: (NSInteger) difference {
	NSInteger view_index = [self.pageElements indexOfObject:view];
	if(view_index != NSNotFound && view_index < self.pageElements.count) {
		for(NSInteger i = (view_index-1); i > -1; i--) {
			UIView * curr_view = self.pageElements[i];
			CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, curr_view.superview.frame.origin.y + difference, self.view.frame.size.width,view.frame.size.height+ELEMENT_OFFSET_DISTANCE);

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
				curr_view.superview.frame = frame;
			}];
		}
	}
}

//Storing new view to our array of elements
-(void) storeView: (UIView*) view inArrayAsBelowView: (UIView*) topView {
	//Ensure the view is not Nil- this will cause problems
	if(!view) return;

	if(![self.pageElements containsObject:view]) {
		if(topView && topView != self.articleTitleField) {
			NSInteger index = [self.pageElements indexOfObject:topView];
			[self.pageElements insertObject:view atIndex:(index+1)];
		}else if(topView == self.articleTitleField) {
			[self.pageElements insertObject:view atIndex:0];
		}else {
			[self.pageElements addObject:view];
		}
	}
	[self shiftElementsBelowView:topView];
	[self adjustMainScrollViewContentSize];//make sure the main scroll view can show everything
}

#pragma  mark - Handling the KeyBoard -

#pragma Remove Keyboard From Screen
//Iain
-(void) removeKeyboardFromScreen
{
	//make sure the device is landscape
	if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
	{
		if(self.sandwichWhat.isEditing)[self.sandwichWhat resignFirstResponder];
		if(self.sandwichWhere.isEditing)[self.sandwichWhere resignFirstResponder];
		if(self.articleTitleField.isEditing)[self.articleTitleField resignFirstResponder];
		[self.openEditContentView.textView resignFirstResponder];
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
					  && self.lowerPinchView && self.upperPinchView) {

				//makes no sense to pinch apart where there is already a tile
				if([self.upperPinchView isKindOfClass:[MediaSelectTile class]] ||
				   [self.lowerPinchView isKindOfClass:[MediaSelectTile class]]) {
					return;
				}

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
		self.scrollViewOfHorizontalPinching.scrollEnabled = YES;

		// Check if open collection was closed. If not rearrange
		NSArray * subviews = self.scrollViewOfHorizontalPinching.subviews;
		if(subviews.count > 1) {

			//remove the objects from their super views so that they can be readded with correct frames
			for (int i=0; i<subviews.count; i++) {
				[(UIView *)subviews[i] removeFromSuperview];
			}
			[self addPinchObjects: [NSMutableArray arrayWithArray:subviews] toScrollView: self.scrollViewOfHorizontalPinching];
		}
		self.scrollViewOfHorizontalPinching = Nil;

	} else if (self.newlyCreatedMediaTile && (sender.scale > 1 )) {

		//new media creation has failed
		if(self.newlyCreatedMediaTile.superview.frame.size.height < PINCH_DISTANCE_THRESHOLD_FOR_NEW_MEDIA_TILE_CREATION){
			[self animateRemoveNewMediaTile];
			return;
		}
		self.newlyCreatedMediaTile = Nil;
	}

	[self shiftElementsBelowView:self.articleTitleField];
	self.pinchingMode = PinchingModeNone;
}

-(void) animateRemoveNewMediaTile {
	float originalHeight = self.newlyCreatedMediaTile.frame.size.height;
	[self.pageElements removeObject:self.newlyCreatedMediaTile];
	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION/2.f animations:^{
		self.newlyCreatedMediaTile.alpha = 0.f;
		self.newlyCreatedMediaTile.frame = [self getStartFrameForNewMediaTile];
		self.newlyCreatedMediaTile.superview.frame = CGRectMake(0,self.newlyCreatedMediaTile.superview.frame.origin.y + originalHeight/2.f,0,0);
		[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
		[self shiftElementsBelowView:self.articleTitleField];

	} completion:^(BOOL finished) {
		[self.newlyCreatedMediaTile.superview removeFromSuperview];
		self.newlyCreatedMediaTile = Nil;
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
		if(self.pageElements.count < 2) return;
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
		self.scrollViewOfHorizontalPinching.pagingEnabled = NO;
		self.scrollViewOfHorizontalPinching.scrollEnabled = NO;

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
	[self moveViewsWithLeftDifference:leftDifference andRightDifference:rightDifference];
	self.horizontalPinchDistance += (leftDifference - rightDifference);

	//they have pinched enough to join the objects
	if(self.horizontalPinchDistance > HORIZONTAL_PINCH_THRESHOLD) {
		self.upperPinchView = self.lowerPinchView = nil;
		[self closeOpenCollectionInScrollView:self.scrollViewOfHorizontalPinching];
		self.pinchingMode = PinchingModeNone;
	}
}


//moves the views in the scrollview of the opened collection
-(void) moveViewsWithLeftDifference: (int) leftDifference andRightDifference: (int) rightDifference {

	NSArray * pinchViews = self.scrollViewOfHorizontalPinching.subviews;
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		for(int i = 0; i < pinchViews.count; i++) {
			CGRect oldFrame = ((PinchView *)pinchViews[i]).frame;

			if(oldFrame.origin.x < self.leftTouchPointInHorizontalPinch.x+ self.scrollViewOfHorizontalPinching.contentOffset.x) {

				CGRect newFrame = CGRectMake(oldFrame.origin.x + leftDifference , oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
				((PinchView *)pinchViews[i]).frame = newFrame;
			} else {

				CGRect newFrame = CGRectMake(oldFrame.origin.x + rightDifference , oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
				((PinchView *)pinchViews[i]).frame = newFrame;
			}
		}
	}];
}

-(void) closeAllOpenCollections {
	for (UIScrollView* scrollView in self.pinchViewScrollViews) {
		[self closeOpenCollectionInScrollView:scrollView];
	}
}

-(void)closeOpenCollectionInScrollView:(UIScrollView*)openCollectionScrollView {

	NSArray * pinchViews = openCollectionScrollView.subviews;
	if ([pinchViews count] < 2) return;

	//make sure the pullbar is showing when things are pinched together
	[self showPullBarWithTransition:YES];

	CGRect newFrame = CGRectMake(self.defaultElementCenter.x - self.defaultElementRadius, self.defaultElementCenter.y - self.defaultElementRadius, self.defaultElementRadius*2.f, self.defaultElementRadius*2.f);

	// animate all pinch views towards each other

	PinchView* placeholder = [[PinchView alloc] init];
	[self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:pinchViews[0]] withObject:placeholder];

	PinchView * collectionPinchView = [PinchView pinchTogether:[NSMutableArray arrayWithArray:pinchViews]];
	[collectionPinchView specifyFrame:newFrame];
	[self addTapGestureToView:collectionPinchView];

	[self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:placeholder] withObject:collectionPinchView];

	for(PinchView* pinchView in pinchViews) {
		[pinchView removeFromSuperview];
	}
	openCollectionScrollView.contentSize = self.defaultElementPersonalScrollViewContentSize;
	openCollectionScrollView.contentOffset = self.defaultElementPersonalScrollViewContentOffset;
	[openCollectionScrollView addSubview:collectionPinchView];
	//Turn paging back on because now it's one element
	openCollectionScrollView.pagingEnabled =YES;
}

#pragma mark - Vertical Pinching

//If it's a verticle pinch- find which media you're pinching together or apart
-(void) handleVerticlePinchGestureBegan: (UIPinchGestureRecognizer *)sender
{
	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
	CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];

	CGPoint midPoint = [self findMidPointBetween:touch1 and:touch2];

	if(touch1.y>touch2.y)
	{
		[self findElementsFromPinchPoint:midPoint andLowerTouchPoint: touch1];
		self.upperTouchPointInVerticalPinch = touch2;
		self.lowerTouchPointInVerticalPinch = touch1;
	}else
	{
		[self findElementsFromPinchPoint:midPoint andLowerTouchPoint:touch2];
		self.lowerTouchPointInVerticalPinch = touch2;
		self.upperTouchPointInVerticalPinch = touch1;
	}

	//if it's a pinch apart then create the media tile
	if(sender.scale > 1) [self createNewViewToRevealBetweenPinchViews];
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
	self.upperPinchView.superview.frame = [self newVerticalTranslationFrameForView:self.upperPinchView andChange:changeInPosition];
	[self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
	return changeInPosition;
}

//handle the translation of the lower view
//returns change in position of lower view
-(float) handleLowerViewFromTouch: (CGPoint) touch {

	float changeInPosition;
	changeInPosition = touch.y - self.lowerTouchPointInVerticalPinch.y;
	self.lowerTouchPointInVerticalPinch = touch;
	self.lowerPinchView.superview.frame = [self newVerticalTranslationFrameForView:self.lowerPinchView andChange:changeInPosition];
	[self shiftElementsBelowView:self.lowerPinchView];
	return changeInPosition;
}


//Takes a change in vertical position and constructs the frame for the views new position
-(CGRect) newVerticalTranslationFrameForView: (UIView*)view andChange: (float) changeInPosition {
	CGRect frame= CGRectMake(view.superview.frame.origin.x, view.superview.frame.origin.y+changeInPosition, view.superview.frame.size.width, view.superview.frame.size.height);
	return frame;
}

#pragma mark Pinching Apart two Pinch views, Adding media tile

-(void) createNewViewToRevealBetweenPinchViews
{
	CGRect frame = [self getStartFrameForNewMediaTile];
	self.newlyCreatedMediaTile = [[MediaSelectTile alloc]initWithFrame:frame];
	self.newlyCreatedMediaTile.delegate = self;
	self.newlyCreatedMediaTile.alpha = 0; //start it off as invisible
	self.newlyCreatedMediaTile.isBaseSelector = NO;
	[self addMediaTile: self.newlyCreatedMediaTile underView: self.upperPinchView];
}

-(CGRect) getStartFrameForNewMediaTile {
	return CGRectMake(self.baseMediaTileSelector.frame.origin.x + (self.baseMediaTileSelector.frame.size.width/2),0, 0, 0);
}

-(void) addMediaTile: (MediaSelectTile *) mediaView underView: (UIView *) topView {
	//create frame for the personal scrollview of the new text view
	UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
	newPersonalScrollView.frame = [self getStartFrameForNewMediaTileScrollViewUnderView:topView];

	newPersonalScrollView.delegate = self;
	if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
	if(mediaView) [newPersonalScrollView addSubview:mediaView];
	[self storeView:mediaView inArrayAsBelowView:topView];

	for(int i=0; i<newPersonalScrollView.subviews.count;i++) {
		if([newPersonalScrollView.subviews[i] isMemberOfClass:[UIImageView class]]) {
			[newPersonalScrollView.subviews[i] removeFromSuperview];
		}
	}
}

-(CGRect) getStartFrameForNewMediaTileScrollViewUnderView: (UIView *) topView  {
	return CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.view.frame.size.width,0);
}

-(void) handleRevealOfNewMediaViewWithGesture: (UIPinchGestureRecognizer *)gesture andChangeInTopViewPosition:(float)changeInTopViewPosition andChangeInBottomViewPosition:(float) changeInBottomViewPosition {

	float absChangeInTopViewPosition = fabs(changeInTopViewPosition);
	float absChangeInBottomViewPosition = fabs(changeInBottomViewPosition);
	float totalChange = absChangeInBottomViewPosition + absChangeInTopViewPosition;
	float widthToHeightRatio = self.baseMediaTileSelector.frame.size.width/self.baseMediaTileSelector.frame.size.height;
	float changeInWidth = widthToHeightRatio * totalChange;

	if(self.newlyCreatedMediaTile.superview.frame.size.height < PINCH_DISTANCE_THRESHOLD_FOR_NEW_MEDIA_TILE_CREATION) {

		//construct new frames for view and personal scroll view
		self.newlyCreatedMediaTile.frame = CGRectMake(self.newlyCreatedMediaTile.frame.origin.x - changeInWidth/2.f,
												 self.newlyCreatedMediaTile.frame.origin.y,
												 self.newlyCreatedMediaTile.frame.size.width + changeInWidth,
												 self.newlyCreatedMediaTile.frame.size.height + totalChange);

		//have it gain visibility as it grows
		self.newlyCreatedMediaTile.alpha = self.newlyCreatedMediaTile.frame.size.height/self.baseMediaTileSelector.frame.size.height;

		self.newlyCreatedMediaTile.superview.frame = CGRectMake(self.newlyCreatedMediaTile.superview.frame.origin.x,
														   self.newlyCreatedMediaTile.superview.frame.origin.y + changeInTopViewPosition,
														   self.newlyCreatedMediaTile.superview.frame.size.width + changeInWidth,
														   self.newlyCreatedMediaTile.superview.frame.size.height + totalChange);


		//format the scrollview accordingly
		[self formatNewElementScrollView:(UIScrollView *)self.newlyCreatedMediaTile.superview];
		[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
		[self.newlyCreatedMediaTile setNeedsDisplay];

	}
	//the distance is enough that we can just animate the rest
	else {

		gesture.enabled = NO;
		gesture.enabled = YES;

		[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{

			self.newlyCreatedMediaTile.frame = self.baseMediaTileSelector.frame;
			self.newlyCreatedMediaTile.alpha = 1; //make it fully visible

			self.newlyCreatedMediaTile.superview.frame = CGRectMake(self.newlyCreatedMediaTile.superview.frame.origin.x,
															   self.newlyCreatedMediaTile.superview.frame.origin.y + changeInTopViewPosition,
															   self.baseMediaTileSelector.frame.size.width, self.baseMediaTileSelector.frame.size.height);

			[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
			[self shiftElementsBelowView:self.articleTitleField];
		} completion:^(BOOL finished) {
			[self shiftElementsBelowView:self.articleTitleField];
			gesture.enabled = NO;
			gesture.enabled = YES;
			self.pinchingMode = PinchingModeNone;

		}];
	}
}

//adds the appropriate parameters to a generic scrollview
-(void)formatNewElementScrollView:(UIScrollView *) scrollview {

	scrollview.scrollEnabled= YES;
	scrollview.delegate = self;
	scrollview.pagingEnabled= YES;
	scrollview.showsHorizontalScrollIndicator = NO;
	scrollview.showsVerticalScrollIndicator = NO;
	scrollview.contentOffset = CGPointMake(self.defaultElementPersonalScrollViewContentOffset.x, self.defaultElementPersonalScrollViewContentOffset.y);
	scrollview.contentSize = self.defaultElementPersonalScrollViewContentSize;
}

#pragma mark Pinch Apart Failed

//Removes the new view being made and resets page
-(void) clearNewMediaView
{
	[self.newlyCreatedMediaTile.superview removeFromSuperview];
	[self.pageElements removeObject:self.newlyCreatedMediaTile];
	[self shiftElementsBelowView:self.articleTitleField];
	//stop pointing to the object so it is freed from memory
	self.newlyCreatedMediaTile = nil;
}

#pragma mark Pinching Views together

-(void) pinchObjectsTogether {
	if(![self sufficientOverlapBetweenPinchedObjects]
	   || ![self tilesOkToPinch]) {
		return;
	}

	UIScrollView * newCollectionScrollView = (UIScrollView *)self.upperPinchView.superview;
	NSMutableArray* pinchViewArray = [[NSMutableArray alloc] initWithObjects:self.upperPinchView,self.lowerPinchView, nil];
	PinchView * pinchView = [PinchView pinchTogether:pinchViewArray];

	[self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:self.upperPinchView] withObject:pinchView];
	[self.pageElements removeObject:self.lowerPinchView];
	[self.upperPinchView removeFromSuperview];
	[self.lowerPinchView.superview removeFromSuperview];
	[self.lowerPinchView removeFromSuperview];

	//format your scrollView and add pinch view
	[self addTapGestureToView:pinchView];
	[newCollectionScrollView addSubview:pinchView];
	self.lowerPinchView = self.upperPinchView = nil;
	self.pinchingMode = PinchingModeNone;
	[self shiftElementsBelowView:self.articleTitleField];
	//make sure the pullbar is showing when things are pinched together
	[self showPullBarWithTransition:YES];
}


#pragma mark - Identify views involved in pinch


-(CGPoint) findMidPointBetween: (CGPoint) touch1 and: (CGPoint) touch2 {
	CGPoint midPoint = CGPointZero;
	midPoint.x = (touch1.x + touch2.x)/2;
	midPoint.y = (touch1.y + touch2.y)/2;
	return midPoint;
}

-(UIScrollView *)findElementScrollViewFromPoint: (CGPoint) point {

	NSInteger distanceTraveled = 0;
	UIScrollView * wantedView;

	//Runs through the view positions to find the first one that passes the touch point
	for (UIView * view in self.pageElements) {

		UIView * superview = view.superview;
		if([superview isKindOfClass:[UIScrollView class]]) {

			if(!distanceTraveled) distanceTraveled = superview.frame.origin.y;
			distanceTraveled += superview.frame.size.height;
			if(distanceTraveled > point.y) {
				wantedView = (UIScrollView *)view.superview;
				break;
			}
		}
	}
	//Cannot pinch a single pinch view open or close
	if(wantedView.subviews.count < 2) return Nil;
	return wantedView;
}

//Takes a midpoint and a lower touch point and finds the two views that were being interacted with
-(void) findElementsFromPinchPoint: (CGPoint) pinchPoint andLowerTouchPoint: (CGPoint) lowerTouchPoint
{

	UIView * wantedView = [self findFirstPinchViewFromPinchPoint:pinchPoint];

	if(wantedView)//make sure we have a view
	{
		//heuristic to more accurately identify which views we want
		if([self point: lowerTouchPoint isInRangeOfView:wantedView]) //checks to see if we have got the top textview or the lower textview -improves accuracy
		{
			self.index = [self.pageElements indexOfObject:wantedView];

			if(self.pageElements.count>(self.index) && self.index != NSNotFound)/*make sure the indexes are in range*/
			{
				self.lowerPinchView = wantedView;
			}
			if(self.pageElements.count>(self.index-1) && self.index != NSNotFound)
			{
				self.upperPinchView = self.pageElements[self.index -1];
			}
		}else
		{
			self.index = [self.pageElements indexOfObject:wantedView];
			if(self.index != NSNotFound)self.lowerPinchView = self.pageElements[self.index+1];

			if(self.pageElements.count>(self.index) && self.index != NSNotFound)/*make sure the indexes are in range*/
			{
				self.upperPinchView = self.pageElements[self.index];
			}
			if(self.pageElements.count>(self.index+1)&& self.index != NSNotFound)
			{
				self.lowerPinchView = self.pageElements[self.index+1];
			}
		}
	}
}


//Iain
//Runs through and identifies the first view involved in teh pinch gesture
-(UIView *) findFirstPinchViewFromPinchPoint: (CGPoint) pinchPoint
{
	NSInteger distanceTraveled = 0;
	UIView * wantedView;
	//Runs through the view positions to find the first one that passes the midpoint- we assume the midpoint is
	for (UIView * view in self.pageElements)
	{
		UIView * superview = view.superview;//should be a scrollview

		if([superview isKindOfClass:[UIScrollView class]])
		{
			if(distanceTraveled == 0) distanceTraveled =superview.frame.origin.y;

			distanceTraveled += superview.frame.size.height;

			if(distanceTraveled > pinchPoint.y)
			{
				wantedView = view;
				break;
			}
		}
	}
	return wantedView;
}

//Iain
//checks to see if we have got the top textview or the lower textview -improves accuracy
-(BOOL) point: (CGPoint) lowerTouchPoint isInRangeOfView: (UIView *) wantedView
{
	return (lowerTouchPoint.y > wantedView.superview.frame.origin.y && lowerTouchPoint.y < (wantedView.superview.frame.origin.y + wantedView.superview.frame.size.height));
}


//checks if the two selected tiles should be pinched together
-(BOOL) tilesOkToPinch {
	if([self.upperPinchView isKindOfClass:[PinchView class]]  && [self.lowerPinchView isKindOfClass:[PinchView class]]) {
		if(!((PinchView *)self.upperPinchView).isCollection || !((PinchView *)self.lowerPinchView).isCollection) {
			return true;
		}
	}
	return false;
}

-(BOOL)sufficientOverlapBetweenPinchedObjects
{
	if(self.upperPinchView.superview.frame.origin.y+(self.upperPinchView.superview.frame.size.height/2)>= self.lowerPinchView.superview.frame.origin.y)
		return true;
	return false;
}



#pragma mark - Media Tile Options -

#pragma mark Text
-(void) textButtonPressedOnTile: (MediaSelectTile*) tile {
	NSInteger index = [self.pageElements indexOfObject:tile];
	self.index = (index-1);
	if (self.index >= 0) {
		//TODO this should only be created if user enters text before pressing done
		UIView *upperView = [self.pageElements objectAtIndex:(self.index)];
		[self newPinchObjectBelowView:upperView fromView: nil isTextView:YES];
		[self createEditContentViewFromPinchView:self.pageElements[index] andTextView:[[VerbatmUITextView alloc]init]];
	}else {
		[self newPinchObjectBelowView:nil fromView: nil isTextView:YES];
		[self createEditContentViewFromPinchView:self.pageElements[0] andTextView:[[VerbatmUITextView alloc]init]];
	}
	if (!tile.isBaseSelector) {
		[self clearNewMediaView];
	}
}

-(void) multiMediaButtonPressedOnTile: (MediaSelectTile*) tile {
	NSInteger index = [self.pageElements indexOfObject:tile];
	self.index = (index-1);
	[self presentEfficientGallery];
	if (!tile.isBaseSelector) {
		[self clearNewMediaView];
	}
}

-(UIView *) findSecondToLastElementInPageElements
{
	if(!self.pageElements.count) return nil;

	unsigned long last_index =  self.pageElements.count -1;

	if(last_index) return self.pageElements[last_index -1];
	return nil;
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
			if(self.pageElements.count==0 || [sender numberOfTouches] != 1) {
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

// Finds first view that contains location of press and sets it as the selectedView
-(void) findSelectedViewFromSender:(UILongPressGestureRecognizer *)sender {

	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];

	self.selectedView_PAN = Nil;
	for (int i=0; i<self.pageElements.count; i++) {
		UIView * view = ((UIView *)self.pageElements[i]).superview;
		UIView * first_view = ((UIView *)self.pageElements[0]).superview;

		//make sure touch is not above the first view
		if (touch1.y >= first_view.frame.origin.y ) {
			//we stop when we find the first one
			if((view.frame.origin.y+view.frame.size.height)>touch1.y) {
				if([self.pageElements[i] isKindOfClass:[UIView class]]
				   && [self.pageElements[i] conformsToProtocol:@protocol(ContentDevElementDelegate)]) {
					self.selectedView_PAN = self.pageElements[i];
					[self.mainScrollView bringSubviewToFront:self.selectedView_PAN.superview];
				}
				return;
			}
		}
	}
}

//
-(void) selectItem:(UILongPressGestureRecognizer *)sender {
	[self findSelectedViewFromSender:sender];
	//if we didn't find the view then leave
	if (!self.selectedView_PAN
		|| ([self.selectedView_PAN isKindOfClass:[MediaSelectTile class]]
	   && ((MediaSelectTile *)self.selectedView_PAN).isBaseSelector)) {
		return;
	}

	self.startLocationOfTouchPoint_PAN = [sender locationOfTouch:0 inView:self.mainScrollView];
	self.originalFrameBeforeLongPress = self.selectedView_PAN.superview.frame;

	[self.selectedView_PAN markAsSelected:YES];
}

-(void) moveItem:(UILongPressGestureRecognizer *)sender {
	if (!self.selectedView_PAN || ([self.selectedView_PAN isKindOfClass:[MediaSelectTile class]] && ((MediaSelectTile *)self.selectedView_PAN).isBaseSelector)) return;//if we didn't find the view then leave

	CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
	NSInteger y_differrence  = touch1.y - self.startLocationOfTouchPoint_PAN.y;
	self.startLocationOfTouchPoint_PAN = touch1;

	//ok so move the view up or down by the amount the finger has moved
	CGRect newFrame = CGRectMake(self.selectedView_PAN.superview.frame.origin.x, self.selectedView_PAN.superview.frame.origin.y + y_differrence, self.selectedView_PAN.superview.frame.size.width, self.selectedView_PAN.superview.frame.size.height);
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{
		self.selectedView_PAN.superview.frame = newFrame;
	}] ;

	NSInteger view_index = [self.pageElements indexOfObject:self.selectedView_PAN];
	UIView * topView=Nil;
	UIView * bottomView=Nil;

	if(view_index !=0)
	{
		topView  = self.pageElements[view_index-1];
		if(self.selectedView_PAN != [self.pageElements lastObject])
		{
			bottomView = self.pageElements[view_index +1];
		}
	}else if (view_index==0)
	{
		bottomView = self.pageElements[view_index +1];
	}else if (self.selectedView_PAN == [self.pageElements lastObject])
	{
		topView  = self.pageElements[view_index-1];
	}

	if(topView && bottomView)
	{
		//object moving up
		if(newFrame.origin.y +(newFrame.size.height/2) > topView.superview.frame.origin.y && newFrame.origin.y+(newFrame.size.height/2) < (topView.superview.frame.origin.y + topView.superview.frame.size.height))
		{
			[self swapObject:self.selectedView_PAN andObject:topView];//exchange their positions in page elements array

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{
				self.potentialFrameAfterLongPress = topView.superview.frame;
				topView.superview.frame = CGRectMake(self.originalFrameBeforeLongPress.origin.x, self.originalFrameBeforeLongPress.origin.y, topView.superview.frame.size.width, topView.superview.frame.size.height);
				self.originalFrameBeforeLongPress = self.potentialFrameAfterLongPress;
			}];

			//object moving down
		}else if(newFrame.origin.y + (newFrame.size.height/2) +CENTERING_OFFSET_FOR_TEXT_VIEW > bottomView.superview.frame.origin.y && newFrame.origin.y+ (newFrame.size.height/2)+CENTERING_OFFSET_FOR_TEXT_VIEW < (bottomView.superview.frame.origin.y + bottomView.superview.frame.size.height))
		{

			if(bottomView == self.baseMediaTileSelector) return;

			[self swapObject:self.selectedView_PAN andObject:bottomView];//exchange their positions in page elements array

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{
				self.potentialFrameAfterLongPress = bottomView.superview.frame;
				bottomView.superview.frame = CGRectMake(self.originalFrameBeforeLongPress.origin.x, self.originalFrameBeforeLongPress.origin.y, bottomView.superview.frame.size.width, bottomView.superview.frame.size.height);
				self.originalFrameBeforeLongPress = self.potentialFrameAfterLongPress;
			}];
		}

		//move the offest of the main scroll view
		if(self.mainScrollView.contentOffset.y > self.selectedView_PAN.superview.frame.origin.y -(self.selectedView_PAN.superview.frame.size.height/2) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0))
		{
			CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET);

			[UIView animateWithDuration:0.2 animations:^{
				self.mainScrollView.contentOffset = newOffset;
			}];

		} else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_PAN.superview.frame.origin.y + self.selectedView_PAN.superview.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height)
		{
			CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET);

			[UIView animateWithDuration:0.2 animations:^{
				self.mainScrollView.contentOffset = newOffset;
			}];
		}
	}else if(view_index ==0 && bottomView != self.baseMediaTileSelector)
	{
		if(newFrame.origin.y + (newFrame.size.height/2) > bottomView.superview.frame.origin.y && newFrame.origin.y+ (newFrame.size.height/2) < (bottomView.superview.frame.origin.y + bottomView.superview.frame.size.height))
		{
			[self swapObject:self.selectedView_PAN andObject:bottomView];//exchange their positions in page elements array

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
				self.potentialFrameAfterLongPress = bottomView.superview.frame;
				bottomView.superview.frame = CGRectMake(self.originalFrameBeforeLongPress.origin.x, self.originalFrameBeforeLongPress.origin.y, bottomView.superview.frame.size.width, bottomView.superview.frame.size.height);
				self.originalFrameBeforeLongPress = self.potentialFrameAfterLongPress;
			}];
		}

		//move the offest of the main scroll view
		if(self.mainScrollView.contentOffset.y > self.selectedView_PAN.superview.frame.origin.y -(self.selectedView_PAN.superview.frame.size.height/2) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0))
		{
			CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET);

			[UIView animateWithDuration:0.2 animations:^{
				self.mainScrollView.contentOffset = newOffset;
			}];

		} else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_PAN.superview.frame.origin.y + self.selectedView_PAN.superview.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height)
		{
			CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET);

			[UIView animateWithDuration:0.2 animations:^{
				self.mainScrollView.contentOffset = newOffset;
			}];
		}

	}else if (self.selectedView_PAN == [self.pageElements lastObject])
	{
		if(newFrame.origin.y +(newFrame.size.height/2) > topView.superview.frame.origin.y && newFrame.origin.y+(newFrame.size.height/2) < (topView.superview.frame.origin.y + topView.superview.frame.size.height))
		{
			[self swapObject:self.selectedView_PAN andObject:topView];//exchange their positions in page elements array

			[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
				self.potentialFrameAfterLongPress = topView.superview.frame;
				topView.superview.frame = CGRectMake(self.originalFrameBeforeLongPress.origin.x, self.originalFrameBeforeLongPress.origin.y, topView.superview.frame.size.width, topView.superview.frame.size.height);

				self.originalFrameBeforeLongPress = self.potentialFrameAfterLongPress;
			}];

		}

		//move the offest of the main scroll view
		if(self.mainScrollView.contentOffset.y > self.selectedView_PAN.superview.frame.origin.y -(self.selectedView_PAN.superview.frame.size.height/2) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0))
		{
			CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET);

			[UIView animateWithDuration:0.2 animations:^{
				self.mainScrollView.contentOffset = newOffset;
			}];

		} else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_PAN.superview.frame.origin.y + self.selectedView_PAN.superview.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height)
		{
			CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET);

			[UIView animateWithDuration:0.2 animations:^{
				self.mainScrollView.contentOffset = newOffset;
			}];
		}
	}
}

// If the selected item was a pinch view, deselect it and set its final position in relation to other views
-(void) finishMovingSelectedItem {

	//if we didn't find the view then leave
	if (!self.selectedView_PAN) return;

	if([self.selectedView_PAN isKindOfClass:[MediaSelectTile class]] && ((MediaSelectTile *)self.selectedView_PAN).isBaseSelector) {
		//sanitize for next run
		self.selectedView_PAN = Nil;
		return;
	}

	CGRect newFrame = CGRectMake(self.originalFrameBeforeLongPress.origin.x, self.originalFrameBeforeLongPress.origin.y, self.selectedView_PAN.superview.frame.size.width, self.selectedView_PAN.superview.frame.size.height);
	self.selectedView_PAN.superview.frame = newFrame;

	[self.selectedView_PAN markAsSelected:NO];

	//sanitize for next run
	self.selectedView_PAN = Nil;

	[self shiftElementsBelowView:self.articleTitleField];
	[self adjustMainScrollViewContentSize];
}

//swaps to objects in the page elements array
-(void) swapObject: (UIView *) obj1 andObject: (UIView *) obj2
{
	NSInteger index1 = [self.pageElements indexOfObject:obj1];
	NSInteger index2 = [self.pageElements indexOfObject:obj2];
	[self.pageElements replaceObjectAtIndex:index1 withObject:obj2];
	[self.pageElements replaceObjectAtIndex:index2 withObject:obj1];
}


#pragma mark- MIC

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	//return supported orientation masks
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- memory handling -
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (void)dealloc
{
	//tune out of nsnotification
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Undo implementation -

-(void)deletedTile: (UIView *) tile withIndex: (NSNumber *) index
{
	if ([self.pageElements count] <= 1) {
		[self sendRemovedAllMediaNotification];
	}
	if(!tile) return;//make sure there is something to delete
	[tile removeFromSuperview];
	[self.tileSwipeViewUndoManager registerUndoWithTarget:self selector:@selector(undoTileDelete:) object:@[tile, index]];
	[self showPullBarWithTransition:YES];//show the pullbar so that they can undo
}

-(void) sendRemovedAllMediaNotification {
	NSNotification *notification = [[NSNotification alloc]initWithName:NOTIFICATION_REMOVED_ALL_MEDIA object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)undoTileDeleteSwipe: (NSNotification *) notification
{
	[self.tileSwipeViewUndoManager undo];
}


#pragma mark Undo tile swipe

-(void) undoTileDelete: (NSArray *) tileAndInfo
{
	UIView * view = tileAndInfo[0];
	NSNumber * index = tileAndInfo[1];

	if([view isKindOfClass:[PinchView class]]) {
		[((PinchView<ContentDevElementDelegate>*)view) markAsDeleting:NO];
	}

	[self returnObject:[PinchView pinchObjectFromPinchObject:(PinchView *)view] ToDisplayAtIndex:index.integerValue];
}

-(void)returnObject: (UIView *) view ToDisplayAtIndex:(NSInteger) index{

	UIScrollView * newSV = [[UIScrollView  alloc] init];

	if(index)
	{
		UIScrollView * topSv = (UIScrollView *)((UIView *)self.pageElements[(index -1)]).superview;
		newSV.frame = CGRectMake(topSv.frame.origin.x, topSv.frame.origin.y+ topSv.frame.size.height, topSv.frame.size.width, topSv.frame.size.height);

	}else if (!index)
	{
		newSV.frame = CGRectMake(0,self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height, self.defaultElementFrame.width, self.defaultElementFrame.height);
	}

	[self.pageElements insertObject:view atIndex:index];
	[self formatNewElementScrollView:newSV];
	[newSV addSubview:view];//expecting the object to have kept its old frame
	[self.mainScrollView addSubview:newSV];
	[self shiftElementsBelowView:self.articleTitleField];
	[self addTapGestureToView:(PinchView *)view];
}


#pragma - mainScrollView handler -
-(void)setMainScrollViewEnabled:(BOOL) enabled {

	if(enabled) {
		self.mainScrollView.scrollEnabled = enabled;
	} else {
		self.mainScrollView.contentOffset = CGPointMake(0, 0);
		self.mainScrollView.scrollEnabled = enabled;
	}
}


#pragma mark - Open Element Collection -

#pragma mark Snap Item to the top

//give me a view and I will snap it to the top of the screen
-(void)snapToTopView: (UIView *) view {
	UIScrollView * scrollview = (UIScrollView *) view.superview;
	int yDifference = scrollview.frame.origin.y - self.mainScrollView.contentOffset.y;

	[UIView animateWithDuration:0.2 animations:^{
		self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + yDifference);
	}];

}


#pragma mark - Sense Tap Gesture -
#pragma mark EditContentView

-(void) addTapGestureToEditContentView: (EditContentView *) isv
{
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeEditContentView:)];

	if(isv.gestureView)[isv.gestureView addGestureRecognizer:tap];
	else [isv addGestureRecognizer:tap];
}

-(void) removeEditContentView: (UITapGestureRecognizer *) sender
{
	if (!self.openEditContentView) {
		return;
	}
	if(self.openImagePinchView.containsText)
	{
		if([self.openEditContentView.textView.text isEqualToString:@""])
		{
			[self.openImagePinchView.superview removeFromSuperview];
			[self.pageElements removeObject:self.openImagePinchView];
			[self shiftElementsBelowView:self.articleTitleField];
		}else
		{
			[self.openImagePinchView changeText:self.openEditContentView.textView];
		}
	}
	[self.openEditContentView.textView resignFirstResponder];

	//if there is a video lets stop it
	if (self.openEditContentView.videoView) {
		[self.openEditContentView.videoView pauseVideo];
	}
	[self.openEditContentView removeFromSuperview];
	[self showPullBarWithTransition:NO];
	self.openEditContentView = nil;

	//makes sure the vidoes are playing..may need to make more efficient
	[self playVideos];
	[self.openImagePinchView renderMedia];
}

#pragma mark EditContentView
-(void)addTapGestureToView: (PinchView *) pinchView
{
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectTapped:)];
	[pinchView addGestureRecognizer:tap];
}

-(void) pinchObjectTapped:(UITapGestureRecognizer *) sender {

	//only accept touches from pinch objects
	if(![sender.view isKindOfClass:[PinchView class]]) {
		return;
	}

	PinchView * pinch_object = (PinchView *)sender.view;

	//checks if there is anything to open by telling you if the element has multiple things in it
	if(pinch_object.hasMultipleMedia)
	{
		[self openCollection:pinch_object];
	}
	//tap to open an element for viewing or editing
	else if(!pinch_object.isCollection) {

		NSMutableArray * array = [pinch_object mediaObjects];
		//could be textview or customimageview
		UIView* mediaView = [array firstObject];

		if([mediaView isKindOfClass:[UITextView class]]) {

			[self createEditContentViewFromPinchView:pinch_object andTextView:(VerbatmUITextView *)mediaView];
		} else if([mediaView isKindOfClass:[NSData class]]) {
			[self createEditContentViewFromPinchView:pinch_object andImageView:(NSData *)mediaView];
		} else if([mediaView isKindOfClass:[AVAsset class]]) {
			[self createEditContentViewFromPinchView:pinch_object andVideo:(AVAsset *)mediaView];
		}

		//when things are offscreen then pause all videos
		[self pauseAllVideos];
		//make sure the pullbar is not available
		[self hidePullBarWithTransition:NO];
	}
}

-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andVideo: (AVAsset*) videoAsset {
	EditContentView * editContentView = [[EditContentView alloc] initCustomViewWithFrame:self.view.bounds ];

	[self.view addSubview:editContentView];
	[editContentView addVideo:videoAsset];

	[self addTapGestureToEditContentView:editContentView];
	self.openEditContentView = editContentView;
	self.openImagePinchView = pinchView;
}

-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andImageView: (NSData*)imageView {

	EditContentView * editContentView = [[EditContentView alloc] initCustomViewWithFrame:self.view.bounds ];

	[self.view addSubview:editContentView];
	[editContentView addImage:imageView];

	[self addTapGestureToEditContentView:editContentView];
	self.openEditContentView = editContentView;
	self.openImagePinchView = pinchView;
}

-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andTextView: (VerbatmUITextView *) textView
{
	if (!textView) {
		return; //TODO: error message
	}
	EditContentView * textScroll = [[EditContentView alloc ]initCustomViewWithFrame:self.view.bounds];

	[self.view addSubview:textScroll];
	[textScroll createTextViewFromTextView: textView];
	textScroll.textView.delegate = self;
	[textScroll.textView becomeFirstResponder];
	[self addTapGestureToEditContentView:textScroll];
	self.openEditContentView = textScroll;
	self.openImagePinchView = pinchView;
}

#pragma mark Open Collection
-(void)openCollection: (PinchView *) collection
{
	NSMutableArray * elementArray = [PinchView openCollection:collection];
	UIScrollView * scrollView = (UIScrollView *)collection.superview;
	scrollView.pagingEnabled = NO;
	[collection removeFromSuperview];//clear the scroll view. It's about to be filled by the array's elements
	[self addPinchObjects:elementArray toScrollView: scrollView];
	[self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:collection] withObject:elementArray[0]];
}


-(void) addPinchObjects:(NSMutableArray *) array toScrollView: (UIScrollView *) sv
{
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		int x_position = ELEMENT_OFFSET_DISTANCE;
		for(int i = 0; i< array.count; i++)
		{
			PinchView * pinch_view = array[i];
			CGRect new_frame =CGRectMake(x_position, ELEMENT_OFFSET_DISTANCE/2, self.defaultElementRadius*2.f, self.defaultElementRadius*2.f);
			pinch_view.autoresizesSubviews = YES;
			[pinch_view specifyFrame:new_frame];
			[sv addSubview:pinch_view];
			//now every open pinch collection can have it's objects opened
			[self addTapGestureToView:pinch_view];
			x_position += pinch_view.frame.size.width + ELEMENT_OFFSET_DISTANCE;
			[pinch_view renderMedia];
		}
		sv.contentSize = CGSizeMake(x_position, sv.contentSize.height);
	}];
}

#pragma mark - Send Picture Notification -

//tells our other class to hide the pullbar or to show it depending on where we are
-(void) hidePullBarWithTransition: (BOOL) withTransition {
	NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_HIDE_PULLBAR object:nil userInfo:@{WITH_TRANSITION: @(withTransition)}];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)showPullBarWithTransition: (BOOL) withTransition {
	NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_SHOW_PULLBAR object:nil userInfo:@{WITH_TRANSITION: @(withTransition)}];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - Clean up Content Page -
//we clean up the content page if we press publish or simply want to reset everything
//all the text views are cleared and all the pinch objects are cleared
-(void)cleanUpNotification
{
	[self cleanUp];
}

-(void)cleanUp
{
	[self.pageElements removeAllObjects];
	[self removeCreationObjectsFromScrollview];
	[self clearTextFields];
	self.baseMediaTileSelector = nil;//make sure this is set to nil so that we can create a new base selector
	[self createBaseSelector];

}

-(void)clearTextFields
{
	self.sandwichWhat.text = @"";
	self.sandwichWhere.text = @"";
	self.articleTitleField.text =@"";
}

-(void)removeCreationObjectsFromScrollview
{
	for(UIView * view in self.mainScrollView.subviews)
	{
		if([view isKindOfClass:[UIScrollView class]])
		{
			[view removeFromSuperview];
		}
	}
}


#pragma mark -New Gallery Implementaiton-

-(void)presentEfficientGallery
{

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

-(void)addAssetToView:(id)asset
{
	NSLock  * lock =[[NSLock alloc] init];
	//thread safety
	[lock lock];
	UIView * topView;
	if(self.index==-1 || self.pageElements.count==1)topView = nil;
	else topView = self.pageElements[self.index];
	[lock unlock];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self newPinchObjectBelowView:topView fromData:asset];
	});


}


//add assets from picker to our scrollview
-(void)presentAssets:(NSArray *)phassets
{
	PHImageManager * iman = [[PHImageManager alloc] init];
	for(PHAsset * asset in phassets)//store local identifiers so we can querry the nsassets
	{

		if(asset.mediaType==PHAssetMediaTypeImage)
		{
			[iman requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
				// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
				dispatch_async(dispatch_get_main_queue(), ^{
					[self addAssetToView: imageData];
				});
			}];
		}else
		{
			[iman requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
				// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
				dispatch_async(dispatch_get_main_queue(), ^{
					[self addAssetToView:asset];
				});
			}];
		}
	}
}


- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray {

	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
		[self presentAssets:assetArray];
	}];

	if ([assetArray count] > 0) {
		[self sendAddedMediaNotification];
	}

	NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);
}

-(void) sendAddedMediaNotification {
	NSNotification *notification = [[NSNotification alloc]initWithName:NOTIFICATION_ADDED_MEDIA object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
}


# pragma mark - Videos

//goes through all pinch views and pauses videos
-(void)pauseAllVideos {
	for (UIView * view in self.pageElements) {
		if([view isKindOfClass:[PinchView class]])[((PinchView *)view).videoView pauseVideo];
	}
}

//goes through all pinch views and plays the videos
-(void)playVideos {
	for (UIView * view in self.pageElements) {
		if([view isKindOfClass:[PinchView class]])[((PinchView *)view).videoView continueVideo];
	}
}

@end