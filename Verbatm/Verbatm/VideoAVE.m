//
//  v_videoview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VideoAVE.h"
#import "Icons.h"
#import "BaseArticleViewingExperience.h"

@interface VideoAVE()

@property (strong, nonatomic) UIImageView* videoProgressImageView;  //Kept because of the snake....will be implemented soon
@property (strong, nonatomic) UIButton* play_pauseBtn;
@property (nonatomic) CGPoint firstTranslation;
#define RGB 255,225,255, 0.7
#define PROGR_VIEW_HEIGHT 60
#define PLAYBACK_ICON_SIZE 40
#define MAX_VD_RATE 2
#define PLY_PSE_FRAME self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 50, 50,50
@end


@implementation VideoAVE

//no seeking. Fast forward and rewind.
//play and pause button that doesn't move on the side.s
-(id)initWithFrame:(CGRect)frame andVideoAssetArray:(NSArray*)videoList {
    if((self = [super initWithFrame:frame])) {
		[self repeatVideoOnEnd:YES];
        if(videoList.count) {
            [self playVideos:videoList];
        }
    }
    return self;
}



-(void)playVideos:(NSArray*)videoList
{
	//comes as avurlasset in preview
	if ([[videoList objectAtIndex:0] isKindOfClass:[AVURLAsset class]]) {
		[self playVideoFromArray:videoList];
		//comes as NSURL from parse
	} else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
		[self playVideoFromURLList:videoList];
	}
	[self pauseVideo];
}

#pragma mark - showing the progess bar -
/*This function shows the play and pause icons*/
//-(void)showPlayBackIcons
//{
//    [self setUpPlayAndPauseButtons];
//}
//
//#pragma mark - manipulating playing of videos -
//-(void)setUpPlayAndPauseButtons
//{
//    self.play_pauseBtn = [UIButton buttonWithType: UIButtonTypeCustom];
//    [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
//    [self.play_pauseBtn setFrame:CGRectMake(PLY_PSE_FRAME)];
//    [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
//    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(modifyPlayback:)];
//    [self addGestureRecognizer:panGesture];
//    [self addSubview: self.play_pauseBtn];
//}


-(void)offScreen
{
    [self pauseVideo];
}

-(void)onScreen
{
    [self continueVideo];
    [self unmuteVideo];

}

@end
