//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "EditContentView.h"
#import "VerbatmImageScrollView.h"
#import "VerbatmPullBarView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UIEffects.h"
#import "Notifications.h"
#import "ContentDevVC.h"
#import "VerbatmKeyboardToolBar.h"


@interface EditContentView () <KeyboardToolBarDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIImageView * imageView;
#pragma mark FilteredPhotos
@property (nonatomic, weak) NSArray * filteredImages;
@property (nonatomic) NSInteger imageIndex;

@end


@implementation EditContentView

-(instancetype) initCustomViewWithFrame:(CGRect)frame
{
	self = [super init];
	if(self) {
		self.backgroundColor = [UIColor blackColor];
		self.frame = frame;
	}
	return self;
}

#pragma mark - Text View -

-(void) editText: (NSString *) text {

	CGRect textViewFrame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2, self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);
	self.textView = [[VerbatmUITextView alloc] initWithFrame:textViewFrame];
	[self formatTextView:self.textView];
	[self addSubview:self.textView];
	[self.textView setDelegate:self];
	self.textView.text = text;
	[self addToolBarToView];
	[self adjustContentSizing];
	[self.textView becomeFirstResponder];
}

//creates a toolbar to add onto the keyboard
-(void)addToolBarToView {
	CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - TEXT_TOOLBAR_HEIGHT, self.frame.size.width, TEXT_TOOLBAR_HEIGHT);
	VerbatmKeyboardToolBar* toolBar = [[VerbatmKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	[toolBar setBackgroundColor:[UIColor colorWithWhite:0 alpha:1]];
	[toolBar setDelegate:self];

	self.textView.inputAccessoryView = toolBar;
}

//Calculate the appropriate bounds for the text view
//We only return a frame that is larger than the default frame size
-(CGRect) calculateBoundsForOpenTextView: (UIView *) view
{
	CGSize  tightbounds = [view sizeThatFits:view.bounds.size];

	return CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tightbounds.height);
}


//Formats a textview to the appropriate settings
-(void) formatTextView: (UITextView *) textView
{
	[textView setFont:[UIFont fontWithName:TEXT_AVE_FONT size:TEXT_AVE_FONT_SIZE]];
	textView.backgroundColor = [UIColor TEXT_SCROLLVIEW_BACKGROUND_COLOR];
	textView.textColor = [UIColor TEXT_AVE_COLOR];
	textView.tintColor = [UIColor TEXT_AVE_COLOR];

	//ensure keyboard is black
	textView.keyboardAppearance = UIKeyboardAppearanceDark;
	textView.scrollEnabled = YES;
}

-(NSString*) getText {
	return [self.textView text];
}

#pragma mark Text view content changed
-(void)adjustContentSizing {
	if (self.textView) {
		//drawing boundary
		CGRect frame = self.textView.bounds;
		CGSize size = CGSizeMake(frame.size.width, [UIEffects measureContentHeightOfUITextView:self.textView] + TEXT_VIEW_BOTTOM_PADDING);
		if (size.height > frame.size.height) {
			frame.size = size;
		}
		frame.origin = CGPointMake(frame.origin.x, 0);
		[UIEffects addDashedBorderToView:self.textView withFrame:frame];
	}
}

//User has edited the text view somehow so we recount the words in the view. And adjust its size
- (void)textViewDidChange:(UITextView *)textView {
	[self adjustContentSizing];
}

#pragma mark Adjust text view frame to keyboard

//called when the keyboard is up. The Gap gives you the amount of visible space after
//the keyboard is up
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap {
	if(gap) {
		self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,
										 self.textView.frame.size.width, gap - VIEW_WALL_OFFSET);
	}else {
		self.textView.frame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2,
										 self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);
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
	self.imageView.clipsToBounds = YES;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
	[self addTapGestureToMainView];
	[self addSwipeGestureToImageView];
}

#pragma mark Filters

-(void)addSwipeGestureToImageView {
	UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(filterViewSwipeLeft:)];
	leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(filterViewSwipeRight:)];
	rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self addGestureRecognizer:leftSwipeRecognizer];
	[self addGestureRecognizer:rightSwipeRecognizer];
}

-(void)filterViewSwipeRight: (UISwipeGestureRecognizer *) sender {
	if (self.imageIndex > 0) {
		self.imageIndex = self.imageIndex -1;
		[self.imageView setImage:self.filteredImages[self.imageIndex]];
	}
}

-(void)filterViewSwipeLeft: (UISwipeGestureRecognizer *) sender {
	if (self.imageIndex < ([self.filteredImages count]-1)) {
		self.imageIndex = self.imageIndex +1;
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
	[self exitEditContentView];
}

-(void) exitEditContentView {
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EXIT_EDIT_CONTENT_VIEW object:nil userInfo:nil];
}

@end
