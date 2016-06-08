//
//  onboardingBlogSelectionViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 6/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "onboardingBlogSelectionViewController.h"
#import "FeaturedContentVC.h"
#import "SizesAndPositions.h"
#import "StoryboardVCIdentifiers.h"
#import "Icons.h"


#define DONE_BUTTON_WIDTH 100
#define DONE_BUTTON_HEIGHT 50
#define BLOG_LIST_TOP_OFFSET STATUS_BAR_HEIGHT + 20

@interface onboardingBlogSelectionViewController ()
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;

@end

@implementation onboardingBlogSelectionViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundImage];
    
  
    CGFloat headerViewHeight = BLOG_LIST_TOP_OFFSET;
    
    self.tableContainerView.frame = CGRectMake(0.f, headerViewHeight,
                                               self.view.frame.size.width, self.view.frame.size.height);
    
    self.tableContainerView.backgroundColor = [UIColor clearColor];
    
    [self addListVC];
    
}

-(void)addListVC{
    FeaturedContentVC * fvc = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    fvc.onboardingBlogSelection = YES;
    [self.tableContainerView addSubview:fvc.view];
    [self addChildViewController:fvc];
    [fvc didMoveToParentViewController:self];
    [self addDoneButton];
    
    
}

-(void)addDoneButton{
    CGRect buttomFrame = CGRectMake(self.view.frame.size.width - (DONE_BUTTON_WIDTH + 2), 15, DONE_BUTTON_WIDTH, DONE_BUTTON_HEIGHT);
    
    UIButton * done = [[UIButton alloc] initWithFrame:buttomFrame];
    [done addTarget:self action:@selector(exitDiscover) forControlEvents:UIControlEventTouchUpInside];
    [done setTitle:@"done" forState:UIControlStateNormal];
    [self.view addSubview:done];
    [self.view bringSubviewToFront:done];
}


-(void)exitDiscover{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) addBackgroundImage {
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image =[UIImage imageNamed:DISCOVER_BACKGROUND];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:backgroundView belowSubview:self.tableContainerView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
