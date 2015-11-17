//
//  v_videoview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VideoAVE.h"
#import "Icons.h"
#import "CollectionPinchView.h"
#import "VideoPinchView.h"
#import "EditMediaContentView.h"
#import "BaseArticleViewingExperience.h"

@interface VideoAVE()

@property (strong, nonatomic) UIImageView* videoProgressImageView;  //Kept because of the snake....will be implemented soon
@property (strong, nonatomic) UIButton* play_pauseBtn;
@property (nonatomic) CGPoint firstTranslation;
@property (nonatomic, strong) NSArray * videoList;
@property (nonatomic) BOOL hasBeenSetUp;
@property (nonatomic) EditMediaContentView * ourEMCV;
#define RGB 255,225,255, 0.7
#define PROGR_VIEW_HEIGHT 60
#define PLAYBACK_ICON_SIZE 40
#define MAX_VD_RATE 2
#define PLY_PSE_FRAME self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 50, 50,50
@end


@implementation VideoAVE

-(id)initWithFrame:(CGRect)frame pinchView:(PinchView *)pinchView orVideoArray:(NSArray*) videoAndTextList {
    if((self = [super initWithFrame:frame])) {
		[self repeatVideoOnEnd:YES];
        if(videoAndTextList.count) {
            [self playVideosFromArray:videoAndTextList];
        }else if (pinchView){
             NSMutableArray * videoAssets = [[NSMutableArray alloc] init];
            if([pinchView isKindOfClass:[CollectionPinchView class]]){
                for(VideoPinchView * view in ((CollectionPinchView *)pinchView).pinchedObjects) {
                    [videoAssets addObject:view.video];
                }
                
            }else{//it's a videopinchview
                [videoAssets addObject:((VideoPinchView *)pinchView).video];
            }
        
            self.ourEMCV= [[EditMediaContentView alloc] initWithFrame:self.bounds];
            self.ourEMCV.pinchView = pinchView;
            [self.ourEMCV displayVideo:videoAssets];
            [self addSubview:self.ourEMCV];
        }
    }
    return self;
}


-(void)playVideosFromArray:(NSArray *) videoAndTextList{
    NSMutableArray* videoList = [[NSMutableArray alloc] initWithCapacity: videoAndTextList.count];
    for (NSArray* videoWithText in videoAndTextList) {
        [videoList addObject: videoWithText[0]];
        NSString* text = videoWithText[1];
        NSNumber* textYPos = videoWithText[2];
    }
    [self playVideos:videoList];
    self.hasBeenSetUp = NO;
}


-(void)playVideos:(NSArray*)videoList {
    if(self.videoList != videoList){
        self.videoList = videoList;
        return;
    }
    //comes as avurlasset in preview
	if ([[videoList objectAtIndex:0] isKindOfClass:[AVURLAsset class]]) {
		//comes as NSURL from backend
        [self prepareVideoFromArrayOfAssets_asynchronous:videoList];
	} else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
		[self prepareVideoFromURLArray_asynchronouse:videoList];
	} else {
		return;
	}
}


#pragma mark - On and Off Screen (play and pause) -

-(void)offScreen{
    [self stopVideo];
    self.hasBeenSetUp = NO;
}

-(void)onScreen {
    if(!self.hasBeenSetUp){
        self.playAtEndOfAsynchronousSetup = YES;//triggers a condition in the prepare system to allow the video to play
        [self playVideos:self.videoList];
    }else{
        [self playVideo];
        self.hasBeenSetUp = YES;
    }
}

-(void)almostOnScreen{
    if(self.videoList)[self stopVideo];
    [self playVideos:self.videoList];
    self.hasBeenSetUp = YES;
}

@end
