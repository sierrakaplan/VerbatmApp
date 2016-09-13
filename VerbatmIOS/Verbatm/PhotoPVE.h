//
//  PhotoPVEDelegate.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Page View for photos

#import <UIKit/UIKit.h>

#import "OpenCollectionView.h"

#import "PageViewingExperience.h"
#import "PinchView.h"

@protocol PhotoPVETextEntryDelegate <NSObject>

-(void) editContentViewTextIsEditing;
-(void) editContentViewTextDoneEditing;

@end

@interface PhotoPVE : PageViewingExperience

@property (weak, nonatomic) id<PhotoPVETextEntryDelegate> textEntryDelegate;
@property (weak, nonatomic) UIScrollView * postScrollView;

// Will start loading icon until displayPhotos is called if halfScreen is false
-(instancetype) initWithFrame:(CGRect)frame small:(BOOL) small isPhotoVideoSubview:(BOOL)halfScreen;
-(void) displayPhotos:(NSArray*) photos;




//When a view is animating it doesn't sense gestures very well. This makes it tough for users
// to scroll up and down while their photo slideshow is playing.
//To manage this we add to clear views above the animating views to catch the gestures.
//We add two views instead of one because of the buttons on the bottom right -- don't want
// to cover them.
@property (nonatomic, weak) UIView * panGestureSensingViewVertical;
@property (nonatomic, weak) UIView * panGestureSensingViewHorizontal;


-(void)layoutContainerViews;
-(void) initialFormatting;
-(void) addPhotos:(NSArray*)photosTextArray;
-(void) setImageViewsToLocation:(NSInteger)index;
-(void)playSlideshow;
-(void)startBaseSlideshowTimer;

@property (nonatomic, weak) PinchView *pinchView;
@property (nonatomic, weak) UIButton * pauseToRearrangeButton;
@property (nonatomic, weak) OpenCollectionView * rearrangeView;
@property (nonatomic) BOOL animating;
@property (nonatomic) BOOL slideShowPlaying;
@property (nonatomic) BOOL slideShowPaused;//when not in preview mode

// Tells whether should display smaller sized images
@property (nonatomic) BOOL small;

@property (nonatomic) BOOL photoVideoSubview;
@property (strong, nonatomic) NSMutableArray* imageContainerViews;
@property (nonatomic) NSInteger currentPhotoIndex;

#define TEXT_VIEW_HEIGHT 70.f
#define OPEN_COLLECTION_FRAME_HEIGHT 70.f

#define IMAGE_FADE_OUT_ANIMATION_DURATION 1.f

#define CIRCLE_ANIMATION_DURATION ((PHOTO_SLIDESHOW_PROGRESS_PATH_SECTION_SPEED + IMAGE_FADE_OUT_ANIMATION_DURATION) * self.imageContainerViews.count)

@end
