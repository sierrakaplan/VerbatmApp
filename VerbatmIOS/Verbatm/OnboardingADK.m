//
//  OnboardingADK.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ContentPageElementScrollView.h"
#import "PinchView.h"
#import "OnboardingADK.h"
#import "MediaSelectTile.h"
#import "PublishingProgressManager.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "VerbatmCameraView.h"
#import "VerbatmScrollView.h"
#import "UserInfoCache.h"
#import "UserSetupParameters.h"

@interface OnboardingADK() <MediaSelectTileDelegate, UIScrollViewDelegate, ContentPageElementScrollViewDelegate, VerbatmCameraViewDelegate>

@property (nonatomic) UIView *topNavMessage;
@property (nonatomic) UILabel *topNavLabel;
@property (nonatomic) UIImageView *firstSlideBackground;
@property (nonatomic) MediaSelectTile *baseMediaTileSelector;

@property (nonatomic) BOOL captureMediaInstructionShown;
@property (nonatomic) BOOL pinchInstructionShown;

#pragma mark Camera View

@property (strong, nonatomic) VerbatmCameraView* cameraView;

#define NAV_MESSAGE_HEIGHT 100.f
#define OFFSET_X 30.f
#define OFFSET_Y 10.f

@end

@implementation OnboardingADK

-(void) viewDidLoad {
	self.navigationItem.hidesBackButton = YES;
	self.captureMediaInstructionShown = NO;
	self.pinchInstructionShown = NO;
	[self initializeVariables];
	[self setFrameMainScrollView];
	[self setElementDefaultFrames];
	self.firstSlideBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
	self.firstSlideBackground.image = [UIImage imageNamed:@"ADK_slide_1"];
	self.firstSlideBackground.contentMode = UIViewContentModeScaleAspectFill;
	[self.view addSubview: self.firstSlideBackground];
	self.navigationController.navigationBar.hidden = YES;
}

-(void) viewWillAppear:(BOOL)animated {
	//do not want super method's called
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTutorial)];
	[self.firstSlideBackground addGestureRecognizer: tapGesture];
	self.firstSlideBackground.userInteractionEnabled = YES;
}

-(void) startTutorial {
	[self.firstSlideBackground removeFromSuperview];
	[self addBackgroundImage];
	[self.view addSubview: self.topNavMessage];
	self.topNavLabel.text = @"All the media you capture will be saved here. Tap the camera icon to capture your media.";
	[self addCamera];
}

-(void) addCamera {
	CGRect scrollViewFrame = CGRectMake(0, NAV_MESSAGE_HEIGHT + OFFSET_Y*2,
										self.view.frame.size.width, MEDIA_TILE_SELECTOR_HEIGHT + ELEMENT_Y_OFFSET_DISTANCE);

	ContentPageElementScrollView *baseMediaTileSelectorScrollView = [[ContentPageElementScrollView alloc]
																	 initWithFrame:scrollViewFrame
																	 andElement:self.baseMediaTileSelector];
	baseMediaTileSelectorScrollView.scrollEnabled = NO;
	baseMediaTileSelectorScrollView.delegate = self; // scroll view delegate
	baseMediaTileSelectorScrollView.contentPageElementScrollViewDelegate = self;

	[self.mainScrollView addSubview:baseMediaTileSelectorScrollView];
	[self.pageElementScrollViews addObject:baseMediaTileSelectorScrollView];
}

-(void) cameraButtonPressedOnTile:(MediaSelectTile *)tile {
	[self.view addSubview:self.cameraView];
	[self.cameraView createAndInstantiateGestures];
	if (self.captureMediaInstructionShown) {
		[self.cameraView enableCapturingPhoto: YES];
		[self.cameraView enableCapturingVideo: YES];
		return;
	}
	[self.cameraView enableCapturingPhoto: NO];
	[self.view bringSubviewToFront: self.topNavMessage];
	self.topNavLabel.text = @"Press and hold to capture a short video of what you're doing.";
}

// These should not be called, as the gallery button and text button are disabled
-(void) galleryButtonPressedOnTile: (MediaSelectTile*) tile {
	[super galleryButtonPressedOnTile: tile];
}

-(void) textButtonPressedOnTile:(MediaSelectTile*) tile {
	[super textButtonPressedOnTile:tile];
}

#pragma mark - Verbatm Camera View Delegate methods -

// add image to deck (create pinch view)
-(void) imageAssetCaptured: (PHAsset *) asset {
	[self placeNewMediaAtBottomOfDeck];
	[self getImageFromAsset:asset];
	if (self.captureMediaInstructionShown) return;
	if (self.pageElementScrollViews.count >= 3) {
		[self minimizeCameraViewButtonTapped];
		self.captureMediaInstructionShown = YES;
		[self.baseMediaTileSelector enableGalleryButton:YES];
		[self.baseMediaTileSelector enableTextButton:YES];
		self.topNavLabel.text = @"Pinch two of the circles together!";
	}
}

// add video asset to deck (create pinch view)
-(void) videoAssetCaptured:(PHAsset *) asset {
	[self placeNewMediaAtBottomOfDeck];
	[self getVideoFromAsset: asset];
	if (self.captureMediaInstructionShown) return;
	[self.cameraView enableCapturingVideo:NO];
	[self.cameraView enableCapturingPhoto:YES];
	self.topNavLabel.text = @"Now capture two pictures.";
}

-(void) minimizeCameraViewButtonTapped {
	[self.cameraView removeFromSuperview];
	[self removeExcessMediaTiles];
}

//not called
-(void) pinchviewSelected:(PinchView *)pinchView {}

-(void) pinchingHasEnded {
	if (self.pinchInstructionShown) return;
	self.pinchInstructionShown = YES;
	self.topNavLabel.text = @"Each circle is a page in your story. Tap one open to see what you just made!";
}

-(void) aboutToRemovePreview {
	[super aboutToRemovePreview];
	if (!self.pinchInstructionShown) return;
	self.topNavLabel.text = @"Now tap here to publish your post!";
	UITapGestureRecognizer *tapToPublishGesture = [[UITapGestureRecognizer alloc]
												   initWithTarget:self action:@selector(tappedToPublish)];
	[self.topNavMessage addGestureRecognizer: tapToPublishGesture];
}

-(void) tappedToPublish {
	NSMutableArray * pinchViews = [[NSMutableArray alloc] init];

	for(ContentPageElementScrollView * contentElementScrollView in self.pageElementScrollViews){
		if([contentElementScrollView.pageElement isKindOfClass:[PinchView class]]){
			[pinchViews addObject:contentElementScrollView.pageElement];
		}
	}

	if(pinchViews.count){
		[self publishOurStoryWithPinchViews:pinchViews];
	}
}

-(void) continueToPublish {
	[[UserInfoCache sharedInstance] loadUserChannelsWithCompletionBlock:^{
		//todo: make sure not creating two
		self.userChannel = [[UserInfoCache sharedInstance] getUserChannel];
		[[PublishingProgressManager sharedInstance] publishPostToChannel:self.userChannel andFacebook:TRUE withCaption:@"" withPinchViews:self.pinchViewsToPublish
													 withCompletionBlock:^(BOOL isAlreadyPublishing, BOOL noNetwork) {
														 NSString *errorMessage;
														 if(isAlreadyPublishing) {
															 errorMessage = @"Please wait until the previous post has finished publishing.";
														 } else if (noNetwork) {
															 errorMessage = @"Something went wrong - please check your network connection and try again.";
														 } else {
															 //Everything went ok
															 [self performSegueWithIdentifier:UNWIND_SEGUE_FROM_ONBOARDING_TO_MASTER sender:self];
															 //														 [self cleanUp];
															 return;
														 }
														 UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Couldn't Publish" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
														 UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
																											   handler:^(UIAlertAction * action) {}];
														 [newAlert addAction:defaultAction];
														 [self presentViewController:newAlert animated:YES completion:nil];
													 }];
	}];
}

#pragma mark - Lazy Instantiation -

-(VerbatmCameraView*) cameraView {
	if (!_cameraView) {
		_cameraView = [[VerbatmCameraView alloc] initWithFrame:self.view.bounds];
		_cameraView.delegate = self;
	}
	return _cameraView;
}

-(UIView*) topNavMessage {
	if (!_topNavMessage) {
		_topNavMessage = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, NAV_MESSAGE_HEIGHT)];
		[_topNavMessage addSubview: self.topNavLabel];
		_topNavMessage.backgroundColor = [UIColor orangeColor];
	}
	return _topNavMessage;
}

-(UILabel*) topNavLabel {
	if (!_topNavLabel) {
		_topNavLabel = [[UILabel alloc] initWithFrame:CGRectMake(OFFSET_X, OFFSET_Y, self.view.frame.size.width - OFFSET_X*2,
																 NAV_MESSAGE_HEIGHT - OFFSET_Y*2)];
		_topNavLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_topNavLabel.numberOfLines = 3;
		_topNavLabel.textAlignment = NSTextAlignmentCenter;
		_topNavLabel.font = [UIFont fontWithName:BOLD_FONT size:20.f];
	}
	return _topNavLabel;
}

-(MediaSelectTile*) baseMediaTileSelector {
	if (!_baseMediaTileSelector) {
		CGRect frame = CGRectMake(ELEMENT_X_OFFSET_DISTANCE,
								  ELEMENT_Y_OFFSET_DISTANCE/2.f,
								  self.view.frame.size.width - (ELEMENT_X_OFFSET_DISTANCE * 2), MEDIA_TILE_SELECTOR_HEIGHT);
		_baseMediaTileSelector= [[MediaSelectTile alloc]initWithFrame:frame];
		_baseMediaTileSelector.isBaseSelector = YES;
		[_baseMediaTileSelector enableTextButton:NO];
		[_baseMediaTileSelector enableGalleryButton:NO];
		_baseMediaTileSelector.delegate = self;
		[_baseMediaTileSelector createFramesForButtonsWithFrame:frame];
		[_baseMediaTileSelector buttonGlow];
	}

	return _baseMediaTileSelector;
}


@end
