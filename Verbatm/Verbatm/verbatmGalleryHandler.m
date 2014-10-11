//
//  verbatmGalleryHandler.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmGalleryHandler.h"


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
@property( nonatomic) BOOL mediaIsLoaded;
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
#define SCROLLVIEW_ALPHA 1;
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
        [self getVerbatmMediaFolder];
        [self createScrollView];
        self.mediaIsLoaded = NO;
    }
    return  self;
}

-(void)createScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(DROP_FROM_COORDINATES)];
    self.scrollView.backgroundColor = [UIColor  grayColor];
    self.scrollView.alpha= SCROLLVIEW_ALPHA;
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
    //try to do this in a new queue in order not to block the main queue
    if(!self.mediaIsLoaded){
            [self loadMediaUntoScrollView];
    }
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
    self.mediaIsLoaded = YES;
    CGRect viewSize = CGRectMake(START_POSITION_FOR_MEDIA);
    self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
    for(ALAsset* asset in self.media){
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                             scale:[assetRepresentation scale]
                                       orientation:UIImageOrientationUp];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = viewSize;
        
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
                                              [self loadMediaUntoScrollView];
                                              return;
                                          }
                                      }
                                    failureBlock:^(NSError* error) {
                                        NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                    }];
}

//by Lucio
//Fills array with the media gotte from the verbatm folder
-(void)fillArrayWithMedia
{
//    dispatch_queue_t otherQ = dispatch_queue_create("Load media queue", NULL);
//    dispatch_async(otherQ, ^{
//       
//    });
    
    __weak verbatmGalleryHandler* weakSelf = self;
    [self.verbatmFolder enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result){
            [weakSelf.media insertObject:result atIndex:0] ;
        }else{
            *stop = YES;
        }
    }];
    
}

//delegate methods
-(IBAction)selectMedia:(id)sender
{
    UISwipeGestureRecognizer* swiper = (UISwipeGestureRecognizer*)sender;
    __block CGPoint location = [swiper locationInView: self.view];
    __block int indexa = ceil((self.scrollView.contentOffset.x + location.x)/((self.scrollView.frame.size.width - OFFSET)/2)) - 1;
    UIImageView* selectedImageView ;
    if(self.mediaImageViews.count >= 1)selectedImageView = [self.mediaImageViews objectAtIndex:indexa];
    if(selectedImageView){
        [UIView animateWithDuration:0.8 animations:^{
            CGRect viewSize = selectedImageView.frame;
            selectedImageView.frame = (location.x < self.view.frame.size.width/ 2)? CGRectMake(START_POSITION_FOR_MEDIA) : CGRectMake(START_POSITION_FOR_MEDIA2);
            //            [UIView animateWithDuration: 0.1 animations:^{
            //                [selectedImageView removeFromSuperview];
            //                selectedImageView.frame = CGRectMake(POSITION_TO_SWIPE_TO);
            //                [self.view addSubview: selectedImageView];
            //            }];
            [self.mediaImageViews removeObject: selectedImageView];
            for(; indexa < self.mediaImageViews.count; indexa++){
                ((UIImageView*)[self.mediaImageViews objectAtIndex:indexa]).frame = viewSize;
                viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2, 0);
            }
            self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
        }];
        [selectedImageView removeFromSuperview];
        [self.customDelegate didSelectImageView:selectedImageView ofAsset: [self.media objectAtIndex:indexa]];
        [self.media removeObjectAtIndex:indexa];
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
    //        if( [[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypeVideo"]){
    //            CALayer* playIconLayer = [[CALayer alloc] init];
    //            playIconLayer.backgroundColor = [[UIColor clearColor]CGColor];
    //            playIconLayer.bounds = imageView.frame;
    //            [playIconLayer setContents: (__bridge id)[UIImage imageNamed:PLAY_VIDEO_ICON].CGImage];
    //            [imageView.layer addSublayer:playIconLayer];
    //        }
    viewSize = CGRectOffset(viewSize, (self.scrollView.frame.size.width - OFFSET)/2 , 0);
    [self.mediaImageViews addObject: imageView];
    [self.scrollView addSubview: imageView];
    self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE);
}
@end