//
//  onboardingBlogSelectionViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 6/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "OnboardingBlogSelectionViewController.h"
#import "DiscoverVC.h"
#import "SizesAndPositions.h"
#import "StoryboardVCIdentifiers.h"
#import "Icons.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>

#define DONE_BUTTON_WIDTH 100
#define DONE_BUTTON_HEIGHT 50
#define BLOG_LIST_TOP_OFFSET STATUS_BAR_HEIGHT + 20

@interface OnboardingBlogSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIView *tableContainerView;

@end

@implementation OnboardingBlogSelectionViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundImage];
    CGFloat headerViewHeight = BLOG_LIST_TOP_OFFSET;
    self.tableContainerView.frame = CGRectMake(0.f, headerViewHeight,
                                               self.view.frame.size.width, self.view.frame.size.height);
    self.tableContainerView.backgroundColor = [UIColor clearColor];
    [self addListVC];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)addListVC{
    DiscoverVC *followingScreen = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    followingScreen.onboardingBlogSelection = YES;
    [self.tableContainerView addSubview:followingScreen.view];
    [self addChildViewController:followingScreen];
    [followingScreen didMoveToParentViewController:self];
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
		[[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:USER_FTUE];
		[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(error) {
				[[Crashlytics sharedInstance] recordError:error];
			}
		}];
    }];
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

@end
