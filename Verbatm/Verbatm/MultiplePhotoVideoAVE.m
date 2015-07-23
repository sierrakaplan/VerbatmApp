
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "MultiplePhotoVideoAVE.h"
#import "VideoAVE.h"
#import "Notifications.h"
#import "Durations.h"
#import "BaseArticleViewingExperience.h"
#import "VerbatmImageScrollView.h"

@interface MultiplePhotoVideoAVE()
@property (weak, nonatomic) IBOutlet VideoAVE *videoView;
@property (weak, nonatomic) IBOutlet VerbatmImageScrollView *photoListScrollView;
@property (strong, nonatomic) AVMutableComposition* mix;
//@property (strong, nonatomic) UIView * gestureView;//to be placed ontop of video view to sense all gestures

#define x_ratio 3
#define y_ratio 4
#define ELEMENT_WALL_OFFSET 10
#define  VIDEO_VIEW_HALF_FRAME CGRectMake(0, 0, self.frame.size.width, VIDEO_VIEW_HEIGHT)
#define VIDEO_VIEW_HEIGHT (((self.frame.size.width*3)/4))
#define SV_DEFAULT_HEIGHT (self.frame.size.height - VIDEO_VIEW_HEIGHT)
@end
@implementation MultiplePhotoVideoAVE

-(id)initWithFrame:(CGRect)frame andPhotos:(NSArray*)photos andVideos:(NSArray*)videos
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"MultiplePhotoVideoAVE" owner:self options:nil]firstObject];
    if(self)
    {
        self.frame = frame;
        [self setViewFrames];
        [self.photoListScrollView renderPhotos:photos];
		[self.videoView playVideos:videos];
    }
    return self;
}

//sets the frames for the video view and the photo scrollview
-(void) setViewFrames {
    self.videoView.frame = VIDEO_VIEW_HALF_FRAME;
//    self.gestureView.frame = self.videoView.frame;
    self.photoListScrollView.frame = CGRectMake(0, VIDEO_VIEW_HEIGHT, self.frame.size.width, SV_DEFAULT_HEIGHT);
    [self bringSubviewToFront:self.photoListScrollView];

	[self addTapGestureToView: self.photoListScrollView];
	[self addTapGestureToView: self.videoView];
}


-(void) addTapGestureToView:(UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(elementTapped:)];
    tap.numberOfTapsRequired =1;
    [view addGestureRecognizer:tap];
}


-(void) elementTapped:(UITapGestureRecognizer *) gesture {

	UIView * view = gesture.view;
	BaseArticleViewingExperience* superview = (BaseArticleViewingExperience*)self.superview;

	if(superview.mainViewIsFullScreen) {
		[superview removeMainView];
	} else {
		[superview setViewAsMainView:view];
		if (view == self.photoListScrollView) {
			[UIView animateWithDuration:AVE_VIEW_FILLS_SCREEN_DURATION animations:^{
				[self.photoListScrollView setImagesToFullScreen];
			}];
		}
	}
}


-(void)offScreen
{
    [self.videoView offScreen];

}

-(void)onScreen
{
    [self.videoView onScreen];
}

/*Mute the video*/
-(void)mutePlayer
{
    
    [self.videoView muteVideo];
    
}

/*Enable's the sound on the video*/
-(void)enableSound
{
    
    [self.videoView unmuteVideo];
}

@end
