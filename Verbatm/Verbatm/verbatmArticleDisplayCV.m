//
//  verbatmArticleDisplayCV.m
//  Verbatm
//
//  Created by Iain Usiri on 6/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmArticleDisplayCV.h"
#import "v_textview.h"
#import "v_videoview.h"
#import "verbatmPhotoVideoAve.h"
#import "v_multiplePhotoVideo.h"
#import "v_Analyzer.h"
#import "Page.h"
#import "Article.h"

@interface verbatmArticleDisplayCV () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray * Objects;//either pinchObjects or Pages
@property (strong, nonatomic) NSMutableArray* poppedOffPages;
@property (strong, nonatomic) UIView* animatingView;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (nonatomic) CGPoint lastPoint;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
//The first object in the list will be the last to be shown in the Article
@property (strong, nonatomic) NSMutableArray* pinchedObjects;
@property (weak, nonatomic) IBOutlet UIButton *exitArticle_Button;
@property (nonatomic) CGPoint prev_Gesture_Point;//saves the prev point for the exit (pan) gesture
#define BEST_ALPHA_FOR_TEXT 0.8
#define ANIMATION_DURATION 0.4
#define NOTIFICATION_EXIT_ARTICLE_DISPLAY @"Notification_exitArticleDisplay"
#define EXIT_EPSILON 60 //the amount of space that must be pulled to exit
#define SV_RESTING_FRAME CGRectMake(self.view.frame.size.width, 0,  self.view.frame.size.width, self.view.frame.size.height);
#define NOTIFICATION_SHOW_ARTICLE @"notification_showArticle"


@end


@implementation verbatmArticleDisplayCV
@synthesize poppedOffPages = _poppedOffPages;
@synthesize animatingView = _animatingView;
@synthesize lastPoint = _latestPoint;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showArticle:) name:NOTIFICATION_SHOW_ARTICLE object: nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)displayArticle: (NSNotification *) notification
{
    
}

//called when we want to present an article. article should be set with our content
-(void)showArticle:(NSNotification *) notification
{
    Article *article = [[notification userInfo] objectForKey:@"article"];
    NSMutableArray  *PO = [[notification userInfo] objectForKey:@"pinchObjects"];
    if(article)
    {
        [self setUpScrollView];
        [self show_remove_ScrollView:YES];
        
        //add animation indicator here
        //Create and add the Activity Indicator to splashView
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.alpha = 1.0;
        self.activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        self.activityIndicator.hidesWhenStopped = YES;
        [self.scrollView addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
        
        dispatch_queue_t articleDownload_queue = dispatch_queue_create("articleDisplay", NULL);
        dispatch_async(articleDownload_queue, ^{
            NSArray * pages = [article getAllPages];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray * pincObjetsArray = [[NSMutableArray alloc]init];
                //get pinch views for our array
                for (Page * page in pages)
                {
                    //here the radius and the center dont matter because this is just a way to wrap our data for the analyser
                    verbatmCustomPinchView * pv = [page getPinchObjectWithRadius:0 andCenter:CGPointMake(0, 0)];
                    [pincObjetsArray addObject:pv];
                }
                
                v_Analyzer * analyser = [[v_Analyzer alloc]init];
                self.pinchedObjects = [analyser processPinchedObjectsFromArray:pincObjetsArray withFrame:self.view.frame];
                //[self muteEverything];<--we shouldn't need this anymore becaue we mute each page at it's creation
                //stop animation indicator
                [self.activityIndicator stopAnimating];
                [self renderPinchPages];
                self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self.pinchedObjects count]*self.view.frame.size.height); //adjust contentsize to fit
                _latestPoint = CGPointZero;
                _animatingView = nil;
            });
        });
        
    }else{
        v_Analyzer * analyser = [[v_Analyzer alloc]init];
        self.pinchedObjects = [analyser processPinchedObjectsFromArray:PO withFrame:self.view.frame];
        [self muteEverything];
        self.view.backgroundColor = [UIColor clearColor];
        [self setUpScrollView];
        [self renderPinchPages];
        [self show_remove_ScrollView:YES];
        _latestPoint = CGPointZero;
        _animatingView = nil;
    }
}

-(void) clearArticle
{
    //We clear these so that the media is released
    self.scrollView = NULL;
    self.animatingView = NULL;
    self.poppedOffPages = NULL;
    self.pinchedObjects = Nil;//sanitize array so memory is cleared
}


-(void)setUpScrollView
{
    if(self.scrollView)
    {
        //this means that we have already used this scrollview to present another article
        //so we want to clear it and then exit
        for(UIView * page in self.scrollView.subviews) [page removeFromSuperview];
    }else{
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = SV_RESTING_FRAME;
        [self.view addSubview: self.scrollView];
        self.scrollView.pagingEnabled  = YES;
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        self.scrollView.bounces = NO;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [self addShadowToView:self.scrollView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self.pinchedObjects count]*self.view.frame.size.height);
    self.scrollView.delegate = self;
}

-(void)show_remove_ScrollView: (BOOL) show
{
    if(show)//present the scrollview
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
         self.articleCurrentlyViewing= YES;
         //[self.view bringSubviewToFront:self.scrollView];
         self.scrollView.frame = self.view.bounds;
     }];
    }else//send the scrollview back to the right
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self muteEverything];
            self.scrollView.frame = SV_RESTING_FRAME;
        }completion:^(BOOL finished) {
            if(finished)
            {
                //[self.view sendSubviewToBack:self.scrollView];
                self.articleCurrentlyViewing = NO;
                [self clearArticle];
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setting the array of pinch objects
-(void)setPinchedObjects:(NSMutableArray *)pinchedObjects
{
    _pinchedObjects = pinchedObjects;
}


#pragma mark - render pinchPages -
//takes AVE pages and displays them on our scrollview
-(void)renderPinchPages
{
    CGRect viewFrame = self.view.bounds;
    
    for(UIView* view in self.pinchedObjects){
        if([view isKindOfClass:[v_textview class]]){
            view.frame = viewFrame;
            [self.scrollView addSubview: view];
            viewFrame = CGRectOffset(viewFrame, 0, self.view.frame.size.height);
            continue;
        }
        [self.scrollView insertSubview:view atIndex:0];
        view.frame = viewFrame;
        viewFrame = CGRectOffset(viewFrame, 0, self.view.frame.size.height);
    }
    
    
    //This makes sure that if the first object is a video it is playing the sound
    [self everythingOffScreen];
    [self handleSound];
    [self setUpGestureRecognizers];
}


#pragma mark - sorting out the ui for pinch object -


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    //We clear these so that the media is released
//    self.scrollView = NULL;
//    self.animatingView = NULL;
//    self.poppedOffPages = NULL;
//}



#pragma mark - Gesture recognizers -
//
////Sets up the gesture recognizer for dragging from the edges.
-(void)setUpGestureRecognizers
{
    UIScreenEdgePanGestureRecognizer* edgePanL = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(exitDisplay:)];
    edgePanL.edges =  UIRectEdgeLeft;
    [self.scrollView addGestureRecognizer: edgePanL];
}

//to be called when an aritcle is first rendered to unsure all videos are off
-(void)muteEverything
{
    for (int i=0; i< self.pinchedObjects.count; i++)
    {
        if([self.pinchedObjects[i] isKindOfClass:[v_videoview class]]){
            [((v_videoview*)self.pinchedObjects[i]) mutePlayer];
        }else if([self.pinchedObjects[i] isKindOfClass:[verbatmPhotoVideoAve class]]){
            [((verbatmPhotoVideoAve *)self.pinchedObjects[i]) mute];
        }else if([self.pinchedObjects[i] isKindOfClass:[v_multiplePhotoVideo class]]){
            [((v_multiplePhotoVideo*)self.pinchedObjects[i]) mutePlayer];
        }
    }
}


//to be called when an aritcle is first rendered to unsure all videos are off
-(void)everythingOffScreen
{
    return;
    
    for (int i=0; i< self.pinchedObjects.count; i++)
    {
        if(self.pinchedObjects[i] == self.animatingView)continue;
        
        if([self.pinchedObjects[i] isKindOfClass:[v_videoview class]]){
            [((v_videoview*)self.pinchedObjects[i]) offScreen];
        }else if([self.pinchedObjects[i] isKindOfClass:[verbatmPhotoVideoAve class]]){
            [((verbatmPhotoVideoAve *)self.pinchedObjects[i]) offScreen];
        }else if([self.pinchedObjects[i] isKindOfClass:[v_multiplePhotoVideo class]]){
            [((v_multiplePhotoVideo*)self.pinchedObjects[i]) offScreen];
        }
    }
}


-(void)handleSound//plays sound if first video is
{
    if(_animatingView)[self muteSound];
    else {
        _animatingView = self.pinchedObjects[0];
        [self muteSound];
    }
    int index = (self.scrollView.contentOffset.y/self.view.frame.size.height);
    _animatingView = self.pinchedObjects[index];
    [self enableSound];
}

//call this after changing the animating view to the current view
-(void)enableSound
{
    if([_animatingView isKindOfClass:[v_videoview class]] )
    {
        [((v_videoview*)_animatingView) enableSound];
        //[((v_videoview*)_animatingView) onScreen];
    }else if([_animatingView isKindOfClass:[verbatmPhotoVideoAve class]]){
        [((verbatmPhotoVideoAve*)_animatingView) unmute];
        //[((verbatmPhotoVideoAve*)_animatingView) onScreen];
    }else if([_animatingView isKindOfClass:[v_multiplePhotoVideo class]]){
        [((v_multiplePhotoVideo*)_animatingView) enableSound];
       //[((v_multiplePhotoVideo*)_animatingView) onScreen];
    }
}

-(void)muteSound//call this before changing the nimating view so that we stop the previous thing
{
    if([_animatingView isKindOfClass:[v_videoview class]]){
        [((v_videoview*)_animatingView) mutePlayer];
    }else if([_animatingView isKindOfClass:[verbatmPhotoVideoAve class]]){
        [((verbatmPhotoVideoAve *)_animatingView) mute];
    }else if([_animatingView isKindOfClass:[v_multiplePhotoVideo class]]){
        [((v_multiplePhotoVideo*)_animatingView) mutePlayer];
    }
}

- (void)exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender
{
    
    if([sender numberOfTouches] >1) return;//we want only one finger doing anything when exiting
    if(sender.state ==UIGestureRecognizerStateBegan)
    {
        self.prev_Gesture_Point  = [sender locationOfTouch:0 inView:self.view];
    }
    
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint current_point= [sender locationOfTouch:0 inView:self.view];;
        
        int diff = current_point.x - self.prev_Gesture_Point.x;
        self.prev_Gesture_Point = current_point;
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x +diff, self.scrollView.frame.origin.y,  self.scrollView.frame.size.width,  self.scrollView.frame.size.height);
    }
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        if(self.scrollView.frame.origin.x > EXIT_EPSILON)
        {
            //exit article
            [self show_remove_ScrollView:NO];
        }else{
            //return view to original position
            [self show_remove_ScrollView:YES];
        }
    }
    
    
}

//Adds a shadow to whatever view is sent
//Iain
-(void) addShadowToView: (UIView *) view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(3.0f, 0.3f);
    view.layer.shadowOpacity = 0.8f;
    view.layer.shadowPath = shadowPath.CGPath;
}


////for ios8- To hide the status bar
//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
//
//-(void) removeStatusBar
//{
//    //remove the status bar
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        // iOS 7
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//    } else {
//        // iOS 6
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
//    }
//}
//
//#pragma mark Orientation
//- (NSUInteger)supportedInterfaceOrientations
//{
//    //return supported orientation masks
//    return UIInterfaceOrientationMaskPortrait;
//}

#pragma mark - scrolling -

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleSound];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

@end
