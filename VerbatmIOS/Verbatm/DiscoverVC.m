//
//  DiscoverVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "DiscoverVC.h"
#import "SizesAndPositions.h"
#import "FeaturedContentVC.h"
#import "StoryboardVCIdentifiers.h"
@interface DiscoverVC()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

#define DONE_BUTTON_WIDTH 100
#define DONE_BUTTON_HEIGHT 50

@end

@implementation DiscoverVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self addBackgroundImage];
	self.headerView.backgroundColor = [UIColor clearColor];

	//todo: bring back search bar
	self.searchBar.frame = CGRectMake(0.f, STATUS_BAR_HEIGHT, self.searchBar.frame.size.width, 0.f);
									  //self.searchBar.frame.size.height);
	CGFloat headerViewHeight = self.searchBar.frame.size.height + STATUS_BAR_HEIGHT;
    
    if(!self.regularDiscoverPresentation){
        headerViewHeight = headerViewHeight + 15;
    }
    
	self.headerView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, headerViewHeight);
    
	self.tableContainerView.frame = CGRectMake(0.f, headerViewHeight,
											   self.view.frame.size.width, self.view.frame.size.height);
    
    self.tableContainerView.backgroundColor = [UIColor clearColor];
    
    [self addListVC];
    
}

-(void)addListVC{
    FeaturedContentVC * fvc = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    fvc.onboardingBlogSelection = !self.regularDiscoverPresentation;
    [self.tableContainerView addSubview:fvc.view];
    [self addChildViewController:fvc];
    [fvc didMoveToParentViewController:self];
    if(!self.regularDiscoverPresentation){
        [self addDoneButton];
    }
    
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


@end
