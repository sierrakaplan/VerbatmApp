//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomImageScrollView.h"
#import "verbatmCustomImageView.h"

@interface verbatmCustomImageScrollView ()

#pragma mark FilteredPhotos
@property (nonatomic, strong) UIImage * filter_Original;
@property (nonatomic, strong) UIImage * filter_BW;
@property (nonatomic, strong) UIImage * filter_WARM;
@property (nonatomic, strong) NSString * filter;

@end


@implementation verbatmCustomImageScrollView

-(instancetype) initWithFrame:(CGRect)frame andYOffset: (NSInteger) yoffset
{
    self = [super init];
    if(self)
    {
        self.contentSize =  CGSizeMake(0,3*frame.size.height);//make it up and down swipeable
        self.contentOffset = CGPointMake(0,frame.size.height);
        self.backgroundColor = [UIColor blackColor];
        self.frame = frame;
        self.pagingEnabled = YES;
    }
    return self;
}


//-(void) createTextView
//{
//    verbatmUITextView * textView = [[verbatmUITextView alloc] init];
//    
//    
//}


-(void)addImage: (verbatmCustomImageView *) givenImageView withPinchObject: (verbatmCustomPinchView *) pinchObject
{
    
    if(givenImageView.isVideo)
    {
        self.openImage = [[verbatmCustomImageView alloc]init];
        [self addSubview:self.openImage];
        self.openImage.frame = CGRectMake(0,self.frame.size.height, self.frame.size.width, self.frame.size.height);
        AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:givenImageView.asset.defaultRepresentation.url options:nil];
        [self playVideo:asset];
        
    }else
    {
        //create a new scrollview to place the images
        self.openImage = [[verbatmCustomImageView alloc]init];
        self.openImage.image = givenImageView.image;
        self.openImage.asset = givenImageView.asset;
        self.openImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.openImage];
        [self creatFilteredImages];
        [self addSwipeToOpenedView];
        self.openImage.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
    
}

-(void)playVideo:(AVURLAsset*)asset
{
    // Create an AVPlayerItem using the asset
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // Create the AVPlayer using the playeritem
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

    [player setMuted:YES];//mutes the player

    // Create an AVPlayerLayer using the player
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.openImage.bounds;
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    // Add it to your view's sublayers
    [self.openImage.layer addSublayer:playerLayer];
    // You can play/pause using the AVPlayer object
    
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    //register for the notification in order to keep looping the video
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    [player play];
}


-(void)creatFilteredImages
{
    //original "filter"
    ALAssetRepresentation *assetRepresentation = [self.openImage.asset defaultRepresentation];
    self.filter_Original = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                               scale:[assetRepresentation scale]
                                         orientation:UIImageOrientationUp];
    
    NSData * data = UIImagePNGRepresentation(self.openImage.image);
    
    //warm filter
    CIImage *beginImage =  [CIImage imageWithData:data];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues: kCIInputImageKey, beginImage, nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    self.filter_WARM = [UIImage imageWithCGImage:cgimg];
    
    //black and white filter
    //warm filter
    CIImage *beginImage1 =  [CIImage imageWithData:data];
    
    CIFilter *filter1 = [CIFilter filterWithName:@"CIPhotoEffectMono"
                                   keysAndValues: kCIInputImageKey, beginImage1, nil];
    
    CIImage *outputImage1 = [filter1 outputImage];
    
    CGImageRef cgimg1 =[context createCGImage:outputImage1 fromRect:[outputImage1 extent]];
    
    self.filter_BW = [UIImage imageWithCGImage:cgimg1];
    
    CGImageRelease(cgimg);
}



-(void)addSwipeToOpenedView
{
    UISwipeGestureRecognizer * leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(filterViewSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipe];
    [self creatFilteredImages];
    
}


-(void)filterViewSwipe: (UISwipeGestureRecognizer *) sender
{
    if(self.filter && [self.filter isEqualToString:@"BW"])
    {
        self.openImage.image = self.filter_Original;
        self.filter = @"Original";
    }else if (self.filter && [self.filter isEqualToString:@"WARM"])
    {
        self.openImage.image = self.filter_BW;
        self.filter = @"BW";
    }else
    {
        self.openImage.image = self.filter_WARM;
        self.filter = @"WARM";
    }
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
