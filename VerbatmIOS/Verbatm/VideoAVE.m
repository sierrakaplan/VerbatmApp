
//
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"

#import "EditMediaContentView.h"

#import "Icons.h"

#import "SizesAndPositions.h"

#import "VideoAVE.h"
#import "VideoPinchView.h"

#import "OpenCollectionView.h"

@interface VideoAVE()<OpenCollectionViewDelegate>

@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (strong, nonatomic) UIButton* playButton;
@property (nonatomic) CGPoint firstTranslation;
@property (nonatomic, strong) NSArray * videoList;
@property (nonatomic) BOOL hasBeenSetUp;

#pragma mark - In Preview Mode -
@property (strong, nonatomic) PinchView* pinchView;
@property (nonatomic) EditMediaContentView * editContentView;
@property (nonatomic) OpenCollectionView * rearrangeView;
@property (nonatomic) UIButton * rearrangeButton;

@end


@implementation VideoAVE

-(instancetype) initWithFrame:(CGRect)frame andVideoArray:(NSArray*) videoAndTextList {
	self = [super initWithFrame:frame];
	if (self) {
		self.inPreviewMode = NO;
		[self.videoPlayer repeatVideoOnEnd:YES];
        [self playVideosFromArray:videoAndTextList];
    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView {
	self = [super initWithFrame:frame];
	if (self) {
		self.inPreviewMode = YES;

		NSMutableArray * videoAssets = [[NSMutableArray alloc] init];
		if([pinchView isKindOfClass:[CollectionPinchView class]]){
			for(VideoPinchView* videoPinchView in ((CollectionPinchView *)pinchView).videoPinchViews) {
				[videoAssets addObject: videoPinchView.video];
			}
		} else {
			[videoAssets addObject:((VideoPinchView *)pinchView).video];
		}

		self.editContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];
		self.editContentView.pinchView = pinchView;
		[self.editContentView displayVideo:videoAssets];
		[self addSubview: self.editContentView];
		if(videoAssets.count > 1) [self createRearrangeButton];
	}
	return self;
}

-(void)playVideosFromArray:(NSArray *) videoAndTextList{
    NSMutableArray* videoList = [[NSMutableArray alloc] initWithCapacity: videoAndTextList.count];
    for (NSArray* videoWithText in videoAndTextList) {
        [videoList addObject: videoWithText[0]];
//        NSString* text = videoWithText[1];
//        NSNumber* textYPos = videoWithText[2];
    }
    [self prepareVideos:videoList];
    self.hasBeenSetUp = NO;
}


-(void)prepareVideos:(NSArray*)videoList {
	if ([[videoList objectAtIndex:0] isKindOfClass:[AVURLAsset class]]) {
        [self.videoPlayer prepareVideoFromArrayOfAssets_asynchronous:videoList];
	} else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
		[self.videoPlayer prepareVideoFromURLArray_asynchronouse:videoList];
	} else {
		return;
	}
}
#pragma mark - Rearrange button -

-(void)createRearrangeButton {
    [self.rearrangeButton setImage:[UIImage imageNamed:CREATE_REARRANGE_ICON] forState:UIControlStateNormal];
    self.rearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.rearrangeButton addTarget:self action:@selector(rearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rearrangeButton];
    [self bringSubviewToFront:self.rearrangeButton];
}

-(void)rearrangeButtonPressed {
    if(!self.rearrangeView){
        self.rearrangeView = [[OpenCollectionView alloc] initWithFrame:self.bounds
													 andPinchViewArray: ((CollectionPinchView*)self.pinchView).videoPinchViews];
        self.rearrangeView.delegate = self;
        [self insertSubview:self.rearrangeView belowSubview:self.rearrangeButton];
    } else{
        [self.rearrangeView exitView];
    }
}

-(void) collectionClosedWithFinalArray:(NSMutableArray *)pinchViews {
    
    NSMutableArray * assetArray = [[NSMutableArray alloc] init];
    for(VideoPinchView * videoPinchView in pinchViews) {
        [assetArray addObject:videoPinchView.video];
    }
    if(self.editContentView.videoView.isPlaying){
        [self.editContentView displayVideo:assetArray];
        [self.editContentView almostOnScreen];
        [self.editContentView onScreen];
    }
    if([self.editContentView.pinchView isKindOfClass:[CollectionPinchView class]]){
		((CollectionPinchView*)self.pinchView).videoPinchViews = pinchViews;
    }
    if(self.rearrangeView){
        [self.rearrangeView removeFromSuperview];
        self.rearrangeView = nil;
    }
}


#pragma mark - On and Off Screen (play and pause) -

-(void)offScreen{
    if(self.editContentView) {
        [self.editContentView offScreen];
    } else{
        [self.videoPlayer pauseVideo];
    }
    if(self.rearrangeView) [self.rearrangeView exitView];
}

-(void)onScreen {
    if (self.editContentView){
        [self.editContentView onScreen];
    } else{
        [self.videoPlayer playVideo];
    }
}

-(void)almostOnScreen{
    if(self.editContentView){
        [self.editContentView almostOnScreen];
    }
}

#pragma mark - Lazy Instantiation -

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
