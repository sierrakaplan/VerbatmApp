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

@interface DiscoverVC() <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;



@end

@implementation DiscoverVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self addBackgroundImage];
	self.headerView.backgroundColor = [UIColor clearColor];

	self.searchBar.delegate = self;
	self.searchBar.frame = CGRectMake(0.f, STATUS_BAR_HEIGHT, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
	CGFloat headerViewHeight = self.searchBar.frame.size.height + STATUS_BAR_HEIGHT;
    
    
	self.headerView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, headerViewHeight);
    
	self.tableContainerView.frame = CGRectMake(0.f, headerViewHeight,
											   self.view.frame.size.width, self.view.frame.size.height);
    
    self.tableContainerView.backgroundColor = [UIColor clearColor];
    
    [self addListVC];
    
}

-(void)addListVC{
    FeaturedContentVC * fvc = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    fvc.onboardingBlogSelection = NO;
    [self.tableContainerView addSubview:fvc.view];
    [self addChildViewController:fvc];
    [fvc didMoveToParentViewController:self];
   
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
