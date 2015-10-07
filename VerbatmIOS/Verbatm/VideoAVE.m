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

-(id)initWithFrame:(CGRect)frame andVideoArray:(NSArray*)videoList {
    if((self = [super initWithFrame:frame])) {
		[self repeatVideoOnEnd:YES];
        if(videoList.count) {
            [self playVideos:videoList];
        }
    }
    return self;
}

-(void)playVideos:(NSArray*)videoList {
	//comes as avurlasset in preview
	if ([[videoList objectAtIndex:0] isKindOfClass:[AVURLAsset class]]) {
		//comes as NSURL from backend
        [self playVideoFromArrayOfAssets:videoList];
	} else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
		[self playVideoFromURL:videoList[0]];
	} else {
		return;
	}
	[self pauseVideo];
}


#pragma mark - On and Off Screen (play and pause) -

-(void)offScreen{
    [self pauseVideo];
}

-(void)onScreen {
    [self continueVideo];
    [self unmuteVideo];

}

@end
