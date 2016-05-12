//
//  DiscoverVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "DiscoverVC.h"
#import "SizesAndPositions.h"

@interface DiscoverVC()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) UIImageView * backgroundView;

#define BACKGROUND_IMAGE @"windowPane"

@end

@implementation DiscoverVC

-(void) viewDidLoad {
	[super viewDidLoad];
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.frame = self.view.bounds;
    self.backgroundView.image = [UIImage imageNamed:BACKGROUND_IMAGE];
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
	self.headerView.backgroundColor = [UIColor blackColor];
	//todo: bring back search bar
	self.searchBar.frame = CGRectMake(0.f, STATUS_BAR_HEIGHT, self.searchBar.frame.size.width, 0.f);
									  //self.searchBar.frame.size.height);
	CGFloat headerViewHeight = self.searchBar.frame.size.height + STATUS_BAR_HEIGHT;
	self.headerView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, headerViewHeight);

	self.tableContainerView.frame = CGRectMake(0.f, headerViewHeight,
											   self.view.frame.size.width, self.view.frame.size.height);
    self.tableContainerView.backgroundColor = [UIColor clearColor];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

@end
