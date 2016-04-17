//
//  DiscoverVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "DiscoverVC.h"

@interface DiscoverVC()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;


@end

@implementation DiscoverVC

-(void) viewDidLoad {
	[super viewDidLoad];
//	CGFloat featuredContentYOffset = self.searchBar.frame.size.height + self.searchBar.frame.origin.y + 10.f;
//	CGFloat featuredContentHeight = self.view.frame.size.height/2.f;
//	CGFloat trendingContentYOffset = featuredContentYOffset + featuredContentHeight + 10.f;
//	self.featuredContentContainerView.frame = CGRectMake(0.f, featuredContentYOffset,
//														 self.view.frame.size.width, featuredContentHeight);
//	self.trendingContainerView.frame = CGRectMake(0.f, trendingContentYOffset, CGFloat width, CGFloat height)
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.tableContainerView.frame = CGRectMake(0.f, self.searchBar.frame.size.height + 45.f, self.view.frame.size.width, self.view.frame.size.height);
}

@end
