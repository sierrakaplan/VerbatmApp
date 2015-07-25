//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "EditContentView.h"
#import "VerbatmImageView.h"
#import "VerbatmPullBarView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UIEffects.h"
#import "ContentDevVC.h"

@interface EditContentView ()

#pragma mark FilteredPhotos
@property (nonatomic, strong) UIImage * filter_Original;
@property (nonatomic, strong) UIImage * filter_BW;
@property (nonatomic, strong) UIImage * filter_WARM;
@property (nonatomic, strong) NSString * filter;

@property (strong, nonatomic) UIButton* publishButton;

@end


@implementation EditContentView

-(instancetype) initCustomViewWithFrame:(CGRect)frame
{
	self = [super init];
	if(self)
	{
		self.backgroundColor = [UIColor blackColor];
		self.frame = frame;

	}
	return self;
}

#pragma mark - Text View -

-(void)adjustContentSizing {
	[self.textView adjustToolBarFrame];
	[UIEffects addDashedBorderToView:self.textView];
}

//called when the keyboard is up. The Gap gives you the amount of visible space after
//the keyboard is up
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap
{
	if(gap)
	{
		self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, gap - VIEW_WALL_OFFSET);
	}else
	{
		self.textView.frame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2, self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);
	}

	[self adjustContentSizing];

}

-(void) createTextViewFromTextView: (UITextView *) textView {

	//be sure to remove it
	if(self.gestureView) {
		[self.gestureView removeFromSuperview];
		self.gestureView = nil;
	}

	CGRect textViewFrame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2, self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);
	self.textView = [[VerbatmUITextView alloc] initWithFrame:textViewFrame];
	[self formatTextViewAppropriately:self.textView];
	[self addSubview:self.textView];

	if(textView) {
		//adjusts the frame of the textview andthe contentsize of the scrollview if need be
		[self adjustContentSizing];
		self.textView.text = textView.text;
	}
}

//Calculate the appropriate bounds for the text view
//We only return a frame that is larger than the default frame size
-(CGRect) calculateBoundsForOpenTextView: (UIView *) view
{
	CGSize  tightbounds = [view sizeThatFits:view.bounds.size];

	return CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tightbounds.height);
}


//Formats a textview to the appropriate settings
-(void) formatTextViewAppropriately: (UITextView *) textView
{
	//Set delegate for text new view
	[textView setFont:[UIFont fontWithName:TEXT_AVE_FONT size:TEXT_AVE_FONT_SIZE]];
	textView.backgroundColor = [UIColor TEXT_SCROLLVIEW_BACKGROUND_COLOR];//sets the background as clear
	textView.textColor = [UIColor TEXT_AVE_COLOR];
	textView.tintColor = [UIColor TEXT_AVE_COLOR];

	//ensure keyboard is black
	textView.keyboardAppearance = UIKeyboardAppearanceDark;

	textView.scrollEnabled = YES;
}

#pragma mark - Image or Video View -
-(void)addVideo: (AVAsset*) video {
	self.videoView = [[VideoPlayerView alloc]init];
	self.videoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:self.videoView];
	[self bringSubviewToFront:self.videoView];
	[self.videoView playVideoFromAsset:video];
	[self.videoView repeatVideoOnEnd:YES];
}

-(void)addImage: (NSData*) image
{

	if(self.gestureView)//be sure to remove it
	{
		[self.gestureView removeFromSuperview];
		self.gestureView = nil;
	}

	//create a new scrollview to place the images
	self.imageView = [[VerbatmImageView alloc]init];
	self.imageView.image = [[UIImage alloc] initWithData:image];
	self.imageView.asset = image;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
	[self createFilteredImages];
	[self addSwipeToOpenedView];
	self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)createFilteredImages
{
	//original "filter"
	NSData *data = (NSData *) self.imageView.asset;

	//warm filter
	CIImage *beginImage =  [CIImage imageWithData:data];

	CIContext *context = [CIContext contextWithOptions:nil];

	CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues: kCIInputImageKey, beginImage, nil];
	CIImage *outputImage = [filter outputImage];

	CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];

	self.filter_WARM = [UIImage imageWithCGImage:cgimg];


	CIImage *beginImage1 =  [CIImage imageWithData:data];

	CIFilter *filter1 = [CIFilter filterWithName:@"CIPhotoEffectMono"
								   keysAndValues: kCIInputImageKey, beginImage1, nil];

	CIImage *outputImage1 = [filter1 outputImage];

	CGImageRef cgimg1 =[context createCGImage:outputImage1 fromRect:[outputImage1 extent]];

	self.filter_BW = [UIImage imageWithCGImage:cgimg1];

	CGImageRelease(cgimg);
	//free the buffer after use
	//free(buffer);
}



-(void)addSwipeToOpenedView
{
	UISwipeGestureRecognizer * leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(filterViewSwipe:)];
	leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	[self addGestureRecognizer:leftSwipe];
}


-(void)filterViewSwipe: (UISwipeGestureRecognizer *) sender
{
	if(self.filter && [self.filter isEqualToString:@"BW"])
	{
		self.imageView.image = self.filter_Original;
		self.filter = @"Original";
	}else if (self.filter && [self.filter isEqualToString:@"WARM"])
	{
		self.imageView.image = self.filter_BW;
		self.filter = @"BW";
	}else
	{
		self.imageView.image = self.filter_WARM;
		self.filter = @"WARM";
	}
}

@end
