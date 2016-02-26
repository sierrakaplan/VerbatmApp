
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

@property (strong, nonatomic, readwrite) VideoPlayerView* videoPlayer;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (strong, nonatomic) UIButton* playButton;
@property (nonatomic) CGPoint firstTranslation;
@property (nonatomic, strong) NSArray * videoList;
@property (nonatomic) BOOL hasBeenSetUp;

@property (nonatomic) UIImageView * thumbNailView;

#pragma mark - In Preview Mode -
@property (strong, nonatomic) PinchView* pinchView;
@property (nonatomic) EditMediaContentView * editContentView;
@property (nonatomic) OpenCollectionView * rearrangeView;
@property (nonatomic) UIButton * rearrangeButton;

@property (nonatomic) UIImageView * videoThumbNail;

@end


@implementation VideoAVE

-(instancetype) initWithFrame:(CGRect)frame andVideoArray:(NSArray*) videoAndTextList {
	self = [super initWithFrame:frame];
	if (self) {
        if (videoAndTextList.count) {//protecting from failed uploads being downloaded
            self.inPreviewMode = NO;
            [self.videoPlayer repeatVideoOnEnd:YES];
            [self playVideosFromArray:videoAndTextList];
            
            NSArray * firstVideoObject = [videoAndTextList firstObject];
            
            if(firstVideoObject.count >= 4){
                //this means there's a thumbnail
                [self createVideoThumbnailView:firstVideoObject[3]];
            }
        }
        
		
    }
    return self;
}

-(void)createVideoThumbnailView:(UIImage *) image{
   
    self.videoThumbNail = [[UIImageView alloc] initWithFrame:self.bounds];
    self.videoThumbNail.image = image;
    self.videoThumbNail.contentMode = UIViewContentModeScaleAspectFill;
    [self insertSubview:self.videoThumbNail belowSubview:self.videoPlayer];
}

-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView inPreviewMode: (BOOL) inPreviewMode {
	self = [super initWithFrame:frame];
	if (self) {
		self.inPreviewMode = inPreviewMode;
		[self.videoPlayer repeatVideoOnEnd:YES];

		NSMutableArray * videoAssets = [[NSMutableArray alloc] init];
		if([pinchView isKindOfClass:[CollectionPinchView class]]){
			for(VideoPinchView* videoPinchView in ((CollectionPinchView *)pinchView).videoPinchViews) {
				[videoAssets addObject: videoPinchView.video];
			}
		} else if (((VideoPinchView *)pinchView).video) {
			[videoAssets addObject:((VideoPinchView *)pinchView).video];
		} else {
			NSLog(@"Something went wrong, video nil");
		}

		if (self.inPreviewMode) {
			self.editContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];
			self.editContentView.pinchView = pinchView;
			[self.editContentView displayVideo:videoAssets];
			[self addSubview: self.editContentView];
			if(videoAssets.count > 1) [self createRearrangeButton];
		} else {
			[self prepareVideos:videoAssets];
			self.hasBeenSetUp = NO;
		}
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


-(void)presentThumbnail:(UIImage *) thumbnail {
    
    if(self.thumbNailView){
        [self.thumbNailView removeFromSuperview];
        self.thumbNailView = nil;
    }
    self.thumbNailView = [[UIImageView alloc] initWithImage:thumbnail];
    
    
    
    
}

-(void)prepareVideos:(NSArray*)videoList {
	if (!videoList.count) return;
	if ([[videoList objectAtIndex:0] isKindOfClass:[AVURLAsset class]]) {
        [self.videoPlayer prepareVideoFromArrayOfAssets_asynchronous:videoList];
	} else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
		[self.videoPlayer prepareVideoFromURLArray_asynchronouse:videoList];
	} else {
		return;
	}
    self.videoList = videoList;
 }

-(void)prepareVideos_synchronous:(NSArray*)videoList {
    if (!videoList.count) return;
    if ([[videoList objectAtIndex:0] isKindOfClass:[AVURLAsset class]]) {
        [self.videoPlayer prepareVideoFromArrayOfAssets_synchronous:videoList];
    } else if ([[videoList objectAtIndex:0] isKindOfClass:[NSURL class]]) {
        [self.videoPlayer prepareVideoFromArrayOfURL_synchronous:videoList];
    } else {
        return;
    }
    self.videoList = videoList;
    
    //[self.videoPlayer playVideo];
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
       [self.videoPlayer stopVideo];
    }
    if(self.rearrangeView) [self.rearrangeView exitView];
    self.hasBeenSetUp = NO;
}

-(void)onScreen {
    if (self.editContentView){
        [self.editContentView onScreen];
    } else{
        if(self.hasBeenSetUp){
           [self.videoPlayer playVideo];
        }else{
            if(self.videoList){
                [self.videoPlayer stopVideo];
            }
            [self prepareVideos_synchronous:self.videoList];
            [self.videoPlayer playVideo];
        }
        
        
    }
}

-(void)almostOnScreen{
    if(self.editContentView){
        [self.editContentView almostOnScreen];
    }else{
        if(self.videoList){
            [self.videoPlayer stopVideo];
            [self prepareVideos:self.videoList];
            self.hasBeenSetUp = YES;
        }
    }
}

#pragma mark - Lazy Instantiation -

-(VideoPlayerView*) videoPlayer {
	if (!_videoPlayer) {
		_videoPlayer = [[VideoPlayerView alloc] initWithFrame:self.bounds];
        _videoPlayer.backgroundColor = [UIColor clearColor];
		[self addSubview:_videoPlayer];
	}
	return _videoPlayer;
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
