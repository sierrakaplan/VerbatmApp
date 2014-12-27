//
//  articleDispalyViewController.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "articleDispalyViewController.h"
#import "v_textview.h"

@interface articleDispalyViewController ()
@property (strong, nonatomic) NSMutableArray* poppedOffPages;
@property (strong, nonatomic) UIView* animatingView;
@property (nonatomic) CGPoint lastPoint;
#define BEST_ALPHA_FOR_TEXT 0.5
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
}

-(NSMutableArray*)poppedOffPages
{
    if(!_poppedOffPages){
        _poppedOffPages = [[NSMutableArray alloc]init];
    }
    return _poppedOffPages;
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
        view.frame = self.view.bounds;
        if([view isKindOfClass:[v_textview class]]){
            view.alpha = BEST_ALPHA_FOR_TEXT;   //Apply blur if only text
        }
        [self.view insertSubview:view atIndex:0];
    }
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
            _animatingView.frame = CGRectOffset(self.view.bounds, -self.view.frame.size.width, 0);
            [self.view addSubview:_animatingView];
        }else{
            if(self.view.subviews.count == 1)return;
            _animatingView = (UIView*)[self.view.subviews lastObject];
        }
        _latestPoint = translation;
        return;
    }else if (edgePan.state == UIGestureRecognizerStateEnded){
        _latestPoint = translation;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            int x_location = _animatingView.frame.origin.x + _animatingView.frame.size.width;
            int mid_pt = self.view.frame.origin.x + self.view.frame.size.width/2;
            if(x_location > mid_pt){
                _animatingView.frame = self.view.bounds;
            }else{
                _animatingView.frame = CGRectOffset(self.view.bounds, -self.view.frame.size.width, 0);
            }
        } completion:^(BOOL finished) {
            if(translation.x < 0){
                [_animatingView removeFromSuperview];
                [_poppedOffPages addObject:_animatingView];
            }
            _latestPoint = CGPointZero;
            _animatingView = nil;
        }];
        return;
    }
    if(!_animatingView) return;
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
@end
