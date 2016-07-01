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

@interface DiscoverVC() <UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (weak, nonatomic) FeaturedContentVC *featuredContentVC;
@property (weak, nonatomic) IBOutlet UIView *headerView;


@property (weak, nonatomic) UISearchBar *searchBar;

@end

@implementation DiscoverVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self addBackgroundImage];
	self.headerView.backgroundColor = [UIColor clearColor];

	// Create the search results controller and store a reference to it.
//	MySearchResultsController* resultsController = [[MySearchResultsController alloc] init];
	
	[self addListVC];

	self.featuredContentVC.tableView.tableHeaderView = self.searchBar;
	self.featuredContentVC.tableView.backgroundColor = [UIColor redColor];
	self.featuredContentVC.tableView.tableHeaderView.backgroundColor = [UIColor greenColor];
	self.searchBar.backgroundImage = [UIImage imageNamed:DISCOVER_BACKGROUND];

	self.headerView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, STATUS_BAR_HEIGHT);

	self.tableContainerView.frame = CGRectMake(0.f, STATUS_BAR_HEIGHT,
											   self.view.frame.size.width, self.view.frame.size.height);

	self.tableContainerView.backgroundColor = [UIColor yellowColor];

}

-(void) addBackgroundImage {
	UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	backgroundView.image =[UIImage imageNamed:DISCOVER_BACKGROUND];
	backgroundView.contentMode = UIViewContentModeScaleAspectFill;
	
}

-(void)addListVC{
    self.featuredContentVC = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    self.featuredContentVC.onboardingBlogSelection = NO;
    [self.tableContainerView addSubview: self.featuredContentVC.view];
    [self addChildViewController: self.featuredContentVC];
    [self.featuredContentVC didMoveToParentViewController:self];
}

//todo:
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

}

@end
