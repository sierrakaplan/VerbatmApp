
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
#import "Styles.h"
#import "BaseArticleViewingExperience.h"
#import "VerbatmImageScrollView.h"

@interface MultiplePhotoVideoAVE() <AVEDelegate>

@property (strong, nonatomic) VideoAVE *videoView;
@property (strong, nonatomic) VerbatmImageScrollView *photoListScrollView;
@property (strong, nonatomic) AVMutableComposition* mix;

@end
@implementation MultiplePhotoVideoAVE

-(id)initWithFrame:(CGRect)frame andPhotos:(NSArray*)photos andVideos:(NSArray*)videos
{
    self = [super initWithFrame:frame];
    if(self)
    {
		[self setBackgroundColor:[UIColor AVE_BACKGROUND_COLOR]];
        [self setSubViews];
        [self.photoListScrollView renderPhotos:photos withBlurBackground:YES];
		[self.videoView playVideos:videos];
    }
    return self;
}

//sets the frames for the video view and the photo scrollview
-(void) setSubViews {

	float videoViewHeight = ((self.frame.size.width*3)/4);
	float photoListScrollViewHeight = (self.frame.size.height - videoViewHeight);

    CGRect videoViewFrame = CGRectMake(0, 0, self.frame.size.width, videoViewHeight);
    CGRect photoListFrame = CGRectMake(0, videoViewHeight, self.frame.size.width, photoListScrollViewHeight);
	self.photoListScrollView = [[VerbatmImageScrollView alloc] initWithFrame:photoListFrame];
	self.videoView = [[VideoAVE alloc] initWithFrame:videoViewFrame];

	[self addSubview:self.videoView];
	[self addSubview:self.photoListScrollView];

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

-(void) viewDidAppear {
	//TODO
}

@end
