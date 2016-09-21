//
//  FeedProfileListTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
#import "Channel.h"

#import "FeedProfileListTVC.h"
#import "FeedListTableViewCell.h"
#import "FeedTableViewController.h"

#import "UINavigationBar+CustomHeight.h"

#import "ParseBackendKeys.h"
#import "ProfileListHeader.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Icons.h"
#import "UserInfoCache.h"

@interface FeedProfileListTVC ()<FeedTableViewDelegate,UITableViewDelegate>

@property (nonatomic) FeedTableViewController *profileListFeed;
@property (nonatomic) NSMutableArray *channelsUserFollowing;
@property (nonatomic) NSMutableArray *channelsRecentlyUpdated;
@property (nonatomic) Channel *currentUserChannel;
@property (nonatomic) UIView *headerView;


@property (nonatomic) UIImageView * emptyStateView;

@end

//todo: cleanup commented out code

#define CELL_HEIGHT 65.f
#define HEADER_TITLE_HEIGHT 60.f
#define FEED_LIST_CELL_ID @"FeedListTableViewCell"
#define NAVIGATION_BAR_HEIGHT 15.f

@implementation FeedProfileListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width,
																		  STATUS_BAR_HEIGHT)];
	self.headerView.backgroundColor = [UIColor blackColor];
	[self.navigationController.view addSubview: self.headerView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[FeedListTableViewCell class] forCellReuseIdentifier:@"FeedListTableViewCell"];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
	[self formatNavigationItem];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshListOfContent) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

-(void) formatNavigationItem {
	self.navigationItem.title = @"Profile List";
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshListOfContent];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)clearEmptyState{
    if(self.emptyStateView){
        [self.emptyStateView removeFromSuperview];
        self.emptyStateView = nil;
    }
}


-(void)createEmptyStateView{
    if(self.emptyStateView) return;
    UIImage * emptyStateImage = [UIImage imageNamed:PROFILE_NAME_LIST_EMPTY_STATE];
    self.emptyStateView = [[UIImageView alloc] initWithImage:emptyStateImage];
    self.emptyStateView.contentMode = UIViewContentModeScaleAspectFit;
    self.emptyStateView.frame = CGRectMake(10.f, 0.f, self.view.frame.size.width - 20.f, self.view.frame.size.height);
    
    UITapGestureRecognizer * goToDiscoverTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDiscoverTapGesture:)];
    [self.emptyStateView addGestureRecognizer:goToDiscoverTap];
    [self.tableView setCanCancelContentTouches:NO];
    [self.view addSubview:self.emptyStateView];
    [self.view bringSubviewToFront:self.emptyStateView];
    
}


-(void)findUpdatedPosts{
    [self.channelsRecentlyUpdated removeAllObjects];
    for(Channel * channel in self.channelsUserFollowing){
        if([channel.followObject[FOLLOW_LATEST_POST_DATE]
			compare:[channel dateOfMostRecentChannelPost]] == NSOrderedAscending){
            [self.channelsRecentlyUpdated addObject:channel];
        }
    }
}


#pragma mark - Table view data source -

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ProfileListHeader *view = [[ProfileListHeader alloc] initWithFrame:CGRectMake(0, 0,
																				  tableView.frame.size.width, HEADER_TITLE_HEIGHT)];
    [view setHeaderTitleWithSectionIndex:section];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEADER_TITLE_HEIGHT;
}

-(NSMutableArray *)getCombinedChannelList {
    NSMutableArray * newList = [[NSMutableArray alloc] init];
    [newList addObjectsFromArray:self.channelsRecentlyUpdated];
    [newList addObjectsFromArray:self.channelsUserFollowing];
    return newList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger startIndex = (indexPath.section == 0) ? indexPath.row : indexPath.row + self.channelsRecentlyUpdated.count;

    [self.profileListFeed setAndRefreshWithList:[self getCombinedChannelList] withStartIndex:startIndex];
	[self.navigationController pushViewController:self.profileListFeed animated:YES];
    [self.tableView setScrollEnabled:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.emptyStateView) ? 0 : 2;//if there's nothing then we don't have sections
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return self.channelsRecentlyUpdated.count;
    }
    return (self.channelsUserFollowing) ? self.channelsUserFollowing.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_LIST_CELL_ID];
    
    if(cell == nil) {
        cell = [[FeedListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_LIST_CELL_ID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else {
        [cell removeFromSuperview];
    }
    
    NSInteger objectIndex = indexPath.row;
    
    Channel *channel = (indexPath.section == 0) ? [self.channelsRecentlyUpdated objectAtIndex:objectIndex]: [self.channelsUserFollowing objectAtIndex:objectIndex];
    [cell presentChannel:channel isSelected:(indexPath.section == 0)];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - ProfileTableList Protocol -

-(void)exitProfileList {
    [self findUpdatedPosts];
    [self.tableView reloadData];
//    [self.tableView insertSubview:self.logoBar belowSubview:self.profileListFeed.view];
    [self.profileListFeed.view removeFromSuperview];
    self.profileListFeed = nil;
    [self.tableView setScrollEnabled:YES];
}

-(void)goToDiscoverTapGesture:(UITapGestureRecognizer *) gesture {
    [self.delegate goToDiscover];
}

-(void) refreshListOfContent {
    self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel];
    //todo: change how getfollowersandfollowing is used everywhere (also make sure one instance of updating followers is used)
    [self.currentUserChannel getChannelsFollowingWithCompletionBlock:^{
        
//        //No channels have been previously loaded
        self.channelsUserFollowing = [NSMutableArray arrayWithArray: [self.currentUserChannel channelsUserFollowing]];
        [self.channelsUserFollowing sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Channel * leftObj = obj1;
            Channel * rightObj = obj2;
            
            return [[leftObj userName] caseInsensitiveCompare:[rightObj userName]];
        }];
        [self findUpdatedPosts];
        
        if(!self.channelsUserFollowing || self.channelsUserFollowing.count == 0){
            [self createEmptyStateView];
        }else{
            [self clearEmptyState];
        }
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
    }];
}

#pragma mark - Lazy Instantiation -


-(FeedTableViewController *)profileListFeed{
    if(!_profileListFeed){
        _profileListFeed = [[FeedTableViewController alloc] init];
		_profileListFeed.view.frame = self.view.bounds;
        _profileListFeed.delegate = self;
    }
    return _profileListFeed;
}


-(NSMutableArray *)channelsRecentlyUpdated{
    if(!_channelsRecentlyUpdated){
        _channelsRecentlyUpdated = [[NSMutableArray alloc] init];
    }
    return _channelsRecentlyUpdated;
}

@end
