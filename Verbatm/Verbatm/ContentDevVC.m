

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
#import "verbatmGalleryHandler.h"
#import "MediaSelectTile.h"
#import "VerbatmScrollView.h"
#import "ILTranslucentView.h"
#import "PinchView.h"
#import "VerbatmImageView.h"
#import "VerbatmImageScrollView.h"
#import "GMImagePickerController.h"




@interface ContentDevVC () < UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,verbatmCustomMediaSelectTileDelegate,verbatmGalleryHandlerDelegate,GMImagePickerControllerDelegate>

#pragma mark - *Helper properties

#pragma mark Keyboard related properties
@property (atomic) NSInteger keyboardHeight;

#pragma mark Helpful integer stores
@property (atomic) NSInteger index; //the index of the first view that is pushed up/down by the pinch/stretch gesture
@property (atomic, strong) NSString * textBeforeNavigationLabel;


#pragma mark undo related properties
@property (atomic, strong) NSUndoManager * tileSwipeViewUndoManager;

#pragma mark - Parameters to function within

#define CURSOR_BASE_GAP 10



#define ANIMATION_DURATION 0.5
#define PINCH_DISTANCE_FOR_ANIMATION 100

#define SIZE_REQUIRED_MIN 100 //size for text tiles
#pragma TextView properties


#pragma mark - Used_properties -
#define CENTERING_OFFSET_FOR_TEXT_VIEW 30 //the gap between the bottom of the screen and the cursor


#define SCROLLDISTANCE_FOR_PINCHVIEW_RETURN 200 //if the image is up- you can scroll up and have it turn to circles. This gives that scrollup distance

#define BACKGROUND_COLOR clearColor

#pragma mark Notification helper


#define NOTIFICATION_HIDE_PULLBAR @"Notification_shouldHidePullBar"
#define NOTIFICATION_SHOW_PULLBAR @"Notification_shouldShowPullBar"
#define PICTURE_SELECTED_NOTIFICATION @"pictureObjectSelected"
#define PICTURE_UNSELECTED_NOTIFICATION @"pictureObjectUnSelected"
#define NOTIFICATION_CLEAR_CONTENTPAGE @"Notification_ClearContentPage"
#define CLOSED_ELEMENT_FACTOR (2/5)
#define MAX_WORD_LIMIT 350
#define ELEMENT_OFFSET_DISTANCE 20 //distance between elements on the page
#define IMAGE_SWIPE_ANIMATION_TIME 0.5 //time it takes to animate a image from the top scroll view into position
#define HORIZONTAL_PINCH_THRESHOLD 100 //distance two fingers must travel for the horizontal pinch to be accepted
#define TEXTFIELD_BORDER_WIDTH 0.8f
#define AUTO_SCROLL_OFFSET 10
#define CONTENT_SIZE_OFFSET 20

#pragma mark Default frame properties
@property (nonatomic) CGSize defaultPersonalScrollViewFrameSize_closedElement;

#pragma mark Display manipulation outlets



@property (weak, nonatomic) IBOutlet UIScrollView *personalScrollViewOfFirstContentPageTextBox;
@property (weak, nonatomic) IBOutlet UILabel *wordsLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *label_AT;
@property (strong, nonatomic) verbatmGalleryHandler * gallery;

#pragma mark Closed Element properties
@property (nonatomic) CGPoint closedElement_Center;
@property (strong, nonatomic) NSNumber * closedElement_Radius;

#pragma mark TextView related properties
@property (nonatomic) CGRect caretPosition;//position of caret on screen relative to scrollview origin

#pragma mark Helpful integer stores
@property (nonatomic) NSInteger numberOfWordsLeft;//number of words left in the article

#pragma mark Standard offset and content size properties
@property (nonatomic) CGPoint standardContentOffsetForPersonalView;// gives the standard content offset for each personalScrollview.
@property (nonatomic) CGSize standardContentSizeForPersonalView; //gives the standard content size for each personal Scrollview

#pragma mark Text input outlets
@property (weak, atomic) IBOutlet VerbatmUITextView *firstContentPageTextBox;
@property (strong, atomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, atomic) MediaSelectTile * baseMediaTileSelector;

#pragma mark Horizontal Pinch Gesture Properties
@property(nonatomic) CGPoint startLocationOfLeftestTouchPoint_PINCH;
@property (nonatomic) CGPoint startLocationOfRightestTouchPoint_PINCH;
@property (nonatomic, strong) UIScrollView * scrollViewForHorizontalPinchView;
@property (nonatomic) NSInteger horizontalPinchDistance;


#pragma mark PanGesture Properties
@property (atomic, strong) UIView * selectedView_Pan;
@property(nonatomic) CGPoint startLocationOfTouchPoint_PAN;
@property (nonatomic) CGRect originalFrame;//keep track of the starting from of the selected view so that you can easily shift things around
@property (nonatomic) CGRect potentialFrame;//keep track of the frame the selected view could take so that we can easily shift

#pragma mark FilteredPhotos
@property (nonatomic, strong) VerbatmImageScrollView * openImageScrollView;//the scrollview presented with the taped pinch object's image
@property (nonatomic, strong) PinchView * openImagePinchView; //the pinch view that has been taped
@property (nonatomic, strong) NSString * filter;


#pragma mark Vertical Pinch Gesture Related Properties
@property (nonatomic) BOOL VerticalPinch;
@property(nonatomic) CGPoint startLocationOfLowerTouchPoint;
@property (nonatomic) CGPoint startLocationOfUpperTouchPoint;
@property (nonatomic) NSInteger changeInTopViewPosition;
@property (nonatomic) NSInteger changeInBottomViewPostion;
@property (nonatomic) NSInteger totalChangeInViewPositions;
@property (nonatomic,strong) UIView * lowerPinchView;
@property (nonatomic,strong) UIView * upperPinchView;
@property (nonatomic,strong) UIView * createdMediaView;
@property (nonatomic) BOOL pinching; //tells if pinching is occurring


#pragma mark New Properties and Defines

#define OFFSET_BELOW_ARTICLE_TITLE 30
#define NOTIFICATION_PAUSE_VIDEOS @"pauseContentPageVideosNotification"
#define NOTIFICATION_PLAY_VIDEOS @"playContentPageVideosNotification"

#define NOTIFICATION_UNDO @"undoTileDeleteNotification"
#define LEFT_DELETE_OFFSET (self.view.frame.size.width/2)
#define RIGHT_DELETE_OFFSET (self.view.frame.size.width*(4/3))
@end

/*
 Perhaps for word count lets not prevent typing- lets just not let them publish with the word count over 350.
 It's more curtious.
 */


@implementation ContentDevVC

#pragma mark - Prepare ContentPage -
//By Iain
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) centerViews {
    NSInteger middle = self.view.frame.size.width/2;
    
    //@ sign
    self.label_AT.frame = CGRectMake(middle - self.label_AT.frame.size.width/2, self.label_AT.frame.origin.y, self.label_AT.frame.size.width, self.label_AT.frame.size.height);
    //the space to the left and to the write of the @ label
    NSInteger spaceLeft = (self.view.frame.size.width - self.label_AT.frame.size.width)/2;
    
    
    //s@ndwiches
    self.sandwhichWhat.frame = CGRectMake((spaceLeft/2)-(self.sandwhichWhat.frame.size.width/2), self.sandwhichWhat.frame.origin.y, self.sandwhichWhat.frame.size.width, self.sandwhichWhat.frame.size.height);
    self.sandwichWhere.frame = CGRectMake(((self.label_AT.frame.origin.x + self.label_AT.frame.size.width)+(spaceLeft/2))-(self.sandwichWhere.frame.size.width/2), self.sandwichWhere.frame.origin.y, self.sandwichWhere.frame.size.width, self.sandwichWhere.frame.size.height);
    
    //article title
    self.articleTitleField.frame = CGRectMake(middle - (self.articleTitleField.frame.size.width/2), self.articleTitleField.frame.origin.y, self.articleTitleField.frame.size.width, self.articleTitleField.frame.size.height);
}

//makes sure the main scrollview is edged to it's superview
-(void)sizeMainScrollViewPhoneSize {
    self.mainScrollView.frame= self.view.frame;
}


//Iain
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //set up gallery
    //after view loads load the gallery
    // self.gallery = [[verbatmGalleryHandler alloc] initWithView:self.view];
    //add blurview
    [self addBlurView];
    [self setPlaceholderColors];
    [self set_PersonalScrollView_ContentSizeandOffset];
    [self setClosedElementDefaultFrame];
    [self createBaseSelector];
    [self centerViews];
    [self sizeMainScrollViewPhoneSize];
    [self configureViews];
    self.pinching = NO;//initialise pinching to no
    
}


//gives the placeholders a white color
-(void) setPlaceholderColors {
    if ([self.sandwhichWhat respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.sandwhichWhat.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.sandwhichWhat.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    if ([self.sandwichWhere respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.sandwichWhere.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.sandwichWhere.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    if ([self.articleTitleField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.articleTitleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.articleTitleField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

-(void) addBlurView
{
    ILTranslucentView* blurView = [[ILTranslucentView alloc]init];
    blurView.frame = self.view.frame;
    blurView.translucentStyle = UIBarStyleBlack;
    blurView.translucentAlpha = 2;
    [self.view insertSubview:blurView atIndex:0];
}


-(void) createBaseSelector
{
    
    if(_baseMediaTileSelector)return;//make sure we don't create another one when we return from image picking
    CGRect frame = CGRectMake(self.view.frame.size.width + ELEMENT_OFFSET_DISTANCE,
                              ELEMENT_OFFSET_DISTANCE/2,
                              self.view.frame.size.width - (ELEMENT_OFFSET_DISTANCE * 2), self.view.frame.size.height/5);
    self.baseMediaTileSelector= [[MediaSelectTile alloc]initWithFrame:frame];
    self.baseMediaTileSelector.baseSelector =YES;
    self.baseMediaTileSelector.customDelegate = self;
    [self.baseMediaTileSelector createFramesForButtonsWithFrame:frame];
    
    UIScrollView * scrollview = [[UIScrollView alloc]init];
    scrollview.frame = CGRectMake(0, self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.view.frame.size.width, (self.view.frame.size.height/5)+ELEMENT_OFFSET_DISTANCE);
    
    scrollview.contentSize = self.standardContentSizeForPersonalView;
    scrollview.contentOffset = self.standardContentOffsetForPersonalView;
    scrollview.pagingEnabled = YES;
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


//records the generic frame for any element that is a square and not a pinch view circle
//and its personal scrollview.
-(void)setClosedElementDefaultFrame
{
    self.defaultPersonalScrollViewFrameSize_closedElement = CGSizeMake(self.view.frame.size.width, ((self.view.frame.size.height*2)/5));
    
    self.closedElement_Center = CGPointMake((self.standardContentSizeForPersonalView.width/2), self.defaultPersonalScrollViewFrameSize_closedElement.height/2);
    
    self.closedElement_Radius = [NSNumber numberWithDouble:(self.defaultPersonalScrollViewFrameSize_closedElement.height - ELEMENT_OFFSET_DISTANCE)/2];
}

//Iain
//save these offset and contentside values for use later
-(void)set_PersonalScrollView_ContentSizeandOffset
{
    //set the content offset for the personal scrollview
    self.standardContentOffsetForPersonalView = CGPointMake(self.view.frame.size.width, 0);
    self.standardContentSizeForPersonalView = CGSizeMake(self.view.frame.size.width * 3, 0);
    
}


//Set up views
-(void) configureViews
{
    [self setUpNotifications];
    //insert any text that was added in previous scenes
    [self setUpKeyboardPrefferedColors];
    [self setDelegates];
    [self whitenCursors];
}

//Iain
-(void) whitenCursors
{
    //make cursor white on textfields and textviews
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
}

//Iain
//makes the keyboard look black for all views present at the start
-(void) setUpKeyboardPrefferedColors
{
    self.sandwhichWhat.keyboardAppearance = UIKeyboardAppearanceDark;
    self.sandwichWhere.keyboardAppearance = UIKeyboardAppearanceDark;
    self.articleTitleField.keyboardAppearance = UIKeyboardAppearanceDark;
}


//Iain
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

//goes through all pinch views and pauses videos
-(void)pauseAllVideos
{
    for (UIView * view in self.pageElements)
    {
        if([view isKindOfClass:[PinchView class]])[((PinchView *)view).videoView pauseVideo];
    }
}

//goes through all pinch views and plays the videos
-(void)playVideos
{
    for (UIView * view in self.pageElements)
    {
        if([view isKindOfClass:[PinchView class]])[((PinchView *)view).videoView continueVideo];
    }
    
}


//Iain
//set appropriate delegates for views on page
-(void) setDelegates
{
    self.gallery.customDelegate = self;
    
    //Set delgates for textviews
    self.sandwhichWhat.delegate = self;
    self.sandwichWhere.delegate = self;
    self.articleTitleField.delegate = self;
    self.mainScrollView.delegate = self;
    
}


#pragma mark - TextFields -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //S@nwiches shouldn't have any spaces between them
    if([string isEqualToString:@" "]  && textField != self.articleTitleField) return NO;
    return YES;
}

//Iain
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.sandwhichWhat)
    {
        if([self.sandwichWhere.text isEqualToString:@""])
        {
            [self.sandwichWhere becomeFirstResponder];
        }else
        {
            [self.sandwhichWhat resignFirstResponder];
        }
    }else if(textField == self.sandwichWhere)
    {
        [self.sandwichWhere resignFirstResponder];
        
    }else if(textField == self.articleTitleField)
    {
        [self.articleTitleField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - Open Elements -


#pragma mark Text Entered
//Iain
//User has edited the text view somehow so we recount the words in the view. And adjust its size
- (void)textViewDidChange:(UITextView *)textView
{
    [self editWordCount];
    //you only want the scrollview to update if we are in MSAV mode
    if(((self.containerViewFrame.size.height + self.pullBarHeight) < self.view.frame.size.height)) [self updateScrollViewPosition];
}

//Iain
//Called when user types an input into the textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //If the user clicked enter add a textview
    if([text isEqualToString:@"\n"])
    {
        [self removeImageScrollview:nil];
        //when enter is clicked we give them a new textview
        //        verbatmCustomPinchView * pinchView = [self newPinchObjectBelowView:self.openImagePinchView fromView: nil isTextView:YES];
        //        [self createCustomImageScrollViewFromPinchView:pinchView andImageView: nil orTextView:[[verbatmUITextView alloc] init]];
        
        return NO;
    }
    return YES;
}

#pragma mark Bounds for TextViews


#pragma mark Caret within TextView
//Update the stored position of the carret within the textview it's in
-(void) updateCaretPositionInView: (VerbatmUITextView *) view
{
    self.caretPosition = [view caretRectForPosition:view.selectedTextRange.end];
}

#pragma mark Word Count - to be implemented
//Iain
//Counts the words in the content page
-(void) editWordCount
{
    self.numberOfWordsLeft = MAX_WORD_LIMIT - [self countWordsInContentPage];
    self.wordsLeftLabel.text = [NSString stringWithFormat:@"Words: %ld ", (long)self.numberOfWordsLeft];
}


//To be implemented
//Counts the number of words that are in the page
-(NSInteger) countWordsInContentPage
{
    NSUInteger words = 0;
    for(id object in self.pageElements)
    {
        if([object isKindOfClass:[UITextView class]])
        {
            NSString * string = ((UITextView *) object).text;
            NSArray * string_array = [string componentsSeparatedByString: @" "];
            words += [string_array count];
            
            //Make sure to discount blanks in the array
            for (NSString * string in string_array)
            {
                if([string isEqualToString:@""] && words != 0) words--;
            }
            //make sure that the last word is complete by having a space after it
            if(![[string_array lastObject] isEqualToString:@""]) words --;
        }else if([object isKindOfClass:[PinchView class]]&& ((PinchView *)object).there_is_text)
        {
            NSString * string = [((PinchView *) object) getTextFromPinchObject];
            NSArray * string_array = [string componentsSeparatedByString: @" "];
            words += [string_array count];
            
            //Make sure to discount blanks in the array
            for (NSString * string in string_array)
            {
                if([string isEqualToString:@""] && words != 0) words--;
            }
            
            //make sure that the last word is complete by having a space after it
            if(![[string_array lastObject] isEqualToString:@""]) words --;
        }
    }
    return words;
}


#pragma mark - ScrollViews -
#pragma mark Personal ScrollViews
#pragma mark Bounds
//Iain
-(CGRect) calculateBoundsForScrollViewForView: (UIView *) view
{
    CGRect frameToSet = CGRectMake(view.superview.frame.origin.x, view.superview.frame.origin.y, view.superview.bounds.size.width, view.frame.size.height + ELEMENT_OFFSET_DISTANCE);
    return frameToSet;
}



#pragma mark Main ScrollView
#pragma mark ContentSize
//adjusts the contentsize of the main view to the last element
-(void) adjustMainScrollViewContentSize
{
    UIScrollView * Sv = (UIScrollView *)[[self.pageElements lastObject] superview];
    self.mainScrollView.contentSize = CGSizeMake(0, Sv.frame.origin.y + Sv.frame.size.height + CONTENT_SIZE_OFFSET);
}

#pragma mark scroll positioning of the screen

//Iain
//Moves the scrollview to keep the cursor in view - To be fixed
-(void) updateScrollViewPosition
{
    
    
    if(self.sandwhichWhat.editing || self.sandwichWhere.editing) return; //if it is the s@andwiches that are set then
    
    [self updateCaretPositionInView:self.openImageScrollView.textView];//ensure that the caret is up to date
    
    
    //get y-position of caret relative to openimage scrollView
    NSInteger contentOffSet = self.openImageScrollView.textView.contentOffset.y ;
    NSInteger screenHeight =self.view.frame.size.height;
    NSInteger keyboardHeight = self.keyboardHeight;
    NSInteger keyboardBarHeight = self.pullBarHeight;
    //note that this is a coordinate relative to self.view so it must be converted depending on the
    //view you are talking about
    NSInteger keyboardYCoordinate= (screenHeight - (keyboardHeight+ keyboardBarHeight)) ;
    
    //if we are in msav change the keyboard height to msav mode
    if((self.containerViewFrame.size.height + self.pullBarHeight) < self.view.frame.size.height )
    {
        keyboardYCoordinate =self.containerViewFrame.size.height;
    }
    
    
    NSInteger yCoordinateOfCaretRelativeToImageScrollView = self.openImageScrollView.textView.frame.origin.y + self.caretPosition.origin.y + self.caretPosition.size.height;
    
    //the range/distance of visible space on the screen not we are doing this for readability
    NSInteger visibilityRange = keyboardYCoordinate;
    
    //If our cursor is inline with or below the keyboard, adjust the scrollview
    if(yCoordinateOfCaretRelativeToImageScrollView >= (self.openImageScrollView.textView.contentOffset.y + visibilityRange))
    {
        NSInteger differenceBTWNKeyboardAndTextView = yCoordinateOfCaretRelativeToImageScrollView - (self.openImageScrollView.textView.contentOffset.y + visibilityRange);
        
        CGPoint newScrollViewOffset = CGPointMake(self.mainScrollView.contentOffset.x, (contentOffSet + differenceBTWNKeyboardAndTextView /*+CENTERING_OFFSET_FOR_TEXT_VIEW*/));
        
        [UIView animateWithDuration:ANIMATION_DURATION*2 animations:^{
            [self.openImageScrollView.textView setContentOffset:newScrollViewOffset animated:YES];
            
        }];
        
    }else if (yCoordinateOfCaretRelativeToImageScrollView-CURSOR_BASE_GAP <= self.openImageScrollView.contentOffset.y) //Checking if the cursor is past the top
    {
        NSInteger differenceBTWNScreenTopAndTextView = (yCoordinateOfCaretRelativeToImageScrollView-CURSOR_BASE_GAP)-self.openImageScrollView.textView.contentOffset.y;
        CGPoint newScrollViewOffset = CGPointMake(self.openImageScrollView.contentOffset.x, (self.openImageScrollView.textView.contentOffset.y + differenceBTWNScreenTopAndTextView /*-
                                                                                                                                                                                     CENTERING_OFFSET_FOR_TEXT_VIEW*/));
        [UIView animateWithDuration:ANIMATION_DURATION*2 animations:^{
            [self.openImageScrollView.textView setContentOffset:newScrollViewOffset animated:YES];
            
        }];
    }
    //[self.openImageScrollView adjustImageScrollViewContentSizing];
}


#pragma mark - Creating New Views -


#pragma mark - Shift Positions of Elements -

//Once view is added- we make sure the views below it are appropriately adjusted
//in position
-(void)shiftElementsBelowView: (UIView *) view
{
    if(!view) return; //makes sure the view is not nil
    if([self.pageElements containsObject:view])//if we are shifting things from somewhere in the middle of the scroll view
    {
        NSInteger view_index = [self.pageElements indexOfObject:view];
        NSInteger firstYCoordinate  = view.superview.frame.origin.y + view.superview.frame.size.height;
        
        for(NSInteger i = (view_index+1); i < [self.pageElements count]; i++)
        {
            UIView * curr_view = self.pageElements[i];
            
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, firstYCoordinate, self.view.frame.size.width,curr_view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                curr_view.superview.frame = frame;
            }];
            
            firstYCoordinate+= frame.size.height;
        }
    }else if ([view isMemberOfClass:[UITextField class]]) //If we must shift everything from the top - we pass in the text field
    {
        NSInteger firstYCoordinate  = view.frame.origin.y + view.frame.size.height + ELEMENT_OFFSET_DISTANCE;
        
        for(NSInteger i = 0; i < [self.pageElements count]; i++)
        {
            UIView * curr_view = self.pageElements[i];
            
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, firstYCoordinate, self.defaultPersonalScrollViewFrameSize_closedElement.width,curr_view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                curr_view.superview.frame = frame;
            }];
            firstYCoordinate+= frame.size.height;
        }
    }
    
    [self adjustMainScrollViewContentSize];//make sure the main scroll view can show everything
}


//Shifts elements above a certain view up by the given difference
-(void) shiftElementsAboveView: (UIView *) view withDifference: (NSInteger) difference {
    NSInteger view_index = [self.pageElements indexOfObject:view];
    if(view_index != NSNotFound && view_index < self.pageElements.count) {
        for(NSInteger i = (view_index-1); i > -1; i--) {
            UIView * curr_view = self.pageElements[i];
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, curr_view.superview.frame.origin.y + difference, self.view.frame.size.width,view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                curr_view.superview.frame = frame;
            }];
        }
    }
}

#pragma mark - Add Elements to PageElements Array -
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


#pragma mark - Deleting views with swipe -

//make sure the object is in the right position
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if(scrollView != self.mainScrollView) {        //if the delete swipe wasn't far enough then return the pinch object to the middle
        if((scrollView.contentOffset.x > LEFT_DELETE_OFFSET || scrollView.contentOffset.x < RIGHT_DELETE_OFFSET) && scrollView.subviews.count == 1) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
            }];
        }
    }
}


//called when the view is scrolled - we see if the offset has changed
//if so we remove the view
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    if(scrollView.subviews.count >1 || scrollView == self.openImageScrollView) return; /* this is a scrollview with an open collection so you can swipe away anything and also it's not an opened image*/
    
    MediaSelectTile * tile= Nil;
    
    if([[scrollView.subviews firstObject] isKindOfClass:[MediaSelectTile class]])
    {
        tile = [scrollView.subviews firstObject];
    }
    
    if((!tile || !tile.baseSelector) && scrollView != self.mainScrollView && !self.pinching && [self.pageElements count] >1 )//make sure you are not mixing it up with the virtical scroll of the main scroll view
    {
        if(scrollView.contentOffset.x != self.standardContentOffsetForPersonalView.x)//If the view is scrolled left/right and not centered
        {
            [self.gallery dismissGallery];//make sure gallery is closed
            
            //remove swiped view from mainscrollview
            UIView * view = [scrollView.subviews firstObject]; //it is the only subview in this scrollview
            NSUInteger index = [self.pageElements indexOfObject:view];
            [scrollView removeFromSuperview];
            [self.pageElements removeObject:view];
            
            [self shiftElementsBelowView:self.articleTitleField]; //if it was the top element then shift everything below
            
            //recycle the object you just deleted
            
            if([view isKindOfClass:[PinchView class]])
            {
                NSMutableArray *array = [(PinchView *)view mediaObjects];
                for(int i=0; i<array.count;i++)
                {
                    if([array[i] isKindOfClass:[VerbatmImageView class]])
                    {
                        //[self.gallery returnToGallery:(verbatmCustomImageView *)array[i]];
                    }
                }
            }else if ([view isKindOfClass:[VerbatmImageView class]])
            {
                //[self.gallery returnToGallery: (verbatmCustomImageView *)view];
            }
            //sanitize your memory
            if(self.upperPinchView == view) self.upperPinchView = Nil;//sanitize the pointers so the objects don't stay in memory
            if(self.lowerPinchView ==view) self.lowerPinchView =Nil;//sanitize these pointers so that the objects don't stay in memory
            
            [self deletedTile:view withIndex:[NSNumber numberWithUnsignedLong:index]]; //register deleted tile - register in undo stack
        }
        
    }else if(scrollView != self.mainScrollView) { //return the view to it's old position
        [UIView animateWithDuration:0.7 animations:^ {
            scrollView.contentOffset = self.standardContentOffsetForPersonalView;
        }];
    }
}


#pragma mark Color of Tiles being deleted
//Iain
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.openImageScrollView)[self.openImageScrollView adjustImageScrollViewContentSizing];
    
    //show and hide the pullbar depending on the direction of the scroll
    if(scrollView == self.mainScrollView) {
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:self.mainScrollView];
        
        if(translation.y < 0) {
            [self hidePullBar];
        }else {
            [self showPullBar];
        }
    }
    
    //change the background color of the element being deleted to highlight that it's being deleted
    if(scrollView != self.mainScrollView && scrollView.subviews.count <2 && scrollView != self.openImageScrollView ) { //makes sure it's only one element on the view
        
        if(scrollView.contentOffset.x > self.standardContentOffsetForPersonalView.x + 80 || scrollView.contentOffset.x < self.standardContentOffsetForPersonalView.x - 80){
            if(scrollView.contentOffset.x >3) {
                if([[scrollView.subviews firstObject] isKindOfClass:[PinchView class]]) {
                    [((PinchView *)[scrollView.subviews firstObject]) markAsDeleting];
                } else {
                    ((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor redColor];
                }
            }
        } else {
            [UIView animateWithDuration:0.4 animations:^ {
                if([[scrollView.subviews firstObject] isKindOfClass:[PinchView class]]) {
                    [((PinchView *)[scrollView.subviews firstObject]) unmarkAsDeleting];
                } else {
                    ((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor BACKGROUND_COLOR];//for all objects not text views
                }
            }];
        }
    }
}


#pragma  mark - Handling the KeyBoard -

#pragma Remove Keyboard From Screen
//Iain
-(void) removeKeyboardFromScreen
{
    //make sure the device is landscape
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        if(self.sandwhichWhat.isEditing)[self.sandwhichWhat resignFirstResponder];
        if(self.sandwichWhere.isEditing)[self.sandwichWhere resignFirstResponder];
        if(self.articleTitleField.isEditing)[self.articleTitleField resignFirstResponder];
        [self.openImageScrollView.textView resignFirstResponder];
    }
}


//Remove keyboard when scrolling
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}


#pragma mark Keyboard Notifications
//When keyboard appears get its height. This is only neccessary when the keyboard first appears
-(void)keyboardWillShow:(NSNotification *) notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
}


-(void)keyBoardWillChangeFrame: (NSNotification *) notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = keyboardSize.height;
    
    [self.openImageScrollView adjustFrameOfTextViewForGap: (self.view.frame.size.height - ( self.keyboardHeight + self.pullBarHeight))];
}



-(void) keyBoardDidShow:(NSNotification *) notification
{
    
    [self.openImageScrollView adjustFrameOfTextViewForGap: (self.view.frame.size.height - ( self.keyboardHeight + self.pullBarHeight))];
}


-(void)keyboardWillDisappear:(NSNotification *) notification
{
    [self.openImageScrollView adjustFrameOfTextViewForGap: 0];
}

#pragma mark - Pinch Gesture -

#pragma mark  Sensing Pinch
//pinch open to add new element
- (IBAction)addElementPinchGesture:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self.gallery dismissGallery];//make sure gallery is closed
        if([sender numberOfTouches] == 2 ) //make sure there are only 2 touches
        {
            self.pinching = YES;
            //sometimes people will rest their hands on the screen so make sure the textviews are selectable
            for (UIView * new_view in self.mainScrollView.pageElements)
            {
                if([new_view isKindOfClass:[UITextView class]])
                {
                    ((UITextView *)new_view).selectable = YES;
                }
            }
            [self handlePinchGestureBegan:sender];
        }
    }
    
    
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        
        if(!self.VerticalPinch && self.scrollViewForHorizontalPinchView && [sender numberOfTouches] == 2 && self.pinching && sender.scale <1)
        {
            [self handleHorizontalPincheGestureChanged:sender];
            
        }else if (self.lowerPinchView && self.upperPinchView && [sender numberOfTouches] == 2 && self.pinching)
        {
            //makes no sense to pinch apart where there is alrady a tile
            if([self.upperPinchView isKindOfClass:[MediaSelectTile class]] ||
               [self.lowerPinchView isKindOfClass:[MediaSelectTile class]]
               )return;
            
            [self handleVerticlePinchGestureChanged:sender];
        }
    }
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.pinching = NO;
        self.horizontalPinchDistance =0;//Sanitize the figure
        self.startLocationOfLeftestTouchPoint_PINCH = CGPointMake(0, 0);
        self.startLocationOfRightestTouchPoint_PINCH = CGPointMake(0, 0);
        self.scrollViewForHorizontalPinchView.scrollEnabled = YES;
        if(sender.scale > 1 )
        {
            if(self.createdMediaView.superview.frame.size.height < PINCH_DISTANCE_FOR_ANIMATION)
            {
                [self clearNewMediaView]; //new media creation has failed
            }
        }
        
        if(self.scrollViewForHorizontalPinchView.subviews.count >1)//check if the stuff was turned into one. If not rearrange
        {
            
            NSArray * array = self.scrollViewForHorizontalPinchView.subviews;
            //remove the objects fromt their super views so that they can be readded with correct frames
            for (int i=0; i<array.count; i++) {
                [(UIView *)array[i] removeFromSuperview];
            }
            
            [self addPinchObjects: [NSMutableArray arrayWithArray:array] toScrollView: self.scrollViewForHorizontalPinchView];
        }
        [self shiftElementsBelowView:self.articleTitleField];
    }
}


#pragma mark *Pinch Collection Closed
-(void)handleHorizontalPincheGestureChanged:(UIGestureRecognizer *) sender
{
    CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
    CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];
    
    if(touch1.x >touch2.x)
    {
        int left_most_difference = touch2.x- self.startLocationOfLeftestTouchPoint_PINCH.x;
        int right_most_difference = touch1.x - self.startLocationOfRightestTouchPoint_PINCH.x;//this will be negative
        self.startLocationOfRightestTouchPoint_PINCH = touch1;
        self.startLocationOfLeftestTouchPoint_PINCH = touch2;
        [self moveViewsWithLeftDifference:left_most_difference andRightDifference:right_most_difference];
        self.horizontalPinchDistance += (left_most_difference - right_most_difference);
    }else
    {
        int left_most_difference = touch1.x- self.startLocationOfLeftestTouchPoint_PINCH.x;
        int right_most_difference = touch2.x - self.startLocationOfRightestTouchPoint_PINCH.x;//this will be negative
        self.startLocationOfRightestTouchPoint_PINCH = touch2;
        self.startLocationOfLeftestTouchPoint_PINCH = touch1;
        [self moveViewsWithLeftDifference:left_most_difference andRightDifference:right_most_difference];
        self.horizontalPinchDistance += (left_most_difference - right_most_difference);
    }
    
    if(self.horizontalPinchDistance > HORIZONTAL_PINCH_THRESHOLD)//they have pinched enough to join the objects
    {
        self.upperPinchView = self.lowerPinchView = nil;
        [self joinOpenCollectionToOne];
        self.pinching = NO;//not that pinching should be done now
    }
}


//moves the views in the scrollview of the opened collection
-(void) moveViewsWithLeftDifference: (int) left_difference andRightDifference: (int) right_difference
{
    NSArray * pinchViews = self.scrollViewForHorizontalPinchView.subviews;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        for(int i = 0; i < pinchViews.count; i++)
        {
            CGRect oldFrame = ((PinchView *)pinchViews[i]).frame;
            
            if(oldFrame.origin.x < self.startLocationOfLeftestTouchPoint_PINCH.x+ self.scrollViewForHorizontalPinchView.contentOffset.x)
            {
                CGRect newFrame = CGRectMake(oldFrame.origin.x + left_difference , oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                ((PinchView *)pinchViews[i]).frame = newFrame;
            }else
            {
                CGRect newFrame = CGRectMake(oldFrame.origin.x + right_difference , oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                ((PinchView *)pinchViews[i]).frame = newFrame;
            }
        }
    }];
}


-(void)joinOpenCollectionToOne
{
    [self showPullBar];//make sure the pullbar is showing when things are pinched together
    
    
    PinchView * placeHolder = [[PinchView alloc]init];//just holds the place inorder to be replaced
    NSArray * pinch_views = self.scrollViewForHorizontalPinchView.subviews;
    
    //find the object that is in the pageElements array and remove it.
    //Save the index though so you can insert something in there
    //Also remove from the scrollview
    for(int i=0; i<pinch_views.count; i++)
    {
        if([self.pageElements containsObject:pinch_views[i]]){
            [self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:pinch_views[i]] withObject:placeHolder];
        }
        [((UIView *)pinch_views[i]) removeFromSuperview];
    }
    
    PinchView * newView = [PinchView pinchTogether:[NSMutableArray arrayWithArray:pinch_views]];
    
    pinch_views = nil;//reduce number of pointers
    
    self.scrollViewForHorizontalPinchView.contentSize = self.standardContentSizeForPersonalView;
    self.scrollViewForHorizontalPinchView.contentOffset = self.standardContentOffsetForPersonalView;
    
    CGRect newFrame = CGRectMake(self.closedElement_Center.x - [self.closedElement_Radius intValue], self.closedElement_Center.y - [self.closedElement_Radius intValue], [self.closedElement_Radius intValue]*2, [self.closedElement_Radius intValue]*2);
    
    [newView specifyFrame:newFrame];
    [self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:placeHolder] withObject:newView];
    [self addTapGestureToView:newView];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self.scrollViewForHorizontalPinchView addSubview:newView];
        self.scrollViewForHorizontalPinchView.pagingEnabled =YES;//Turn paging back on because now it's one element
    }];
}


#pragma mark *Pinch Apart/Add a media tile

#pragma mark Create New Tile
//Iain
-(void) createNewViewToRevealBetweenPinchViews
{
    CGRect frame =  CGRectMake(self.baseMediaTileSelector.frame.origin.x + (self.baseMediaTileSelector.frame.size.width/2),0, 0, 0);
    MediaSelectTile * mediaTile = [[MediaSelectTile alloc]initWithFrame:frame];
    mediaTile.customDelegate = self;
    mediaTile.alpha = 0; //start it off as invisible
    mediaTile.baseSelector=NO;
    [self addMediaTile: mediaTile underView: self.upperPinchView];
    mediaTile.backgroundColor = [UIColor clearColor];
    self.createdMediaView = mediaTile;
}

//Iain
-(void) addMediaTile: (MediaSelectTile *) mediaView underView: (UIView *) topView
{
    //create frame for the personal scrollview of the new text view
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.view.frame.size.width,0);
    
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(mediaView) [newPersonalScrollView addSubview:mediaView]; //textview is subview of scroll view
    //format scrollview and text view
    //store the new view in our array
    [self storeView:mediaView inArrayAsBelowView:topView];
    
    for(int i=0; i<newPersonalScrollView.subviews.count;i++) {
        if([newPersonalScrollView.subviews[i] isMemberOfClass:[UIImageView class]]) {
            [newPersonalScrollView.subviews[i] removeFromSuperview];
        }
    }
    
}

-(void) handleRevealOfNewMediaViewWithGesture: (UIPinchGestureRecognizer *)gesture
{
    //note that the personal scroll view of the new media view will not have the element offset in the begining- this is to be added here
    if(self.createdMediaView.superview.frame.size.height< PINCH_DISTANCE_FOR_ANIMATION)
    {
        
        //construct new frames for view and personal scroll view
        self.createdMediaView.frame = CGRectMake(self.createdMediaView.frame.origin.x- (ABS(self.changeInBottomViewPostion)),
                                                 self.createdMediaView.frame.origin.y,
                                                 self.createdMediaView.frame.size.width+(ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition))/2,
                                                 self.createdMediaView.frame.size.height + (ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition))/2);
        self.createdMediaView.alpha =1;//self.createdMediaView.frame.size.width/self.baseMediaTileSelector.frame.size.width;
        //have it gain visibility as it grows
        
        
        self.createdMediaView.superview.frame = CGRectMake(self.createdMediaView.superview.frame.origin.x,
                                                           self.createdMediaView.superview.frame.origin.y+self.changeInTopViewPosition,
                                                           self.createdMediaView.superview.frame.size.width,
                                                           self.createdMediaView.superview.frame.size.height + (ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition)));
        
        
        //format the scrollview accordingly
        [self formatNewScrollView:(UIScrollView *)self.createdMediaView.superview];
        
        [(MediaSelectTile *)self.createdMediaView createFramesForButtonsWithFrame: self.createdMediaView.frame];
        [self.createdMediaView setNeedsDisplay];
    }else if(self.createdMediaView.superview.frame.size.height >= PINCH_DISTANCE_FOR_ANIMATION) {//the distance is enough that we can just animate the rest
        
        gesture.enabled = NO;
        gesture.enabled = YES;
        
        [UIView animateWithDuration:1.0f animations:^{
            
            self.createdMediaView.frame = self.baseMediaTileSelector.frame;
            self.createdMediaView.alpha = 1; //make it fully visible
            
            self.createdMediaView.superview.frame = CGRectMake(self.createdMediaView.superview.frame.origin.x,
                                                               self.createdMediaView.superview.frame.origin.y+self.changeInTopViewPosition,
                                                               self.baseMediaTileSelector.frame.size.width, self.baseMediaTileSelector.frame.size.height);
            
            [(MediaSelectTile *)self.createdMediaView createFramesForButtonsWithFrame: self.createdMediaView.frame];
            [self shiftElementsBelowView:self.articleTitleField];
        } completion:^(BOOL finished) {
            [self shiftElementsBelowView:self.articleTitleField];
            gesture.enabled = NO;
            gesture.enabled = YES;
            self.pinching = NO;
            
        }];
    }
}

//adds the appropriate parameters to a generic scrollview
-(void)formatNewScrollView:(UIScrollView *) scrollview
{
    scrollview.scrollEnabled= YES;
    scrollview.delegate = self;
    scrollview.pagingEnabled= YES;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.contentOffset = CGPointMake(self.standardContentOffsetForPersonalView.x, self.standardContentOffsetForPersonalView.y);
    scrollview.contentSize = self.standardContentSizeForPersonalView;
}

#pragma mark Pinch began - identify midpoint
//Iain
-(void) handlePinchGestureBegan: (UIPinchGestureRecognizer *)sender
{
    CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
    CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];
    
    if(touch1.y>touch2.y)
    {
        if(touch1.x >touch2.x)
        {
            int x_difference = touch1.x -touch2.x;
            int y_difference =touch1.y -touch2.y;
            if(x_difference > y_difference)//figure out if it's a horizontal pinch or vertical pinch
            {
                self.VerticalPinch = NO;
                [self horitzontalPinchWithGesture:sender];
            }else
            {
                if(self.pageElements.count==0) return;//you can pinch together two things when there's only one
                self.VerticalPinch = YES;
                [self verticlePinchWithGesture:sender];
            }
            
        }else
        {
            int x_difference = touch2.x -touch1.x;
            int y_difference =touch1.y -touch2.y;
            if(x_difference > y_difference)//figure out if it's a horizontal pinch or vertical pinch
            {
                self.VerticalPinch = NO;
                [self horitzontalPinchWithGesture:sender];
            }else
            {
                if(self.pageElements.count==0) return;//you can pinch together two things when there's only one
                self.VerticalPinch = YES;
                [self verticlePinchWithGesture:sender];
            }
        }
    }else
    {
        if(touch1.x >touch2.x)
        {
            int x_difference = touch1.x -touch2.x;
            int y_difference =touch2.y -touch1.y;
            
            if(x_difference > y_difference)//figure out if it's a horizontal pinch or vertical pinch
            {
                self.VerticalPinch = NO;
                [self horitzontalPinchWithGesture:sender];
            }else
            {
                if(self.pageElements.count==0) return;//you can pinch together two things when there's only one
                self.VerticalPinch = YES;
                [self verticlePinchWithGesture:sender];
            }
            
        }else
        {
            int x_difference = touch2.x -touch1.x;
            int y_difference =touch2.y -touch1.y;
            if(x_difference > y_difference)//figure out if it's a horizontal pinch or vertical pinch
            {
                self.VerticalPinch = NO;
                [self horitzontalPinchWithGesture:sender];
            }else
            {
                if(self.pageElements.count==0) return;//you can pinch together two things when there's only one
                self.VerticalPinch = YES;
                [self verticlePinchWithGesture:sender];
            }
        }
    }
}


//The gesture is horizontal. Get the scrollView for the list of pinch views open
-(void)horitzontalPinchWithGesture: (UIPinchGestureRecognizer *)sender
{
    if(sender.scale >1) return;
    CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
    CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];
    if(touch1.x>touch2.x)
    {
        self.scrollViewForHorizontalPinchView = [self findCollectionScrollViewFromTouchPoint:touch1];
        if(self.scrollViewForHorizontalPinchView)
        {
            self.startLocationOfLeftestTouchPoint_PINCH = touch2;
            self.startLocationOfRightestTouchPoint_PINCH = touch1;
            self.scrollViewForHorizontalPinchView.pagingEnabled =NO;
            self.scrollViewForHorizontalPinchView.scrollEnabled= NO;
        }
    }else
    {
        self.scrollViewForHorizontalPinchView = [self findCollectionScrollViewFromTouchPoint:touch1];
        if(self.scrollViewForHorizontalPinchView)
        {
            self.startLocationOfLeftestTouchPoint_PINCH = touch1;
            self.startLocationOfRightestTouchPoint_PINCH = touch2;
            self.scrollViewForHorizontalPinchView.pagingEnabled =NO;
            self.scrollViewForHorizontalPinchView.scrollEnabled = NO;
            
        }
    }
}

-(UIScrollView *)findCollectionScrollViewFromTouchPoint: (CGPoint) touch
{
    NSInteger distanceTraveled = 0;
    UIScrollView * wantedView;
    
    //Runs through the view positions to find the first one that passes the touch point
    for (UIView * view in self.pageElements)
    {
        UIView * superview = view.superview;//should be a scrollview
        if([superview isKindOfClass:[UIScrollView class]])
        {
            if(!distanceTraveled) distanceTraveled =superview.frame.origin.y;
            
            distanceTraveled += superview.frame.size.height;
            if(distanceTraveled > touch.y)
            {
                wantedView = (UIScrollView *)view.superview;
                break;
            }
        }
    }
    if(wantedView.subviews.count <2) return Nil;//If they are trying to close a closed element
    return wantedView;
}



//If it's a verticle pinch- find which media you're pinching together or apart
-(void)verticlePinchWithGesture: (UIPinchGestureRecognizer *)sender
{
    CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
    CGPoint touch2 = [sender locationOfTouch:1 inView:self.mainScrollView];
    
    CGPoint midPoint = [self findMidPointBetween:touch1 and:touch2];
    
    if(touch1.y>touch2.y)
    {
        [self findElementsFromPinchPoint:midPoint andLowerTouchPoint: touch1];
        self.startLocationOfUpperTouchPoint = touch2;
        self.startLocationOfLowerTouchPoint = touch1;
    }else
    {
        [self findElementsFromPinchPoint:midPoint andLowerTouchPoint:touch2];
        self.startLocationOfLowerTouchPoint = touch2;
        self.startLocationOfUpperTouchPoint = touch1;
    }
    if(sender.scale >1) [self createNewViewToRevealBetweenPinchViews]; //if it's a pinch apart then create the media tile
}

//Iain
-(CGPoint) findMidPointBetween: (CGPoint) touch1 and: (CGPoint) touch2
{
    CGPoint midPoint = CGPointZero;
    midPoint.x = (touch1.x + touch2.x)/2;
    midPoint.y = (touch1.y + touch2.y)/2;
    return midPoint;
}


#pragma mark Identify views involved in pinch

//Iain
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


#pragma mark Handle movement of pinched views

//Iain
-(void) handleVerticlePinchGestureChanged: (UIPinchGestureRecognizer *)gesture
{
    [self handleUpperViewWithGesture:gesture]; //handle view of the top finger and views above it
    [self handleLowerViewWithGesture:gesture]; //handle view of the bottom finger and views below it
    
    if([gesture numberOfTouches] ==2 && gesture.scale >1)//objects are being pinched apart
    {
        [self handleRevealOfNewMediaViewWithGesture:gesture]; //reveal the new mediaimageview
        
    }else if([gesture numberOfTouches] ==2 && gesture.scale <1)//objects are being pinched together
    {
        if([self sufficientOverlapBetweenPinchedObjects])
        {
            //checks of the tiles are both collections. If so then no pinching together
            if(![self tilesOkToPinch] || ![self.upperPinchView isKindOfClass:[PinchView class]] || ![self.lowerPinchView isKindOfClass:[PinchView class]]) return;
            
            UIScrollView * keeping_scrollView = (UIScrollView *)self.upperPinchView.superview;
            PinchView * placeHolder = [[PinchView alloc]init];
            
            [self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:self.upperPinchView] withObject:placeHolder];
            
            [self.upperPinchView removeFromSuperview];
            [self.lowerPinchView.superview removeFromSuperview];
            [self.lowerPinchView removeFromSuperview];
            [self.pageElements removeObject:self.lowerPinchView];
            
            
            NSMutableArray* array_of_objects = [[NSMutableArray alloc] initWithObjects:self.upperPinchView,self.lowerPinchView, nil];
            self.lowerPinchView = self.upperPinchView = nil;
            PinchView * pinchView = [PinchView pinchTogether:array_of_objects];
            //format your scrollView and add pinch view
            [self addTapGestureToView:pinchView];
            
            [keeping_scrollView addSubview:pinchView];
            [self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:placeHolder] withObject:pinchView];
            self.pinching = NO;
            [self shiftElementsBelowView:self.articleTitleField];
            [self showPullBar];//make sure the pullbar is showing when things are pinched together
            
            self.lowerPinchView = self.upperPinchView = nil;
        }
    }
}

//checks if the two selected tiles should be pinched together
-(BOOL) tilesOkToPinch
{
    if([self.upperPinchView isKindOfClass:[PinchView class]]  && [self.lowerPinchView isKindOfClass:[PinchView class]])
    {
        if(!((PinchView *)self.upperPinchView).isCollection || !((PinchView *)self.lowerPinchView).isCollection)
        {
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

//Iain
//handle the translation of the upper view
-(void) handleUpperViewWithGesture: (UIPinchGestureRecognizer *)gesture
{
    CGPoint touch1;
    CGPoint touch2;
    NSInteger changeInPosition;
    if([gesture numberOfTouches]==2){
        touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
        touch2 = [gesture locationOfTouch:1 inView:self.mainScrollView];
        
        if((touch1.y<touch2.y)){
            changeInPosition = touch1.y - self.startLocationOfUpperTouchPoint.y;
            self.startLocationOfUpperTouchPoint = touch1;
            self.upperPinchView.superview.frame = [self newTranslationForUpperPinchViewFrameWithChange:changeInPosition];
            self.changeInTopViewPosition = changeInPosition;
            [self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
        }else if ( touch2.y < touch1.y){
            changeInPosition = touch2.y - self.startLocationOfUpperTouchPoint.y;
            self.startLocationOfUpperTouchPoint = touch2;
            self.upperPinchView.superview.frame = [self newTranslationForUpperPinchViewFrameWithChange:changeInPosition];
            self.changeInTopViewPosition = changeInPosition;
            [self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
            
        }
    }else if ([gesture numberOfTouches]==1){
        touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
        if(touch1.y < self.startLocationOfUpperTouchPoint.y){
            changeInPosition = touch1.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfUpperTouchPoint = touch1;
            self.upperPinchView.superview.frame = [self newTranslationForUpperPinchViewFrameWithChange:changeInPosition];
            self.changeInTopViewPosition = changeInPosition;
            
            [self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
        }
    }
}

//Handle the translation of the lower view
-(void) handleLowerViewWithGesture: (UIPinchGestureRecognizer *)gesture
{
    CGPoint touch1;
    CGPoint touch2;
    NSInteger changeInPosition;
    
    if([gesture numberOfTouches]==2)
    {
        touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
        touch2 = [gesture locationOfTouch:1 inView:self.mainScrollView];
        
        if((touch1.y>touch2.y))
        {
            changeInPosition = touch1.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfLowerTouchPoint = touch1;
            self.lowerPinchView.superview.frame = [self newTranslationFrameForLowerPinchFrameWithChange:changeInPosition];
            self.changeInBottomViewPostion = changeInPosition;
            [self shiftElementsBelowView:self.lowerPinchView];
        }else if (touch2.y > touch1.y)
        {
            changeInPosition = touch2.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfLowerTouchPoint = touch2;
            self.lowerPinchView.superview.frame = [self newTranslationFrameForLowerPinchFrameWithChange:changeInPosition];
            [self shiftElementsBelowView:self.lowerPinchView];
            self.changeInBottomViewPostion = changeInPosition;
            
        }
    }else if ([gesture numberOfTouches]==1)
    {
        touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
        
        if(touch1.y > self.startLocationOfLowerTouchPoint.y)
        {
            changeInPosition = touch1.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfLowerTouchPoint = touch1;
            self.lowerPinchView.superview.frame = [self newTranslationFrameForLowerPinchFrameWithChange:changeInPosition];
            self.changeInBottomViewPostion = changeInPosition;
            [self shiftElementsBelowView:self.lowerPinchView];
        }
    }
}


//Takes a change in position and constructs the frame for the views new position
-(CGRect) newTranslationFrameForLowerPinchFrameWithChange: (NSInteger) changeInPosition
{
    CGRect frame= CGRectMake(self.lowerPinchView.superview.frame.origin.x,self.lowerPinchView.superview.frame.origin.y+changeInPosition, self.lowerPinchView.superview.frame.size.width, self.lowerPinchView.superview.frame.size.height);
    return frame;
}

//Takes a change in position and constructs the frame for the views new position
-(CGRect) newTranslationForUpperPinchViewFrameWithChange: (NSInteger) changeInPosition
{
    CGRect frame= CGRectMake(self.upperPinchView.superview.frame.origin.x,self.upperPinchView.superview.frame.origin.y+changeInPosition, self.upperPinchView.superview.frame.size.width, self.upperPinchView.superview.frame.size.height);
    return frame;
}

#pragma mark Pinch Apart Failed


#pragma deleting new mdeia view
//Removes the new view being made and resets page
-(void) clearNewMediaView
{
    [self.createdMediaView.superview removeFromSuperview];
    [self.pageElements removeObject:self.createdMediaView];
    [self shiftElementsBelowView:self.articleTitleField];
    self.createdMediaView = nil;//stop pointing to the object so it is freed from memory
}


#pragma mark - Media Tile Options -
#pragma mark Text
-(void) addTextViewButtonPressedAsBaseView: (BOOL) isBaseView
{
    if(!isBaseView)
    {
        NSInteger index = [self.pageElements indexOfObject:self.createdMediaView];
        if(index != NSNotFound)
        {
            if(!index)
            {
                [self newPinchObjectBelowView:nil fromView: nil isTextView:YES];
                [self createVerbatmImageScrollViewFromPinchView:self.pageElements[0] andTextView:[[VerbatmUITextView alloc]init]];

                [self clearNewMediaView];
            }else
            {
                UIView * view;
                if(index)
                {
                    view = [self.pageElements objectAtIndex:(index-1)];
                }
                
                if(view)
                {
                    [self newPinchObjectBelowView:view fromView: nil isTextView:YES];
                    [self createVerbatmImageScrollViewFromPinchView:self.pageElements[[self.pageElements indexOfObject:view] +1] andTextView:[[VerbatmUITextView alloc]init]];
                    [self clearNewMediaView];
                }
            }
        }
    }
    
    
    if(isBaseView)
    {
        
        UIView * view = [self findSecondToLastElementInPageElements]; //returns nil if there are less than two objects in page elements
        if(view)
        {
            [self newPinchObjectBelowView:view fromView: nil isTextView:YES];
            [self createVerbatmImageScrollViewFromPinchView:self.pageElements[[self.pageElements indexOfObject:view] +1] andTextView:[[VerbatmUITextView alloc]init]];
        }else
        {
            [self newPinchObjectBelowView:nil fromView: nil isTextView:YES];
            [self createVerbatmImageScrollViewFromPinchView:self.pageElements[0] andTextView:[[VerbatmUITextView alloc]init]];
        }
    }
}

-(UIView *) findSecondToLastElementInPageElements
{
    if(!self.pageElements.count) return nil;
    
    unsigned long last_index =  self.pageElements.count -1;
    
    if(last_index) return self.pageElements[last_index -1];
    return nil;
}



#pragma mark Image/Video

-(void) addMultiMediaButtonPressedAsBaseView:(BOOL)isBaseView fromView: (MediaSelectTile *) tile
{
    if(self.baseMediaTileSelector.dashed) [self.baseMediaTileSelector returnToButtonView];
    
    self.index = ([self.pageElements indexOfObject:tile]-1);
    
    [self presentEfficientGallery];
    //[self.gallery presentGallery];
}

-(void)didSelectImageView:(VerbatmImageView*)imageView
{
    [(MediaSelectTile *)self.createdMediaView returnToButtonView];
    
    if(self.index==-1 || self.pageElements.count==1)
    {
        [self animateView:imageView InToPositionUnder:self.articleTitleField];
    }else
    {
        [self animateView:imageView InToPositionUnder:self.pageElements[self.index]];
    }
    
}

-(void) animateView:(UIView*) view InToPositionUnder: (UIView *) topView
{
    
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    CGRect frame;
    if(topView == self.articleTitleField) {
        frame  = CGRectMake((self.view.frame.size.width/2) - (view.frame.size.width/2), self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height + ELEMENT_OFFSET_DISTANCE, view.frame.size.width, view.frame
                            .size.height);
    }else {
        CGFloat x_coord = (self.view.frame.size.width/2) - (view.frame.size.width/2);
        
        CGFloat y_coord = (topView.superview.frame.origin.y + topView.superview.frame.size.height + ELEMENT_OFFSET_DISTANCE) - self.mainScrollView.contentOffset.y;
        frame = CGRectMake(x_coord, y_coord,view.frame.size.width, view.frame.size.height);
    }
    
    [UIView animateWithDuration:IMAGE_SWIPE_ANIMATION_TIME animations:^{
        view.frame = frame;
        if([view isKindOfClass:[VerbatmImageView class]] && ((VerbatmImageView*)view).isVideo){
            if ([[view.layer.sublayers firstObject] isKindOfClass:[AVPlayerLayer class]]) {
                AVPlayerLayer* layer = (AVPlayerLayer*)[view.layer.sublayers firstObject];
                layer.frame = view.bounds;
            }
        }
    } completion:^(BOOL finished) {
        if(finished) {
            if(topView == self.articleTitleField) {
                [self newPinchObjectBelowView:nil fromView: view isTextView:NO];
            } else {
                [self newPinchObjectBelowView:self.pageElements[self.index] fromView: view isTextView:NO];
            }
            [view removeFromSuperview];
            self.index ++;//makes it that the next image is below this image just added
        }
    }];
}

- (void) newPinchObjectBelowView: (UIView *)upperView withPinchView:(PinchView *) pinchView {
    NSLock  * lock =[[NSLock alloc] init];
    //thread safety
    [lock lock];
    
    [self addTapGestureToView:pinchView];
    
    UIScrollView * sv = [[UIScrollView alloc]init];
    
    [self formatNewScrollView:sv];
    
    if(!upperView)
    {
        sv.frame = CGRectMake(0,self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height, self.defaultPersonalScrollViewFrameSize_closedElement.width, self.defaultPersonalScrollViewFrameSize_closedElement.height);
        
        [self.pageElements insertObject:pinchView atIndex:0];
        
    }else{
        NSInteger index = [self.pageElements indexOfObject:upperView];
        UIScrollView * sv_reference = (UIScrollView *)upperView.superview;
        
        sv.frame = CGRectMake(sv_reference.frame.origin.x, sv_reference.frame.origin.y+sv_reference.frame.size.height, sv_reference.frame.size.width, sv_reference.frame.size.height);
        [self.pageElements insertObject:pinchView atIndex:index+1];
    }
    
    self.index ++;//makes it that the next image is below this image just added
    
    [lock unlock];
    [sv addSubview:pinchView];
    [self.mainScrollView addSubview:sv];
    [self shiftElementsBelowView:self.articleTitleField];
    
    
    //imageview's get added for some reason- so this is a quick patch that removes the views
    //don't want. The bug should be reexamined
    for (int i = 0; i < sv.subviews.count; i++)
    {
        if(![sv.subviews[i] isKindOfClass:[PinchView class]])[sv.subviews[i] removeFromSuperview];
    }
}

- (PinchView *) newPinchObjectBelowView:(UIView *)upperView fromView: (UIView *) view isTextView: (BOOL) isText {
    PinchView * pinchView=nil;
	NSMutableArray *media = [[NSMutableArray alloc]init];
    
    if(isText)
    {
        UITextView * textView = [[UITextView alloc]init];
		[media addObject: textView];
        
    } else if (view) {
		[media addObject: view];
    }

	pinchView = [[PinchView alloc] initWithRadius:[self.closedElement_Radius floatValue] withCenter:self.closedElement_Center andMedia:media];
    
    if (pinchView) {
        [self newPinchObjectBelowView:upperView withPinchView:pinchView];
    }
    return pinchView;
}

- (PinchView *) newPinchObjectBelowView:(UIView *)upperView fromData: (id) data {
	PinchView * pinchView=nil;
	if(data)
	{
		NSMutableArray *media = [[NSMutableArray alloc]init];
		[media addObject: data];

		pinchView = [[PinchView alloc] initWithRadius:[self.closedElement_Radius floatValue] withCenter:self.closedElement_Center andMedia:media];

	}
    if (pinchView) {
        [self newPinchObjectBelowView:upperView withPinchView:pinchView];
    }
    return pinchView;
}

#pragma mark Enter new view in page
//Takes two views and places one below the other with a scroll view
//Only called if the view is multimedia - not for textView!
-(void) addView:(UIView *) view underView: (UIView *) topView
{
    //create frame for the personal scrollview of the new text view
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    
    
    if(topView ==self.articleTitleField)
    {
        //note that this depends on the fact that the first personal scrollview is still being pointed to by the iboulet even if the object was deleted.
        newPersonalScrollView.frame = CGRectMake(0,self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height + ELEMENT_OFFSET_DISTANCE, self.defaultPersonalScrollViewFrameSize_closedElement.width, self.defaultPersonalScrollViewFrameSize_closedElement.height);
        
    }else
    {
        newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrameSize_closedElement.width, self.defaultPersonalScrollViewFrameSize_closedElement.height);
    }
    
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    
    //new textview
    //format scrollview and text view
    
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(view) [newPersonalScrollView addSubview:view]; //textview is subview of scroll view
    
    //snap the view to the top of the screen
    if(![view isKindOfClass:[MediaSelectTile class]])[self snapToTopView:view];
    
    //store the new view in our array
    [self storeView:view inArrayAsBelowView:topView];
    
    //reposition views on screen
    [self shiftElementsBelowView:view];
}


#pragma mark - Change position of elements -
//attempt 1
-(void) findSelectedViewFromSender:(UILongPressGestureRecognizer *)sender
{
    
    CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
    
    for (int i=0; i<self.pageElements.count; i++)
    {
        UIView * view = ((UIView *)self.pageElements[i]).superview;
        UIView * first_view = ((UIView *)self.pageElements[0]).superview;
        
        if (touch1.y >= first_view.frame.origin.y )//make sure touch is not above the first view
        {
            if((view.frame.origin.y+view.frame.size.height)>touch1.y)//we stop when we find the first one
            {
                self.selectedView_Pan = self.pageElements[i];
                [self.mainScrollView bringSubviewToFront:self.selectedView_Pan.superview];
                return;
            }
        }
    }
    self.selectedView_Pan = Nil;
}



- (IBAction)longPressSensed:(UILongPressGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (!self.selectedView_Pan) return;//if we didn't find the view then leave
        
        if([self.selectedView_Pan isKindOfClass:[MediaSelectTile class]] && ((MediaSelectTile *)self.selectedView_Pan).baseSelector) return;
        
        CGRect newFrame = CGRectMake(self.originalFrame.origin.x, self.originalFrame.origin.y, self.selectedView_Pan.superview.frame.size.width, self.selectedView_Pan.superview.frame.size.height);
        self.selectedView_Pan.superview.frame = newFrame;
        
        if([self.selectedView_Pan isKindOfClass:[PinchView class]])
        {
            [((PinchView *)self.selectedView_Pan) unmarkAsSelected];
        }
        //self.selectedView_Pan.superview.backgroundColor = [UIColor clearColor];//for debugging
        self.selectedView_Pan = Nil;//sanitize for next run
        
        [self shiftElementsBelowView:self.articleTitleField];
        [self adjustMainScrollViewContentSize];
    }
    
    
    //make sure it's a single finger touch and that there are multiple elements on the screen
    if(self.pageElements.count==0 || [sender numberOfTouches] != 1) return;
    
    
    //first lets assume that this is an element in the regular stream
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        [self findSelectedViewFromSender:sender];
        if (!self.selectedView_Pan) return;//if we didn't find the view then leave
        
        if([self.selectedView_Pan isKindOfClass:[MediaSelectTile class]] && ((MediaSelectTile *)self.selectedView_Pan).baseSelector) return;
        
        self.startLocationOfTouchPoint_PAN = [sender locationOfTouch:0 inView:self.mainScrollView];
        self.originalFrame =self.selectedView_Pan.superview.frame;
        if(![self.selectedView_Pan isKindOfClass:[PinchView class]])
        {
            //if the object is not a pinchview it should not be movable
            sender.enabled = NO;
            sender.enabled= YES;
            return;
        }
        
        [((PinchView *)self.selectedView_Pan) markAsSelected];
        
        //self.selectedView_Pan.superview.backgroundColor = [UIColor blueColor];//for debugging
        
    }
    
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        
        if (!self.selectedView_Pan || ([self.selectedView_Pan isKindOfClass:[MediaSelectTile class]] && ((MediaSelectTile *)self.selectedView_Pan).baseSelector)) return;//if we didn't find the view then leave
        
        CGPoint touch1 = [sender locationOfTouch:0 inView:self.mainScrollView];
        NSInteger y_differrence  = touch1.y - self.startLocationOfTouchPoint_PAN.y;
        self.startLocationOfTouchPoint_PAN = touch1;
        
        //ok so move the view up or down by the amount the finger has moved
        CGRect newFrame = CGRectMake(self.selectedView_Pan.superview.frame.origin.x, self.selectedView_Pan.superview.frame.origin.y + y_differrence, self.selectedView_Pan.superview.frame.size.width, self.selectedView_Pan.superview.frame.size.height);
        [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
            self.selectedView_Pan.superview.frame = newFrame;
        }] ;
        
        NSInteger view_index = [self.pageElements indexOfObject:self.selectedView_Pan];
        UIView * topView=Nil;
        UIView * bottomView=Nil;
        
        if(view_index !=0)
        {
            topView  = self.pageElements[view_index-1];
            if(self.selectedView_Pan != [self.pageElements lastObject])
            {
                bottomView = self.pageElements[view_index +1];
            }
        }else if (view_index==0)
        {
            bottomView = self.pageElements[view_index +1];
        }else if (self.selectedView_Pan == [self.pageElements lastObject])
        {
            topView  = self.pageElements[view_index-1];
        }
        
        if(topView && bottomView)
        {
            //object moving up
            if(newFrame.origin.y +(newFrame.size.height/2) > topView.superview.frame.origin.y && newFrame.origin.y+(newFrame.size.height/2) < (topView.superview.frame.origin.y + topView.superview.frame.size.height))
            {
                [self swapObject:self.selectedView_Pan andObject:topView];//exchange their positions in page elements array
                
                [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
                    self.potentialFrame = topView.superview.frame;
                    topView.superview.frame = CGRectMake(self.originalFrame.origin.x, self.originalFrame.origin.y, topView.superview.frame.size.width, topView.superview.frame.size.height);
                    self.originalFrame = self.potentialFrame;
                }];
                
                //object moving down
            }else if(newFrame.origin.y + (newFrame.size.height/2) +CENTERING_OFFSET_FOR_TEXT_VIEW > bottomView.superview.frame.origin.y && newFrame.origin.y+ (newFrame.size.height/2)+CENTERING_OFFSET_FOR_TEXT_VIEW < (bottomView.superview.frame.origin.y + bottomView.superview.frame.size.height))
            {
                
                if(bottomView == self.baseMediaTileSelector) return;
                
                [self swapObject:self.selectedView_Pan andObject:bottomView];//exchange their positions in page elements array
                
                [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
                    self.potentialFrame = bottomView.superview.frame;
                    bottomView.superview.frame = CGRectMake(self.originalFrame.origin.x, self.originalFrame.origin.y, bottomView.superview.frame.size.width, bottomView.superview.frame.size.height);
                    self.originalFrame = self.potentialFrame;
                }];
            }
            
            //move the offest of the main scroll view
            if(self.mainScrollView.contentOffset.y > self.selectedView_Pan.superview.frame.origin.y -(self.selectedView_Pan.superview.frame.size.height/2) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0))
            {
                CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET);
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.mainScrollView.contentOffset = newOffset;
                }];
                
            } else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_Pan.superview.frame.origin.y + self.selectedView_Pan.superview.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height)
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
                [self swapObject:self.selectedView_Pan andObject:bottomView];//exchange their positions in page elements array
                
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    self.potentialFrame = bottomView.superview.frame;
                    bottomView.superview.frame = CGRectMake(self.originalFrame.origin.x, self.originalFrame.origin.y, bottomView.superview.frame.size.width, bottomView.superview.frame.size.height);
                    self.originalFrame = self.potentialFrame;
                }];
            }
            
            //move the offest of the main scroll view
            if(self.mainScrollView.contentOffset.y > self.selectedView_Pan.superview.frame.origin.y -(self.selectedView_Pan.superview.frame.size.height/2) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0))
            {
                CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET);
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.mainScrollView.contentOffset = newOffset;
                }];
                
            } else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_Pan.superview.frame.origin.y + self.selectedView_Pan.superview.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height)
            {
                CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET);
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.mainScrollView.contentOffset = newOffset;
                }];
            }
            
        }else if (self.selectedView_Pan == [self.pageElements lastObject])
        {
            if(newFrame.origin.y +(newFrame.size.height/2) > topView.superview.frame.origin.y && newFrame.origin.y+(newFrame.size.height/2) < (topView.superview.frame.origin.y + topView.superview.frame.size.height))
            {
                [self swapObject:self.selectedView_Pan andObject:topView];//exchange their positions in page elements array
                
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    self.potentialFrame = topView.superview.frame;
                    topView.superview.frame = CGRectMake(self.originalFrame.origin.x, self.originalFrame.origin.y, topView.superview.frame.size.width, topView.superview.frame.size.height);
                    
                    self.originalFrame = self.potentialFrame;
                }];
                
            }
            
            //move the offest of the main scroll view
            if(self.mainScrollView.contentOffset.y > self.selectedView_Pan.superview.frame.origin.y -(self.selectedView_Pan.superview.frame.size.height/2) && (self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET >= 0))
            {
                CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y - AUTO_SCROLL_OFFSET);
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.mainScrollView.contentOffset = newOffset;
                }];
                
            } else if (self.mainScrollView.contentOffset.y + self.view.frame.size.height < (self.selectedView_Pan.superview.frame.origin.y + self.selectedView_Pan.superview.frame.size.height) && self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET < self.mainScrollView.contentSize.height)
            {
                CGPoint newOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + AUTO_SCROLL_OFFSET);
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.mainScrollView.contentOffset = newOffset;
                }];
            }
        }
    }
    
}



//when someone closes an image let the view slide down slightly
-(void) scrollMainScrollViewDownForEffect
{
    if(self.mainScrollView.contentOffset.y > 80)
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y -80);
        }];
    }
    
    
}

//swaps to objects in the page elements array
-(void)swapObject: (UIView *) obj1 andObject: (UIView *) obj2
{
    NSInteger index1 = [self.pageElements indexOfObject:obj1];
    NSInteger index2 = [self.pageElements indexOfObject:obj2];
    [self.pageElements replaceObjectAtIndex:index1 withObject:obj2];
    [self.pageElements replaceObjectAtIndex:index2 withObject:obj1];
}


#pragma mark - Lazy Instantiation -
///Iain
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


#pragma mark- MIC

-(NSInteger) totalChangeInViewPositions
{
    return self.changeInBottomViewPostion - self.changeInTopViewPosition;
}

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
    if(!tile) return;//make sure there is something to delete
    [tile removeFromSuperview];
    [self.tileSwipeViewUndoManager registerUndoWithTarget:self selector:@selector(undoTileDelete:) object:@[tile, index]];
    [self showPullBar];//show the pullbar so that they can undo
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
    
    if([view isKindOfClass:[PinchView class]])
    {
        [((PinchView *)view) unmarkAsDeleting];
    }
    
    [self returnObject:[PinchView pinchObjectFromPinchObject:(PinchView *)view] ToDisplayAtIndex:index.integerValue];
}

-(void)returnObject: (UIView *) view ToDisplayAtIndex:(NSInteger) index
{
    
    UIScrollView * newSV = [[UIScrollView  alloc] init];
    
    if(index)
    {
        UIScrollView * topSv = (UIScrollView *)((UIView *)self.pageElements[(index -1)]).superview;
        newSV.frame = CGRectMake(topSv.frame.origin.x, topSv.frame.origin.y+ topSv.frame.size.height, topSv.frame.size.width, topSv.frame.size.height);
        
    }else if (!index)
    {
        newSV.frame = CGRectMake(0,self.articleTitleField.frame.origin.y + self.articleTitleField.frame.size.height, self.defaultPersonalScrollViewFrameSize_closedElement.width, self.defaultPersonalScrollViewFrameSize_closedElement.height);
    }
    
    [self.pageElements insertObject:view atIndex:index];
    [self formatNewScrollView:newSV];
    [newSV addSubview:view];//expecting the object to have kept its old frame
    [self.mainScrollView addSubview:newSV];
    [self shiftElementsBelowView:self.articleTitleField];
    [self addTapGestureToView:(PinchView *)view];
}


#pragma - mainScrollView handler -
-(void)freeMainScrollView:(BOOL) isFree
{
    if(isFree)
    {
        self.mainScrollView.scrollEnabled = isFree;
    }else{
        self.mainScrollView.contentOffset = CGPointMake(0, 0);
        self.mainScrollView.scrollEnabled = isFree;
    }
}


#pragma mark - Open Element Collection -

#pragma mark Snap Item to the top
//give me a view and I will snap it to the top of the screen
-(void)snapToTopView: (UIView *) view
{
    UIScrollView * scrollview = (UIScrollView *) view.superview;
    
    int y_difference = scrollview.frame.origin.y - self.mainScrollView.contentOffset.y;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + y_difference);//not that y_difference could be negative
    }];
    
}




#pragma mark - Sense Tap Gesture -
#pragma mark ImageScrollView

-(void) addTapGestureToCustomImageScrollView: (VerbatmImageScrollView *) isv
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImageScrollview:)];
    
    if(isv.gestureView)[isv.gestureView addGestureRecognizer:tap];
    else [isv addGestureRecognizer:tap];
}

-(void) removeImageScrollview: (UITapGestureRecognizer *) sender
{
    VerbatmImageScrollView * isv = self.openImageScrollView;
	//TODO(sierra): what is this for??
//    if(self.openImagePinchView.there_is_picture)[self.openImagePinchView changePicture:self.openImageScrollView.imageView.image];
    if(self.openImagePinchView.there_is_text)
    {
        if([self.openImageScrollView.textView.text isEqualToString:@""])
        {
            [self.openImagePinchView.superview removeFromSuperview];
            [self.pageElements removeObject:self.openImagePinchView];
            [self shiftElementsBelowView:self.articleTitleField];
        }else
        {
            [self.openImagePinchView changeText:self.openImageScrollView.textView];
        }
    }
    [isv.textView resignFirstResponder];

	//if there is a video lets stop it
	if (isv.videoView) {
   	 [isv.videoView pauseVideo];
	}
    [isv removeFromSuperview];
    
    //makes sure the vidoes are playing..may need to make more efficient
    isv = nil;
    self.openImageScrollView = nil;
    [self playVideos];
    [self.openImagePinchView renderMedia];
    //[self showPullBar];
}

#pragma mark ImageScrollView
-(void)addTapGestureToView: (PinchView *) pinchView
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectTapped:)];
    [pinchView addGestureRecognizer:tap];
}

-(void) pinchObjectTapped:(UITapGestureRecognizer *) sender
{
    
    if(![sender.view isKindOfClass:[PinchView class]]) return; //only accept touches from pinch objects
    
    PinchView * pinch_object = (PinchView *)sender.view;
    if(pinch_object.hasMultipleMedia)
    {
        [self openCollection:pinch_object];//checks if there is anything to open by telling you if the element has multiple things in it
    }
    if(!pinch_object.isCollection && !pinch_object.hasMultipleMedia) { //tap to open an element for viewing or editing
        
        NSMutableArray * array = [pinch_object mediaObjects];
        UIView* mediaView = [array firstObject]; //could be textview or customimageview
        
        if([mediaView isKindOfClass:[UITextView class]]) {
            
            [self createVerbatmImageScrollViewFromPinchView:pinch_object andTextView:(VerbatmUITextView *)mediaView];
        } else if([mediaView isKindOfClass:[NSData class]]) {
            [self createVerbatmImageScrollViewFromPinchView:pinch_object andImageView:(NSData *)mediaView];
		} else if([mediaView isKindOfClass:[AVAsset class]]) {
			[self createVerbatmImageScrollViewFromPinchView:pinch_object andVideo:(AVAsset *)mediaView];
		}

        [self pauseAllVideos];//when things are offscreen then pause all videos
        
    }
    [self hidePullBar];//make sure the pullbar is not available
}

-(void) createVerbatmImageScrollViewFromPinchView: (PinchView *) pinchView andVideo: (AVAsset*) videoAsset {
	VerbatmImageScrollView * imageScroll = [[VerbatmImageScrollView alloc] initCustomViewWithFrame:self.view.bounds ];
	imageScroll.delegate = self;

	[self.view addSubview:imageScroll];
	[imageScroll addVideo:videoAsset];

	imageScroll.showsHorizontalScrollIndicator = NO;
	imageScroll.showsVerticalScrollIndicator = NO;
	[self addTapGestureToCustomImageScrollView:imageScroll];
	self.openImageScrollView = imageScroll;
	self.openImagePinchView = pinchView;
}

-(void) createVerbatmImageScrollViewFromPinchView: (PinchView *) pinchView andImageView: (NSData*)imageView {
    
    VerbatmImageScrollView * imageScroll = [[VerbatmImageScrollView alloc] initCustomViewWithFrame:self.view.bounds ];
    imageScroll.delegate = self;
    
    [self.view addSubview:imageScroll];
    [imageScroll addImage:imageView];
    
    imageScroll.showsHorizontalScrollIndicator = NO;
    imageScroll.showsVerticalScrollIndicator = NO;
    [self addTapGestureToCustomImageScrollView:imageScroll];
    self.openImageScrollView = imageScroll;
    self.openImagePinchView = pinchView;
}

-(void) createVerbatmImageScrollViewFromPinchView: (PinchView *) pinchView andTextView: (VerbatmUITextView *) textView
{
    if (!textView) {
        return; //TODO: error message
    }
    VerbatmImageScrollView * textScroll = [[VerbatmImageScrollView alloc ]initCustomViewWithFrame:self.view.bounds];
    textScroll.delegate = self;
    
    
    [self.view addSubview:textScroll];
    [textScroll createTextViewFromTextView: textView];
    textScroll.textView.delegate = self;
    textScroll.showsHorizontalScrollIndicator = NO;
    textScroll.showsVerticalScrollIndicator = NO;
    [textScroll.textView becomeFirstResponder];
    [self addTapGestureToCustomImageScrollView:textScroll];
    self.openImageScrollView = textScroll;
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
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        int x_position = ELEMENT_OFFSET_DISTANCE;
        for(int i = 0; i< array.count; i++)
        {
            PinchView * pinch_view = array[i];
            CGRect new_frame =CGRectMake(x_position, ELEMENT_OFFSET_DISTANCE/2, [self.closedElement_Radius intValue] *2, [self.closedElement_Radius intValue] * 2);
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
-(void) hidePullBar
{
    NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_HIDE_PULLBAR object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)showPullBar
{
    NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_SHOW_PULLBAR object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - close gallery -
//when the user taps on empty space the gallery leaves
- (IBAction)closeGallery:(UITapGestureRecognizer *)sender
{
    [self.gallery dismissGallery];//make sure gallery is closed
}


#pragma mark - alert the gallery -

-(void)alertGallery:(ALAsset*)asset
{
    [self.gallery addMediaToGallery:asset];
}


#pragma mark - video playing methods -

-(void)playVideo:(AVURLAsset*)asset forView:(UIImageView*)view
{
    // Create an AVPlayerItem using the asset
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    // Create the AVPlayer using the playeritem
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //MUTE THE PLAYER
    [self mutePlayer:player forAsset:asset];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    // Create an AVPlayerLayer using the player
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = view.bounds;
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    // Add it to your view's sublayers
    [view.layer addSublayer:playerLayer];
    // You can play/pause using the AVPlayer object
    [player play];
}

//mutes the player
-(void)mutePlayer:(AVPlayer*)avPlayer forAsset:(AVURLAsset*)asset
{
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =  [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    [[avPlayer currentItem] setAudioMix:audioZeroMix];
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}




#pragma mark - Clean up Content Page -
//we clean up the content page if we press publish or simply want to reset everything
//all the text views are cleared and all the pinch objects are cleared
//We also reload the gallery

-(void)cleanUpNotification
{
    [self cleanUp];
}

-(void)cleanUp
{
    [self.pageElements removeAllObjects];
    [self removeCreationObjectsFromScrollview];
    [self clearTextFields];
    [self createBaseSelector];
    
}

-(void)clearTextFields
{
    self.sandwhichWhat.text = @"";
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
    picker.title = @"Verbatm";
    picker.customNavigationBarPrompt = @"Custom helper message!";
    
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
    //self.index ++;//makes it that the next image is below this image just added
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
                [self addAssetToView: imageData];
                
            }];
        }else
        {
            [iman requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                [self addAssetToView:asset];
                
            }];
        }
    }
}


- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray
{
    
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self presentAssets:assetArray];
    }];
    
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);
}


@end