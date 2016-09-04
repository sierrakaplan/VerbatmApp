//
//  CurrentUserProfileVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "GMImagePickerController.h"

#import "CurrentUserProfileVC.h"
#import "Icons.h"
#import "ParseBackendKeys.h"
#import "ProfileHeaderView.h"
#import "ProfileMoreInfoView.h"
#import "SettingsVC.h"
#import "VerbatmNavigationController.h"
#import "StoryboardVCIdentifiers.h"

#import "VerbatmNavigationController.h"
#import "UserManager.h"

@interface CurrentUserProfileVC() <ProfileHeaderViewDelegate, GMImagePickerControllerDelegate>

@property (nonatomic) PHImageManager* imageManager;

#define SETTINGS_BUTTON_SIZE 24.f

@end

@implementation CurrentUserProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
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

#pragma mark - Cover Photo -

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
