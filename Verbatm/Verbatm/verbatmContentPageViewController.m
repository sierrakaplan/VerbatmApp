

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
#import "verbatmCustomImageView.h"

@interface verbatmContentPageViewController () < UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,verbatmCustomMediaSelectTileDelegate,verbatmGalleryHandlerDelegate>



#pragma mark - *Helper properties



#pragma mark Keyboard related properties
@property (nonatomic) NSInteger keyboardHeight;




#pragma mark Helpful integer stores
@property (nonatomic) NSInteger index; //the index of the first view that is pushed up/down by the pinch/stretch gesture
@property (nonatomic, strong) NSString * textBeforeNavigationLabel;


#pragma mark undo related properties
@property (nonatomic, strong) NSUndoManager * tileSwipeViewUndoManager;



#pragma mark - Parameters to function within



#define CENTERING_OFFSET_FOR_TEXT_VIEW 30 //the gap between the bottom of the screen and the cursor
#define CURSOR_BASE_GAP 10



#define TEXT_BOX_FONT_SIZE 15
#define VIEW_WALL_OFFSET 20
#define ANIMATION_DURATION 0.5
#define PINCH_DISTANCE_FOR_ANIMATION 100

#define SIZE_REQUIRED_MIN 100 //size for text tiles




#pragma TextView properties
#define BACKGROUND_COLOR clearColor
#define FONT_COLOR whiteColor






#pragma mark - Used_properties -

#define CLOSED_ELEMENT_FACTOR (2/5)
#define MAX_WORD_LIMIT 350
#define ELEMENT_OFFSET_DISTANCE 20 //distance between elements on the page
#define IMAGE_SWIPE_ANIMATION_TIME 0.5 //time it takes to animate a image from the top scroll view into position

#pragma mark Default frame properties
@property (nonatomic) CGRect defaultOpenElementFrame;
@property (nonatomic) CGSize defaultPersonalScrollViewFrameSize_openElement;
@property (nonatomic) CGSize defaultPersonalScrollViewFrameSize_closedElement;


#pragma mark Display manipulation outlets
@property (weak, nonatomic) IBOutlet verbatmCustomScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *personalScrollViewOfFirstContentPageTextBox;
@property (weak, nonatomic) IBOutlet UILabel *wordsLeftLabel;
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
@property (weak, nonatomic) IBOutlet verbatmUITextView *firstContentPageTextBox;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) verbatmCustomMediaSelectTile * baseMediaTileSelector;


#pragma mark Horizontal Pinch Gesture Properties
@property(nonatomic) CGPoint startLocationOfLeftestTouchPoint;
@property (nonatomic) CGPoint startLocationOfRightestTouchPoint;
@property (nonatomic, strong) UIScrollView * scrollViewForHorizontalPinchView;


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

@end

/*
 Perhaps for word count lets prevent typing- lets just not let them publish with the word count over 350.
 It's more curtious.
 */


@implementation verbatmContentPageViewController

#pragma mark - Prepare ContentPage -
//By Iain
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set up gallery
    self.gallery = [[verbatmGalleryHandler alloc] initWithView:self.view];
    
    //add blurview
    [self addBlurView];
    [self setPlaceholderColors];
    [self set_PersonalScrollView_ContentSizeandOffset];
    [self set_openElement_defaultframe];
    [self addOriginalViewsToPageElementsArray];
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

    ILTranslucentView* blurView = [[ILTranslucentView alloc]init];
    blurView.frame = self.view.frame;
    blurView.translucentStyle = UIBarStyleBlack;
    blurView.translucentAlpha = 1;
    [self.view insertSubview:blurView atIndex:0];
}

//Adds the two views the user gets the first time the open the app
-(void) addOriginalViewsToPageElementsArray
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
        CGRect frame = CGRectMake(self.defaultOpenElementFrame.origin.x,
                                  ELEMENT_OFFSET_DISTANCE/2,
                                  self.defaultOpenElementFrame.size.width,
                                  self.defaultOpenElementFrame.size.width/2);
        
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
//records the generic frame for any element that is a square and not a pinch view circle
//and its personal scrollview.
-(void)set_openElement_defaultframe
{
    //create appropriate generic frame for new textview and save as default
    self.defaultOpenElementFrame  = CGRectMake(self.view.frame.size.width+VIEW_WALL_OFFSET, ELEMENT_OFFSET_DISTANCE/2, self.articleTitleField.frame.size.width, self.firstContentPageTextBox.frame.size.height);
    self.firstContentPageTextBox.frame = self.defaultOpenElementFrame ;
    
    //create appropriate frame for personal scrollview and save as default
    self.defaultPersonalScrollViewFrameSize_openElement = CGSizeMake(self.view.frame.size.width, self.defaultOpenElementFrame.size.height+ELEMENT_OFFSET_DISTANCE);
    
    self.personalScrollViewOfFirstContentPageTextBox.frame = CGRectMake(self.personalScrollViewOfFirstContentPageTextBox.frame.origin.x, self.personalScrollViewOfFirstContentPageTextBox.frame.origin.y, self.defaultPersonalScrollViewFrameSize_openElement.width, self.defaultPersonalScrollViewFrameSize_openElement.height);
    
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
    [self configureViews];
    self.pinching = NO;//initialise pinching to no
}

//Iain
//Set up views
-(void) configureViews
{
    [self setUpKeyboardNotifications];
    //insert any text that was added in previous scenes
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
}



//Iain
//set appropriate delegates for views on page
-(void) setDelegates
{
    self.firstContentPageTextBox.delegate = self;
    
    //self.personalScrollViewOfFirstContentPageTextBox.delegate = self;
    
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
        [self.sandwhichWhat resignFirstResponder];
        
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

#pragma mark  TextViews
#pragma mark Format TextViews
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
//Runs through the page elements and formats all the textviews appropriately
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


#pragma mark Text Entered
//Iain
//Make sure whatever text field is selected is recorded as the active text view
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.activeTextView = (verbatmUITextView *)textView;
    return true;
}

//Iain
//User has edited the text view somehow so we recount the words in the view. And adjust its size
- (void)textViewDidChange:(UITextView *)textView
{
    //Adjust the bounds of the text view
    [self adjustBoundsOfTextView:(verbatmUITextView *)textView updateSCandSE:YES];
    
    //Edit word count
    [self editWordCount];
    
}


//Iain
//Called when user types an input into the textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //If the user clicked enter add a textview
    if([text isEqualToString:@"\n"])
    {
        [self adjustBoundsOfTextView:(verbatmUITextView *)textView updateSCandSE:YES];//resize the textview
        
        [self createNewTextViewBelowView:textView]; //add a new text view below this one
        [self updateScrollViewPosition]; //make sure we scroll to the new textview
        return NO;
    }
    
    [self updateScrollViewPosition]; //ensure that the caret is visible
    return YES;
}

#pragma mark Bounds for TextViews

//Iain
//Adjust the bounds of the tex views the user is typing in
-(void) adjustBoundsOfTextView: (verbatmUITextView *) textView updateSCandSE:(BOOL) update /*should the scrollview and elements below be shifted*/
{
    //get position of caret relative to bounds
    NSInteger yCoordinateOfCaretRelativeToMainView= textView.frame.origin.y+ self.caretPosition.origin.y + self.caretPosition.size.height+textView.superview.frame.origin.y;
    NSInteger yCordinateOfBaseOfActiveView = textView.superview.frame.origin.y + textView.superview.frame.size.height;
    
    //adjust bounds of textView to best size for it with respect to the content inside
    if((yCordinateOfBaseOfActiveView - yCoordinateOfCaretRelativeToMainView)< CURSOR_BASE_GAP)
    {
        
        textView.frame = [self calculateBoundsForOpenTextView:textView];
        textView.superview.frame = [self calculateBoundsForScrollViewForView:textView];
        ((UIScrollView *)(textView.superview)).contentSize = self.standardContentSizeForPersonalView;
        if(update)[self shiftElementsBelowView:textView]; //make sure this isn't being called rapidly
    }
    //make sure scroll is appropriately positioned
    if(update)[self updateScrollViewPosition]; //make sure this isn't happening rapidly
}

//Iain
//Calculate the appropriate bounds for the text view
//We only return a frame that is larger than the default frame size
-(CGRect) calculateBoundsForOpenTextView: (UIView *) view
{
    CGSize  tightbounds = [view sizeThatFits:view.bounds.size];
    if(tightbounds.height >= self.defaultOpenElementFrame.size.height)//only adjust the size if the frame size is larger than the extended page size
    {
        return CGRectMake(self.defaultOpenElementFrame.origin.x, ELEMENT_OFFSET_DISTANCE/2, view.bounds.size.width, tightbounds.height);
    }
    return view.frame; //if we reach here the bounds of the view are just fine
}


#pragma mark Caret within TextView
//Iain
//Update the stored position of the carret within the textview it's in
-(void) updateCaretPositionInView: (verbatmUITextView *) view
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
        }else if([object isKindOfClass:[verbatmCustomPinchView class]]&& ((verbatmCustomPinchView *)object).there_is_text)
        {
            NSString * string = [((verbatmCustomPinchView *) object) getTextFromPinchObject];
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
    self.mainScrollView.contentSize = CGSizeMake(0, Sv.frame.origin.y + Sv.frame.size.height);
}

#pragma mark scroll positioning of the screen

//Iain
//Moves the scrollview to keep the cursor in view - To be fixed
-(void) updateScrollViewPosition
{
    if(self.sandwhichWhat.editing || self.sandwichWhere.editing) return; //if it is the s@andwiches that are set then
    
    [self updateCaretPositionInView:self.activeTextView];//ensure that the caret is up to date
    
    //get y-position of caret relative to main view
    NSInteger contentOffSet = self.mainScrollView.contentOffset.y ;
    NSInteger screenHeight =self.view.frame.size.height;
    NSInteger keyboardHeight = self.keyboardHeight;
    NSInteger keyboardBarHeight = self.pullBarHeight;
    NSInteger keyboardYCoordinate= (screenHeight - (keyboardHeight+ keyboardBarHeight)) ;
    
    if(self.containerViewFrame.size.height != self.view.frame.size.height) keyboardYCoordinate =self.containerViewFrame.size.height;//((UITextView*)self.pageElements.lastObject).frame.size.height + ELEMENT_OFFSET_DISTANCE;
    NSInteger activeViewYOrigin = ((UIScrollView *)(self.activeTextView.superview)).frame.origin.y;
    NSInteger yCoordinateOfCaretRelativeToMainView= activeViewYOrigin +self.activeTextView.frame.origin.y + self.caretPosition.origin.y + self.caretPosition.size.height - contentOffSet;
    
    //If our cursor is inline with or below the keyboard, adjust the scrollview
    if(yCoordinateOfCaretRelativeToMainView > keyboardYCoordinate)
    {
        NSInteger differenceBTWNKeyboardAndTextView = yCoordinateOfCaretRelativeToMainView-(keyboardYCoordinate/*-self.topLayerViewBottom.frame.size.height*/);
        
        CGPoint newScrollViewOffset = CGPointMake(self.mainScrollView.contentOffset.x, (contentOffSet + differenceBTWNKeyboardAndTextView +CENTERING_OFFSET_FOR_TEXT_VIEW));
        
        [self.mainScrollView setContentOffset:newScrollViewOffset animated:YES];
        
    }else if (yCoordinateOfCaretRelativeToMainView-CURSOR_BASE_GAP <= 0) //Checking if the cursor is past the top
    {
        NSInteger differenceBTWNScreenTopAndTextView = yCoordinateOfCaretRelativeToMainView;
        
        CGPoint newScrollViewOffset = CGPointMake(self.mainScrollView.contentOffset.x, (contentOffSet + differenceBTWNScreenTopAndTextView - CENTERING_OFFSET_FOR_TEXT_VIEW*3));
        
        [self.mainScrollView setContentOffset:newScrollViewOffset animated:YES];
    }
    [self shiftElementsBelowView:self.activeTextView];
}



#pragma mark - Creating New Views -

#pragma mark New TextView

-(verbatmUITextView *) newTextView
{
    verbatmUITextView * newTextView =[[verbatmUITextView alloc]init];
    newTextView.mainScrollView = self.mainScrollView;
    newTextView.delegate = self;
    newTextView.backgroundColor = [UIColor BACKGROUND_COLOR];//sets the background as clear
    newTextView.textColor = [UIColor FONT_COLOR];
    return newTextView;
}

//Iain
//When prompted it adds a new textview below the one specified
-(void) createNewTextViewBelowView: (UIView *) topView
{
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    
    //create frame for the personal scrollview of the new text view
    if(topView == self.articleTitleField)
    {
        newPersonalScrollView.frame = ((UIScrollView *)(((UIView *)[self.pageElements firstObject]).superview)).frame;
    }else
    {
        newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrameSize_openElement.width,self.defaultPersonalScrollViewFrameSize_openElement.height);
    }
    
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    
    //new textview
    verbatmUITextView * newTextView = [self newTextView];
    
    //format scrollview and text view
    [self formatView:newTextView andScrollView: newPersonalScrollView];
    
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(newTextView) [newPersonalScrollView addSubview:newTextView]; //textview is subview of scroll view
    
    //store the new view in our array
    [self storeView:newTextView inArrayAsBelowView:topView];
    //format the text as needed
    [self formatTextViewAppropriately:newTextView];
    
    //initialise the keyboard to this responder
    [newTextView becomeFirstResponder];
    
    //reposition views on screen
    [self shiftElementsBelowView:newTextView];
    //ensure the the screen is scrolled in order for view to appear
    [self updateScrollViewPosition];
}


//Iain
//Format a default scrollView and view
-(void) formatView: (UIView *) view andScrollView: (UIScrollView *) scrollView
{
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.contentSize = self.standardContentSizeForPersonalView;
    scrollView.contentOffset = self.standardContentOffsetForPersonalView;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    if([view isKindOfClass:[UITextView class]])
    {
        ((UITextView *)view).bounces= NO;
        ((UITextView *)view).scrollEnabled = NO;
    }
    view.frame = self.defaultOpenElementFrame;//every view should have this frame
}



#pragma mark -Shift Positions of Elements-

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
            
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, firstYCoordinate, self.defaultPersonalScrollViewFrameSize_openElement.width,curr_view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
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
            
            CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, firstYCoordinate, self.defaultPersonalScrollViewFrameSize_openElement.width,curr_view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                curr_view.superview.frame = frame;
            }];
            firstYCoordinate+= frame.size.height;
        }
    }
    
    [self adjustMainScrollViewContentSize];//make sure the main scroll view can show everything
}


//Shifts elements above a certain view up by the given difference
-(void) shiftElementsAboveView: (UIView *) view withDifference: (NSInteger) difference
{
    NSInteger view_index = [self.pageElements indexOfObject:view];
    for(NSInteger i = (view_index-1); i > -1; i--)
    {
        UIView * curr_view = self.pageElements[i];
        
        CGRect frame = CGRectMake(curr_view.superview.frame.origin.x, curr_view.superview.frame.origin.y + difference, self.defaultPersonalScrollViewFrameSize_openElement.width,view.frame.size.height+ELEMENT_OFFSET_DISTANCE);
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            curr_view.superview.frame = frame;
        }];
    }

}

#pragma mark - Add Elements to PageElements Array -
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
        }else if(topView == self.articleTitleField)
        {
            [self.pageElements insertObject:view atIndex:0];
        }else
        {
            [self.pageElements addObject:view];
        }
    }
    
    [self adjustMainScrollViewContentSize];//make sure the main scroll view can show everything
}


#pragma mark - Deleting views with swipe -
//called when the view is scrolled - we see if the offset has changed
//if so we remove the view
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    return;//for now
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
        }
        
    }else if(scrollView != self.mainScrollView) //return the view to it's old position
    {
        [UIView animateWithDuration:0.7 animations:^
         {
             scrollView.contentOffset = self.standardContentOffsetForPersonalView;
         }];
    }
}


#pragma mark Color of Tiles being deleted
//Iain
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //change the background color of the element being deleted to highlight that it's being deleted
    if(scrollView != self.mainScrollView)
    {
        if(scrollView.contentOffset.x > self.standardContentOffsetForPersonalView.x + 80 || scrollView.contentOffset.x < self.standardContentOffsetForPersonalView.x - 80)
        {
            if(scrollView.contentOffset.x >3)((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor redColor];
            
        }else{
            
            [UIView animateWithDuration:0.4 animations:^
             {
                 if([[scrollView.subviews firstObject] isKindOfClass:[UITextView class]])
                 {
                     ((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor BACKGROUND_COLOR];
                 }else
                 {
                     ((UIView *)[scrollView.subviews firstObject]).backgroundColor = [UIColor BACKGROUND_COLOR];//for all objects not text views
                 }
             }];
        }
    }
}


#pragma  mark - Handling the KeyBoard -

#pragma Remove Keyboard From Screen

//Iain
//If user touches in empty space remove the keyboard no matter what field is being edited
- (IBAction)touchOutsideTextViews:(UITapGestureRecognizer *)sender
{
    [self removeKeyboardFromScreen];
    [self convertToPincheableObjects];
    
}

//Iain
-(void) removeKeyboardFromScreen
{
    if(self.sandwhichWhat.isEditing)[self.sandwhichWhat resignFirstResponder];
    if(self.sandwichWhere.isEditing)[self.sandwichWhere resignFirstResponder];
    if(self.articleTitleField.isEditing)[self.articleTitleField resignFirstResponder];
    [self.activeTextView resignFirstResponder];
}

//Remove keyboard when scrolling page
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == self.mainScrollView)self.mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark Keyboard Notifications
//When keyboard appears get its height. This is only neccessary when the keyboard first appears
- (void)keyboardWasShown:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    [self updateScrollViewPosition];
}

#pragma mark - Pinch Gesture -
#pragma mark  Sensing Pinch
//pinch open to add new element
- (IBAction)addElementPinchGesture:(UIPinchGestureRecognizer *)sender
{
    
    //if(self.createdMediaView && (((verbatmCustomMediaSelectTile *)self.createdMediaView).optionSelected)) return; //no pinching unless the one that was pinched before has been used.

    if (sender.state == UIGestureRecognizerStateBegan)
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
        if([sender numberOfTouches] == 2 ) //make sure there are only 2 touches
        {
            [self handlePinchGestureBegan:sender];
        }
    }
    
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        
        if(self.VerticalPinch && self.scrollViewForHorizontalPinchView)
        {
            [self handleHorizontalPincheGestureChanged:sender];
        }else if (self.lowerPinchView && self.upperPinchView && [sender numberOfTouches] == 2 && self.pinching)
        {
            [self handleVerticlePinchGestureChanged:sender];
        }
    }
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.pinching = NO;
        if(sender.scale > 1 )
        {
            if(self.createdMediaView.superview.frame.size.height < PINCH_DISTANCE_FOR_ANIMATION)
            {
                [self clearNewMediaView]; //new media creation has failed
            }
        }else
        {
            if(!self.VerticalPinch && (self.scrollViewForHorizontalPinchView.subviews.count >1))//still needs work
            {
                [self joinOpenElementsToOne];
            }
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
        int left_most_difference = touch2.x- self.startLocationOfLeftestTouchPoint.x;
        int right_most_difference = touch1.x - self.startLocationOfRightestTouchPoint.x;//this will be negative
        self.startLocationOfRightestTouchPoint = touch1;
        self.startLocationOfLeftestTouchPoint = touch2;
        [self moveViewsWithLeftDifference:left_most_difference andRightDifference:right_most_difference];
    }else
    {
        int left_most_difference = touch1.x- self.startLocationOfLeftestTouchPoint.x;
        int right_most_difference = touch2.x - self.startLocationOfRightestTouchPoint.x;//this will be negative
        self.startLocationOfRightestTouchPoint = touch2;
        self.startLocationOfLeftestTouchPoint = touch1;
        [self moveViewsWithLeftDifference:left_most_difference andRightDifference:right_most_difference];
    }
}


//moves the views in the scrollview of the opened collection
-(void) moveViewsWithLeftDifference: (int) left_difference andRightDifference: (int) right_difference
{
    NSArray * pinchViews = self.scrollViewForHorizontalPinchView.subviews;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        for(int i = 0; i < pinchViews.count; i++)
        {
            CGRect oldFrame = ((verbatmCustomPinchView *)pinchViews[i]).frame;
            
            if(oldFrame.origin.x < self.startLocationOfLeftestTouchPoint.x)
            {
                CGRect newFrame = CGRectMake(oldFrame.origin.x + left_difference , oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                ((verbatmCustomPinchView *)pinchViews[i]).frame = newFrame;
            }else
            {
                CGRect newFrame = CGRectMake(oldFrame.origin.x + right_difference , oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                ((verbatmCustomPinchView *)pinchViews[i]).frame = newFrame;
            }
        }
    }];
}

-(void)joinOpenElementsToOne
{
    NSUInteger index =0;
    NSArray * pinch_views = self.scrollViewForHorizontalPinchView.subviews;
    
    //find the object that is in the pageElements array and remove it.
    //Save the index though so you can insert something in there
    //Also remove from the scrollview
    for(int i=0; i<pinch_views.count; i++)
    {
        index = [self.pageElements indexOfObject:pinch_views[i]];
        if(index != NSNotFound){
            [self.pageElements removeObject:pinch_views[i]];
        }
        [(UIView *)pinch_views[i] removeFromSuperview];
    }
    
    
    verbatmCustomPinchView * newView = [verbatmCustomPinchView pinchTogether:[NSMutableArray arrayWithArray:pinch_views]];
    
    self.scrollViewForHorizontalPinchView.contentSize = self.standardContentSizeForPersonalView;
    self.scrollViewForHorizontalPinchView.contentOffset = self.standardContentOffsetForPersonalView;
    
    CGRect newFrame = CGRectMake(self.closedElement_Center.x - [self.closedElement_Radius intValue], self.closedElement_Center.y + [self.closedElement_Radius intValue], [self.closedElement_Radius intValue]*2, [self.closedElement_Radius intValue]*2);
    [newView specifyFrame:newFrame];
    
    [self.pageElements insertObject:newView atIndex:index];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self.scrollViewForHorizontalPinchView addSubview:newView];
    }];
}

#pragma mark *Pinch Apart/Add a media tile


#pragma mark Create New Tile
//Iain
-(void) createNewViewToRevealBetweenPinchViews
{
    CGRect frame =  CGRectMake(self.firstContentPageTextBox.frame.origin.x + (self.firstContentPageTextBox.frame.size.width/2),0/*self.firstContentPageTextBox.frame.origin.y */, 0, 0);
    verbatmCustomMediaSelectTile * mediaTile = [[verbatmCustomMediaSelectTile alloc]initWithFrame:frame];
    mediaTile.customDelegate = self;
    mediaTile.alpha = 0;//start it off as invisible
    mediaTile.baseSelector=NO;
    [self addMediaTile: mediaTile underView: self.upperPinchView];
    mediaTile.backgroundColor = [UIColor clearColor];
    self.createdMediaView = mediaTile;

}

//Iain
-(void) addMediaTile: (verbatmCustomMediaSelectTile *) mediaView underView: (UIView *) topView
{
    //create frame for the personal scrollview of the new text view
    UIScrollView * newPersonalScrollView = [[UIScrollView alloc]init];
    newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrameSize_openElement.width,0);
    
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(mediaView) [newPersonalScrollView addSubview:mediaView]; //textview is subview of scroll view
    //format scrollview and text view
    [self formatView:mediaView andScrollView: newPersonalScrollView];
    //store the new view in our array
    [self storeView:mediaView inArrayAsBelowView:topView];
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
                if(x_difference > y_difference)
                {
                    self.VerticalPinch = NO;
                    [self horitzontalPinchWithGesture:sender];
                }else
                {
                    self.VerticalPinch = YES;
                    [self verticlePinchWithGesture:sender];
                }
                
            }else
            {
                int x_difference = touch2.x -touch1.x;
                int y_difference =touch1.y -touch2.y;
                if(x_difference > y_difference)
                {
                    self.VerticalPinch = NO;
                    [self horitzontalPinchWithGesture:sender];
                }else
                {
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
            
            if(x_difference > y_difference)
            {
                self.VerticalPinch = NO;
                [self horitzontalPinchWithGesture:sender];
            }else
            {
                self.VerticalPinch = YES;
                [self verticlePinchWithGesture:sender];
                [self horitzontalPinchWithGesture:sender];
            }
            
        }else
        {
            int x_difference = touch2.x -touch1.x;
            int y_difference =touch2.y -touch1.y;
            if(x_difference > y_difference)
            {
                self.VerticalPinch = NO;
                [self horitzontalPinchWithGesture:sender];
            }else
            {
                self.VerticalPinch = YES;
                [self verticlePinchWithGesture:sender];
            }
        }
    }
    [self verticlePinchWithGesture:sender];
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
            self.startLocationOfLeftestTouchPoint = touch1;
            self.startLocationOfRightestTouchPoint = touch2;
        }
    }else
    {
        self.scrollViewForHorizontalPinchView = [self findCollectionScrollViewFromTouchPoint:touch1];
        if(self.scrollViewForHorizontalPinchView)
        {
            self.startLocationOfLeftestTouchPoint = touch2;
            self.startLocationOfRightestTouchPoint = touch1;
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
        if([self sufficienOverlapBetweenPinchedObjects])
        {
            if(![self tilesOkToPinch] || ![self.upperPinchView isKindOfClass:[verbatmCustomPinchView class]] || ![self.lowerPinchView isKindOfClass:[verbatmCustomPinchView class]]) return;//checks of the tiles are both collections. If so then no pinching together
            
            UIScrollView * keeping_scrollView = (UIScrollView *)self.upperPinchView.superview;
            long index_to_insert = [self.pageElements indexOfObject:self.upperPinchView];
            
            [self.upperPinchView removeFromSuperview];
            [self.pageElements removeObject:self.upperPinchView];
            
            [self.lowerPinchView.superview removeFromSuperview];
            [self.pageElements removeObject:self.lowerPinchView];
            
            NSMutableArray* array_of_objects = [[NSMutableArray alloc] initWithObjects:self.upperPinchView,self.lowerPinchView, nil];
            verbatmCustomPinchView * pinchView = [verbatmCustomPinchView pinchTogether:array_of_objects];
            
            //format your scrollView and add pinch view
            [keeping_scrollView addSubview:pinchView];
            [self.pageElements insertObject:pinchView atIndex:index_to_insert];
            self.pinching = NO;
            [self shiftElementsBelowView:self.articleTitleField];
        }
    }
}

-(BOOL) tilesOkToPinch
{
    if([(verbatmCustomPinchView *)self.upperPinchView isCollection] && [(verbatmCustomPinchView *)self.lowerPinchView isCollection]) return false;
    return true;
}

-(BOOL)sufficienOverlapBetweenPinchedObjects
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
        
        if((touch1.y>touch2.y) /*&& (touch1.y > self.startLocationOfLowerTouchPoint.y)*/)
        {
            changeInPosition = touch1.y - self.startLocationOfLowerTouchPoint.y;
            self.startLocationOfLowerTouchPoint = touch1;
            self.lowerPinchView.superview.frame = [self newTranslationFrameForLowerPinchFrameWithChange:changeInPosition];
            self.changeInBottomViewPostion = changeInPosition;
            [self shiftElementsBelowView:self.lowerPinchView];
        }else if (/*touch2.y > self.startLocationOfLowerTouchPoint.y &&*/ touch2.y > touch1.y)
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
        self.createdMediaView.alpha = self.createdMediaView.frame.size.width/self.defaultPersonalScrollViewFrameSize_openElement.width; //have it gain visibility as it grows
        
        
        self.createdMediaView.superview.frame = CGRectMake(self.createdMediaView.superview.frame.origin.x,
                                                           self.createdMediaView.superview.frame.origin.y+self.changeInTopViewPosition,
                                                           self.createdMediaView.superview.frame.size.width,
                                                           self.createdMediaView.superview.frame.size.height + (ABS(self.changeInBottomViewPostion) +  ABS(self.changeInTopViewPosition)));
        
        [(verbatmCustomMediaSelectTile *)self.createdMediaView createFramesForButtonsWithFrame: self.createdMediaView.frame];
        [self.createdMediaView setNeedsDisplay];
    }else if(self.createdMediaView.superview.frame.size.height>=PINCH_DISTANCE_FOR_ANIMATION)
    {
        
        [UIView animateWithDuration:1.0f animations:^{
            
            self.createdMediaView.frame = CGRectMake(self.defaultOpenElementFrame.origin.x,
                                                     ELEMENT_OFFSET_DISTANCE/2,
                                                     self.defaultOpenElementFrame.size.width,
                                                     self.defaultOpenElementFrame.size.width/2);
            self.createdMediaView.alpha = 1; //make it fully visible
            
            self.createdMediaView.superview.frame = CGRectMake(self.createdMediaView.superview.frame.origin.x,
                                                               self.createdMediaView.superview.frame.origin.y+self.changeInTopViewPosition,
                                                               self.createdMediaView.superview.frame.size.width,
                                                               self.defaultOpenElementFrame.size.width/2 +ELEMENT_OFFSET_DISTANCE);
            
            [(verbatmCustomMediaSelectTile *)self.createdMediaView createFramesForButtonsWithFrame: self.createdMediaView.frame];
            // [self.createdMediaView setNeedsDisplay];
            [self shiftElementsBelowView:self.articleTitleField];
        } completion:^(BOOL finished) {
            [self shiftElementsBelowView:self.articleTitleField];
            gesture.enabled = NO;
            gesture.enabled = YES;
            self.pinching = NO;
            
        }];
    }
}






#pragma mark Pinch Apart Failed


#pragma deleting new mdeia view

//Iain
//Removes the new view being made and resets page
-(void) clearNewMediaView
{
    [self.createdMediaView.superview removeFromSuperview];
    [self.pageElements removeObject:self.createdMediaView];
    [self shiftElementsBelowView:self.articleTitleField];
    self.createdMediaView = nil;//stop pointing to the object so it is freed from memory
}


#pragma mark - Media Tile Options -
#pragma mark Reacting To User MediaView Choice
//Iain
-(void) addTextViewButtonPressedAsBaseView: (BOOL) isBaseView
{
    if(!isBaseView)[self replaceNewMediaViewWithTextView];
    if(isBaseView)
    {
        UIView * view = [self findSecondToLastElementInPageElements]; //returns nil if there are less than two objects in page elements
        if(view)[self createNewTextViewBelowView:view];
        else [self createNewTextViewBelowView:self.articleTitleField];
    }
}

-(UIView *) findSecondToLastElementInPageElements
{
    
    if(!self.pageElements.count) return nil;
    
    unsigned long last_index =  self.pageElements.count -1;
    
    if(last_index) return self.pageElements[last_index -1];
    return nil;
}



-(void) addMultiMediaButtonPressedAsBaseView:(BOOL)isBaseView
{
     [self.gallery presentGallery];
}

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
    newPersonalScrollView.frame = CGRectMake(topView.superview.frame.origin.x, topView.superview.frame.origin.y +topView.superview.frame.size.height, self.defaultPersonalScrollViewFrameSize_openElement.width,self.defaultPersonalScrollViewFrameSize_openElement.height);
    //set scrollview delegate
    newPersonalScrollView.delegate = self;
    
    //new textview
    //format scrollview and text view
    [self formatView: view andScrollView: newPersonalScrollView];
    
    //Add new views as subviews
    if(newPersonalScrollView)[self.mainScrollView addSubview:newPersonalScrollView];
    if(view) [newPersonalScrollView addSubview:view]; //textview is subview of scroll view
    
    //store the new view in our array
    [self storeView:view inArrayAsBelowView:topView];
    
    //reposition views on screen
    [self shiftElementsBelowView:view];
    //ensure the the screen is scrolled in order for view to appear
    [self updateScrollViewPosition];

}

#pragma mark - lazy instantiation
///Iain
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

-(NSInteger) totalChangeInViewPositions
{
    return self.changeInBottomViewPostion - self.changeInTopViewPosition;
}


-(void)didSelectImageView:(verbatmCustomImageView*)imageView
{
    [self.view addSubview:imageView];
    [self animateView:imageView InToPositionUnder:self.pageElements[self.index]];

}

-(void) animateView:(UIView*) view InToPositionUnder: (UIView *) topView
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


#pragma mark - Convert to pinch circles -


-(void)convertToPincheableObjects
{
    for(int i = 0; i < [self.pageElements count]; i++){
        id object = [self.pageElements objectAtIndex: i];
        if(![object isKindOfClass:[verbatmCustomMediaSelectTile class]] && ![object isKindOfClass:[verbatmCustomPinchView class]]){
            UIScrollView* superView = (UIScrollView*)[(UIView*)object superview];
            superView.frame = CGRectMake(superView.frame.origin.x, superView.frame.origin.y, self.view.frame.size.width, self.defaultPersonalScrollViewFrameSize_closedElement.height);
            verbatmCustomPinchView* pinch = [[verbatmCustomPinchView alloc] initWithRadius: [self.closedElement_Radius floatValue] withCenter: self.closedElement_Center  andMedia:object];
            [(UIView*)object removeFromSuperview];
            [superView addSubview:pinch];
            [self.pageElements replaceObjectAtIndex:i withObject:pinch];
            [self addTapGestureToView:pinch];//add tap gesture to the newly created pinch object
            [self shiftElementsBelowView:pinch];
        }
    }
}


#pragma mark - Open Element Collection -

#pragma mark Sense Tap
-(void)addTapGestureToView: (verbatmCustomPinchView *) pinchView
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectTaped:)];
    [pinchView addGestureRecognizer:tap];
}

-(void) pinchObjectTaped:(UITapGestureRecognizer *) sender
{
    if(![sender.view isKindOfClass:[verbatmCustomPinchView class]]) return; //only accept touches from pinch objects

    verbatmCustomPinchView * pinch_object = (verbatmCustomPinchView *)sender.view;
    if(pinch_object.hasMultipleMedia)[self openCollection:pinch_object];//checks if there is anything to open by telling you if the element has multiple things in it
}

#pragma mark Open Collection
-(void)openCollection: (verbatmCustomPinchView *) collection
{
    NSMutableArray * element_array = [verbatmCustomPinchView openCollection:collection];
    
    UIScrollView * scroll_view = (UIScrollView *)collection.superview;
    
    [collection removeFromSuperview];//clear the scroll view. It's about to be filled by the array's elements
    [self addPinchObjects:element_array toScrollView: scroll_view];
    [self.pageElements replaceObjectAtIndex:[self.pageElements indexOfObject:collection] withObject:element_array[0]];
}

-(void) addPinchObjects:(NSMutableArray *) array toScrollView: (UIScrollView *) sv
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        int x_position = ELEMENT_OFFSET_DISTANCE;
        for(int i = 0; i< array.count; i++)
        {
            verbatmCustomPinchView * pinch_view = array[i];
            CGRect new_frame =CGRectMake(x_position, ELEMENT_OFFSET_DISTANCE/2, [self.closedElement_Radius intValue] *2, [self.closedElement_Radius intValue] * 2);
            [pinch_view specifyFrame:new_frame];
            [sv addSubview:pinch_view];
            x_position += pinch_view.frame.size.width + ELEMENT_OFFSET_DISTANCE;
        }
        sv.contentSize = CGSizeMake(x_position, sv.contentSize.height);
        sv.pagingEnabled = YES;
    }];
    
    
    
}

#pragma mark Open element
-(void) openElement: (verbatmCustomPinchView *) view
{
    
}


#pragma mark - alert the gallery -

-(void)alertGallery
{
    [self.gallery fillArrayWithMedia];
}























@end