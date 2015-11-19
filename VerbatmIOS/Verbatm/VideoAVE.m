//
//  v_videoview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "BaseArticleViewingExperience.h"

#import "CollectionPinchView.h"

#import "EditMediaContentView.h"

#import "Icons.h"

#import "SizesAndPositions.h"

#import "VideoAVE.h"
#import "VideoPinchView.h"

#import "RearrangePV.h"

@interface VideoAVE()<RearrangePVDelegate>

@property (strong, nonatomic) UIImageView* videoProgressImageView;  //Kept because of the snake....will be implemented soon
@property (strong, nonatomic) UIButton* play_pauseBtn;
@property (nonatomic) CGPoint firstTranslation;
@property (nonatomic, strong) NSArray * videoList;
@property (nonatomic) BOOL hasBeenSetUp;
@property (nonatomic) EditMediaContentView * ourEMCV;
@property (nonatomic) RearrangePV * rearrangeView;
@property (nonatomic) UIButton * rearrangeButton;

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
                for(PinchView * view in ((CollectionPinchView *)pinchView).pinchedObjects) {
                    if([view isKindOfClass:[VideoPinchView class]])[videoAssets addObject:((VideoPinchView *)view).video];
                }
            }else{//it's a videopinchview
                [videoAssets addObject:((VideoPinchView *)pinchView).video];
            }
        
            self.ourEMCV= [[EditMediaContentView alloc] initWithFrame:self.bounds];
            self.ourEMCV.pinchView = pinchView;
            [self.ourEMCV displayVideo:videoAssets];
            [self addSubview:self.ourEMCV];
            if(videoAssets.count > 1) [self createRearrangeButton];
            
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
#pragma mark -Add button-

-(void)createRearrangeButton {
    [self.rearrangeButton setImage:[UIImage imageNamed:CREATE_REARRANGE_ICON] forState:UIControlStateNormal];
    self.rearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.rearrangeButton addTarget:self action:@selector(rearrangeContentSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rearrangeButton];
    [self bringSubviewToFront:self.rearrangeButton];
}

-(void)rearrangeContentSelected {
    if(!self.rearrangeView){
        self.rearrangeView = [[RearrangePV alloc] initWithFrame:self.bounds andPinchViewArray:[((CollectionPinchView *)self.ourEMCV.pinchView) getVideoPinchViews]];
        self.rearrangeView.delegate = self;
        [self insertSubview:self.rearrangeView belowSubview:self.rearrangeButton];

    }else{
        [self.rearrangeView removeFromSuperview];
        [self.rearrangeView exitRearrangeView];
        self.rearrangeView = nil;
    }

}

-(void)exitPVWithFinalArray:(NSMutableArray *) pvArray{
    
    NSMutableArray * assetArray = [[NSMutableArray alloc] init];
    for(VideoPinchView * videoPinchView in pvArray){
        [assetArray addObject:videoPinchView.video];
    }
    
    [self.ourEMCV displayVideo:assetArray];//this sets the assets
    [self.ourEMCV almostOnScreen];//prepares screen
    [self.ourEMCV onScreen];//makes it play now
    if([self.ourEMCV.pinchView isKindOfClass:[CollectionPinchView class]]){
        [((CollectionPinchView *)self.ourEMCV.pinchView) replaceVideoPinchViesWithNewVPVs:pvArray];
    }
}


#pragma mark - On and Off Screen (play and pause) -

-(void)offScreen{
    if(self.ourEMCV){
        [self.ourEMCV offScreen];
    }else{
        [self stopVideo];
        self.hasBeenSetUp = NO;
    }
   
}

-(void)onScreen {
    
    
    if(self.ourEMCV){
        [self.ourEMCV onScreen];
    }else{
        if(!self.hasBeenSetUp){
            self.playAtEndOfAsynchronousSetup = YES;//triggers a condition in the prepare system to allow the video to play
            [self playVideos:self.videoList];
        }else{
            [self playVideo];
            self.hasBeenSetUp = YES;
        }
    
    }
}

-(void)almostOnScreen{
    
    
    if(self.ourEMCV){
        [self.ourEMCV almostOnScreen];
    }else{
        if(self.videoList)[self stopVideo];
        [self playVideos:self.videoList];
        self.hasBeenSetUp = YES;
    }
}

#pragma mark -lacy instantiation-

-(UIButton *)rearrangeButton {
    if(!_rearrangeButton){
        _rearrangeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
                                                                      EXIT_CV_BUTTON_WIDTH,
                                                                      self.frame.size.height - (EXIT_CV_BUTTON_HEIGHT) -
                                                                      (EXIT_CV_BUTTON_WALL_OFFSET),
                                                                      EXIT_CV_BUTTON_WIDTH,
                                                                      EXIT_CV_BUTTON_HEIGHT)];
    }
    return _rearrangeButton;
}

@end
