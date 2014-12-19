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
@property (nonatomic) int numVideosReadded;
#define ALBUM_NAME @"Verbatm"
#define OFFSET 15
#define PLAY_VIDEO_ICON @"videoPreview_play_icon"
#define POSITION_TO_SWIPE_TO 50, self.view.frame.size.height/2 + 50, selectedImageView.frame.size.width -50, selectedImageView.frame.size.height - 50
#define DROP_FROM_COORDINATES 0,-400, self.view.frame.size.width, (self.view.frame.size.width*2/3)
#define VERTICAL_OFFSET 400
#define START_POSITION_FOR_MEDIA OFFSET, OFFSET, (self.scrollView.frame.size.width - 3*OFFSET)/2, self.scrollView.frame.size.height - 2*OFFSET
#define CONTENT_SIZE (self.scrollView.frame.size.width - OFFSET)*self.media.count/2 , (self.view.frame.size.width*2/3)
#define START_POSITION_FOR_MEDIA2   (self.scrollView.frame.size.width + OFFSET)/2, OFFSET, (self.scrollView.frame.size.width - 3*OFFSET)/2  , self.scrollView.frame.size.height - 2*OFFSET
#define BACKGROUND @"background"
#define SCROLLVIEW_ALPHA 0.5
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
        //get the verbatm folder
        self.numVideosReadded = 0;
        self.isRaised = YES;
        [self getVerbatmMediaFolder];
        [self createScrollView];
        [self addScrollViewGestures];
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

-(void)addScrollViewGestures
{
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
}

//by Lucio
//sets the scrollView and presents it lowering from the top
-(void)lowerScrollView
{
    for(verbatmCustomImageView* view in self.mediaImageViews){
        if(self.numVideosReadded == 0) break;
        if(view.isVideo){
            AVPlayerLayer* pLayer = [view.layer.sublayers firstObject];
            self.numVideosReadded--;
            pLayer.frame = view.bounds;
            [self.scrollView addSubview: view];
        }
    }
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
    self.isRaised = NO;
}

-(void)dismissGallery
{
    [self raiseScrollView];
    [self.animator removeAllBehaviors];
    self.isRaised = YES;
    //[self.customDelegate didDismissGallery];
}

//by Lucio
//loads the images unto the scrollView
-(void)loadMediaUntoScrollView
{
    CGRect viewSize = CGRectMake(START_POSITION_FOR_MEDIA);
    self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
    for(ALAsset* asset in self.media){
        verbatmCustomImageView* imageView = [self imageViewFromAsset:asset];
        imageView.frame = viewSize;
        if(imageView.isVideo){
            AVURLAsset *avurlAsset = [AVURLAsset URLAssetWithURL:asset.defaultRepresentation.url options:nil];
            [self playVideo:avurlAsset forView:imageView];
        }
        viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2 , 0);
        [self addBorder: imageView];
        [self.mediaImageViews addObject: imageView];
        [self.scrollView addSubview: imageView];
    }
    [self.view bringSubviewToFront:self.scrollView];
}

-(verbatmCustomImageView*)imageViewFromAsset:(ALAsset*)asset
{
    verbatmCustomImageView* imageView = [[verbatmCustomImageView alloc] init];
    imageView.asset = asset;
    if([[asset valueForProperty: ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
        imageView.isVideo = YES;
    }else{
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                             scale:[assetRepresentation scale]
                                       orientation:UIImageOrientationUp];
        [imageView setImage:image];
        imageView.isVideo = NO;
    }
    imageView.autoresizingMask = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

-(void)addMediaToGallery:(ALAsset*)asset
{
    verbatmCustomImageView* view = [self imageViewFromAsset:asset];
    [self returnToGallery:view];
}

-(void)addBorder:(verbatmCustomImageView*)view
{
    view.layer.cornerRadius = 8.0f;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 2.0f;
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
            self.isRaised = YES;
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
    __weak verbatmGalleryHandler* weakSelf = self;
    [self.verbatmFolder enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result){
            if(![weakSelf.media containsObject:result]){
                [weakSelf.media insertObject:result atIndex:0];
            }
        }else{
            *stop = YES;
            [weakSelf loadMediaUntoScrollView];
        }
    }];
}

//delegate methods
-(IBAction)selectMedia:(id)sender
{
    UISwipeGestureRecognizer* swiper = (UISwipeGestureRecognizer*)sender;
    __block CGPoint location = [swiper locationInView: self.view];
    __block int indexa = ceil((self.scrollView.contentOffset.x + location.x)/((self.scrollView.frame.size.width - OFFSET)/2)) - 1;
    verbatmCustomImageView* selectedImageView ;
    if(self.mediaImageViews.count >= 1)selectedImageView = [self.mediaImageViews objectAtIndex:indexa];
    if(selectedImageView){
        [self.media removeObjectAtIndex:indexa];
        __block CGRect viewSize = selectedImageView.frame;
        [self.mediaImageViews removeObject: selectedImageView];
        [UIView animateWithDuration:0.8 animations:^{
            for(; indexa < self.mediaImageViews.count; indexa++){
                ((UIImageView*)[self.mediaImageViews objectAtIndex:indexa]).frame = viewSize;
                viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2, 0);
            }
            self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
        }];
        [self.scrollView.superview addSubview:selectedImageView];
        selectedImageView.frame = CGRectOffset(selectedImageView.frame, -(self.scrollView.contentOffset.x), 0);
        [selectedImageView removeFromSuperview];
        [self.customDelegate didSelectImageView:selectedImageView];
        
    }
}

-(void)returnToGallery:(verbatmCustomImageView*)view
{
    [[view.layer.sublayers firstObject]removeFromSuperlayer];
    view = [self imageViewFromAsset:view.asset];
    [self.media insertObject: view.asset atIndex:0];
    CGRect viewSize = CGRectMake(START_POSITION_FOR_MEDIA);
    self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
    for(verbatmCustomImageView* otherView in self.mediaImageViews){
        otherView.frame = CGRectOffset(otherView.frame,  (self.scrollView.frame.size.width - OFFSET)/2, 0);
    }
    view.frame = viewSize;
    [self addBorder: view];
    if(view.isVideo){
        AVURLAsset *avurlAsset = [AVURLAsset URLAssetWithURL:view.asset.defaultRepresentation.url options:nil];
        [self playVideo:avurlAsset forView:view];
        if(self.isRaised){
             self.numVideosReadded++;
        }else{
            [self.scrollView addSubview: view];
        }
    }else{
        [self.scrollView addSubview: view];
    }
    [self.mediaImageViews insertObject:view atIndex:0];
    [self.view bringSubviewToFront:self.scrollView];
    [self.scrollView bringSubviewToFront:view];
}
@end