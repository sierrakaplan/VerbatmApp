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

@interface articleDispalyViewController ()
@property (strong, nonatomic) NSMutableArray* poppedOffPages;
@property (strong, nonatomic) UIView* animatingView;
@property (nonatomic) CGPoint lastPoint;
#define BEST_ALPHA_FOR_TEXT 0.8
#define ANIMATION_DURATION 0.4
@end

@implementation articleDispalyViewController
@synthesize poppedOffPages = _poppedOffPages;
@synthesize animatingView = _animatingView;
@synthesize lastPoint = _latestPoint;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpGestureRecognizers];
    [self renderPinchObjects];
    _latestPoint = CGPointZero;
    _animatingView = nil;
    _poppedOffPages = [[NSMutableArray alloc]init];
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
    for(UIView* view in self.pinchedObjects){
        if([view isKindOfClass:[v_textview class]]){
//            UIView* parentView = [[UIView alloc]initWithFrame:self.view.bounds];
//            view.frame = CGRectMake(25, 40, parentView.frame.size.width - 50, parentView.frame.size.height - 80);
//            [parentView addSubview:view];
//            parentView.backgroundColor = [UIColor blackColor];
//            parentView.alpha = BEST_ALPHA_FOR_TEXT;   //Apply blur if only text
            view.frame = self.view.bounds;
            [self.view addSubview: view];
            continue;
        }
        view.frame = self.view.bounds;
        
        //[self addShadowToView: view];
        
        [self.view insertSubview:view atIndex:0];
    }
    //This makes sure that if the first object is a video it is playing the sound
    _animatingView = [self.view.subviews lastObject];
    [self enableSound];
    _animatingView = nil;
}

#pragma mark - sorting out the ui for pinch object -

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Gesture recognizers -

//Sets up the gesture recognizer for dragging from the edges.
-(void)setUpGestureRecognizers
{
    UIScreenEdgePanGestureRecognizer* edgePanR = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(transitionBtnPinchedViews:)];
    edgePanR.edges =  UIRectEdgeRight;
    UIScreenEdgePanGestureRecognizer* edgePanL = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(transitionBtnPinchedViews:)];
    edgePanL.edges =  UIRectEdgeLeft;
    [self.view addGestureRecognizer: edgePanR];
    [self.view addGestureRecognizer: edgePanL];
}


-(void)transitionBtnPinchedViews:(UIScreenEdgePanGestureRecognizer*)edgePan
{

    CGPoint translation = [edgePan translationInView:self.view];
    if(edgePan.state == UIGestureRecognizerStateBegan){
        if(translation.x > 0){
            if(_poppedOffPages.count == 0)return;
            _animatingView = (UIView*)[_poppedOffPages lastObject];
            [_poppedOffPages removeLastObject];
            _animatingView.frame = CGRectOffset(self.view.bounds, -self.view.frame.size.width, 0);
            [self.view addSubview:_animatingView];
        }else{
            if(self.view.subviews.count == 1)return;
            _animatingView = (UIView*)[self.view.subviews lastObject];
            _animatingView.backgroundColor = [UIColor blueColor];
        }
        _latestPoint = translation;
        return;
    }
    if(!_animatingView) return;
    if (edgePan.state == UIGestureRecognizerStateEnded){
        _latestPoint = translation;
        int x_location = _animatingView.frame.origin.x + _animatingView.frame.size.width;
        int mid_pt = self.view.frame.origin.x + self.view.frame.size.width/2;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            if(x_location > mid_pt){
                _animatingView.frame = self.view.bounds;
            }else{
                _animatingView.frame = CGRectOffset(self.view.bounds, -self.view.frame.size.width, 0);
            }
        } completion:^(BOOL finished) {
            if(x_location <= mid_pt){
                [_animatingView removeFromSuperview];
                [_poppedOffPages addObject:_animatingView];
                [self muteSound];
                _animatingView = [self.view.subviews lastObject];
                [self enableSound];
            }else{
                [self enableSound];
                _animatingView = [self.view.subviews objectAtIndex: self.view.subviews.count - 2];//Get previous view and mute it
                [self muteSound];
            }
            _latestPoint = CGPointZero;
            _animatingView = nil;
        }];
        return;
    }
    
    if(translation.x > 0)
    {
        if(_animatingView.frame.origin.x + (translation.x - _latestPoint.x) > 0){
            _animatingView.frame = self.view.bounds;
            _latestPoint = translation;
            return;
        }
    }
    _animatingView.frame = CGRectOffset(_animatingView.frame, translation.x - _latestPoint.x, 0);
    _latestPoint = translation;
}


#pragma mark - adding tilt to the objects -
//Pulled from the web. Adds horizontal tilt to the pich object
- (void)addHorizontalTilt:(CGFloat)x ToView:(UIView *)view
{
    UIInterpolatingMotionEffect *xAxis = nil;
    if (x != 0.0)
    {
        xAxis = [[UIInterpolatingMotionEffect alloc]
                 initWithKeyPath:@"center.x"
                 type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-x];
        xAxis.maximumRelativeValue = [NSNumber numberWithFloat:x];
    }
    if (xAxis)
    {
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        NSMutableArray *effects = [[NSMutableArray alloc] init];
        if (xAxis)
        {
            [effects addObject:xAxis];
        }
        group.motionEffects = effects;
        [view addMotionEffect:group];
    }
}

-(void)enableSound
{
    if([_animatingView isKindOfClass:[v_videoview class]] ){
        [((v_videoview*)_animatingView) enableSound];
    }else if([_animatingView isKindOfClass:[verbatmPhotoVideoAve class]]){
        [((verbatmPhotoVideoAve*)_animatingView) unmute];
    }else if([_animatingView isKindOfClass:[v_multiplePhotoVideo class]]){
        [((v_multiplePhotoVideo*)_animatingView) enableSound];
    }
}

-(void)muteSound
{
    if([_animatingView isKindOfClass:[v_videoview class]]){
        [((v_videoview*)_animatingView) mutePlayer];
    }else if([_animatingView isKindOfClass:[verbatmPhotoVideoAve class]]){
        [((verbatmPhotoVideoAve *)_animatingView) mute];
    }else if([_animatingView isKindOfClass:[v_multiplePhotoVideo class]]){
        [((v_multiplePhotoVideo*)_animatingView) mutePlayer];
    }
}

//Adds a shadow to whatever view is sent
//Iain
-(void) addShadowToView: (UIView *) view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(2.0f, 0.3f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
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

@end
