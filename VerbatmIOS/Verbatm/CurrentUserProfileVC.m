//
//  CurrentUserProfileVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "GMImagePickerController.h"

#import <ReplayKit/ReplayKit.h>

#import "CurrentUserProfileVC.h"
#import "Icons.h"
#import "ParseBackendKeys.h"
#import "ProfileHeaderView.h"
#import "ProfileMoreInfoView.h"
#import "SettingsVC.h"
#import "VerbatmNavigationController.h"
#import "StoryboardVCIdentifiers.h"
#import "Notifications.h"
#import "VerbatmNavigationController.h"
#import "UserManager.h"

@interface CurrentUserProfileVC() <ProfileHeaderViewDelegate, GMImagePickerControllerDelegate, RPPreviewViewControllerDelegate, RPScreenRecorderDelegate>

@property (nonatomic) PHImageManager* imageManager;
@property (nonatomic) UIImageView * noInternetState;
#define SETTINGS_BUTTON_SIZE 24.f
@property (nonatomic) BOOL currentlyRecording;

@end

@implementation CurrentUserProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionUpdate:)
                                                 name:INTERNET_CONNECTION_NOTIFICATION
                                               object:nil];
}

-(void)networkConnectionUpdate:(NSNotification *) notification {
    
    NSNumber * connectivity =  [notification userInfo][INTERNET_CONNECTION_KEY];
    if(![connectivity boolValue]){
        if(self.noInternetState) return;
        [self clearOurViews];
        self.noInternetState = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.noInternetState setImage:[UIImage imageNamed:NO_INTERNET_ICON]];
        [self.view addSubview:self.noInternetState];
    }else{
        if(!self.noInternetState) return;
        [self.noInternetState removeFromSuperview];
        self.noInternetState = nil;
        [self reloadProfile];
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor blackColor]];
    
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void) setNavigationItem {
}

-(void) headerViewTapped {
	[super headerViewTapped];
}

-(void) moreInfoButtonTapped {
	[super moreInfoButtonTapped];
}

-(void) addCoverPhotoButtonTapped {
	[self presentGalleryToSelectImage];
}


-(void) settingsButtonTapped {
	SettingsVC *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:SETTINGS_VC_ID];
	[self.navigationController pushViewController:settingsVC animated:YES];
}


-(void)addReplayKitGesture{
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(replayKitLongPress:)];
    [self.profileHeaderView addGestureRecognizer:longPress];
    
}

-(void)replayKitLongPress:(UILongPressGestureRecognizer *) longPress{
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            self.currentlyRecording = !self.currentlyRecording;
            if(self.currentlyRecording){
                
                if([RPScreenRecorder sharedRecorder].available){
                    NSLog(@"Replay Kit is available");
                }else{
                    NSLog(@"Can't user replay kit");
                }
                
                [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
                    if(error){
                        NSLog(@"Error when starting to record. Desctiption: %@", error.description);
                    }
                }];
                
                
            }else{
              
                 NSLog(@"Stopping recording");
                //end recording
                [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
                    if(!error && previewViewController){
                        NSLog(@"Presenting preview VC");
                        previewViewController.previewControllerDelegate = self;
                       // previewViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        //[self presentViewController:previewViewController animated:NO completion:nil];
                        [self.navigationController pushViewController:previewViewController animated:YES];
                    }
                }];
            }
            
            break;
        default:
            break;
    }
    
    
}



/*! @abstract Called when recording has stopped for any reason.
 @param screenRecorder The instance of the screen recorder.
 @param error An NSError describing why recording has stopped in the RPRecordingErrorDomain.
 @param previewController If a partial movie is available before it was stopped, an instance of RPPreviewViewController will be returned.
 */
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(nullable RPPreviewViewController *)previewViewController{
    if(error){
        NSLog(@"%@", error.description);
    }
}

/*! @abstract Called when the recorder becomes available or stops being available. Check the screen recorder's availability property to check the current availability state. Possible reasons for the recorder to be unavailable include an in-progress Airplay/TVOut session or unsupported hardware.
 @param screenRecorder The instance of the screen recorder.
 */
- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder{
    if(!screenRecorder.available){
        NSLog(@"Screen recorder stopped being available.");
    }
}
#pragma mark -RPPreviewController-
/* @abstract Called when the view controller is finished. */
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController{
    
}

/* @abstract Called when the view controller is finished and returns a set of activity types that the user has completed on the recording. The built in activity types are listed in UIActivity.h. */
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes{
    
}


#pragma mark -Cover Photo-

-(void)presentGalleryToSelectImage {
	GMImagePickerController *picker = [[GMImagePickerController alloc] init];
	picker.delegate = self;
	//Display or not the selection info Toolbar:
	picker.displaySelectionInfoToolbar = YES;

	//Display or not the number of assets in each album:
	picker.displayAlbumsNumberOfAssets = YES;

	//Customize the picker title and prompt (helper message over the title)
	picker.title = @"Verbatm";
	picker.customNavigationBarPrompt = @"Pick a cover photo for your profile!";

	[picker setSelectOnlyOneImage:YES];

	//Customize the number of cols depending on orientation and the inter-item spacing
	picker.colsInPortrait = 3;
	picker.colsInLandscape = 5;
	picker.minimumInteritemSpacing = 2.0;
	[self presentViewController:picker animated:YES completion:nil];
}

-(void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray{
	for(PHAsset * asset in assetArray) {
		if(asset.mediaType==PHAssetMediaTypeImage) {
			@autoreleasepool {
				[self getImageFromAsset:asset];
			}
		}
	}
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
}

-(void) getImageFromAsset: (PHAsset *) asset {
	PHImageRequestOptions *options = [PHImageRequestOptions new];
	options.synchronous = YES;
	[self.imageManager requestImageForAsset:asset targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFill
									options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
										// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
										dispatch_async(dispatch_get_main_queue(), ^{
											[self setCoverPhotoImage:image];
										});
									}];
}

-(void)setCoverPhotoImage:(UIImage *) coverPhotoImage {
	[self.profileHeaderView setNewCoverPhoto: coverPhotoImage];
	[self.channel storeCoverPhoto:coverPhotoImage];
	[[UserManager sharedInstance]holdCurrentCoverPhoto:coverPhotoImage];
}

-(PHImageManager*) imageManager {
	if (!_imageManager) {
		_imageManager = [[PHImageManager alloc] init];
	}
	return _imageManager;
}

@end
