

//
//  verbatmContentPageViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "ContentDevVC.h"
#import "CustomNavigationBar.h"
#import "CollectionPinchView.h"
#import "ContentPageElementScrollView.h"
#import "Channel_BackendObject.h"
#import "Durations.h"

#import "EditContentVC.h"

#import "GMImagePickerController.h"

#import "ImagePinchView.h"
#import "Icons.h"

#import "PinchView.h"
#import "PreviewDisplayView.h"
#import "PostInProgress.h"
#import "PublishingProgressManager.h"

#import "MediaDevVC.h"
#import "MediaSelectTile.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "Styles.h"

#import "UIImage+ImageEffectsAndTransforms.h"
#import "UserInfoCache.h"

#import "VerbatmCameraView.h"
#import "VideoPinchView.h"

@interface ContentDevVC () <UITextFieldDelegate, UIScrollViewDelegate, MediaSelectTileDelegate,
GMImagePickerControllerDelegate, ContentPageElementScrollViewDelegate, CustomNavigationBarDelegate, PreviewDisplayDelegate, VerbatmCameraViewDelegate,
UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UITextField * createNewChannelField;
@property (nonatomic) NSString * channelNameForNewChannel;
#pragma mark Image Manager

@property (strong, nonatomic) PHImageManager *imageManager;
@property (strong, nonatomic) PHVideoRequestOptions *videoRequestOptions;

#pragma mark Pinch Views

//keeps track of ContentPageElementScrollViews
@property (strong, nonatomic) NSMutableArray * pageElementScrollViews;
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

#pragma mark Camera View

@property (strong, nonatomic) VerbatmCameraView* cameraView;

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



@property (nonatomic) UIImageView * pinchElementsTogetherInstructionView;//presents instrutions to user to pinch together their media


//note when previewing
@property (nonatomic) BOOL currentlyPreviewingContent;


@property (nonatomic) NSMutableArray * userChannels;


#pragma mark - Preview -

@property (strong, nonatomic) PreviewDisplayView * previewDisplayView;

#define CHANNEL_CREATION_PROMPT @"enter channel name"

#define TITLE_FIELD_Y_OFFSET 10.f
#define TITLE_FIELD_X_OFFSET 10.f
#define TITLE_FIELD_HEIGHT 80
#define TITLE_FIELD_LABEL_TILE_HEIGHT 80

#define MAX_TITLE_CHARACTERS 40

#define REPLACE_PHOTO_FRAME_WIDTH 35
#define REPLACE_PHOTO_FRAME_HEIGHT 35

#define REPLACE_PHOTO_YOFFSET 20
#define REPLACE_PHOTO_XsOFFSET 10

#define COVER_PIC_RADIUS (self.defaultPinchViewRadius * 3.f/4.f)

@property(nonatomic, strong) NSMutableArray * ourPosts;
@end


@implementation ContentDevVC

#pragma mark - Initialization And Instantiation -

- (void)viewDidLoad {
	[super viewDidLoad];
    self.ourPosts = [[NSMutableArray alloc] init];
	[self initializeVariables];
	[self setFrameMainScrollView];
	[self setElementDefaultFrames];
	[self formatNavBar];
	[self setKeyboardAppearance];
	[self setCursorColor];
	[self setUpNotifications];
	self.titleField.delegate = self;
	self.mainScrollView.delegate = self;
    [self addBackgroundImage];
    [self loadChannelsAndCreateTicker];
}

-(void)loadChannelsAndCreateTicker{

	self.userChannels = [NSMutableArray arrayWithArray:[[UserInfoCache sharedInstance] getUserChannels]];
    
    if(self.userChannels.count){
        NSUInteger startViewIndex =[[UserInfoCache sharedInstance] currentChannelViewedIndex];
        id channel = [self.userChannels objectAtIndex:startViewIndex];
        //we simple set the current index being viewed as the first channel. This is
        // a heuristic for the user.
        [self.userChannels removeObject:channel];
        [self.userChannels insertObject:channel atIndex:0];
    }
     [self formatTitle];
     [self createBaseSelector];
     [self loadPostFromUserDefaults];
}

-(void) addBackgroundImage {
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image =[UIImage imageNamed:BACKGROUND_IMAGE];
    //backgroundView.image =[UIImage imageNamed:];
	backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view insertSubview:backgroundView belowSubview:self.mainScrollView];
    self.mainScrollView.backgroundColor = [UIColor clearColor];
}



-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) initializeVariables {
	self.pinchingMode = PinchingModeNone;
	self.numPinchViews = 0;
	self.pinchObject_HasBeenAdded_ForTheFirstTime = NO;
	self.addMediaBelowView = nil;
	self.pinchViewTappedAndClosedForTheFirstTime = NO;
}

-(void) setFrameMainScrollView {
	self.mainScrollView.frame = CGRectMake(0.f, CUSTOM_NAV_BAR_HEIGHT,
										   self.view.frame.size.width, self.view.frame.size.height - CUSTOM_NAV_BAR_HEIGHT);
	self.mainScrollView.scrollEnabled = YES;
	self.mainScrollView.bounces = YES;
	[self adjustMainScrollViewContentSize];
}

//records the generic frame for any element that is a square and not a pinch view circle,
// as well as the pinch view center and radius
-(void)setElementDefaultFrames {
	self.defaultPageElementScrollViewSize = CGSizeMake(self.view.frame.size.width, ((self.view.frame.size.height*2.f)/5.f));
	self.defaultPinchViewCenter = CGPointMake(self.view.frame.size.width/2.f,
											  self.defaultPageElementScrollViewSize.height/2.f);
	self.defaultPinchViewRadius = (self.defaultPageElementScrollViewSize.height - ELEMENT_Y_OFFSET_DISTANCE)/2.f;
}

-(void) formatNavBar {
	[self.navBar createLeftButtonWithTitle:@"CLOSE" orImage:nil];
	[self.navBar createRightButtonWithTitle:@"PUBLISH" orImage:nil];
	self.navBar.delegate = self;
	[self.view addSubview: self.navBar];
}

-(void) createBaseSelector {

	CGRect scrollViewFrame = CGRectMake(0, self.titleField.frame.origin.y + self.titleField.frame.size.height + ELEMENT_Y_OFFSET_DISTANCE,
										self.view.frame.size.width, MEDIA_TILE_SELECTOR_HEIGHT+ELEMENT_Y_OFFSET_DISTANCE);

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
-(void) formatTitle{
    
    CGRect titleFrame = CGRectMake(TITLE_FIELD_X_OFFSET, TITLE_FIELD_Y_OFFSET,
											   self.view.bounds.size.width - 2*TITLE_FIELD_X_OFFSET,
											   TITLE_FIELD_HEIGHT);
    [self createChannelPickerFromChannelsFromFrame:titleFrame];
}


-(void)createChannelPickerFromChannelsFromFrame:(CGRect) frame{
    UIPickerView * picker = [[UIPickerView alloc] initWithFrame:frame];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    self.titleField = picker;
    picker.backgroundColor = [UIColor clearColor];
    picker.clipsToBounds = YES;
    
    self.currentPresentedPickerRow = 0;
    
    
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedChannelSelctor:)];
    tap.delegate = self;
    [picker addGestureRecognizer:tap];
    
    [self.mainScrollView addSubview:picker];
}



// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return (self.userChannels.count + 1);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component{
    return TITLE_FIELD_HEIGHT;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view{
    
    CGRect labelFrame = CGRectMake(pickerView.frame.size.height * row, 0.f, pickerView.frame.size.width, TITLE_FIELD_LABEL_TILE_HEIGHT);
    if(view){
        return view;
    }else {
        if(row == self.userChannels.count){//this is the create new channel row
            return [self getCreateNewChannelTextFieldWithFrame:labelFrame];
            
        }else{
            return [self formatTitleFieldFromFrame:labelFrame andChannel:self.userChannels[row]];
        }
    }
}



-(UILabel *) formatTitleFieldFromFrame: (CGRect) frame andChannel:(Channel *) channel {
	UILabel * channelTitle = [[UILabel alloc] initWithFrame: frame];
	channelTitle.textAlignment = NSTextAlignmentCenter;
	channelTitle.font = [UIFont fontWithName:TITLE_TEXT_FONT size: TITLE_TEXT_SIZE];
    [channelTitle setTextColor:[UIColor TITLE_TEXT_COLOR]];
	channelTitle.tintColor = [UIColor TITLE_TEXT_COLOR];
    channelTitle.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [channelTitle setText:channel.name];
    return channelTitle;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component{
    
    if(row == self.userChannels.count){
        UITextField * textField = (UITextField *) [pickerView viewForRow:row forComponent:component];
        [textField becomeFirstResponder];
    }else{
        [self removeKeyboardFromScreen];
    }
    self.currentPresentedPickerRow = row;
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // return
    return true;
}

-(void)userTappedChannelSelctor:(UITapGestureRecognizer *) tap{
    if(self.currentPresentedPickerRow == self.userChannels.count){
        UITextField * textField = (UITextField *) [self.titleField viewForRow:self.userChannels.count forComponent:0];
        if(textField)[textField becomeFirstResponder];
    }else{
        [self removeKeyboardFromScreen];
    }
}

-(UITextField *)getCreateNewChannelTextFieldWithFrame:(CGRect) frame{
    UITextField * field = [[UITextField alloc] initWithFrame:frame];
    UIFont* titleFont = [UIFont fontWithName:PLACEHOLDER_FONT size: TITLE_TEXT_SIZE];
    field.textAlignment = NSTextAlignmentCenter;
    field.font = [UIFont fontWithName:TITLE_TEXT_FONT size: TITLE_TEXT_SIZE];
    [field setTextColor:[UIColor whiteColor]];
    field.tintColor = [UIColor whiteColor];
    field.attributedPlaceholder = [[NSAttributedString alloc]
                                             initWithString: @"Create New Channel"
                                             attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                          NSFontAttributeName : titleFont}];
    
    field.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8];
    [field resignFirstResponder];
    field.enabled = YES;
    field.autocorrectionType = UITextAutocorrectionTypeYes;
    [field setReturnKeyType:UIReturnKeyDone];
    field.delegate = self;
    self.createNewChannelField = field;
    return field;
}

//text field protocol
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
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

// Loads pinch views from user defaults
-(void) loadPostFromUserDefaults {

	NSArray* savedPinchViews = [[PostInProgress sharedInstance] pinchViews];
	for (PinchView* pinchView in savedPinchViews) {
		[pinchView specifyRadius:self.defaultPinchViewRadius
					   andCenter:self.defaultPinchViewCenter];
		[self newPinchView:pinchView belowView: nil];
	}
}

#pragma mark - Nav Bar Delegate Methods -

#pragma mark Close Button

-(void) leftButtonPressed {
    self.view.clipsToBounds = YES;
	[self performSegueWithIdentifier:UNWIND_SEGUE_FROM_ADK_TO_MASTER sender:self];
}

#pragma mark Save Draft Button
-(void) middleButtonPressed {
	
}

#pragma mark Preview Button
-(void) rightButtonPressed {
    NSMutableArray * pinchViews = [[NSMutableArray alloc] init];
    
    for(ContentPageElementScrollView * contentElementScrollView in self.pageElementScrollViews){
        if([contentElementScrollView.pageElement isKindOfClass:[PinchView class]]){
            [pinchViews addObject:contentElementScrollView.pageElement];
        }
    }
  
	if(pinchViews.count) [self publishOurStoryWithPinchViews:pinchViews];
}


#pragma mark - Configure Text Fields -


#pragma mark - ScrollViews -

//adjusts the contentsize of the main view to the last element
-(void) adjustMainScrollViewContentSize {
	CGFloat minContentHeight = self.view.bounds.size.height + CONTENT_SIZE_OFFSET;
	if (self.pageElementScrollViews && self.pageElementScrollViews.count) {
		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			ContentPageElementScrollView *lastScrollView = (ContentPageElementScrollView *)[self.pageElementScrollViews lastObject];
			CGFloat contentHeight = lastScrollView.frame.origin.y + lastScrollView.frame.size.height + CONTENT_SIZE_OFFSET;
			self.mainScrollView.contentSize = (contentHeight > minContentHeight) ? CGSizeMake(0, contentHeight) : CGSizeMake(0, minContentHeight);
		}];
	} else {
		self.mainScrollView.contentSize = CGSizeMake(0.f, minContentHeight);
	}
}

#pragma mark Scroll View actions

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
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
		[[PostInProgress sharedInstance] removePinchView:(PinchView*)pageElementScrollView.pageElement];
		self.numPinchViews--;
	}

    [self.pageElementScrollViews removeObject:pageElementScrollView];
	
    [UIView animateWithDuration:PINCHVIEW_DELETE_ANIMATION_DURATION animations:^{
        if([pageElementScrollView.pageElement isKindOfClass:[PinchView class]]){
           pageElementScrollView.alpha = 0;
        }
    }completion:^ (BOOL finished) {
        if(finished){
            [pageElementScrollView cleanUp];
            [pageElementScrollView removeFromSuperview];
            [self shiftElementsBelowView: self.titleField];
        }
    }];
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
	[self addTapGestureToPinchView:pinchView];
	// must be below base media tile selector
	NSUInteger index = self.pageElementScrollViews.count-1;

	CGRect newElementScrollViewFrame;
	if(!upperScrollView) {
		newElementScrollViewFrame = CGRectMake(0,self.titleField.frame.origin.y + self.titleField.frame.size.height + ELEMENT_Y_OFFSET_DISTANCE,
											   self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
		index = 0;
	} else {
		newElementScrollViewFrame = CGRectMake(upperScrollView.frame.origin.x, upperScrollView.frame.origin.y + upperScrollView.frame.size.height,
											   self.defaultPageElementScrollViewSize.width, self.defaultPageElementScrollViewSize.height);
		index = [self.pageElementScrollViews indexOfObject:upperScrollView]+1;
	}
    
    //makes the object start animating from the top of the screen
    CGRect animationStartFrame = CGRectMake(0, self.mainScrollView.contentOffset.y - newElementScrollViewFrame.size.height, newElementScrollViewFrame.size.width, newElementScrollViewFrame.size.height);
    
    ContentPageElementScrollView *newElementScrollView = [self createNewContentScrollViewWithPinchView:pinchView andFrame:animationStartFrame];
	
    self.numPinchViews++;
    
	//thread safety
	@synchronized(self) {
        if(index <= self.pageElementScrollViews.count)[self.pageElementScrollViews insertObject:newElementScrollView atIndex: index];
	}
    
    [[PostInProgress sharedInstance] addPinchView:pinchView atIndex:index];
    
    
    [UIView animateWithDuration:PINCHVIEW_DROP_ANIMATION_DURATION animations:^{
        [self.mainScrollView addSubview: newElementScrollView];
        newElementScrollView.frame = newElementScrollViewFrame;
        self.addMediaBelowView = newElementScrollView;
        [self shiftElementsBelowView: self.titleField];
        //TODO -- user pinch instruction
//        if(self.pageElementScrollViews.count > 3){
//            [self presentUserInstructionForPinchGesture];
//        }
        
    }];
    
    
}

-(ContentPageElementScrollView *) createNewContentScrollViewWithPinchView:(PinchView *) view andFrame:(CGRect) frame {
    
    ContentPageElementScrollView *newElementScrollView = [[ContentPageElementScrollView alloc]initWithFrame:frame andElement:view];
    newElementScrollView.delegate = self; //scroll view delegate
    newElementScrollView.contentPageElementScrollViewDelegate = self;
    
    return newElementScrollView;
}

#pragma mark - Shift Positions of Elements

//Once view is added- we make sure the views below it are appropriately adjusted in position
-(void)shiftElementsBelowView: (UIView *) view {
	if (!view ||
		(![view isKindOfClass:[ContentPageElementScrollView class]]
	   && ![view isKindOfClass:[UIPickerView class]])) {
		return;
	}
	NSInteger viewIndex = 0;
	NSInteger firstYCoordinate = view.frame.origin.y + view.frame.size.height;

	//if we are shifting things from somewhere in the middle of the scroll view
	if([self.pageElementScrollViews containsObject:view]) {
		viewIndex = [self.pageElementScrollViews indexOfObject:view]+1;
	}
	//If we must shift everything from the top
	else if ([view isKindOfClass:[UITextField class]]) {
		firstYCoordinate = firstYCoordinate + ELEMENT_Y_OFFSET_DISTANCE;
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
[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

-(void) showKeyboard {
//	if(self.titleField.isEditing) {
//		[self.titleField becomeFirstResponder];
//	}
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

-(void) keyBoardDidShow:(NSNotification *) notification {}

-(void)keyboardWillDisappear:(NSNotification *) notification {}

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
                 self.pinchingMode == PinchingModeVerticalUndo)
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

	[self shiftElementsBelowView: self.titleField];
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
		[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
		[self shiftElementsBelowView: self.titleField];

	} completion:^(BOOL finished) {
		[self.newlyCreatedMediaTile.superview removeFromSuperview];
		self.newlyCreatedMediaTile = nil;
		self.pinchingMode = PinchingModeNone;
	}];
}

-(void) handlePinchGestureBegan: (UIPinchGestureRecognizer *)sender {
     if(self.pageElementScrollViews.count < 2) return;//if there is only one object on the screen then don't pinch
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


//checks if scroll view contains an open collection,
//if so shows the pull bar and tells the scroll view to close the collection
-(void)closeOpenCollectionInScrollView:(ContentPageElementScrollView*)openCollectionScrollView {

	if(!openCollectionScrollView.collectionIsOpen) {
		return;
	}
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
         [self removeExcessMediaTiles];
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
        if(self.pinchingMode == PinchingModeVertical){
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
		[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
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
		[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
		[self shiftElementsBelowView: self.titleField];
	} completion:^(BOOL finished) {
		[self shiftElementsBelowView: self.titleField];
		gesture.enabled = NO;
		gesture.enabled = YES;
		self.pinchingMode = PinchingModeNone;
		[self.newlyCreatedMediaTile createFramesForButtonsWithFrame: self.newlyCreatedMediaTile.frame];
		[self.newlyCreatedMediaTile buttonGlow];
	}];
}

#pragma mark Pinch Apart Failed

//Removes the new view being made and resets page
-(void) clearMediaTile:(MediaSelectTile*)mediaTile {
	[self.pageElementScrollViews removeObject:mediaTile.superview];
	[mediaTile.superview removeFromSuperview];
	[self shiftElementsBelowView: self.titleField];
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
	[self shiftElementsBelowView: self.titleField];

	//present swipe to delete notification
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

	if(self.pageElementScrollViews.count > (index+1) && index != NSNotFound && self.pinchingMode != PinchingModeVerticalUndo) {
		self.lowerPinchScrollView = self.pageElementScrollViews[index+1];
    }else if (self.pinchingMode == PinchingModeVerticalUndo){
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

-(ContentPageElementScrollView *) createPinchApartViews {

	CollectionPinchView *collectionPinchView = (CollectionPinchView *)self.upperPinchScrollView.pageElement;
	SingleMediaAndTextPinchView *toRemove = [collectionPinchView.pinchedObjects lastObject];
	CollectionPinchView *newCollectionPinchView = [collectionPinchView unPinchAndRemove:toRemove];
	toRemove.frame = newCollectionPinchView.frame;
	[self addTapGestureToPinchView:toRemove];
	NSInteger index = [self.pageElementScrollViews indexOfObject:self.upperPinchScrollView] + 1;

	if(newCollectionPinchView.pinchedObjects.count == 1){
		SingleMediaAndTextPinchView *unPinchedPinchView = [collectionPinchView.pinchedObjects lastObject];
		unPinchedPinchView.frame = toRemove.frame;
		[[PostInProgress sharedInstance] removePinchView:[newCollectionPinchView unPinchAndRemove:unPinchedPinchView]
									andReplaceWithPinchView:unPinchedPinchView];
		[self.upperPinchScrollView changePageElement:unPinchedPinchView];
	}else{
		[[PostInProgress sharedInstance] updatePinchView:newCollectionPinchView];
		[[PostInProgress sharedInstance] addPinchView:toRemove atIndex:index];
	}

	ContentPageElementScrollView *newElementScrollView = [self createNewContentScrollViewWithPinchView:toRemove andFrame:self.upperPinchScrollView.frame];
	self.numPinchViews++;
	//thread safety
	@synchronized(self) {
		[self.pageElementScrollViews insertObject:newElementScrollView atIndex: index];
	}

	[self.mainScrollView addSubview: newElementScrollView];
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
		if(distanceTraveled > upperPinchPoint.y && [scrollView.pageElement isKindOfClass:[PinchView class]] && (upperPinchPoint.y > scrollView.frame.origin.y)) {
            wantedView = scrollView;
            if([self bothPointsInView:wantedView andLowerPoint:lowerPinchPoint]){
                self.pinchingMode = PinchingModeVerticalUndo;
            }
			break;
		}
	}
	return wantedView;
}

-(BOOL) bothPointsInView: (UIView *) view andLowerPoint: (CGPoint) lowerPoint {
    if(lowerPoint.y < (view.frame.origin.y + (self.defaultPinchViewRadius*2))){
        return YES;
    }
    return NO;
}

-(BOOL)sufficientOverlapBetweenPinchedObjects {
	if(self.upperPinchScrollView.frame.origin.y+(self.upperPinchScrollView.frame.size.height/2)>= self.lowerPinchScrollView.frame.origin.y){
		return YES;
	}
	return NO;
}

#pragma mark - Media Tile Delegate -

-(void) galleryButtonPressedOnTile: (MediaSelectTile *)tile  {
	NSInteger index = [self.pageElementScrollViews indexOfObject: tile.superview] - 1;
	self.addMediaBelowView = index >= 0 ? self.pageElementScrollViews[index] : nil;
	[self presentEfficientGallery];
	if (!tile.isBaseSelector) {
		[self clearMediaTile:tile];
	}
}

-(void) cameraButtonPressedOnTile: (MediaSelectTile *)tile {
		[self.cameraView removeFromSuperview];
		[self.view addSubview:self.cameraView];
		[self.cameraView createAndInstantiateGestures];
        self.selectedView_PAN = (ContentPageElementScrollView *)tile.superview;//should be a contentpagescrollview
}

#pragma mark - Change position of elements on screen by dragging

// Handle users moving elements around on the screen using long press
- (IBAction)longPressSensed:(UILongPressGestureRecognizer *)sender {
	switch (sender.state) {
		case UIGestureRecognizerStateEnded: {
			[self finishMovingSelectedItem];
            [self removeExcessMediaTiles];
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
    [self.selectedView_PAN markAsSelected:YES];
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
            [self.selectedView_PAN markAsSelected:YES];
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


-(void)presentUserInstructionForPinchGesture {

    ContentPageElementScrollView * firstInList = self.pageElementScrollViews[0];

    CGFloat offsetFromPinchViewCenters = 60.f;    
    
    CGFloat frameHeight = firstInList.frame.size.height - (2*offsetFromPinchViewCenters);
    
    CGFloat frameWidth = (frameHeight * 367.f)/331.f ;
    
    
    
    CGRect instructionFrame = CGRectMake(firstInList.center.x - 8.f, firstInList.center.y + offsetFromPinchViewCenters,
                                         frameWidth,frameHeight);
    
    
    UIImage * instructionImage = [UIImage imageNamed:PINCH_OBJECTS_TOGETHER_INSTRUCTION];
    self.pinchElementsTogetherInstructionView = [[UIImageView alloc] initWithImage:instructionImage];
    self.pinchElementsTogetherInstructionView.frame =  instructionFrame;
    
    [self.mainScrollView addSubview:self.pinchElementsTogetherInstructionView];
    [self.mainScrollView bringSubviewToFront:self.pinchElementsTogetherInstructionView];
	
}

//adjusts offset of main scroll view so selected item is in focus
-(void) moveOffsetOfMainScrollViewBasedOnSelectedItem {
	float newYOffset = 0;
	if (self.mainScrollView.contentOffset.y > (self.selectedView_PAN.frame.origin.y + self.selectedView_PAN.frame.size.height/4.f)
		&& (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0)) {

		newYOffset = -AUTO_SCROLL_OFFSET;
	} else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_PAN.frame.origin.y + self.selectedView_PAN.frame.size.height)
			   && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height) {

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
	ContentPageElementScrollView* upperView;
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
 
    [UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2.f animations:^{
			 self.selectedView_PAN.frame = self.previousFrameInLongPress;
    }];
	
    if(self.selectedView_PAN){
        [self.selectedView_PAN.pageElement markAsSelected:NO];
        [self.selectedView_PAN markAsSelected:NO];
    }
	//sanitize for next run
	self.selectedView_PAN = nil;
	[self shiftElementsBelowView:self.titleField];
}

//swaps scroll views in the pageElementScrollView array
-(void) swapScrollView: (ContentPageElementScrollView *) scrollView1 andScrollView: (ContentPageElementScrollView *) scrollView2 {
	NSInteger index1 = [self.pageElementScrollViews indexOfObject: scrollView1];
	NSInteger index2 = [self.pageElementScrollViews indexOfObject: scrollView2];
	[self.pageElementScrollViews replaceObjectAtIndex: index1 withObject: scrollView2];
	[self.pageElementScrollViews replaceObjectAtIndex: index2 withObject: scrollView1];
	if ([scrollView1.pageElement isKindOfClass:[PinchView class]] && [scrollView2.pageElement isKindOfClass:[PinchView class]]) {
		[[PostInProgress sharedInstance] swapPinchView:(PinchView*)scrollView1.pageElement andPinchView:(PinchView*)scrollView2.pageElement];
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
	[self shiftElementsBelowView: self.titleField];
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
	if(![sender.view isKindOfClass:[PinchView class]] || self.currentlyPreviewingContent) {
		return;
	}
    
    UIView * view = sender.view.superview;//this will be a scrollview
    if(view)[self presentPreviewAtIndex:[self.pageElementScrollViews indexOfObject:view]];
}

//protocol for preview view
-(void) aboutToShowPreview{
    self.currentlyPreviewingContent = YES;
}
-(void) aboutToRemovePreview{
    self.currentlyPreviewingContent = NO;
}

-(void)presentPreviewAtIndex:(NSInteger ) index{
    NSMutableArray *pinchViews = [self getPinchViews];

    [self.view bringSubviewToFront:self.previewDisplayView];
    [self.previewDisplayView displayPreviewPostWithTitle:@"" andPinchViews:pinchViews withStartIndex:index];
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
		editContentVC.openPinchView = self.editingPinchView;
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
	[self.mainScrollView setContentOffset:CGPointMake(0, 0)];
	[self adjustMainScrollViewContentSize];
	[self clearTextFields];
    [self clearBaseSelcetor];
	[self createBaseSelector];
    [self initializeVariables];
    [[PostInProgress sharedInstance] clearPostInProgress];//now that you have published then we should get rid of all cashed info
}

-(void)clearBaseSelcetor{
    [self.baseMediaTileSelector removeFromSuperview];
    self.baseMediaTileSelector = nil;
}

-(void)clearTextFields {
	//self.titleField.text =@"";
}


#pragma mark - Verbatm Camera View Delegate methods -

// add image to deck (create pinch view)
-(void) imageCaptured: (UIImage*) image {
	image = [image scaleImageToSize:[image getSizeForImageWithBounds:self.view.bounds]];
	// place it at the bottom of the deck, above base element view selector
    
    if(self.selectedView_PAN.pageElement == self.baseMediaTileSelector){
        
        if(self.pageElementScrollViews.count == 1){
            self.addMediaBelowView = nil;//insert at the very top
        }else{
            self.addMediaBelowView = self.pageElementScrollViews[self.pageElementScrollViews.count - 2];//below the second to last object
        }
        
    }else{
        self.addMediaBelowView = self.selectedView_PAN;
    }
    
    
	[self createPinchViewFromImage: image];
}

// add video asset to deck (create pinch view)
-(void) videoAssetCaptured:(PHAsset *) asset {
    
    if(self.selectedView_PAN.pageElement == self.baseMediaTileSelector){
        
        if(self.pageElementScrollViews.count == 1){
            self.addMediaBelowView = nil;//insert at the very top
        }else{
            self.addMediaBelowView = self.pageElementScrollViews[self.pageElementScrollViews.count - 2];//below the second to last object
        }
        
    }else{
        self.addMediaBelowView = self.selectedView_PAN;
    }
    
	[[PHImageManager defaultManager] requestAVAssetForVideo:asset
													options:self.videoRequestOptions
											  resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [self createPinchViewFromVideoAsset:(AVURLAsset*)videoAsset
																		andPHAssetLocalID: asset.localIdentifier];
												  });
											  }];
}

-(void) minimizeCameraViewButtonTapped {
	[self.cameraView removeFromSuperview];
    [self removeExcessMediaTiles];
	//TODO
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

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray{
	[self presentAssetsAsPinchViews:assetArray];
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
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


}


-(UIImage*) getImageFromImageData:(NSData*) imageData {
	UIImage* image = [[UIImage alloc] initWithData: imageData];
	image = [image getImageWithOrientationUp];
	image = [image scaleImageToSize:CGSizeMake(self.view.bounds.size.height*(image.size.width/image.size.height), self.view.bounds.size.height)];
//	image = [image scaleImageToSize:CGSizeMake(image.size.width/1.2f, image.size.height/1.2f)];
	return image;
}

-(void) createPinchViewFromImage: (UIImage*) image {
	PinchView* newPinchView = [[ImagePinchView alloc] initWithRadius:self.defaultPinchViewRadius
														  withCenter:self.defaultPinchViewCenter
															andImage:image];
	[self newPinchView: newPinchView belowView: self.addMediaBelowView];
}

-(void) createPinchViewFromVideoAsset:(AVURLAsset*) videoAsset andPHAssetLocalID: (NSString*) phAssetLocalId {
	PinchView* newPinchView = [[VideoPinchView alloc] initWithRadius:self.defaultPinchViewRadius
														  withCenter:self.defaultPinchViewCenter
															andVideo: videoAsset
										   andPHAssetLocalIdentifier:phAssetLocalId];

	[self newPinchView: newPinchView belowView: self.addMediaBelowView];
}

#pragma mark - Returning Pinch Views -

-(NSMutableArray*) getPinchViews {
	NSMutableArray *pinchViews = [[NSMutableArray alloc]init];
	for(ContentPageElementScrollView* elementScrollView in self.pageElementScrollViews) {
		if ([elementScrollView.pageElement isKindOfClass:[PinchView class]]) {
			[pinchViews addObject:[elementScrollView pageElement]];
		}
	}
	return pinchViews;
}


#pragma mark -remove excess mediatiles-

-(void)removeExcessMediaTiles{
    for(int i = 0; i < self.pageElementScrollViews.count; i++){
        if(i < self.pageElementScrollViews.count) {
            ContentPageElementScrollView *  contentPageSV = self.pageElementScrollViews[i];
            if([contentPageSV.pageElement isKindOfClass:[MediaSelectTile class]] &&
               contentPageSV.pageElement != self.baseMediaTileSelector){
                [self deleteScrollView:contentPageSV];
            }
        }
    }
}

#pragma mark - Publishing (PreviewDisplay delegate Methods)

-(void) publishWithTitle:(NSString *)title andPinchViews:(NSMutableArray *)pinchViews {
	if(pinchViews) [self publishOurStoryWithPinchViews:pinchViews];
}

-(void) publishOurStoryWithPinchViews:(NSMutableArray *)pinchViews{

    Channel * channelToPostIn;
    if (self.currentPresentedPickerRow < self.userChannels.count) {
        channelToPostIn = self.userChannels[self.currentPresentedPickerRow];
    } else{
        UITextField * textField = (UITextField *) [self.titleField viewForRow:self.currentPresentedPickerRow forComponent:0];
        if ([textField.text isEqualToString:@""]) {
            //prompt user to add channel title-- TODO
            
        } else {
            channelToPostIn = [[Channel alloc] initWithChannelName:textField.text andParseChannelObject:nil];
        }
    }
    BOOL posting = [[PublishingProgressManager sharedInstance] publishPostToChannel:channelToPostIn withPinchViews:pinchViews];
    if(posting){
        [self performSegueWithIdentifier:UNWIND_SEGUE_FROM_ADK_TO_MASTER sender:self];
        [self cleanUp];
    }else{
        //TODO -- either something else is publishing or there is not internet
    }
}

#pragma mark - Tap to clear view -

- (IBAction)tapToClearKeyboard:(UITapGestureRecognizer *)sender {
    [self removeKeyboardFromScreen];
}


#pragma mark - Lazy Instantiation

-(VerbatmCameraView*) cameraView {
	if (!_cameraView) {
		_cameraView = [[VerbatmCameraView alloc] initWithFrame:self.view.bounds];
		_cameraView.delegate = self;
	}
	return _cameraView;
}

-(PreviewDisplayView*) previewDisplayView {
	if(!_previewDisplayView){
		_previewDisplayView = [[PreviewDisplayView alloc] initWithFrame: self.view.frame];
		_previewDisplayView.delegate = self;
		[self.view addSubview:_previewDisplayView];
	}
	return _previewDisplayView;
}

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
		CGRect frame = CGRectMake(ELEMENT_X_OFFSET_DISTANCE,
								  ELEMENT_Y_OFFSET_DISTANCE/2.f,
								  self.view.frame.size.width - (ELEMENT_X_OFFSET_DISTANCE * 2), MEDIA_TILE_SELECTOR_HEIGHT);
		_baseMediaTileSelector= [[MediaSelectTile alloc]initWithFrame:frame];
		_baseMediaTileSelector.isBaseSelector =YES;
		_baseMediaTileSelector.delegate = self;
		[_baseMediaTileSelector createFramesForButtonsWithFrame:frame];
		[_baseMediaTileSelector buttonGlow];
	}
	return _baseMediaTileSelector;
}

-(CustomNavigationBar*) navBar {
	if (!_navBar) {
		_navBar = [[CustomNavigationBar alloc]
                   initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT)
                   andBackgroundColor:ADK_NAV_BAR_COLOR];
	}
	return _navBar;
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