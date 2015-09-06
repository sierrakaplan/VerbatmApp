//
//  topicsViewVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TopicsFeedVC.h"
#import "TopicsTableView.h"


@interface TopicsFeedVC ()

@property (strong, nonatomic) TopicsTableView *topicsListView;

@end

@implementation TopicsFeedVC


-(void) viewDidLoad {
	[super viewDidLoad];
	[self initTopicsListView];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

-(void) initTopicsListView {

}

@end
