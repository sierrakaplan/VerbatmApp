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
		[self repeatVideoOnEnd:YES];
		//comes as NSURL from parse
	} else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
		//TODO(sierra): make sure all videos play sequentially
		[self playVideoFromURL:[videoList objectAtIndex:0]];
		[self repeatVideoOnEnd:YES];
	}
	[self pauseVideo];
}

#pragma mark - showing the progess bar -
/*This function shows the play and pause icons*/
-(void)showPlayBackIcons
{
    [self setUpPlayAndPauseButtons];
}

#pragma mark - manipulating playing of videos -
-(void)setUpPlayAndPauseButtons
{
    self.play_pauseBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn setFrame:CGRectMake(PLY_PSE_FRAME)];
    [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(modifyPlayback:)];
    [self addGestureRecognizer:panGesture];
    [self addSubview: self.play_pauseBtn];
}

-(void)showPlayIcon
{
    [self.play_pauseBtn setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn addTarget:self action:@selector(continueVideo) forControlEvents:UIControlEventTouchUpInside];
}

/*Allows the user to use a pan gesture to determine rewind or fast forward 
 *Right now just the act of panning causes this. This function does not modify the rate as more panning 
 *occurs. Changes could easily be made to take care of this if that turns out to be what the designers want
 */
-(void)modifyPlayback:(UIPanGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self];
    CGRect viableRegion = CGRectMake(self.frame.origin.x + self.frame.size.width/4, self.frame.origin.y, self.frame.size.width/2, self.frame.size.height);
    if(!CGRectContainsPoint(viableRegion, location))return;
    CGPoint translation = [sender translationInView: self];
    if(sender.state == UIGestureRecognizerStateBegan){
        self.firstTranslation = translation;
        [self changeRate];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        self.firstTranslation = CGPointZero;
        [self continueVideo];
    }else{
        if(CGPointEqualToPoint(CGPointZero, self.firstTranslation)){
            self.firstTranslation = translation;
            [self changeRate];
            return;
        }
        BOOL shouldPlayAtNormalRate = (translation.x < 0 &&  self.firstTranslation.x > 0) || (translation.x > 0 &&  self.firstTranslation.x < 0);
        if(shouldPlayAtNormalRate){
            self.firstTranslation = CGPointZero;
            [self continueVideo];
        }
    }
}

/*this function changes the rate at which the video is played. Based on the direction of first translation of the pan gesture. A right translation ie delta_x > 0 means fast forward and vice versa for the left*/
-(void)changeRate
{
    if(self.firstTranslation.x > 0){
        [self fastForwardVideoWithRate:MAX_VD_RATE];
    }else{
        [self rewindVideoWithRate:MAX_VD_RATE];
    }
	[self showPlayIcon];
}

-(void)offScreen
{
    [self pauseVideo];
}

-(void)onScreen
{
    [self continueVideo];
    [self unmuteVideo];

}

-(void) viewDidAppear {
	//TODO
}
@end
