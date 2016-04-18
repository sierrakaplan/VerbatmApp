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


@end

@implementation DiscoverVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.searchBar.frame = CGRectMake(0.f, STATUS_BAR_HEIGHT, self.searchBar.frame.size.width,
									  self.searchBar.frame.size.height);
	self.tableContainerView.frame = CGRectMake(0.f, self.searchBar.frame.origin.y + self.searchBar.frame.size.height,
											   self.view.frame.size.width, self.view.frame.size.height);
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

@end
