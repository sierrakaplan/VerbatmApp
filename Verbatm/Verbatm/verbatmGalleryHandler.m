//
//  verbatmGalleryHandler.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmGalleryHandler.h"
#import "verbatmCustomImageView.h"


@interface verbatmGalleryHandler ()
@property (strong, nonatomic) NSMutableArray* media;
@property (strong, nonatomic) NSMutableArray* mediaImageViews;
@property( strong, nonatomic) ALAssetsGroup* verbatmFolder;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UIDynamicAnimator* animator;
@property (strong, nonatomic)  ALAssetsLibrary* assetsLibrary;
@property (strong, nonatomic)UIGravityBehavior* gravity;
@property (strong, nonatomic) UICollisionBehavior* collider;
@property (strong, nonatomic) UIDynamicItemBehavior* elasticityBehavior;
@property (strong, nonatomic) UIView* view;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
#define ALBUM_NAME @"Verbatm"
#define OFFSET 15
#define PLAY_VIDEO_ICON @"videoPreview_play_icon"
#define POSITION_TO_SWIPE_TO 50, self.view.frame.size.height/2 + 50, selectedImageView.frame.size.width -50, selectedImageView.frame.size.height - 50
#define DROP_FROM_COORDINATES 0,-400, self.view.frame.size.width, self.view.frame.size.height/3
#define VERTICAL_OFFSET 400
#define START_POSITION_FOR_MEDIA OFFSET, OFFSET, (self.scrollView.frame.size.width - 3*OFFSET)/2  , self.scrollView.frame.size.height - 2*OFFSET
#define CONTENT_SIZE self.scrollView.frame.size.width*self.media.count/2 -  2*OFFSET, self.view.frame.size.height/3
#define START_POSITION_FOR_MEDIA2   (self.scrollView.frame.size.width + OFFSET)/2, OFFSET, (self.scrollView.frame.size.width - 3*OFFSET)/2  , self.scrollView.frame.size.height - 2*OFFSET
#define BACKGROUND @"background"
#define SCROLLVIEW_ALPHA 0.5
#define ACTIVITY_INDICATOR_SIZE 30
@end

@implementation verbatmGalleryHandler


-(NSMutableArray*)media
{
    if(!_media){
        _media = [[NSMutableArray alloc]init];
    }
    return _media;
}

- (verbatmGalleryHandler *)initWithView:(UIView*)view
{
    self = [super init];
    if(self){
        self.view = view;
        self.media = [[NSMutableArray alloc] init];
        self.mediaImageViews = [[NSMutableArray alloc] init];
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//        //set up the activity indicator
//        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
//        self.activityIndicator.frame = CGRectMake(self.view.frame.origin.x + (self.view.frame.size.width/2 - ACTIVITY_INDICATOR_SIZE/2), self.view.frame.origin.y + ACTIVITY_INDICATOR_SIZE, ACTIVITY_INDICATOR_SIZE, ACTIVITY_INDICATOR_SIZE);
//        [self.view addSubview:self.activityIndicator];
        //get the verbatm folder
        [self getVerbatmMediaFolder];
        [self createScrollView];
    }
    return  self;
}

-(void)createScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(DROP_FROM_COORDINATES)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: SCROLLVIEW_ALPHA];
    self.scrollView.pagingEnabled = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceHorizontal = YES;
    
}

//by Lucio
//sets the scrollView and presents it lowering from the top
-(void)lowerScrollView
{
    [self.view addSubview: self.scrollView];
    if(!self.collider){
        self.collider = [[UICollisionBehavior alloc]initWithItems:@[self.scrollView]];
    }
    UIBezierPath* bezierpath = [UIBezierPath bezierPathWithRect:CGRectMake(DROP_FROM_COORDINATES + VERTICAL_OFFSET)];
    [bezierpath closePath];
    [self.collider addBoundaryWithIdentifier:@"path" forPath: bezierpath];
    [self.animator addBehavior:self.collider];
    if(!self.elasticityBehavior){
        self.elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.scrollView]];
        self.elasticityBehavior.elasticity = 0.3f;
    }
    [self.animator addBehavior: self.elasticityBehavior];
    if(!self.gravity){
        self.gravity = [[UIGravityBehavior alloc]initWithItems:@[self.scrollView]];
    }
    [self.animator addBehavior:self.gravity];
}

- (void)presentGallery
{
    [self lowerScrollView];
   // [self.customDelegate didPresentGallery];
}

-(void)dismissGallery
{
    [self raiseScrollView];
    [self.animator removeAllBehaviors];
    //[self.customDelegate didDismissGallery];
}

//by Lucio
//loads the images unto the scrollView
-(void)loadMediaUntoScrollView
{
    CGRect viewSize = CGRectMake(START_POSITION_FOR_MEDIA);
    self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
    for(ALAsset* asset in self.media){
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                             scale:[assetRepresentation scale]
                                       orientation:UIImageOrientationUp];
        verbatmCustomImageView* imageView = [[verbatmCustomImageView alloc] initWithImage:image];
        imageView.asset = asset;
        imageView.frame = viewSize;
        if([[asset valueForProperty: ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
            imageView.isVideo = true;
            AVURLAsset *avurlAsset = [AVURLAsset URLAssetWithURL:asset.defaultRepresentation.url options:nil];
            [self playVideo:avurlAsset forView:imageView];
        }else{
            imageView.isVideo = false;
        }
        viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2 , 0);
        [self.mediaImageViews addObject: imageView];
        [self.scrollView addSubview: imageView];
    }
    
    //Add swipe up gesture to dismiss gallery
    UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(raiseScrollView)];
    swipeUp.direction  = UISwipeGestureRecognizerDirectionUp;
    swipeUp.cancelsTouchesInView = NO;
    swipeUp.delegate = self;
    [self.scrollView addGestureRecognizer: swipeUp];
    
    
    UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectMedia:)];
    swipeDown.direction  = UISwipeGestureRecognizerDirectionDown;
    swipeDown.cancelsTouchesInView = NO;
    swipeDown.delegate = self;
    [self.scrollView addGestureRecognizer: swipeDown];
    for(UIGestureRecognizer*gesture in self.scrollView.gestureRecognizers){
        [gesture requireGestureRecognizerToFail:swipeDown];
        NSLog(@"%@",gesture);
    }
    [self.view bringSubviewToFront:self.scrollView];

}


#pragma mark - video playing methods -

-(void)playVideo:(AVURLAsset*)asset forView:(UIImageView*)view
{
    // Create an AVPlayerItem using the asset
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    // Create the AVPlayer using the playeritem
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //MUTE THE PLAYER
    [self mutePlayer:player forAsset:asset];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    
    // Create an AVPlayerLayer using the player
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = view.bounds;
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    // Add it to your view's sublayers
    [view.layer addSublayer:playerLayer];
    // You can play/pause using the AVPlayer object
    [player play];
}

//mutes the player
-(void)mutePlayer:(AVPlayer*)avPlayer forAsset:(AVURLAsset*)asset
{
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =  [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    [[avPlayer currentItem] setAudioMix:audioZeroMix];
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

//by Lucio
//takes the scrollView away by pushing it up
-(void)raiseScrollView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.frame = CGRectMake(DROP_FROM_COORDINATES);
    } completion:^(BOOL finished) {
        if(finished)
        {
           [self.scrollView removeFromSuperview];
        }
    }];

}



//by Lucio
//gets the verbatm folder and assigns it to the class's assetsgroup property
-(void)getVerbatmMediaFolder
{
    //get the album
    __weak verbatmGalleryHandler* weakSelf = self;
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                      usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                          if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString: ALBUM_NAME]) {
                                              NSLog(@"found album %@", ALBUM_NAME);
                                              weakSelf.verbatmFolder = group;
                                              [self fillArrayWithMedia];
                                              return;
                                          }
                                      }
                                    failureBlock:^(NSError* error) {
                                        NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                    }];
}

//by Lucio
//Fills array with the media gotten from the verbatm folder
//this is done on another queue so as not to block the main queue
-(void)fillArrayWithMedia
{
    dispatch_queue_t otherQ = dispatch_queue_create("Load media queue", NULL);
    __weak verbatmGalleryHandler* weakSelf = self;
    dispatch_async(otherQ, ^{
        [self.verbatmFolder enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                [weakSelf.media insertObject:result atIndex:0] ;
            }else{
                *stop = YES;
                [weakSelf loadMediaUntoScrollView];
            }
        }];
    });
    
}

//delegate methods
-(IBAction)selectMedia:(id)sender
{
    UISwipeGestureRecognizer* swiper = (UISwipeGestureRecognizer*)sender;
    __block CGPoint location = [swiper locationInView: self.view];
    __block int indexa = ceil((self.scrollView.contentOffset.x + location.x)/((self.scrollView.frame.size.width - OFFSET)/2)) - 1;
    verbatmCustomImageView* selectedImageView ;
    if(self.mediaImageViews.count >= 1)selectedImageView = [self.mediaImageViews objectAtIndex:indexa];
    int temp = indexa;
    if(selectedImageView){
        [UIView animateWithDuration:0.8 animations:^{
            CGRect viewSize = selectedImageView.frame;
            selectedImageView.frame = (location.x < self.view.frame.size.width/ 2)? CGRectMake(START_POSITION_FOR_MEDIA) : CGRectMake(START_POSITION_FOR_MEDIA2);
            [self.mediaImageViews removeObject: selectedImageView];
            for(; indexa < self.mediaImageViews.count; indexa++){
                ((UIImageView*)[self.mediaImageViews objectAtIndex:indexa]).frame = viewSize;
                viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2, 0);
            }
            self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
        }];
        [selectedImageView removeFromSuperview];
        [self.customDelegate didSelectImageView:selectedImageView];
        [self.media removeObjectAtIndex:temp];
    }
}

-(void)returnToGallery:(ALAsset*)asset
{
    [self.media addObject:asset];
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                         scale:[assetRepresentation scale]
                                   orientation:UIImageOrientationUp];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    CGRect viewSize = CGRectOffset(((UIImageView*)[self.media lastObject]).frame, (self.scrollView.frame.size.width - OFFSET)/2, 0);
    imageView.frame = viewSize;
    viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2 , 0);
    [self.mediaImageViews addObject: imageView];
    [self.scrollView addSubview: imageView];
    self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
}
@end