
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "BaseArticleViewingExperience.h"
#import "CollectionPinchView.h"
#import "Durations.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

#import "Notifications.h"

#import "PhotoAVE.h"
#import "PhotoVideoAVE.h"

#import "Styles.h"
#import "VideoAVE.h"

@interface PhotoVideoAVE() <UIScrollViewDelegate>

@property (strong, nonatomic) PhotoAVE* photosView;

@end
@implementation PhotoVideoAVE

-(id)initWithFrame:(CGRect)frame andPhotos:(NSArray*)photos andVideos:(NSArray*)videos orCollectionView:(CollectionPinchView *) collectionView
{
    self = [super initWithFrame:frame];
    if(self)
    {
		[self setBackgroundColor:[UIColor AVE_BACKGROUND_COLOR]];
        [self setSubViewsWithPhotos: photos andVideos:videos orPinchView:collectionView];
        //make sure the video is on repeat
        [self.videoView repeatVideoOnEnd:YES];
    }
    return self;
}

//sets the frames for the video view and the photo scrollview
-(void) setSubViewsWithPhotos: (NSArray*) photos andVideos: (NSArray*) videos orPinchView:(CollectionPinchView *) collection {
    
	float videoViewHeight = ((self.frame.size.width*3)/4);
	float photosViewHeight = (self.frame.size.height - videoViewHeight);

    CGRect videoViewFrame = CGRectMake(0, 0, self.frame.size.width, videoViewHeight);
    CGRect photoListFrame = CGRectMake(0, videoViewHeight, self.frame.size.width, photosViewHeight);
    
    NSMutableArray * imagePVArray;
    if(collection){
        imagePVArray = [[NSMutableArray alloc] init];
        for (PinchView * pv in collection.pinchedObjects) {
            if([pv isKindOfClass:[ImagePinchView class]]){
                [imagePVArray addObject:pv];
            }
        }
    }
    
    self.photosView = [[PhotoAVE alloc] initWithFrame:photoListFrame andPhotoArray:photos orPinchviewArray:(imagePVArray) ? imagePVArray : nil isSubViewOfPhotoVideoAve:YES];
    
    self.videoView = [[VideoAVE alloc]initWithFrame:videoViewFrame pinchView:(collection.containsVideo) ? collection : nil orVideoArray:videos];

	[self addSubview:self.videoView];
	[self addSubview:self.photosView];

	[self addTapGestureToPhotoView: self.photosView];
	[self addTapGestureToVideoView: self.videoView];
}


-(void) addTapGestureToPhotoView:(UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoElementTapped:)];
    tap.numberOfTapsRequired =1;
    [view addGestureRecognizer:tap];
    if(self.photosView)[tap requireGestureRecognizerToFail:self.photosView.photoAveTapGesture];
}
-(void) addTapGestureToVideoView:(UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoElementTapped:)];
    tap.numberOfTapsRequired =1;
    [view addGestureRecognizer:tap];
    if(self.photosView)[tap requireGestureRecognizerToFail:self.photosView.photoAveTapGesture];
}

-(void) videoElementTapped:(UITapGestureRecognizer *) gesture {
	UIView * view = gesture.view;
	BaseArticleViewingExperience* superview = (BaseArticleViewingExperience*)self.superview;
	if(superview.mainViewIsFullScreen) {
		[superview removeMainView];
	} else {
		[superview setViewAsMainView:view];
	}
}

-(void) photoElementTapped:(UITapGestureRecognizer *) gesture {
    UIView * view = gesture.view;
    BaseArticleViewingExperience* superview = (BaseArticleViewingExperience*)self.superview;
    if(superview.mainViewIsFullScreen) {
        [superview removeMainView];
    } else {
        [superview setViewAsMainView:view];
    }
}


-(void) showAndRemoveCircle {
    if(self.povScrollView){
        self.photosView.povScrollView = self.povScrollView;
    }
    [self.photosView showAndRemoveCircle];
}


//image scroll view is on new page
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	NSInteger newPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
}

-(void)offScreen {
    [self.videoView offScreen];

}

-(void)onScreen {
    [self.videoView onScreen];
}

/*Mute the video*/
-(void)mutePlayer {
	[self.videoView muteVideo];
}

/*Enable's the sound on the video*/
-(void)enableSound{
    [self.videoView unmuteVideo];
}
-(void)almostOnScreen{
    [self.videoView almostOnScreen];
}


@end
