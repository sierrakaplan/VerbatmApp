 //
//  articleDispalyViewController.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "articleDispalyViewController.h"
#import "v_textview.h"
#import "v_videoview.h"
#import "verbatmPhotoVideoAve.h"
#import "v_multiplePhotoVideo.h"
#import "v_Analyzer.h"
#import "Page.h"

@interface articleDispalyViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray* poppedOffPages;
@property (strong, nonatomic) UIView* animatingView;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (nonatomic) CGPoint lastPoint;
//The first object in the list will be the last to be shown in the Article
@property (strong, nonatomic) NSMutableArray* pinchedObjects;
@property (weak, nonatomic) IBOutlet UIButton *exitArticle_Button;
@property (nonatomic) CGPoint prev_Gesture_Point;//saves the prev point for the exit (pan) gesture
#define BEST_ALPHA_FOR_TEXT 0.8
#define ANIMATION_DURATION 0.4
#define NOTIFICATION_EXIT_ARTICLE_DISPLAY @"Notification_exitArticleDisplay"
#define EXIT_EPSILON 60 //the amount of space that must be pulled to exit
@end

@implementation articleDispalyViewController
@synthesize poppedOffPages = _poppedOffPages;
@synthesize animatingView = _animatingView;
@synthesize lastPoint = _latestPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self presentArticlewithPinchObjects:self.Objects arePinchObjects:![self.Objects.firstObject isKindOfClass:[Page class]]];
    
}
- (IBAction)returnToContent:(id)sender
{
}

-(void) clearArticle
{
    //We clear these so that the media is released
    self.scrollView = NULL;
    self.animatingView = NULL;
    self.poppedOffPages = NULL;
    self.pinchedObjects = Nil;//sanitize array so memory is cleared
}


-(void)presentArticlewithPinchObjects: (NSMutableArray *) Objects arePinchObjects: (BOOL) arePO
{
    
    
    //if they are not pinch objects they are pages that must be converted
    if(!arePO)
    {
        NSMutableArray * pincObjetsArray = [[NSMutableArray alloc]init];
        //get pinch views for our array
        for (Page * page in Objects)
        {
            //here the radius and the center dont matter because this is just a way to wrap our data for the analyser
            verbatmCustomPinchView * pv = [page getPinchObjectWithRadius:0 andCenter:CGPointMake(0, 0)];
            [pincObjetsArray addObject:pv];
        }
        
        v_Analyzer * analyser = [[v_Analyzer alloc]init];
        self.pinchedObjects = [analyser processPinchedObjectsFromArray:pincObjetsArray withFrame:self.view.frame];
    }else{        
        v_Analyzer * analyser = [[v_Analyzer alloc]init];
        self.pinchedObjects = [analyser processPinchedObjectsFromArray:Objects withFrame:self.view.frame];
    }
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setUpScrollView];
    [self renderPinchObjects];
    _latestPoint = CGPointZero;
    _animatingView = nil;
    
    
    
}



-(void)setUpScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview: self.scrollView];
    self.scrollView.pagingEnabled  = YES;
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self.pinchedObjects count]*self.view.frame.size.height);
    self.scrollView.delegate = self;
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


#pragma mark - render pinchObjects -

-(void)renderPinchObjects
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
    [self muteEverything];
    [self handleSound];
    [self setUpGestureRecognizers];
}


#pragma mark - sorting out the ui for pinch object -


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //We clear these so that the media is released
    self.scrollView = NULL;
    self.animatingView = NULL;
    self.poppedOffPages = NULL;
}



#pragma mark - Gesture recognizers -
//
////Sets up the gesture recognizer for dragging from the edges.
-(void)setUpGestureRecognizers
{
//    UIScreenEdgePanGestureRecognizer* edgePanR = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(transitionBtnPinchedViews:)];
//    edgePanR.edges =  UIRectEdgeRight;
    UIScreenEdgePanGestureRecognizer* edgePanL = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(exitDisplay:)];
    edgePanL.edges =  UIRectEdgeLeft;
    //[self.view addGestureRecognizer: edgePanR];
    [self.view addGestureRecognizer: edgePanL];
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
    }else if([_animatingView isKindOfClass:[verbatmPhotoVideoAve class]]){
        [((verbatmPhotoVideoAve*)_animatingView) unmute];
    }else if([_animatingView isKindOfClass:[v_multiplePhotoVideo class]]){
        [((v_multiplePhotoVideo*)_animatingView) enableSound];
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
            [self exitAritcleDisplay];
        }else{
            //return view to original position
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.scrollView.frame = self.view.bounds;
            }];
        }
    }
    
    
}



-(void)exitAritcleDisplay
{
    //remove view from the screen
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.scrollView.frame = CGRectMake(self.view.frame.size.width, self.scrollView.frame.origin.y,  self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }completion:^(BOOL finished) {
        if(finished)
        {
            [self muteEverything];
            [self clearArticle];
            //invisible button on the screen that performs segue
            [self.exitArticle_Button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }];
}





//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) removeStatusBar
{
    //remove the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

#pragma mark Orientation
- (NSUInteger)supportedInterfaceOrientations
{
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
}

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
