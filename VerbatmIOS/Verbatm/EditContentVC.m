//
//  EditContentVC.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CoverPicturePinchView.h"
#import "EditContentVC.h"
#import "Icons.h"
#import "ImagePinchView.h"
#import "SizesAndPositions.h"
#import "UserSetupParameters.h"
#import "VideoPinchView.h"
#import "SegueIDs.h"
#import "UserPovInProgress.h"

@interface EditContentVC() <EditContentViewDelegate>

@property (strong, nonatomic) UIButton * exitButton;
@property (strong, nonatomic) EditContentView * openEditContentView;

@end

@implementation EditContentVC

-(void)viewDidLoad {
    [self createEditContentViewFromPinchView];
    [self createExitButton];
}

// This should never be called on a collection pinch view, only on text, image, or video
-(void) createEditContentViewFromPinchView {
    self.openEditContentView = [[EditContentView alloc] initWithFrame:self.view.bounds];
    self.openEditContentView.delegate = self;
	if(self.openPinchView.containsImage) {

		ImagePinchView* imagePinchView = (ImagePinchView*) self.openPinchView;
		[self.openEditContentView displayImages:[imagePinchView filteredImages] atIndex:[imagePinchView filterImageIndex]];

		if (![self.openPinchView isKindOfClass:[CoverPicturePinchView class]]) {
			[self.openEditContentView createTextCreationButton];
			if (imagePinchView.text && imagePinchView.text.length) {
				[self.openEditContentView setText:imagePinchView.text andTextViewYPosition:imagePinchView.textYPosition.floatValue];
			}
		}
	} else if(self.openPinchView.containsVideo) {

		[self.openEditContentView displayVideo:[(VideoPinchView*)self.openPinchView video]];
		NSString* videoPinchViewText = [(VideoPinchView*)self.openPinchView text];
		if (videoPinchViewText && videoPinchViewText.length) {
			[self.openEditContentView setText:videoPinchViewText andTextViewYPosition:[(VideoPinchView*)self.openPinchView textYPosition].floatValue];
		}
	} else {
		return;
	}
    [self.view addSubview:self.openEditContentView];
    if(![[UserSetupParameters sharedInstance] filter_InstructionShown] && [self.openPinchView isKindOfClass:[ImagePinchView class]]) {
		[self alertAddFilter];
	}
}

-(void)createExitButton{
    self.exitButton = [[UIButton alloc] initWithFrame:
                       CGRectMake(EXIT_CV_BUTTON_WALL_OFFSET, EXIT_CV_BUTTON_WALL_OFFSET,
                                  EXIT_CV_BUTTON_WIDTH, EXIT_CV_BUTTON_HEIGHT)];
    [self.exitButton setImage:[UIImage imageNamed:DONE_CHECKMARK] forState:UIControlStateNormal];
	[self.exitButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.exitButton addTarget:self action:@selector(exitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
    [self.view bringSubviewToFront:self.exitButton];
}

-(void)alertAddFilter {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Swipe left to add a filter!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [[UserSetupParameters sharedInstance] set_filter_InstructionAsShown];
}

-(void)exitButtonClicked:(UIButton*) sender{
    [self exitViewController];
}

-(void)exitViewController{
    if (!self.openEditContentView) {
        return;
    }
    if(self.openPinchView.containsImage) {
		ImagePinchView* imagePinchView = (ImagePinchView*) self.openPinchView;
        NSInteger filterImageIndex =  [self.openEditContentView getFilteredImageIndex];
		[imagePinchView changeImageToFilterIndex: filterImageIndex];
		[self.openEditContentView.videoView stopVideo];
        //if there is a text view and it has text then we should save it. otherwise we get rid of any reference
		((ImagePinchView *) self.openPinchView).text = [self.openEditContentView getText];
		((ImagePinchView *) self.openPinchView).textYPosition = [self.openEditContentView getTextYPosition];
		[[UserPovInProgress sharedInstance] updatePinchView: self.openPinchView];
    }
	if(self.openPinchView.containsVideo) {
        if(self.openEditContentView.videoView)[self.openEditContentView.videoView stopVideo];
		//TODO: add text to video
	}
    [self performSegueWithIdentifier:UNWIND_SEGUE_EDIT_CONTENT_VIEW sender:self];
}

#pragma mark - Delegate Methods -
//Delegate method for EditContentView
-(void) exitEditContentView {

    [self exitViewController];
}

@end
