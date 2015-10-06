//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "ContentDevPullBar.h"
#import "ContentDevVC.h"

#import "EditContentView.h"
#import "Notifications.h"
#import "Styles.h"

#import "SizesAndPositions.h"

#import "UIEffects.h"

#import "VerbatmKeyboardToolBar.h"
#import "VerbatmImageScrollView.h"

@interface EditContentView () <KeyboardToolBarDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIImageView * imageView;
#pragma mark FilteredPhotos
@property (nonatomic, weak) NSArray * filteredImages;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic, strong) UIButton * textCreationButton;

@property (nonatomic) CGPoint  panStartLocation;
@property (nonatomic) CGFloat horizontalPanDistance;
@property (nonatomic) BOOL verticlePan;//tracks the pans life cylce from beginning to end
@property (nonatomic) BOOL horizontalPan;//tracks the pans life form beginnig to end
@property (nonatomic) NSInteger keyboardHeight;
#define TEXT_CREATION_ICON @"textCreateIcon"
#define TEXT_VIEW_HEIGHT 70.f
#define HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE 11
#define TOUCH_BUFFER 20
@end


@implementation EditContentView

-(instancetype) initCustomViewWithFrame:(CGRect)frame {
	self = [super init];
	if(self) {
		self.backgroundColor = [UIColor blackColor];
		self.frame = frame;
        self.textView = nil;
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
}

#pragma mark - Text View -

-(void)createTextCreationButton {
    [self.textCreationButton setImage:[UIImage imageNamed:TEXT_CREATION_ICON] forState:UIControlStateNormal];
    [self.textCreationButton addTarget:self action:@selector(textButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.textCreationButton];
    [self bringSubviewToFront:self.textCreationButton];
}

-(void)textButtonClicked:(UIButton*) sender {
    if(self.textView.text)[self editText:self.textView.text];
    else [self editText:@""];
    
}

-(void) editText: (NSString *) text {
    if(!_textView){
        CGRect textViewFrame = CGRectMake(0, VIEW_Y_OFFSET, self.frame.size.width, TEXT_VIEW_HEIGHT);
        self.textView = [[VerbatmUITextView alloc] initWithFrame:textViewFrame];
        [self formatTextView:self.textView];
        [self addSubview:self.textView];
        [self.textView setDelegate:self];
        [self addToolBarToView];
    }
	self.textView.text = text;
	[self.textView becomeFirstResponder];
}

#pragma mark - Keyboard ToolBar -

//creates a toolbar to add onto the keyboard
-(void)addToolBarToView {
	CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	[toolBar setDelegate:self];
	self.textView.inputAccessoryView = toolBar;
}

//Calculate the appropriate bounds for the text view
//We only return a frame that is larger than the default frame size
-(CGRect) calculateBoundsForTextView: (UIView *) view {
	CGSize  tightbounds = [view sizeThatFits:view.bounds.size];
    float height = (TEXT_VIEW_HEIGHT < tightbounds.height) ? tightbounds.height : TEXT_VIEW_HEIGHT;
	return CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}


//Formats a textview to the appropriate settings
-(void) formatTextView: (UITextView *) textView {
	[textView setFont:[UIFont fontWithName:DEFAULT_FONT size:TEXT_AVE_FONT_SIZE]];
	textView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    
    //TEXT_SCROLLVIEW_BACKGROUND_COLOR
	textView.textColor = [UIColor TEXT_AVE_COLOR];
	textView.tintColor = [UIColor TEXT_AVE_COLOR];

	//ensure keyboard is black
	textView.keyboardAppearance = UIKeyboardAppearanceDark;
	textView.scrollEnabled = NO;
}

-(NSString*) getText {
	return [self.textView text];
}

#pragma mark Text view content changed
-(void)adjustContentSizing {
    if (self.textView) {
        self.textView.frame = [self calculateBoundsForTextView: self.textView];
	}
}

//User has edited the text view somehow so we recount the words in the view. And adjust its size
- (void)textViewDidChange:(UITextView *)textView {
	[self adjustContentSizing];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

-(BOOL)textAtEndOfTextview: (UITextView *) tv {
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.textView.frame.origin.y < self.keyboardHeight){
        self.textView.frame = CGRectMake(0, VIEW_Y_OFFSET, self.textView.frame.size.width,
                                         self.textView.frame.size.height);
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
    [self adjustFrameOfTextViewForGap: (self.frame.size.height - self.keyboardHeight)];
}


-(void)keyboardWillDisappear:(NSNotification *) notification {
    [self adjustFrameOfTextViewForGap: 0];
}

#pragma mark Adjust text view frame to keyboard

//called when the keyboard is up. The Gap gives you the amount of visible space after
//the keyboard is up
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap {
	if(gap) {
		self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,
										 self.textView.frame.size.width, gap - VIEW_WALL_OFFSET);
	}else {
		self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,
										 self.frame.size.width, self.frame.size.height-VIEW_WALL_OFFSET);
	}
	[self adjustContentSizing];
}


#pragma mark - Image or Video View -
-(void) displayVideo: (AVAsset*) videoAsset {
	self.videoView = [[VideoPlayerView alloc]init];
	self.videoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:self.videoView];
	[self bringSubviewToFront:self.videoView];
	[self.videoView playVideoFromAsset:videoAsset];
	[self.videoView repeatVideoOnEnd:YES];
	[self addTapGestureToMainView];
}

-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index {
	self.filteredImages = filteredImages;
	self.imageIndex = index;
	self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	[self.imageView setImage:self.filteredImages[self.imageIndex]];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
	[self addTapGestureToMainView];
    [self createTextCreationButton];
}

#pragma mark Filters
-(void)changeFilteredImageLeft{
    if (self.imageIndex < ([self.filteredImages count]-1)) {
        self.imageIndex = self.imageIndex +1;
        [self.imageView setImage:self.filteredImages[self.imageIndex]];
    }
}


-(void)changeFilteredImageRight{
    if (self.imageIndex > 0) {
        self.imageIndex = self.imageIndex -1;
        [self.imageView setImage:self.filteredImages[self.imageIndex]];
    }
}


-(NSInteger) getFilteredImageIndex {
	return self.imageIndex;
}

#pragma mark - Exit view

-(void) addTapGestureToMainView {
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitEditContentView)];
	[self addGestureRecognizer:tap];
}

-(void) doneButtonPressed {
    
    if([self.textView.text isEqualToString:@""]){
        //remove text view from screen
        [self.textView removeFromSuperview];
        self.textView = nil;
    }
    
    
    
	[self.textView resignFirstResponder];
}

-(void) exitEditContentView {
    //if the keyboard is up then remove it
    if(self.textView.isFirstResponder){
        [self.textView resignFirstResponder];
    }else{//if the keyboard is down then remove the view
        [self.delegate exitEditContentView];
    }
}

#pragma maro -Adjust textview position-

-(void)addPanToTextView{
    UIPanGestureRecognizer * panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(adjustTVPosition:)];
    [self addGestureRecognizer:panG];
}

-(void)adjustTVPosition:(UIGestureRecognizer *) sender{
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
                if(sender.numberOfTouches != 1) return;
                CGPoint location = [sender locationOfTouch:0 inView:self];
                self.panStartLocation = location;
                if(self.textView.isFirstResponder)[self.textView resignFirstResponder];
                self.horizontalPanDistance = 0.f;
                self.horizontalPan = NO;
                self.verticlePan = NO;
                break;
            case UIGestureRecognizerStateChanged:{
                if(sender.numberOfTouches != 1) return;
                CGPoint location = [sender locationOfTouch:0 inView:self];
                if([self mostlyHorizontalPan:location] || (self.horizontalPan && !self.verticlePan)) {
                    float diff = location.x - self.panStartLocation.x;
                    self.horizontalPanDistance += diff;
                    //has the horizontal pan gone long enough for a "swipe"
                    if(fabs(self.horizontalPanDistance) >= HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE){
                        //change the filte
                        if(self.horizontalPanDistance < 0){
                            [self changeFilteredImageLeft];
                        }else{
                            [self changeFilteredImageRight];
                        }
                        //now cancel the gesture
                        sender.enabled = NO;
                        sender.enabled = YES;
                    }
                }else if(self.verticlePan){
                    if([self touchInTVBounds:sender]){
                        float diff = location.y - self.panStartLocation.y;
                        if([self textViewTranslationInBounds:diff]){
                            self.textView.frame = CGRectMake(self.textView.frame.origin.x,
                                                             self.textView.frame.origin.y + diff,
                                                             self.textView.frame.size.width, self.textView.frame.size.height);
                        }
                    }else{
                        sender.enabled = NO;
                        sender.enabled = YES;
                    }
                }
                
                self.panStartLocation = location;
                break;
            }
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
                self.horizontalPanDistance = 0.f;
                break;
            default:
                break;
        }
}

-(BOOL) mostlyHorizontalPan: (CGPoint) location {
    BOOL horizontal = ((fabs(location.y - self.panStartLocation.y) < fabs(location.x - self.panStartLocation.x))//make sure it's a horizontal swipe
                       && fabs(location.y - self.panStartLocation.y) <= 9);//prevent diagonal swipes
    
    if(!self.horizontalPan && !self.verticlePan){
        self.horizontalPan = horizontal;
        self.verticlePan = !horizontal;
    }
    return horizontal;
    
}



-(BOOL)textViewTranslationInBounds:(float) diff{
    return ((self.textView.frame.origin.y + diff) > 0.f) &&
            ((self.textView.frame.origin.y + self.textView.frame.size.height + diff) <
            self.frame.size.height);
}


-(BOOL) touchInTVBounds:(UIGestureRecognizer *)sender{
    if(sender.numberOfTouches == 1){
        CGPoint touchPoint = [sender locationOfTouch:0 inView:self];
        return (touchPoint.y > self.textView.frame.origin.y - TOUCH_BUFFER &&
                touchPoint.y < self.textView.frame.origin.y + self.textView.frame.size.height + TOUCH_BUFFER);
    }
        return NO;
}
#pragma mark - custom setters -
-(void)setTextView:(VerbatmUITextView *)textView{
    if(_textView){
        [_textView removeFromSuperview];
    }
    _textView = textView;
    [self addSubview:_textView];
}

#pragma mark - lazy instantiation -
-(UIButton *)textCreationButton{
    if(!_textCreationButton){
        _textCreationButton = [[UIButton alloc] initWithFrame:
                               CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
                                          EXIT_CV_BUTTON_WIDTH,
                                          self.frame.size.height - EXIT_CV_BUTTON_WIDTH -
                                          EXIT_CV_BUTTON_WALL_OFFSET,
                                          EXIT_CV_BUTTON_WIDTH,
                                          EXIT_CV_BUTTON_WIDTH)];
        [self addPanToTextView];
        [self registerForKeyboardNotifications];
    }
    return _textCreationButton;
}

@end
