
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "CollectionPinchView.h"
#import "Durations.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

#import "Notifications.h"

#import "PhotoPVE.h"
#import "PhotoVideoPVE.h"

#import "Styles.h"
#import "VideoPVE.h"

@interface PhotoVideoPVE() <UIScrollViewDelegate, PhotoPVETextEntryDelegate>

@property (strong, nonatomic) PhotoPVE* photosView;
@property (nonatomic) CGRect videoAveFrame;
@property (nonatomic) CGRect photoAveFrame;

#pragma mark - In Preview Mode -
@property (strong, nonatomic) CollectionPinchView* pinchView;

@end

@implementation PhotoVideoPVE

-(instancetype)initWithFrame:(CGRect)frame andPhotos:(NSArray*)photos andVideos:(NSArray*)videos {
    self = [super initWithFrame:frame];
    if(self) {
		self.inPreviewMode = NO;
		[self initialFormatting];

		self.photosView = [[PhotoPVE alloc] initWithFrame:self.photoAveFrame andPhotoArray:photos];
		self.photosView.isPhotoVideoSubview = YES;
		self.photosView.textEntryDelegate = self;
		self.videoView = [[VideoPVE alloc]initWithFrame:self.videoAveFrame andVideoWithTextArray:videos];
		[self addSubview:self.videoView];
		[self addSubview:self.photosView];
    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame andPinchView:(CollectionPinchView*) pinchView inPreviewMode: (BOOL) previewMode {
	self = [super initWithFrame:frame];
	if (self) {
		self.inPreviewMode = previewMode;
		self.pinchView = pinchView;
		[self initialFormatting];

		self.photosView = [[PhotoPVE alloc] initWithFrame:self.photoAveFrame andPinchView:pinchView inPreviewMode: previewMode];
		self.photosView.isPhotoVideoSubview = YES;
		self.photosView.textEntryDelegate = self;
		self.videoView = [[VideoPVE alloc]initWithFrame:self.videoAveFrame andPinchView:pinchView inPreviewMode: previewMode];
		[self addSubview:self.videoView];
		[self addSubview:self.photosView];
	}
	return self;
}

-(void) initialFormatting {
	[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
	//make sure the video is on repeat
	self.videoView.videoPlayer.repeatsVideo = YES;

	float videoAveHeight = ((self.frame.size.width*3)/4);
	float photoAveHeight = (self.frame.size.height - videoAveHeight);

	self.videoAveFrame = CGRectMake(0, 0, self.frame.size.width, videoAveHeight);
	self.photoAveFrame = CGRectMake(0, videoAveHeight, self.frame.size.width, photoAveHeight);
}

-(void) showAndRemoveCircle {
    if(self.postScrollView){
        self.photosView.postScrollView = self.postScrollView;
    }
    [self.photosView showAndRemoveCircle];
}

#pragma mark - PhotoAveTextEntry Delegate methods -

-(void) editContentViewTextIsEditing{
    [self movePhotoPageUp:YES];
}

-(void) editContentViewTextDoneEditing{
    [self movePhotoPageUp:NO];
}

-(void)movePhotoPageUp:(BOOL) moveUp{
    if(moveUp){
        [UIView animateWithDuration:PAGE_VIEW_FILLS_SCREEN_DURATION animations:^{
            [self bringSubviewToFront:self.photosView];
            self.photosView.frame = CGRectMake(0, 0, self.photosView.frame.size.width, self.photosView.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:PAGE_VIEW_FILLS_SCREEN_DURATION animations:^{
            self.photosView.frame = CGRectMake(0, self.videoView.frame.size.height, self.photosView.frame.size.width, self.photosView.frame.size.height);
        }];
    }
}

#pragma mark - Overriding offscreen/onscreen methods -

-(void)offScreen {
    [self.videoView offScreen];
    [self.photosView offScreen];
}

-(void)onScreen {
    [self.videoView onScreen];
	[self.photosView onScreen];
}

-(void)almostOnScreen {
    [self.videoView almostOnScreen];
	[self.photosView almostOnScreen];
}

-(void)unmuteVideo{
    [self.videoView unmuteVideo];
}

-(void)muteVideo{
    [self.videoView muteVideo];
}

@end
