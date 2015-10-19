//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "ContentDevPullBar.h"
#import "ContentDevVC.h"
#import "Durations.h"
#import "EditContentView.h"
#import "Notifications.h"
#import "Styles.h"

#import "SizesAndPositions.h"

#import "TextAndImageView.h"

#import "VerbatmKeyboardToolBar.h"
#import "VerbatmImageScrollView.h"

#import "UITextView+Utilities.h"

@interface EditContentView () <KeyboardToolBarDelegate, UITextViewDelegate>

@property (nonatomic, strong) TextAndImageView* textAndImageView;

#pragma mark FilteredPhotos
@property (nonatomic, weak) NSArray * filteredImages;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic, strong) UIButton * textCreationButton;

@property (nonatomic) CGPoint  panStartLocation;
@property (nonatomic) CGFloat horizontalPanDistance;
@property (nonatomic) BOOL isHorizontalPan;
@property (nonatomic) NSInteger keyboardHeight;

@property (nonatomic) CGRect userSetFrame;//keeps the frame the user set from panning so can revert after keyboard goes away

#define TEXT_CREATION_ICON @"textCreateIcon"
#define HORIZONTAL_PAN_FILTER_SWITCH_DISTANCE 11
#define TOUCH_BUFFER 20

@end


@implementation EditContentView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor blackColor];
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillDisappear:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyBoardDidShow:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];

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
	[self editText];
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
	CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	[toolBar setDelegate:self];
	self.textAndImageView.textView.inputAccessoryView = toolBar;
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
    if((textView.frame.origin.y + textView.frame.size.height) > (self.frame.size.height - self.keyboardHeight - TEXT_TOOLBAR_HEIGHT)){
        [UIView animateWithDuration:SNAP_ANIMATION_DURATION  animations:^{
            self.textAndImageView.textView.frame = CGRectMake(0, (self.frame.size.height - self.keyboardHeight -
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

#pragma mark Keyboard Notifications

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
	self.videoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:self.videoView];
	[self bringSubviewToFront:self.videoView];
	[self.videoView prepareVideoFromAsset_synchronous:videoAsset];
    [self.videoView playVideo];
	[self.videoView repeatVideoOnEnd:YES];
	[self addTapGestureToMainView];
}

-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index {
	self.filteredImages = filteredImages;
	self.imageIndex = index;
	self.textAndImageView = [[TextAndImageView alloc] initWithFrame:self.bounds andImage:self.filteredImages[self.imageIndex]
															andText:@"" andTextYPosition:TEXT_VIEW_OVER_MEDIA_Y_OFFSET];
	[self addSubview: self.textAndImageView];
	[self addTapGestureToMainView];
	[self addPanGesture];
}

#pragma mark Filters

-(void)changeFilteredImageLeft{
    if (self.imageIndex < ([self.filteredImages count]-1)) {
        self.imageIndex = self.imageIndex +1;
        [self.textAndImageView.imageView setImage:self.filteredImages[self.imageIndex]];
    }
}

-(void)changeFilteredImageRight{
    if (self.imageIndex > 0) {
        self.imageIndex = self.imageIndex -1;
        [self.textAndImageView.imageView setImage:self.filteredImages[self.imageIndex]];
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
    if([self.textAndImageView.textView.text isEqualToString:@""]){
        //remove text view from screen
        [self.textAndImageView showText:NO];
    }
	[self.textAndImageView.textView resignFirstResponder];
}

-(void) exitEditContentView {
    //if the keyboard is up then remove it
    if(self.textAndImageView.textView.isFirstResponder){
        [self.textAndImageView.textView resignFirstResponder];
    } else {
        [self.delegate exitEditContentView];
    }
}

#pragma maro -Adjust textview position-

-(void) addPanGesture {
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	panGesture.minimumNumberOfTouches = 1;
	panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];
}

-(void) didPan:(UIGestureRecognizer *) sender{
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
                self.panStartLocation = [sender locationOfTouch:0 inView:self];
                if(self.textAndImageView.textView.isFirstResponder) {
					[self.textAndImageView.textView resignFirstResponder];
				}
                break;
            case UIGestureRecognizerStateChanged:{
				CGPoint location = [sender locationOfTouch:0 inView:self];
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
            self.frame.size.height /*- (CIRCLE_RADIUS*2 + SLIDE_THRESHOLD //we have remove this to test what it's like to have text at the very bottom)*/);
}

// check if the touch is on the text view
-(BOOL) touchInTextViewBounds:(CGPoint) touch {
        return (touch.y > self.textAndImageView.textView.frame.origin.y - TOUCH_BUFFER &&
                touch.y < self.textAndImageView.textView.frame.origin.y +
				self.textAndImageView.textView.frame.size.height + TOUCH_BUFFER);
}



#pragma mark - Filters -

//-(void) setFilteredPhotos {
//    NSArray* filterNames = [UIImage getPhotoFilters];
//    self.filteredImages = [[NSMutableArray alloc] initWithCapacity:[filterNames count]+1];
//    //original photo
//    [self.filteredImages addObject:self.image];
//    [self createFilteredImagesFromImage:self.image andFilterNames:filterNames];
//}
//
////return array of uiimage with filter from image
//-(void)createFilteredImagesFromImage:(UIImage *)image andFilterNames:(NSArray*)filterNames{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        NSData  * imageData = UIImagePNGRepresentation(image);
//        //Background Thread
//        for (NSString* filterName in filterNames) {
//            NSLog(@"Adding filtered photo.");
//            @autoreleasepool {
//                CIImage *beginImage =  [CIImage imageWithData: imageData];
//                CIContext *context = [CIContext contextWithOptions:nil];
//                CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues: kCIInputImageKey, beginImage, nil];
//                CIImage *outputImage = [filter outputImage];
//                CGImageRef CGImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
//                UIImage* imageWithFilter = [UIImage imageWithCGImage:CGImageRef];
//                CGImageRelease(CGImageRef);
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.filteredImages addObject:imageWithFilter];
//                });
//            }
//        }
//    });
//}








#pragma mark - lazy instantiation -

-(UIButton *)textCreationButton{
    if(!_textCreationButton){
        _textCreationButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
                                                                         EXIT_CV_BUTTON_WIDTH,
                                                                         self.frame.size.height - EXIT_CV_BUTTON_WIDTH -
                                                                         EXIT_CV_BUTTON_WALL_OFFSET,
                                                                         EXIT_CV_BUTTON_WIDTH,
                                                                         EXIT_CV_BUTTON_WIDTH)];
    }
    return _textCreationButton;
}

@end
