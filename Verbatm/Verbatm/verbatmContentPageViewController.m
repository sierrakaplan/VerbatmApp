

//
//  verbatmContentPageViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmContentPageViewController.h"
#import "verbatmMediaPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "verbatmUITextView.h"
#import "verbatmGalleryHandler.h"
#import "verbatmCustomMediaSelectTile.h"
#import "verbatmCustomScrollView.h"
#import "ILTranslucentView.h"
#import "verbatmCustomPinchView.h"

@interface verbatmContentPageViewController () < UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,verbatmCustomMediaSelectTileDelegate,verbatmGalleryHandlerDelegate>

#pragma mark - *Text input outlets
@property (weak, nonatomic) IBOutlet verbatmUITextView *firstContentPageTextBox;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) verbatmCustomMediaSelectTile * baseMediaTileSelector;

#pragma mark - *Stylistic subviews
@property (weak, nonatomic) IBOutlet UIView *topLayerViewBottom;

#pragma mark - *Display manipulation outlets
@property (weak, nonatomic) IBOutlet verbatmCustomScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *personalScrollViewOfFirstContentPageTextBox;
@property (weak, nonatomic) IBOutlet UILabel *wordsLeftLabel;
@property (strong, nonatomic) verbatmGalleryHandler * gallery;

#pragma mark - *Helper properties


#pragma mark TextView related properties
@property (nonatomic) CGRect caretPosition;//position of caret on screen relative to scrollview origin

#pragma mark Keyboard related properties
@property (nonatomic) NSInteger keyboardHeight;

#pragma mark Default frame properties
@property (nonatomic) CGRect defaultTextBoxFrame;
@property (nonatomic) CGRect defaultPersonalScrollViewFrame;

#pragma mark Standard offset and content size properties
@property (nonatomic) CGPoint standardContentOffsetForPersonalView;// gives the standard content offset for each personalScrollview.
@property (nonatomic) CGSize standardContentSizeForPersonalView; //gives the standard content size for each personal Scrollview

#pragma mark Helpful integer stores
@property (nonatomic) NSInteger numberOfWordsLeft;//number of words left in the article
@property (nonatomic) NSInteger index; //the index of the first view that is pushed up/down by the pinch/stretch gesture
@property (nonatomic, strong) NSString * textBeforeNavigationLabel;

#pragma mark pich gesture related Properties
@property(nonatomic) CGPoint startLocationOfLowerTouchPoint;
@property (nonatomic) CGPoint startLocationOfUpperTouchPoint;
@property (nonatomic) NSInteger changeInTopViewPosition;
@property (nonatomic) NSInteger changeInBottomViewPostion;
@property (nonatomic) NSInteger totalChangeInViewPositions;
@property (nonatomic,strong) UIView * lowerPinchView;
@property (nonatomic,strong) UIView * upperPinchView;
@property (nonatomic,strong) UIView * createdMediaView;
@property (nonatomic) BOOL pinching; //tells if pinching is occurring

#pragma mark undo related properties
@property (nonatomic) BOOL isUndoInProgress;
@property (nonatomic, strong) NSUndoManager * tileSwipeViewUndoManager;

#pragma mark - Navigation constants
#define UNWIND_SEGUE_IDENTIFIER @"returnFromContentPage"
#define UNWIND_SEGUE_SELECTOR goToRoot:

#pragma mark - Parameters to function within

#define MAX_WORD_LIMIT 350

#define CENTERING_OFFSET_FOR_TEXT_VIEW 30 //the gap between the bottom of the screen and the cursor
#define CURSOR_BASE_GAP 10
#define ELEMENT_OFFSET_DISTANCE 20 //distance between elements on the page


#define TEXT_BOX_FONT_SIZE 15
#define VIEW_WALL_OFFSET 20
#define ANIMATION_DURATION 0.5
#define PINCH_DISTANCE_FOR_ANIMATION 100

#define NUMBER_OF_LINES_BEFORE_BOUNDS_ADJUST 24
#define SIZE_REQUIRED_MIN 100 //size for text tiles

#define TOP_LAYER_BOTTOM_APPEAR_TIME_secs 4

#define IMAGE_SWIPE_ANIMATION_TIME 0.5 //time it takes to animate a image from the top scroll view into position
#define MIN_OFFSET_FOR_NAVIGATION -100 //how far the user has to pull the scrollview in order to leave the page

#pragma mark container view transitions
    #define CONTENT_PAGE_MINI_SCREEN @"contentPageMiniMode"
    #define CONTENT_PAGE_FULL_SCREEN @"contentPageFullMode"

#pragma TextView properties
#define BACKGROUND_COLOR clearColor
#define FONT_COLOR whiteColor


@end

/*
 Perhaps for word count lets prevent typing- lets just not let them publish with the word count over 350.
 It's more curtious.
 */


@implementation verbatmContentPageViewController

#pragma mark - Prepare view
//By Iain
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Give custom scroll view access to our page elements
    ((verbatmCustomScrollView *) self.mainScrollView).pageElements = self.pageElements;
    
    //initialise the verbatmGallery early so that it has time to load
    self.gallery = [[verbatmGalleryHandler alloc]initWithView:self.view];
    
    //set up values for use later- standard frames, content offset and content seize
    [self createAndRecordDefaultScrollviewAndTextViewFrames];
    [self recordStandardOffsetAndStandardContentsizeForPersonalScrollviewsAndFormatAppropriately];
    
    //done after the recording functions because we rely on default sizes that are set there
    [self addOriginalViews];
    
    //make sure bar for keyboard is not visible
    self.topLayerViewBottom.hidden=YES;
    
    [self addBlurView];
    [self setPlaceholderColors];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForMiniScreenMode:)
                                                 name:CONTENT_PAGE_MINI_SCREEN
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForFullScreenMode:)
                                                 name:CONTENT_PAGE_FULL_SCREEN
                                               object:nil];

}

-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}



//gives the placeholders a white color
-(void) setPlaceholderColors
{
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
}

-(void) addBlurView
{
    //return;//to be removed
    ILTranslucentView * blurView = [[ILTranslucentView alloc] init];
    blurView.frame = self.view.frame;
    blurView.translucentStyle = UIBarStyleBlack;
    blurView.translucentAlpha = 1;
    [self.view insertSubview:blurView atIndex:0];
}

//Adds the two views the user gets the first time the open the app
-(void) addOriginalViews
{
    
    //checks to see if the new text view has been added by the storyboard and removes it
    if(self.pageElements.count >0)
    {
        [self.firstContentPageTextBox.superview removeFromSuperview];
        self.firstContentPageTextBox = self.pageElements[0];
    }
    
    //add first page element to array and first media tile element
    if(self.pageElements.count == 0)
    {
        [self storeView:self.firstContentPageTextBox inArrayAsBelowView:Nil];
    }
    
    //make sure there is only one element on the page- this ensures that we add our media button only at the beginning of the
    //app cycle
    if(self.pageElements.count==1 && [[self.pageElements firstObject] isKindOfClass:[UITextView class]])
    {
        CGRect frame = CGRectMake(self.defaultTextBoxFrame.origin.x,
                                  ELEMENT_OFFSET_DISTANCE/2,
                                  self.defaultTextBoxFrame.size.width,
                                  self.defaultTextBoxFrame.size.width/2);
        
        self.baseMediaTileSelector.frame = frame;
        self.baseMediaTileSelector.baseSelector =YES;
        self.baseMediaTileSelector.customDelegate = self;
        [self.baseMediaTileSelector createFramesForButtonsWithFrame:frame];
        if(self.pageElements.count ==1) [self addView:self.baseMediaTileSelector underView:self.firstContentPageTextBox];
    }

    //record the mainview of the first text view
    self.firstContentPageTextBox.mainScrollView = self.mainScrollView;
}

//Iain
-(void) createAndRecordDefaultScrollviewAndTextViewFrames
{
    
    //create appropriate generic frame for new textview and save as default
    self.defaultTextBoxFrame  = CGRectMake(self.view.frame.size.width+VIEW_WALL_OFFSET, ELEMENT_OFFSET_DISTANCE/2, self.articleTitleField.frame.size.width, self.firstContentPageTextBox.frame.size.height);
    self.firstContentPageTextBox.frame = self.defaultTextBoxFrame ;
    
    //create appropriate frame for personal scrollview and save as default
    self.defaultPersonalScrollViewFrame = CGRectMake(self.personalScrollViewOfFirstContentPageTextBox.frame.origin.x, self.personalScrollViewOfFirstContentPageTextBox.frame.origin.y, self.view.frame.size.width, self.defaultTextBoxFrame.size.height+ELEMENT_OFFSET_DISTANCE);
    self.personalScrollViewOfFirstContentPageTextBox.frame = self.defaultPersonalScrollViewFrame;
}

//Iain
//save these offset and contentside values for use later
-(void) recordStandardOffsetAndStandardContentsizeForPersonalScrollviewsAndFormatAppropriately
{
    //set the content offset for the personal scrollview
    self.standardContentOffsetForPersonalView = CGPointMake(self.view.frame.size.width, 0);
    self.personalScrollViewOfFirstContentPageTextBox.contentOffset = self.standardContentOffsetForPersonalView;
    
    self.standardContentSizeForPersonalView = CGSizeMake(self.view.frame.size.width * 3, 0);
    self.personalScrollViewOfFirstContentPageTextBox.contentSize = self.standardContentSizeForPersonalView;
    
    self.personalScrollViewOfFirstContentPageTextBox.bounces=NO;
    self.personalScrollViewOfFirstContentPageTextBox.pagingEnabled=YES;
    
    //Remove scroll indicators
    self.personalScrollViewOfFirstContentPageTextBox.showsHorizontalScrollIndicator = NO;
    self.personalScrollViewOfFirstContentPageTextBox.showsVerticalScrollIndicator = NO;
}

//Iain
-(void) viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //configure views appropriately
    [self configureViews];
    
    //set Scroll View content size
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 3000.0f);
    
    //make sure bar for keyboard is not visible
    self.topLayerViewBottom.hidden=YES;
    
    self.pinching =NO;//initialise pinching property so that we can check it free
}

//Iain
//Set up views
-(void) configureViews
{
    //set frame for top layer bottom view
    self.topLayerViewBottom.frame = CGRectMake(0, self.view.frame.size.height - self.topLayerViewBottom.frame.size.height, self.topLayerViewBottom.frame.size.width, self.topLayerViewBottom.frame.size.height);
    [self setUpKeyboardNotifications];
    //insert any text that was added in previous scenes
    [self setTextEdits];//to be edited
    [self setUpKeyboardPrefferedColors];
    [self setDelegates];
    [self setTextViewFormats];
    [self blackenCursors];
}

//Iain
-(void) blackenCursors
{
    //make cursor black on textfields and textviews
    [[UITextView appearance] setTintColor:[UIColor blackColor]];
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
}

//Iain
//makes the keyboard look black for all views present at the start
-(void) setUpKeyboardPrefferedColors
{
    self.sandwhichWhat.keyboardAppearance = UIKeyboardAppearanceDark;
    self.sandwichWhere.keyboardAppearance = UIKeyboardAppearanceDark;
    self.articleTitleField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    for(UIView * view in self.pageElements)
    {
        if([view isKindOfClass:[UITextView class]])
        {
            ((verbatmUITextView *)view).keyboardAppearance = UIKeyboardAppearanceDark;
        }
        
        //add shadow feature to the text views on the screen
        [self addShadowToView:view];
    }
}


//Iain
-(void) setUpKeyboardNotifications
{
    //Tune in to get notifications of keyboard behavior
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //Listen for when the keyboard is about to disappear
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//Iain
-(void)setTextViewFormats
{
    //Set format textviews
    for(id view in self.pageElements)
    {
        if([view isKindOfClass:[UITextView class]])
        {
            [self formatTextViewAppropriately:view];
        }
    }
}

//Iain
//set appropriate delegates for views on page
-(void) setDelegates
{
    self.firstContentPageTextBox.delegate = self;
    self.gallery.customDelegate = self;
    
    //Set delgates for textviews
    self.sandwhichWhat.delegate = self;
    self.sandwichWhere.delegate = self;
    self.articleTitleField.delegate = self;
    self.mainScrollView.delegate = self;
    
    //set the delegates for elements on page and their personal scroll views
    for(id view in self.pageElements){
        if([view isKindOfClass:[UITextView class]])
        {
            ((verbatmUITextView *) view).delegate= self;
            ((UIScrollView *)((verbatmUITextView *)view).superview).delegate = self;
        }
    }
    
}

//Iain - to be edited
//If the user has entered text at any point- reset it when they return
-(void) setTextEdits
{
    for(UIView * view in self.pageElements)
    {
        [self.mainScrollView addSubview:view.superview];
    }
}


//Figure out which field to start the keyboard on
//Iain
-(void) setFirstResponder
{
    if([self.sandwhichWhat.text length]== 0)
    {
        [self.sandwhichWhat becomeFirstResponder];
    }else if([self.sandwichWhere.text length]==0)
    {
        [self.sandwichWhere becomeFirstResponder];
    }else if([self.articleTitleField.text length]==0)
    {
        [self.articleTitleField becomeFirstResponder];
    }else
    {
        [self.firstContentPageTextBox becomeFirstResponder];
        self.activeTextView = self.firstContentPageTextBox;
    }
}



#pragma mark - *Navigation-
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self shouldTransitionWithScrollViewOffset:self.mainScrollView.contentOffset];
}


-(void) shouldTransitionWithScrollViewOffset: (CGPoint) contentOffset
{
    if(contentOffset.y <= MIN_OFFSET_FOR_NAVIGATION)
    {
        [self.customDelegate leaveContentPage];
    }
}

//Iain
-(void) editTransitionLabelWithScrollViewOffset: (CGPoint) contentOffset
{
    if(contentOffset.y <= MIN_OFFSET_FOR_NAVIGATION)
    {
        if(![self.articleTitleField.text isEqualToString:@"RELEASE TO LEAVE!"])
        {
            self.textBeforeNavigationLabel = self.articleTitleField.text;
        }
        
        self.articleTitleField.text =@"RELEASE TO LEAVE!";
        self.articleTitleField.textColor = [UIColor whiteColor];
        self.articleTitleField.backgroundColor = [UIColor redColor];
        
    }else
    {
        if([self.articleTitleField.text isEqualToString:@"RELEASE TO LEAVE!"])self.articleTitleField.text =self.textBeforeNavigationLabel;
        self.articleTitleField.textColor = [UIColor blackColor];
        self.articleTitleField.backgroundColor = [UIColor whiteColor];
    }
}


//By Iain
- (IBAction)removeViewSwipeGesture:(UISwipeGestureRecognizer *)sender
{
   
}




#pragma mark - Shadow for ScrollView Subviews

//Adds a shadow to whatever view is sent
//Iain
-(void) addShadowToView: (UIView *) view
{
    return;//for now no shadow
    
    if(![view isKindOfClass:[UITextView class]]) return; //make sure we don't add shadow to media views
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}



#pragma mark - *Handling Content TextViews and TextFields for Title and S@ndwich

#pragma mark dismissing the keyboard
//Iain
//Remove keyboard when scrolling page
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == self.mainScrollView)self.mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;//not sure if keeping
}

#pragma mark text views - reacting to content typed in
//Iain
//User has edited the text view somehow so we recount the words in the view. And adjust its size
- (void)textViewDidChange:(UITextView *)textView
{
    //Adjust the bounds of the text view
    [self adjustBoundsOfTextView:(verbatmUITextView *)textView doneEditing:NO updateSCandSE:YES];
    //Edit word count
    [self editWordCountForTextView:(verbatmUITextView *)textView];
    //make sure caret psotion is updated
    [self updateCaretForView:(verbatmUITextView *)textView];
}

//Iain
//Called when user types an input into the textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //If the user has written the max number of words then no more are allowed.
    if(self.numberOfWordsLeft ==0 && [text isEqualToString:@" "])return NO;
    
    //register the stored position of the caret
    [self updateCaretForView: (verbatmUITextView *)textView];
    
    
    //If the user clicked enter add a textview
    if([text isEqualToString:@"\n"])
    {
        [self adjustBoundsOfTextView:(verbatmUITextView *)textView doneEditing:YES updateSCandSE:YES];//resize the textview
        [self createNewTextViewBelowView:textView]; //add a new text view below this one
        return NO;
    }
    
    [self updateScrollViewPosition]; //ensure that the caret is visible
    return YES;
}





#pragma mark scroll positioning of the screen

//Iain
//Update the stored position of the carret within the textview it's in
-(void) updateCaretForView: (verbatmUITextView *) view
{
    self.caretPosition = [view caretRectForPosition:view.selectedTextRange.end];
}

//Iain
//Moves the scrollview to keep the cursor in view - To be fixed
-(void) updateScrollViewPosition
{
    if(self.sandwhichWhat.editing || self.sandwichWhere.editing) return; //if it is the s@andwiches that are set then
    
    //get y-position of caret relative to main view
    NSInteger contentOffSet = self.mainScrollView.contentOffset.y ;
    NSInteger screenHeight =self.view.frame.size.height;
    NSInteger keyboardHeight = self.keyboardHeight;
    NSInteger keyboardBarHeight = self.topLayerViewBottom.frame.size.height;
    NSInteger keyboardYCoordinate= (screenHeight - (keyboardHeight+ keyboardBarHeight)) ;
    
    if(self.containerViewFrame.size.height != self.view.frame.size.height)
    {
        keyboardYCoordinate =self.containerViewFrame.size.height;//((UITextView*)self.pageElements.lastObject).frame.size.height + ELEMENT_OFFSET_DISTANCE;
    }
    
    NSInteger activeViewYOrigin = ((UIScrollView *)(self.activeTextView.superview)).frame.origin.y;
    NSInteger yCoordinateOfCaretRelativeToMainView= activeViewYOrigin +self.activeTextView.frame.origin.y + self.caretPosition.origin.y + self.caretPosition.size.height - contentOffSet;
    
    //If our cursor is inline with or below the keyboard, adjust the scrollview
    if(yCoordinateOfCaretRelativeToMainView > keyboardYCoordinate)
    {
        NSInteger differenceBTWNKeyboardAndTextView = yCoordinateOfCaretRelativeToMainView-(keyboardYCoordinate/*-self.topLayerViewBottom.frame.size.height*/);
        
        CGPoint newScrollViewOffset = CGPointMake(self.mainScrollView.contentOffset.x, (contentOffSet + differenceBTWNKeyboardAndTextView +CENTERING_OFFSET_FOR_TEXT_VIEW));
        
        [self.mainScrollView setContentOffset:newScrollViewOffset animated:YES];
        
    }else if (yCoordinateOfCaretRelativeToMainView-CURSOR_BASE_GAP <= /*contentOffSet*/0) //Checking if the cursor is past the top
    {
        NSInteger differenceBTWNScreenTopAndTextView = yCoordinateOfCaretRelativeToMainView;
        
        CGPoint newScrollViewOffset = CGPointMake(self.mainScrollView.contentOffset.x, (contentOffSet + differenceBTWNScreenTopAndTextView - CENTERING_OFFSET_FOR_TEXT_VIEW*3));
        
        [self.mainScrollView setContentOffset:newScrollViewOffset animated:YES];
    }
    [self shiftElementsBelowView:self.activeTextView];
}




//Iain
//Make sure whatever text field is selected is recorded as the active text view
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.activeTextView = (verbatmUITextView *)textView;
    return true;
}


//Iain
//Gives you the frame for the scrollview to be put under this textview
-(CGRect) personalScrollViewFrameFromTextView:(UITextView *) oldTextView
{
    if(oldTextView){
        CGRect frame =CGRectMake(((UIScrollView *)(oldTextView.superview)).frame.origin.x, (((UIScrollView *)(oldTextView.superview)).frame.origin.y + ((UIScrollView *)(oldTextView.superview)).frame.size.height), ((UIScrollView *)(oldTextView.superview)).frame.size.width, self.defaultTextBoxFrame.size.height + ELEMENT_OFFSET_DISTANCE);
        return frame;
    }
    return CGRectMake(0, 0, 0, 0); //our equivalent of null
}



//Iain
//When prompted it adds a new textview below the one specified
-(void) createNewTextViewBelowView: (UIView *) topView
{
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    
    //create frame for the personal scrollview of the new text view
    if(topView == self.articleTitleField)
    {
        newPersonalScrollView.frame = CGRectMake(self.defaultPersonalScrollViewFrame.origin.x, self.defaultPersonalScrollViewFrame.origin.y, self.defaultPersonalScrollViewFrame.size.width,self.defaultPersonalScrollViewFrame.size.height);
    }else
    {
        newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrame.size.width,self.defaultPersonalScrollViewFrame.size.height);
    }
    
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    
    //new textview
    verbatmUITextView * newTextView = [[verbatmUITextView alloc]init];
    newTextView.mainScrollView = self.mainScrollView;
    newTextView.delegate = self;
    newTextView.backgroundColor = [UIColor BACKGROUND_COLOR];//sets the background as clear
    newTextView.textColor = [UIColor FONT_COLOR];
    
    //format scrollview and text view
    [self setUpParametersForView:newTextView andScrollView: newPersonalScrollView];
    
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(newTextView) [newPersonalScrollView addSubview:newTextView]; //textview is subview of scroll view
    
    //store the new view in our array
    [self storeView:newTextView inArrayAsBelowView:topView];
    
    //add aesthetic touch
    [self addShadowToView:newTextView];
    
    //format the text as needed
    [self formatTextViewAppropriately:newTextView];
    
    //initialise the keyboard to this responder
    [newTextView becomeFirstResponder];
    
    //register as the active field
    self.activeTextView = newTextView;
    
    //reposition views on screen
    [self shiftElementsBelowView:newTextView];
    
    //ensure the the screen is scrolled in order for view to appear
    [self updateCaretForView:newTextView];
    [self updateScrollViewPosition];
}

//Iain
//Format a default scrollView and view
-(void) setUpParametersForView: (UIView *) view andScrollView: (UIScrollView *) scrollView
{
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.contentSize = self.standardContentSizeForPersonalView;
    scrollView.contentOffset = self.standardContentOffsetForPersonalView;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    
    if([view isKindOfClass:[UITextView class]])
    {
        ((UITextView *)view).frame = self.defaultTextBoxFrame;
        ((UITextView *)view).bounces= NO;
        ((UITextView *)view).scrollEnabled = NO;
    }else if (![view isMemberOfClass:[verbatmCustomMediaSelectTile class]])
    {
        //testing
        view.frame = self.defaultTextBoxFrame;
    }
}

//Iain
//Once view is added- we make sure the views below it are appropriately adjusted
//in position
-(void)shiftElementsBelowView: (UIView *) view{
    if(!view) return; //makes sure the view is not nil
    
    if([self.pageElements containsObject:view])//if we are shifting things from somewhere in the middle of the scroll view
    {
        NSInteger view_index = [self.pageElements indexOfObject:view];
        
        NSInteger firstYCoordinate  = view.superview.frame.origin.y + view.superview.frame.size.height;
        
        for(NSInteger i = (view_index+1); i < [self.pageElements count]; i++)
        {
            UIView * curr_view = self.pageElements[i];
            
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, firstYCoordinate, self.defaultPersonalScrollViewFrame.size.width,curr_view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
            
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
            
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, firstYCoordinate, self.defaultPersonalScrollViewFrame.size.width,curr_view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                curr_view.superview.frame = frame;
            }];
            
            firstYCoordinate+= frame.size.height;
        }
    }
}


//Iain
//Shifts elements above a certain view up by the given difference
-(void) shiftElementsAboveView: (UIView *) view withDifference: (NSInteger) difference
{
    NSInteger view_index = [self.pageElements indexOfObject:view];
    for(NSInteger i = (view_index-1); i > -1; i--)
    {
        UIView * curr_view = self.pageElements[i];
        
        CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, curr_view.superview.frame.origin.y + difference, self.defaultPersonalScrollViewFrame.size.width,view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            curr_view.superview.frame = frame;
        }];
    }
}


//Iain
//Storing new view to our array of elements
-(void) storeView: (UIView*) view inArrayAsBelowView: (UIView*) topView
{
    //Ensure the view is not Nil- this will cause problems
    if(!view) return;
    
    if(![self.pageElements containsObject:view])
    {
        if(topView && topView != self.articleTitleField)
        {
            NSInteger index = [self.pageElements indexOfObject:topView];
            [self.pageElements insertObject:view atIndex:(index+1)];
            
        }else
        {
            if(self.pageElements.count)[self.pageElements insertObject:view atIndex:(self.pageElements.count-1)];
            if(!self.pageElements.count) [self.pageElements addObject:view];
        }
    }
}

//Iain
//Formats a textview to the appropriate settings
-(void) formatTextViewAppropriately: (verbatmUITextView *) textView
{
    //Set delegate for text new view
    [textView setDelegate:self];
    [textView setFont:[[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:TEXT_BOX_FONT_SIZE]];
    //ensure keyboard is black
    textView.keyboardAppearance = UIKeyboardAppearanceDark;
}

//Iain
//Adjust the bounds of the tex views the user is typing in
-(void) adjustBoundsOfTextView: (verbatmUITextView *) textView doneEditing: (BOOL) doneEditing updateSCandSE:(BOOL) update /*should the scrollview and elements below be shifted*/
{
    //get position of caret relative to bounds
    NSInteger yCoordinateOfCaretRelativeToMainView= textView.frame.origin.y+ self.caretPosition.origin.y + self.caretPosition.size.height+textView.superview.frame.origin.y;
    NSInteger yCordinateOfBaseOfActiveView = textView.superview.frame.origin.y + textView.superview.frame.size.height;
    NSInteger numberOfLinesInTextView = textView.contentSize.height/textView.font.lineHeight;
    
    //adjust bounds of textView to best size for it with respect to the content inside
    if(numberOfLinesInTextView> NUMBER_OF_LINES_BEFORE_BOUNDS_ADJUST || doneEditing|| (yCordinateOfBaseOfActiveView - yCoordinateOfCaretRelativeToMainView)< CURSOR_BASE_GAP)
    {
        
        textView.frame = [self calculateBoundsForView:textView];
        textView.superview.frame = [self calculateBoundsForScrollViewForView:textView];
        ((UIScrollView *)(textView.superview)).contentSize = [self contentSizeForScrollViewOfView:textView];
        if(update)[self shiftElementsBelowView:textView]; //make sure this isn't being called rapidly
    }
    //Make sure the shadow is reset for the view
    [self addShadowToView:textView];
    
    //make sure scroll is appropriately positioned
    if(update)[self updateScrollViewPosition]; //make sure this isn't happening rapidly
}

//Iain
//Calculate the appropriate boonds for the text view
-(CGRect) calculateBoundsForView: (UIView *) view
{
    CGSize  tightbounds = [view sizeThatFits:view.bounds.size];
    CGRect frameToSet;
    if(tightbounds.height >= SIZE_REQUIRED_MIN)
    {
        frameToSet = CGRectMake(self.defaultTextBoxFrame.origin.x, ELEMENT_OFFSET_DISTANCE/2, view.bounds.size.width, tightbounds.height);
    }else
    {
        frameToSet = CGRectMake(self.defaultTextBoxFrame.origin.x, ELEMENT_OFFSET_DISTANCE/2, view.bounds.size.width, SIZE_REQUIRED_MIN);
    }
    
    return frameToSet;
}

//Iain
-(CGSize) contentSizeForScrollViewOfView: (UIView *) view
{
    CGSize size = CGSizeMake(self.standardContentSizeForPersonalView.width, 0);
    return size;
}

//Iain
-(CGRect) calculateBoundsForScrollViewForView: (UIView *) view
{
    CGRect frameToSet = CGRectMake(view.superview.frame.origin.x, view.superview.frame.origin.y, view.superview.bounds.size.width, view.frame.size.height + ELEMENT_OFFSET_DISTANCE);
    return frameToSet;
}


//Iain
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //S@nwiches shouldn't have any spaces between them
    if([string isEqualToString:@" "]  && textField != self.articleTitleField) return NO;
    return YES;
}

#pragma mark - *Deleting views with swipe-

#pragma mark checking to see if new media view should auto-delete
//Iain
//called when the view is scrolled - we see if the offset has changed
//if so we remove the view
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView != self.mainScrollView && !self.pinching && [self.pageElements count] >1 && scrollView != ((UIView *)[self.pageElements lastObject]).superview  )//make sure you are not mixing it up with the virtical scroll of the main scroll view
    {
        if(scrollView.contentOffset.x != self.standardContentOffsetForPersonalView.x)//If the view is scrolled left/right and not centered
        {
            //remove swiped view from mainscrollview
            UIView * view = [scrollView.subviews firstObject]; //it is the only subview in this scrollview
            NSInteger index = [self.pageElements indexOfObject:view];
            [scrollView removeFromSuperview];
            [self.pageElements removeObject:view];
            
            
            //reposition views on screen
            if(index) [self shiftElementsBelowView:self.pageElements[index-1]]; //if it's a middle element shift everything below
            [self shiftElementsBelowView:self.articleTitleField]; //if it was the top element then shift everything below
            
            
            [self deletedTile:view withIndex:[NSNumber numberWithInt:index]]; //register deleted tile - register in undo stack
            
            //show undo button on the bottom of the top layer
            //make sure the view is on the bottom before it is shown
            self.topLayerViewBottom.frame = CGRectMake(0, self.view.frame.size.height - self.topLayerViewBottom.frame.size.height, self.topLayerViewBottom.frame.size.width, self.topLayerViewBottom.frame.size.height);
            
            
            [UIView animateWithDuration:0.5 animations:^
             {
                 self.topLayerViewBottom.hidden= NO;
                 [self editWordCountForTextView:self.activeTextView];
                 
             } completion:^(BOOL finished)
             {
                 [NSTimer scheduledTimerWithTimeInterval:TOP_LAYER_BOTTOM_APPEAR_TIME_secs target:self selector:@selector(timerFireMethod:) userInfo:Nil repeats:(BOOL)NO];
             }];
        }
        
    }else if(scrollView != self.mainScrollView) //return the view to it's old position
    {
        
        [UIView animateWithDuration:0.7 animations:^
        {
            scrollView.contentOffset = self.standardContentOffsetForPersonalView;
        }];
    }
}

- (void)timerFireMethod:(NSTimer *)timer
{
    self.topLayerViewBottom.hidden=YES;
}

#pragma mark changing transparency of personal scroll view
//Iain
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView != self.mainScrollView)
    {
        if(scrollView.contentOffset.x > self.standardContentOffsetForPersonalView.x + 80 || scrollView.contentOffset.x < self.standardContentOffsetForPersonalView.x - 80)
        {
            
            if(scrollView.contentOffset.x >3)((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor colorWithRed: scrollView.contentOffset.x green:0 blue:0 alpha:1];
            
        }else if(scrollView.contentOffset.x < self.standardContentOffsetForPersonalView.x +80 || scrollView.contentOffset.x > self.standardContentOffsetForPersonalView.x -80 )
        {
            
            [UIView animateWithDuration:0.4 animations:^
             {
                 
                 if([[scrollView.subviews firstObject] isKindOfClass:[UITextView class]])
                 {
                     ((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor BACKGROUND_COLOR];
                 }else
                 {
                     ((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor clearColor];//for all objects not text views
                 }
             }];
        }
        
    }
    
    [self editTransitionLabelWithScrollViewOffset:self.mainScrollView.contentOffset];
  
}

#pragma mark- *Add image/video views to scrollview


#pragma mark - *Word count for Article and Undo implementation-
//Iain
-(void) editWordCountForTextView: (verbatmUITextView *)textView
{
    if([self.pageElements containsObject:textView])
    {
        NSInteger number = MAX_WORD_LIMIT - [self countWordsInPage];
        if(number < self.numberOfWordsLeft && !self.isUndoInProgress)//check if there is a new word added if so then save the state to the undo manager
        {
            //NSString * currentText = self.activeTextView.text;
            //to be implemented
          //  [self.activeTextView.undoManager registerUndoWithTarget:self selector:@selector(undoTextChangeInView:withString:) object:(id)];
        }else if(self.isUndoInProgress)
        {
            self.isUndoInProgress =NO;
        }
        self.numberOfWordsLeft = number;
        self.wordsLeftLabel.text = [NSString stringWithFormat:@"Words: %ld ", (long)number];
    }
}

//Iain
-(NSInteger) countWordsInPage
{
    NSUInteger words =0;
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
        }
    }
    return words;
}

#pragma  mark - Handling the KeyBoard
//Iain
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.sandwhichWhat)
    {
        [self.sandwhichWhat resignFirstResponder];
        
    }else if(textField == self.sandwichWhere)
    {
        [self.sandwichWhere resignFirstResponder];
        
    }else if(textField == self.articleTitleField)
    {
        [self.articleTitleField resignFirstResponder];
    }
    self.topLayerViewBottom.hidden = YES;
	return YES;
}

//Iain
//If user touches in empty space remove the keyboard no matter what field is being edited
- (IBAction)touchOutsideTextViews:(UITapGestureRecognizer *)sender {
    //Might have to be an array in the future
    [self removeKeyboardFromScreen];
    
    self.topLayerViewBottom.hidden=YES;
}

//Iain
-(void) removeKeyboardFromScreen
{
    [self.sandwhichWhat resignFirstResponder];
    [self.sandwichWhere resignFirstResponder];
    [self.articleTitleField resignFirstResponder];
    
    for(UIView * tv in self.pageElements)
    {
        if([tv isKindOfClass:[UITextView class]])
        {
            //run through all of the text views and remove them as responders
            [tv resignFirstResponder];
            //Handle boundary drawing
            [self adjustBoundsOfTextView:(verbatmUITextView *)tv doneEditing:YES updateSCandSE:NO];
        }
    }
    [self shiftElementsBelowView:self.articleTitleField];
    //[self updateScrollViewPosition];
    self.topLayerViewBottom.hidden = YES;
}


//Iain
//When keyboard appears get its height. This is only neccessary when the keyboard first appears
- (void)keyboardWasShown:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    
    //store the keyboard heigh for further use
    if(!self.keyboardHeight)  self.keyboardHeight = height;
    
    [self updateScrollViewPosition];
}


-(void)keyboardWillShow: (NSNotification *)notification
{
    //make sure undo button is not visible    
    [self keyboardUpHandleTopLayerTop];//tester
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect newFrame = CGRectMake(0, (self.view.frame.size.height - (self.topLayerViewBottom.frame.size.height+height)) ,  self.topLayerViewBottom.frame.size.width, self.topLayerViewBottom.frame.size.height);
    self.topLayerViewBottom.hidden = NO;
    
    [UIView animateWithDuration:0.0f animations:^{
        
        self.topLayerViewBottom.frame = newFrame;
    }];
}


-(void) keyboardWillDisappear: (NSNotification *)notification
{
    self.topLayerViewBottom.hidden = YES;
}

//To be implemented
-(void) keyboardUpHandleTopLayerTop
{
}

#pragma mark- custom getter
//Iain
//To be edited
-(void) setmainScrollView: (verbatmCustomScrollView *) scrollView
{
    if(!_mainScrollView) _mainScrollView = scrollView;
    _mainScrollView.contentSize = CGSizeMake(30000, 30000);
}

#pragma mark - *Handling pinch -
#pragma mark  sensing pinch
//Iain
//pinch open to add new element
- (IBAction)addElementPinchGesture:(UIPinchGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.pinching = YES;
        [self shiftElementsBelowView:self.articleTitleField];
        
        for (UIView * new_view in self.mainScrollView.pageElements)
        {
            if([new_view isKindOfClass:[UITextView class]])
            {
                ((UITextView *)new_view).selectable = YES;
            }
        }
        if([sender numberOfTouches] == 2 && sender.scale >1) //make sure there are only 2 touches and that it's a stretch gesture
        {
            [self handlePinchGestureBegan:sender];
        }
    }
    
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        
        if(self.lowerPinchView && sender.scale >1 && self.upperPinchView && [sender numberOfTouches] == 2 )
        {
            [self handlePinchGestureChanged:sender];
        }
    }
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.pinching = NO;
        if(sender.scale > 1 )
        {
            if(self.createdMediaView.superview.frame.size.height < PINCH_DISTANCE_FOR_ANIMATION)
            {
                [self clearNewMediaView];
            }
        }
    }
}

#pragma deleting new mdeia view

//Iain
//Removes the new view being made and resets page
-(void) clearNewMediaView
{
    [UIView animateWithDuration:0.5f animations:^{
        self.createdMediaView.frame = CGRectMake(0, self.createdMediaView.frame.origin.y, self.createdMediaView.frame.size.width, self.createdMediaView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.createdMediaView.superview removeFromSuperview];
        [self.pageElements removeObject:self.createdMediaView];
        [self shiftElementsBelowView:self.articleTitleField];
    }];
}

#pragma mark Create new view to reveal
//Iain
-(void) createNewViewToRevealBetweenPinchViews
{
    CGRect frame =  CGRectMake(self.firstContentPageTextBox.frame.origin.x + (self.firstContentPageTextBox.frame.size.width/2),/*0*/self.createdMediaView.frame.origin.y , 0, 0);
    verbatmCustomMediaSelectTile * mediaTile = [[verbatmCustomMediaSelectTile alloc]initWithFrame:frame];
    mediaTile.customDelegate = self;
    mediaTile.alpha = 0;//start it off as invisible
    mediaTile.baseSelector=NO;
    [self addMediaView: mediaTile underView: self.upperPinchView];
    mediaTile.backgroundColor = [UIColor clearColor];
    self.createdMediaView = mediaTile;
}

//Iain
-(void) addMediaView: (verbatmCustomMediaSelectTile *) mediaView underView: (UIView *) topView
{
    //create frame for the personal scrollview of the new text view
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrame.size.width,0);
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(mediaView) [newPersonalScrollView addSubview:mediaView]; //textview is subview of scroll view
    //format scrollview and text view
    [self setUpParametersForView:mediaView andScrollView: newPersonalScrollView];
    //store the new view in our array
    [self storeView:mediaView inArrayAsBelowView:topView];
    //add aesthetic touch
    [self addShadowToView:mediaView];
}


#pragma mark Pinch began - identify midpoint
//Iain
-(void) handlePinchGestureBegan: (UIPinchGestureRecognizer *)sender
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
    
    [self createNewViewToRevealBetweenPinchViews];
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
                //((UIView *)(self.pageElements[self.index])).backgroundColor = [UIColor blueColor];
                self.lowerPinchView = wantedView;
            }
            if(self.pageElements.count>(self.index-1) && self.index != NSNotFound)
            {
                //((UIView *)(self.pageElements[self.index - 1])).backgroundColor = [UIColor blueColor];
                self.upperPinchView = self.pageElements[self.index -1];
            }
        }else
        {
            self.index = [self.pageElements indexOfObject:wantedView];
            if(self.index != NSNotFound)self.lowerPinchView = self.pageElements[self.index+1];
            
            if(self.pageElements.count>(self.index) && self.index != NSNotFound)/*make sure the indexes are in range*/
            {
                // ((UIView *)(self.pageElements[self.index])).backgroundColor = [UIColor blueColor];
                self.upperPinchView = self.pageElements[self.index];
            }
            if(self.pageElements.count>(self.index+1)&& self.index != NSNotFound)
            {
                // ((UIView *)(self.pageElements[self.index + 1])).backgroundColor = [UIColor blueColor];
                
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
-(void) handlePinchGestureChanged: (UIPinchGestureRecognizer *)gesture
{
    [self handleUpperViewWithGesture:gesture]; //handle view of the top finger and views above it
    [self handleLowerViewWithGesture:gesture]; //handle view of the bottom finger and views below it
    if([gesture numberOfTouches] ==2)
    {
        [self handleRevealOfNewMediaViewWithGesture:gesture]; //reveal the new mediaimageview
    }else if ([gesture numberOfTouches]<=1 || self.changeInBottomViewPostion ==0 || self.changeInTopViewPosition ==0)
    {
        [self clearNewMediaView];
    }
}



//Iain
-(void) handleRevealOfNewMediaViewWithGesture: (UIPinchGestureRecognizer *)gesture
{
    //note that the personal scroll view of the new media view will not have the element offset in the begining- this is to be added here
    if(self.createdMediaView.superview.frame.size.height< PINCH_DISTANCE_FOR_ANIMATION)
    {
        
        //construct new frames for view and personal scroll view
        self.createdMediaView.frame = CGRectMake(self.createdMediaView.frame.origin.x- ((ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition))/2),
                                                 self.createdMediaView.frame.origin.y,
                                                 self.createdMediaView.frame.size.width+(ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition)),
                                                 self.createdMediaView.frame.size.height + (ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition)));
        self.createdMediaView.alpha = self.createdMediaView.frame.size.width/self.defaultTextBoxFrame.size.width; //have it gain visibility as it grows
        
        
        self.createdMediaView.superview.frame = CGRectMake(self.createdMediaView.superview.frame.origin.x,
                                                           self.createdMediaView.superview.frame.origin.y+self.changeInTopViewPosition,
                                                           self.createdMediaView.superview.frame.size.width,
                                                           self.createdMediaView.superview.frame.size.height + (ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition)));
        
        [(verbatmCustomMediaSelectTile *)self.createdMediaView createFramesForButtonsWithFrame: self.createdMediaView.frame];
        // [self.createdMediaView setNeedsDisplay];
    }else if(self.createdMediaView.superview.frame.size.height>=PINCH_DISTANCE_FOR_ANIMATION)
    {
        
        [UIView animateWithDuration:1.0f animations:^{
            
            self.createdMediaView.frame = CGRectMake(self.defaultTextBoxFrame.origin.x,
                                                     ELEMENT_OFFSET_DISTANCE/2,
                                                     self.defaultTextBoxFrame.size.width,
                                                     self.defaultTextBoxFrame.size.width/2);
            self.createdMediaView.alpha = 1; //make it fully visible
            
            self.createdMediaView.superview.frame = CGRectMake(self.createdMediaView.superview.frame.origin.x,
                                                               self.createdMediaView.superview.frame.origin.y+self.changeInTopViewPosition,
                                                               self.createdMediaView.superview.frame.size.width,
                                                               self.defaultTextBoxFrame.size.width/2 +ELEMENT_OFFSET_DISTANCE);
            
            [(verbatmCustomMediaSelectTile *)self.createdMediaView createFramesForButtonsWithFrame: self.createdMediaView.frame];
            // [self.createdMediaView setNeedsDisplay];
            [self shiftElementsBelowView:self.articleTitleField];
        } completion:^(BOOL finished) {
            [self shiftElementsBelowView:self.articleTitleField];
            //methods not quite working-I think
            gesture.enabled = NO;
            gesture.enabled = YES;
            self.pinching = NO;
            
        }];
    }
}


//Iain
//handle the translation of the upper view
-(void) handleUpperViewWithGesture: (UIPinchGestureRecognizer *)gesture
{
    CGPoint touch1;
    CGPoint touch2;
    NSInteger changeInPosition;
    if([gesture numberOfTouches]==2)
    {
        touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
        touch2 = [gesture locationOfTouch:1 inView:self.mainScrollView];
        
        if((touch1.y<touch2.y) && (touch1.y < self.startLocationOfUpperTouchPoint.y))
        {
            changeInPosition = touch1.y - self.startLocationOfUpperTouchPoint.y;
            self.startLocationOfUpperTouchPoint = touch1;
            self.upperPinchView.superview.frame = [self newTranslationForUpperPinchViewFrameWithChange:changeInPosition];
            self.changeInTopViewPosition = changeInPosition;
            [self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
            
        }else if (touch2.y < self.startLocationOfUpperTouchPoint.y && touch2.y < touch1.y)
        {
            changeInPosition = touch2.y - self.startLocationOfUpperTouchPoint.y;
            self.startLocationOfUpperTouchPoint = touch2;
            self.upperPinchView.superview.frame = [self newTranslationForUpperPinchViewFrameWithChange:changeInPosition];
            self.changeInTopViewPosition = changeInPosition;
            [self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
        }
    }else if ([gesture numberOfTouches]==1)
    {
        touch1 = [gesture locationOfTouch:0 inView:self.mainScrollView];
        
        if(touch1.y < self.startLocationOfUpperTouchPoint.y)
        {
            changeInPosition = touch1.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfUpperTouchPoint = touch1;
            self.upperPinchView.superview.frame = [self newTranslationForUpperPinchViewFrameWithChange:changeInPosition];
            self.changeInTopViewPosition = changeInPosition;
            [self shiftElementsAboveView:self.upperPinchView withDifference:changeInPosition];
        }
    }
}

//Iain
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
        
        if((touch1.y>touch2.y) && (touch1.y > self.startLocationOfLowerTouchPoint.y))
        {
            changeInPosition = touch1.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfLowerTouchPoint = touch1;
            self.lowerPinchView.superview.frame = [self newTranslationFrameForLowerPinchFrameWithChange:changeInPosition];
            self.changeInBottomViewPostion = changeInPosition;
            [self shiftElementsBelowView:self.lowerPinchView];
        }else if (touch2.y > self.startLocationOfLowerTouchPoint.y && touch2.y > touch1.y)
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

//Iain
//Takes a change in position and constructs the frame for the views new position
-(CGRect) newTranslationFrameForLowerPinchFrameWithChange: (NSInteger) changeInPosition
{
    CGRect frame= CGRectMake(self.lowerPinchView.superview.frame.origin.x,self.lowerPinchView.superview.frame.origin.y+changeInPosition, self.lowerPinchView.superview.frame.size.width, self.lowerPinchView.superview.frame.size.height);
    return frame;
}

//Iain
//Takes a change in position and constructs the frame for the views new position
-(CGRect) newTranslationForUpperPinchViewFrameWithChange: (NSInteger) changeInPosition
{
    CGRect frame= CGRectMake(self.upperPinchView.superview.frame.origin.x,self.upperPinchView.superview.frame.origin.y+changeInPosition, self.upperPinchView.superview.frame.size.width, self.upperPinchView.superview.frame.size.height);
    return frame;
}


#pragma mark Reacting To User MediaView Choice
//Iain
-(void) addTextViewButtonPressedAsBaseView: (BOOL) isBaseView
{
    if(!isBaseView)[self replaceNewMediaViewWithTextView];
    if(isBaseView) [self createNewTextViewBelowView:self.articleTitleField];
}
//Iain
-(void) addMultiMediaButtonPressedAsBaseView:(BOOL)isBaseView
{
    [self.gallery presentGallery];
}

//Iain
-(void) replaceNewMediaViewWithTextView
{
    NSInteger index = [self.pageElements indexOfObject:self.createdMediaView];
    [self clearNewMediaView];
    if(!index) [self createNewTextViewBelowView:self.articleTitleField];
    if(index) [self createNewTextViewBelowView:self.pageElements[index-1]];
    [self shiftElementsBelowView:self.articleTitleField];//reset the scrollview
}




#pragma mark Enter new view in page
//Iain
//Takes two views and places one below the other with a scroll view
//Only called if the view is multimedia - not for textView!
-(void) addView:(UIView *) view underView: (UIView *) topView
{
    //create frame for the personal scrollview of the new text view
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrame.size.width,self.defaultPersonalScrollViewFrame.size.height/*for now-might need changing*/);
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    
    //new textview
    //format scrollview and text view
    [self setUpParametersForView:view andScrollView: newPersonalScrollView];
    
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(view) [newPersonalScrollView addSubview:view]; //textview is subview of scroll view
    
    //store the new view in our array
    [self storeView:view inArrayAsBelowView:topView];
    
    //add aesthetic touch
    [self addShadowToView:view];
    //reposition views on screen
    [self shiftElementsBelowView:view];
    //ensure the the screen is scrolled in order for view to appear
    [self updateScrollViewPosition];
}

#pragma mark - lazy instantiation
//Iain
-(NSInteger) numberOfWordsLeft
{
    if(!_numberOfWordsLeft) _numberOfWordsLeft = MAX_WORD_LIMIT;
    return  _numberOfWordsLeft;
}

-(verbatmUITextView *) activeTextView
{
    if(!_activeTextView)_activeTextView = self.firstContentPageTextBox;
    return _activeTextView;
}
//Iain
-(NSMutableArray *) pageElements
{
    if(!_pageElements) _pageElements = [[NSMutableArray alloc] init];
    return _pageElements;
}


//Iain
-(NSInteger) totalChangeInViewPositions
{
    return self.changeInBottomViewPostion - self.changeInTopViewPosition;
}


-(verbatmCustomMediaSelectTile *) baseMediaTileSelector
{
    if(!_baseMediaTileSelector) _baseMediaTileSelector = [[verbatmCustomMediaSelectTile alloc]init];
    return _baseMediaTileSelector;
}


//get the undomanager for the main window- use this for the tiles
-(NSUndoManager *) tileSwipeViewUndoManager
{
    if(!_tileSwipeViewUndoManager) _tileSwipeViewUndoManager = [self.view.window undoManager];
    return _tileSwipeViewUndoManager;
}



#pragma mark- MIC

-(void)didSelectImageView:(UIImageView *)imageView ofAsset:(ALAsset *)asset
{
    [self.view addSubview:imageView];
    [self animateView:imageView InToPositionUnder:self.pageElements[self.index]];
}

-(void) animateView:(UIView                 *) view InToPositionUnder: (UIView *) topView
{
    
    [self.view bringSubviewToFront:view];
    
    CGRect  frame = CGRectOffset(topView.superview.frame, 0, topView.superview.frame.size.height);
    
    [UIView animateWithDuration:IMAGE_SWIPE_ANIMATION_TIME animations:^{
        view.frame = frame;
    } completion:^(BOOL finished) {
        if(finished)
        {
            [self addView:view underView:self.pageElements[self.index]];
        }
    }];
}

#pragma mark Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- memory handling
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Full scree and mini screeen notifications

-(void)prepareForMiniScreenMode:(NSNotification*)aNotification
{
    [self updateScrollViewPosition];
}

-(void)prepareForFullScreenMode:(NSNotification*)aNotification
{
    
}


#pragma mark -Undo implementation-

-(void)deletedTile: (UIView *) tile withIndex: (NSNumber *) index
{
    [tile removeFromSuperview];
    [self.tileSwipeViewUndoManager registerUndoWithTarget:self selector:@selector(undoTileDelete:) object:@[tile, index]];
    
}


//User pressed undo button- so call call undo stack
- (IBAction)undoTileSwipe:(UIButton *)sender
{
    [self.tileSwipeViewUndoManager undo];
}

#pragma mark Undo tile swipe

-(void) undoTileDelete: (NSArray *) tileAndInfo
{
    UIView * view = tileAndInfo[0];
    NSNumber * index = tileAndInfo[1];
    
    if([view isKindOfClass:[UITextView class]])
    {
        view.backgroundColor = [UIColor whiteColor];
    }else
    {
        view.backgroundColor = [UIColor clearColor];
    }
    
    if(index.intValue) [self addView:view underView:self.pageElements[index.intValue -1]];
    if(!index.intValue) [self addView:view underView:self.pageElements[index.intValue]];

}



#pragma -mainScrollView handler-
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









@end