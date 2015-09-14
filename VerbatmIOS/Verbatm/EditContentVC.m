//
//  EditContentVC.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "EditContentVC.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"
#import "Identifiers.h"
#import "UserSetupParemeters.h"
@interface EditContentVC()<EditContentViewDelegate>
@property (strong, nonatomic) PinchView * openPinchView;

@end
@implementation EditContentVC

-(void)viewDidLoad {
    [self createEditContentViewFromPinchView:self.pinchView];
}


// This should never be called on a collection pinch view, only on text, image, or video
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView {
    self.openEditContentView = [[EditContentView alloc] initCustomViewWithFrame:self.view.bounds];
    self.openEditContentView.delegate = self;
    //adding text
    if(pinchView == nil) {
        [self.openEditContentView editText:@""];
    } else {
        if (pinchView.containsText) {
            [self.openEditContentView editText:[pinchView getText]];
        } else if(pinchView.containsImage) {
            ImagePinchView* imagePinchView = (ImagePinchView*)pinchView;
            [self.openEditContentView displayImages:[imagePinchView filteredImages] atIndex:[imagePinchView filterImageIndex]];
        } else if(pinchView.containsVideo) {
            [self.openEditContentView displayVideo:[(VideoPinchView*)pinchView video]];
        } else {
            return;
        }
        self.openPinchView = pinchView;
    }
    [self.view addSubview:self.openEditContentView];
    if(![UserSetupParemeters filter_InstructionShown] && [pinchView isKindOfClass:[ImagePinchView class]])[self alertAddFilter];
}

-(void)alertAddFilter{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Swipe left to add a filter!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [UserSetupParemeters set_filter_InstructionAsShown];
}


#pragma mark - Delegate Methods -

//Delegate method for EditContentView
-(void) exitEditContentView {
    if (!self.openEditContentView) {
        return;
    }
    if(self.openPinchView.containsImage) {
       self.filterImageIndex =  [self.openEditContentView getFilteredImageIndex];
    } else if(self.openPinchView.containsVideo) {
        //[self.openEditContentView.videoView stopVideo];
    }
    [self performSegueWithIdentifier:UNWIND_SEGUE_EDIT_CONTENT_VIEW sender:self];
}

@end
