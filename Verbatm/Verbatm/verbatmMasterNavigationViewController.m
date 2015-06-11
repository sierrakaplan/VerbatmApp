//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmMasterNavigationViewController.h"
#import "articleDispalyViewController.h"

@interface verbatmMasterNavigationViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *masterSV;
@property (weak, nonatomic) IBOutlet UIView *adk_contatiner;
@property (weak, nonatomic) IBOutlet UIView *articleList_container;
@property (nonatomic) NSInteger last_View_Index;//stores the index of the view that brings up the article display in order to aid our return
@property (nonatomic, strong) NSMutableArray * Display_pages;
@property (nonatomic, strong) NSMutableArray * Display_pinchObjects;
@property (nonatomic) CGPoint prev_Gesture_Point;

#define ANIMATION_DURATION 0.5
#define NUMBER_OF_CHILD_VCS 3
#define LEFT_FRAME self.view.bounds
#define RIGHT_FRAME CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)



#define NOTIFICATION_SHOW_ADK @"notification_showADK"
#define NOTIFICATION_EXIT_ARTICLE_DISPLAY @"Notification_exitArticleDisplay"
#define NOTIFICATION_SHOW_ARTICLE @"notification_showArticle"
@end

@implementation verbatmMasterNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self formatVCS];
    [self registerForNavNotifications];
    [self setUpGestureRecognizers];
}

-(void)registerForNavNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showADK:) name:NOTIFICATION_SHOW_ADK object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveArticleDisplay:) name:NOTIFICATION_EXIT_ARTICLE_DISPLAY object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayArticle:) name:NOTIFICATION_SHOW_ARTICLE object: nil];
}


-(void) showADK: (NSNotification *) notification
{
   [UIView animateWithDuration:ANIMATION_DURATION animations:^{
       self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
   }];
}


//no longer being done
-(void)leaveArticleDisplay: (NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)setUpGestureRecognizers
{
        UIScreenEdgePanGestureRecognizer* edgePanR = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(exit_enter_adk:)];
        edgePanR.edges =  UIRectEdgeRight;
    UIScreenEdgePanGestureRecognizer* edgePanL = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(exit_enter_adk:)];
    edgePanL.edges =  UIRectEdgeLeft;
    [self.view addGestureRecognizer: edgePanR];
    [self.view addGestureRecognizer: edgePanL];
}

- (void)exit_enter_adk:(UIScreenEdgePanGestureRecognizer *)sender
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
            self.masterSV.contentOffset = CGPointMake(self.masterSV.contentOffset.x + (-1 *diff), 0);
        }
        
        if(sender.state == UIGestureRecognizerStateEnded)
        {
            [self adjustSV];
//            if(self.scrollView.frame.origin.x > EXIT_EPSILON)
//                //return view to original position
//                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
//                    self.scrollView.frame = self.view.bounds;
//                }];
//            }
        }
}


-(void)adjustSV
{
    if(self.masterSV.contentOffset.x > (self.view.frame.size.width/2))
    {
            //bring ADK into View
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
            }];
    }else
    {
        //bring List into View
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.masterSV.contentOffset = CGPointMake(0, 0);
        }];
    }
}

-(void)displayArticle: (NSNotification *) notification
{
    NSArray  *pages = [[notification userInfo] objectForKey:@"pages"];
    NSMutableArray  *PO = [[notification userInfo] objectForKey:@"pinchObjects"];
    if(pages)
    {
        self.Display_pages = [NSMutableArray arrayWithArray:pages];
        self.Display_pinchObjects = Nil;
    }
    else if(PO)
    {
        self.Display_pages = Nil;
        self.Display_pinchObjects = PO;
    }
    if(pages || PO)[self performSegueWithIdentifier: @"display_articles_segue" sender: self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"display_articles_segue"])
    {
        articleDispalyViewController *vc = (articleDispalyViewController *)segue.destinationViewController;
        vc.Objects = (self.Display_pinchObjects) ? self.Display_pinchObjects : self.Display_pages;
    }
}



-(void)formatVCS
{
    self.masterSV.frame = self.view.bounds;
    self.masterSV.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);//enable horizontal scroll
    self.masterSV.contentOffset = CGPointMake(0, 0);//start at the left
    self.articleList_container.frame = LEFT_FRAME ;
    self.adk_contatiner.frame = RIGHT_FRAME;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done:(UIStoryboardSegue *)segue
{
    //MyModalVC *vc = (MyModalVC *)segue.sourceViewController; // get results out of vc, which I presented
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
