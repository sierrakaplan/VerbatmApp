 //
//  PhotoPVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import "CustomNavigationBar.h"

#import "Durations.h"

#import "EditMediaContentView.h"

#import "Icons.h"
#import "ImagePinchView.h"

#import "MathOperations.h"

#import "PointObject.h"
#import "PostInProgress.h"
#import "PhotoPVE.h"

#import "OpenCollectionView.h"

#import "SizesAndPositions.h"
#import "Styles.h"

#import "TextOverMediaView.h"

#import "UIImage+ImageEffectsAndTransforms.h"


@interface PhotoPVE() <UIGestureRecognizerDelegate, OpenCollectionViewDelegate, EditContentViewDelegate>

@property (strong, nonatomic) NSMutableArray* imageContainerViews;
@property (nonatomic) NSInteger currentPhotoIndex;

//When a view is animating it doesn't sense gestures very well. This makes it tough for users
// to scroll up and down while their photo slideshow is playing.
//To manage this we add to clear views above the animating views to catch the gestures.
//We add two views instead of one because of the buttons on the bottom right -- don't want
// to cover them.
@property (nonatomic, weak) UIView * panGestureSensingViewVertical;
@property (nonatomic, weak) UIView * panGestureSensingViewHorizontal;

#pragma mark - In Preview Mode -

@property (nonatomic, weak) PinchView *pinchView;
@property (nonatomic, weak) UIButton * pauseToRearrangeButton;
@property (nonatomic, weak) OpenCollectionView * rearrangeView;

// Tells whether should display smaller sized images
@property (nonatomic) BOOL small;

#define TEXT_VIEW_HEIGHT 70.f
#define SLIDESHOW_ANIMATION_DURATION 1.5f
#define OPEN_COLLECTION_FRAME_HEIGHT 70.f

//this view manages the tapping gesture of the set circles
@property (nonatomic, strong) UIView * circleTapView;
@property (nonatomic) BOOL animating;

@property (nonatomic) BOOL slideShowPlaying;
@end

@implementation PhotoPVE

-(instancetype) initWithFrame:(CGRect)frame andPhotoArray:(NSArray *)photos
						small:(BOOL) small {
	self = [super initWithFrame:frame];
	if (self) {
		self.small = small;
		self.inPreviewMode = NO;
        if ([photos count]) {
			[self addPhotos:photos];
		}
		[self initialFormatting];
	}
	return self;
}

-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView inPreviewMode: (BOOL) inPreviewMode {
	self = [super initWithFrame:frame];
	if (self) {
		self.small = NO;
		self.inPreviewMode = inPreviewMode;
		self.pinchView = pinchView;
		if([self.pinchView isKindOfClass:[CollectionPinchView class]]){
			[self addContentFromImagePinchViews:((CollectionPinchView *)self.pinchView).imagePinchViews];
		}else{
			[self addContentFromImagePinchViews:[NSMutableArray arrayWithObject:pinchView]];
		}
		[self initialFormatting];
	}
	return self;
}

-(void) initialFormatting {
	[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
}

#pragma mark - Preview mode -

-(void) addContentFromImagePinchViews:(NSMutableArray *)pinchViewArray{
	NSMutableArray* photosTextArray = [[NSMutableArray alloc] init];

    for (ImagePinchView * imagePinchView in pinchViewArray) {
		if (self.inPreviewMode) {
			EditMediaContentView * editMediaContentView = [self getEditContentViewFromPinchView:imagePinchView];
			[self.imageContainerViews addObject:editMediaContentView];
		} else {
			[photosTextArray addObject: [imagePinchView getPhotosWithText][0]];
		}
    }
	if (!self.inPreviewMode) {
		[self addPhotos: photosTextArray];
	} else {
		[self layoutContainerViews];
		if(pinchViewArray.count > 1)
         	[self createRearrangeButton];
    }
}

-(EditMediaContentView *) getEditContentViewFromPinchView: (ImagePinchView *)pinchView {
	EditMediaContentView * editMediaContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];

	PHImageRequestOptions *options = [PHImageRequestOptions new];
	options.synchronous = YES;
	[pinchView getLargerImageWithSize: pinchView.largeSize].then(^(UIImage *image) {
		[editMediaContentView changeImageTo:image];
	});

	[editMediaContentView displayImages:[pinchView filteredImages] atIndex:pinchView.filterImageIndex];

	if(pinchView.text && pinchView.text.length) {
		[editMediaContentView setText:pinchView.text
					 andTextYPosition:[pinchView.textYPosition floatValue]
						 andTextColor:pinchView.textColor
					 andTextAlignment:[pinchView.textAlignment integerValue]
						  andTextSize:[pinchView.textSize floatValue]];
	}

	editMediaContentView.pinchView = pinchView;
	editMediaContentView.povViewMasterScrollView = self.postScrollView;
	editMediaContentView.delegate = self;
	return editMediaContentView;
}

-(void)layoutContainerViews{
	//adding subviews in reverse order so that imageview at index 0 on top
	for (int i = (int)[self.imageContainerViews count]-1; i >= 0; i--) {
		[self addSubview:[self.imageContainerViews objectAtIndex:i]];
	}
}

#pragma mark - Not preview mode -

/* photoTextArray is array containing subarrays of photo and text info
  @[@[photourl,photo, text, textYPosition, textColor, textAlignment, textSize],...] */
-(void) addPhotos:(NSArray*)photosTextArray {
    
	for (NSArray* photoText in photosTextArray) {
        [self.imageContainerViews addObject:[self getImageContainerViewFromPhotoTextArray:photoText]];
	}

	// Has to add duplicate of first photo to bottom so that you can fade from the last photo into the first
	//NSArray* firstPhotoText = photosTextArray[0];
	//[self addSubview: [self getImageContainerViewFromPhotoTextArray: firstPhotoText]];
	[self layoutContainerViews];
}

-(TextOverMediaView*) getImageContainerViewFromPhotoTextArray: (NSArray*) photoTextArray {
	NSURL *url = photoTextArray[0];
	UIImage *thumbnailimage = photoTextArray[1];
	NSString* text = photoTextArray[2];
	CGFloat textYPosition = [(NSNumber *)photoTextArray[3] floatValue];
	UIColor *textColor = photoTextArray[4];
	NSTextAlignment textAlignment = (NSTextAlignment) ([(NSNumber *)photoTextArray[5] integerValue]);
	CGFloat textSize = [(NSNumber *)photoTextArray[6] floatValue];

	if(self.isPhotoVideoSubview) {
		textYPosition = textYPosition/2.f;
	}

	TextOverMediaView* textAndImageView = [[TextOverMediaView alloc] initWithFrame:self.bounds
																		  andImageURL: url withSmallImage:thumbnailimage
																		   asSmall:self.small];
	if (text && text.length) {
		[textAndImageView setText: text
				 andTextYPosition: textYPosition
					 andTextColor: textColor
				 andTextAlignment: textAlignment
					  andTextSize: textSize];
		[textAndImageView showText:YES];
	}
	return textAndImageView;
}

#pragma mark - Tap Gesture -


#pragma mark - Rearrange content (preview mode) -

-(void)createRearrangeButton {
    [self.pauseToRearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
    self.pauseToRearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.pauseToRearrangeButton addTarget:self action:@selector(pauseToRearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:self.pauseToRearrangeButton];
}

-(void) pauseToRearrangeButtonPressed {
    if(!self.rearrangeView){
		[self offScreen];
        CGFloat y_pos = (self.isPhotoVideoSubview) ? 0.f : CUSTOM_NAV_BAR_HEIGHT;

        CGRect frame = CGRectMake(0.f,y_pos, self.frame.size.width, OPEN_COLLECTION_FRAME_HEIGHT);
		OpenCollectionView *rearrangeView = [[OpenCollectionView alloc] initWithFrame:frame
																	andPinchViewArray:((CollectionPinchView*)self.pinchView).imagePinchViews];
		[self insertSubview: rearrangeView belowSubview:self.pauseToRearrangeButton];
		self.rearrangeView = rearrangeView;
        self.rearrangeView.delegate = self;
        [self.pauseToRearrangeButton setImage:[UIImage imageNamed:PLAY_SLIDESHOW_ICON] forState:UIControlStateNormal];
    } else {
		for (UIView * view in self.imageContainerViews) {
			if([view isKindOfClass:[EditMediaContentView class]]){
				[((EditMediaContentView *)view) exiting];
			}
		}
        [self.pauseToRearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
        [self.rearrangeView exitView];
        [self playWithSpeed:2.f];
    }
}

//new pinchview tapped in rearange view so we need to change what's presented
-(void)pinchViewSelected:(PinchView *) pv{
    NSInteger imageIndex;
    for(NSInteger index = 0; index < self.imageContainerViews.count; index++){
        EditMediaContentView *eview = self.imageContainerViews[index];
        if(eview.pinchView == pv){
            imageIndex = index;
            break;
        }
    }
    [self setImageViewsToLocation:imageIndex];
}

-(void)playWithSpeed:(CGFloat) speed {
    if(!self.animating){
        CGRect v_frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.pauseToRearrangeButton.frame.origin.y);
        CGRect h_frame = CGRectMake(0.f, self.pauseToRearrangeButton.frame.origin.y,self.pauseToRearrangeButton.frame.origin.x - 10.f,
									self.frame.size.height - self.pauseToRearrangeButton.frame.origin.y);
        
        //create view to sense swiping
        if(self.panGestureSensingViewHorizontal == nil){
			UIView *panViewVertical = [[UIView alloc] initWithFrame:v_frame];
			[self addSubview: panViewVertical];
			self.panGestureSensingViewVertical = panViewVertical;
            self.panGestureSensingViewVertical.backgroundColor = [UIColor clearColor];

			UIView *panViewHorizontal = [[UIView alloc] initWithFrame:h_frame];
			[self addSubview: panViewHorizontal];
            self.panGestureSensingViewHorizontal = panViewHorizontal;
            self.panGestureSensingViewHorizontal.backgroundColor = [UIColor clearColor];
            
            [self bringSubviewToFront:self.panGestureSensingViewVertical];
            [self bringSubviewToFront:self.panGestureSensingViewHorizontal];
        }
        [NSTimer scheduledTimerWithTimeInterval:SLIDESHOW_ANIMATION_DURATION target:self selector:@selector(animateNextView) userInfo:nil repeats:NO];
    }
    self.slideShowPlaying = YES;
}

-(void)stopSlideshow{
    self.slideShowPlaying = NO;
    if(self.inPreviewMode){
        [self.panGestureSensingViewHorizontal removeFromSuperview];
        self.panGestureSensingViewHorizontal = nil;
        [self.panGestureSensingViewVertical removeFromSuperview];
        self.panGestureSensingViewVertical = nil;
    }
}

-(void)animateNextView{
    if(self.slideShowPlaying && !self.animating){
        [UIView animateWithDuration:1.5f animations:^{
            self.animating = YES;
            [self setImageViewsToLocation:(self.currentPhotoIndex + 1)];
        } completion:^(BOOL finished) {
            self.animating = NO;
            [NSTimer scheduledTimerWithTimeInterval:SLIDESHOW_ANIMATION_DURATION target:self selector:@selector(animateNextView) userInfo:nil repeats:NO];
        }];
    }
}


#pragma mark OpenCollectionView delegate method

-(void) collectionClosedWithFinalArray:(NSMutableArray *) pinchViews {
	if(self.rearrangeView){
		[self.rearrangeView removeFromSuperview];
		self.rearrangeView = nil;
	}
	self.imageContainerViews = nil;
	for (UIView * view in self.subviews) {
		[view removeFromSuperview];
	}
	((CollectionPinchView*)self.pinchView).imagePinchViews = pinchViews;
	[[PostInProgress sharedInstance] removePinchViewAtIndex:self.indexInPost andReplaceWithPinchView:self.pinchView];
	[self.pinchView renderMedia];
	[self addContentFromImagePinchViews: pinchViews];
}

#pragma mark Change image views locations and visibility

//sets image at given index to front by setting the opacity of all those in front of it to 0
//and those behind it to 1
-(void) setImageViewsToLocation:(NSInteger)index {
    if(index >= self.imageContainerViews.count){
        index = 0;
        ((UIView *) self.imageContainerViews[index]).alpha = 1.f;
    }
	if ([self.imageContainerViews[self.currentPhotoIndex] isKindOfClass:[TextOverMediaView class]]) {
		TextOverMediaView *oldMediaView = self.imageContainerViews[self.currentPhotoIndex];
		TextOverMediaView *currentMediaView = self.imageContainerViews[index];
		[oldMediaView displayLargeImage:NO];
		[currentMediaView displayLargeImage:YES];
	}
    self.currentPhotoIndex = index;
	for (int i = 0; i < self.imageContainerViews.count; i++) {
		UIView* imageView = self.imageContainerViews[i];
		if (i < self.currentPhotoIndex) {
			imageView.alpha = 0.f;
		} else {
			imageView.alpha = 1.f;
		}
	}
}

//sets all views to opaque again
-(void) reloadImages {
	for (UIView* imageView in self.imageContainerViews) {
		imageView.alpha = 1.f;
	}
}

#pragma mark - Gesture Recognizer Delegate methods -


#pragma mark - Overriding ArticleViewingExperience methods -

-(void) onScreen {
    if(self.imageContainerViews.count > 1){
        if(!self.slideShowPlaying){
            [self playWithSpeed:2.f];
        }
    } else {
		if (self.imageContainerViews.count > 0 && [self.imageContainerViews[0] isKindOfClass:[TextOverMediaView class]]) {
			[(TextOverMediaView*)self.imageContainerViews[0] displayLargeImage:YES];
		}
	}
}

- (void)offScreen {
	[self stopSlideshow];
    for (UIView * view in self.imageContainerViews) {
        if([view isKindOfClass:[EditMediaContentView class]]){
            [((EditMediaContentView *)view) exiting];
        } else {
			[(TextOverMediaView*)view displayLargeImage:NO];
		}
    }
	if(self.rearrangeView)[self.rearrangeView exitView];
}

#pragma mark - EditContentViewDelegate methods -

-(void) textIsEditing{
    if(self.isPhotoVideoSubview) [self.textEntryDelegate editContentViewTextIsEditing];
}

-(void) textDoneEditing{
    if(self.isPhotoVideoSubview) [self.textEntryDelegate editContentViewTextDoneEditing];
}


#pragma mark - Lazy Instantiation


@synthesize imageContainerViews = _imageContainerViews;

-(NSMutableArray*) imageContainerViews {
	if(!_imageContainerViews) _imageContainerViews = [[NSMutableArray alloc] init];
	return _imageContainerViews;
}

-(void) setImageContainerViews:(NSMutableArray *)imageContainerViews {
	_imageContainerViews = imageContainerViews;
}

-(UIButton *)pauseToRearrangeButton {
    if(!_pauseToRearrangeButton){
		UIButton *pauseToRearrangeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
																					  EXIT_CV_BUTTON_WIDTH,
																					  self.frame.size.height - (EXIT_CV_BUTTON_HEIGHT*2) -
																					  (EXIT_CV_BUTTON_WALL_OFFSET*3),
																					  EXIT_CV_BUTTON_WIDTH,
																					  EXIT_CV_BUTTON_HEIGHT)];
		 [self addSubview: pauseToRearrangeButton];
		_pauseToRearrangeButton = pauseToRearrangeButton;
    }
    return _pauseToRearrangeButton;
}

-(void) dealloc {

}
@end
