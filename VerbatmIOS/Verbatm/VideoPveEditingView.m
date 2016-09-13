
//
//  VideoPveEditingView.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoPveEditingView.h"
#import "CollectionPinchView.h"
#import "VideoPinchView.h"
#import "SizesAndPositions.h"

@interface VideoPveEditingView ()<OpenCollectionViewDelegate>
@property (strong, nonatomic) PinchView* pinchView;
@property (nonatomic) EditMediaContentView * editContentView;
@property (nonatomic) OpenCollectionView * rearrangeView;
@property (nonatomic) UIButton * rearrangeButton;
@end

@implementation VideoPveEditingView


-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView isPhotoVideoSubview:(BOOL)halfScreen {
    self = [super initWithFrame:frame];
    if (self) {
        self.hasLoadedMedia = YES;
        self.photoVideoSubview = halfScreen;
        self.videoPlayer.repeatsVideo = YES;
        
        AVAsset *videoAsset = nil;
        NSMutableArray * videoAssets = [[NSMutableArray alloc] init];
        if([pinchView isKindOfClass:[CollectionPinchView class]]){
            videoAsset = ((CollectionPinchView *)pinchView).videoAsset;
            for(VideoPinchView* videoPinchView in ((CollectionPinchView *)pinchView).videoPinchViews) {
                [videoAssets addObject: videoPinchView.video];
            }
        } else if (((VideoPinchView *)pinchView).video) {
            [videoAssets addObject:((VideoPinchView *)pinchView).video];
        } else {
            NSLog(@"Something went wrong, video nil");
        }
        
        self.editContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];
        self.editContentView.pinchView = pinchView;
        [self.editContentView displayVideo];
        [self addSubview: self.editContentView];
        
        if(videoAssets.count > 1) [self createRearrangeButton];
        
        if (videoAsset != nil) {
            [self fuseVideoArray:@[videoAsset]];
        } else {
            [self fuseVideoArray:videoAssets];
        }
        
    }
    return self;
}


-(void)prepareVideo {
    if (self.videoAsset == nil) {
        return;
    }
    [self.editContentView prepareVideoFromAsset:self.videoAsset];
    self.hasBeenSetUp = YES;
}


-(void)offScreen {
    [self.customActivityIndicator stopCustomActivityIndicator];
    self.currentlyOnScreen = NO;
    [self.editContentView offScreen];
    if([self.editContentView.pinchView isKindOfClass:[CollectionPinchView class]]){
        ((CollectionPinchView*)self.editContentView.pinchView).videoAsset = self.videoAsset;
    }
    [self.rearrangeView exitView];
    self.hasBeenSetUp = NO;
}
-(void)onScreen {
    self.currentlyOnScreen = YES;
    if (!self.hasLoadedMedia && !self.photoVideoSubview) {
        [self.customActivityIndicator startCustomActivityIndicator];
        return;
    }
    [self.editContentView onScreen];
}

-(void) almostOnScreen{
    [self.editContentView almostOnScreen];
}

//called by opencollection view but not to be used here
-(void)pinchViewSelected:(PinchView *) pv{
    
}

#pragma mark - Rearrange button -

-(void)createRearrangeButton {
    [self.rearrangeButton setImage:[UIImage imageNamed:MEDIA_REARRANGE_ICON] forState:UIControlStateNormal];
    self.rearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.rearrangeButton addTarget:self action:@selector(rearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rearrangeButton];
    [self bringSubviewToFront:self.rearrangeButton];
}

-(void)rearrangeButtonPressed {
    if(!self.rearrangeView){
        [self offScreen];
        self.rearrangeView = [[OpenCollectionView alloc] initWithFrame:self.bounds
                                                     andPinchViewArray: ((CollectionPinchView*)self.editContentView.pinchView).videoPinchViews];
        self.rearrangeView.delegate = self;
        [self insertSubview:self.rearrangeView belowSubview:self.rearrangeButton];
    } else {
        [self.rearrangeView exitView];
    }
}


-(void) collectionClosedWithFinalArray:(NSMutableArray *)pinchViews {
    NSMutableArray * assetArray = [[NSMutableArray alloc] init];
    for(VideoPinchView * videoPinchView in pinchViews) {
        [assetArray addObject:videoPinchView.video];
    }
    self.videoAsset = nil;
    if (self.editContentView) {
        self.editContentView.videoAsset = nil;
    }
    [self fuseVideoArray:assetArray];
    if(self.editContentView.videoView.isVideoPlaying){
        [self.editContentView offScreen];
    }
    if([self.editContentView.pinchView isKindOfClass:[CollectionPinchView class]]){
        ((CollectionPinchView*)self.editContentView.pinchView).videoPinchViews = pinchViews;
        [self.editContentView.pinchView renderMedia];
    }
    if(self.rearrangeView){
        [self.rearrangeView removeFromSuperview];
        self.rearrangeView = nil;
    }
    self.hasBeenSetUp = NO;
    [self onScreen];
}


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
