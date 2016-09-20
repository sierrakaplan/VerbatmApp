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

#import "InternetConnectionMonitor.h"
#import "Icons.h"

#import "Notifications.h"

#import "ParseBackendKeys.h"
#import "ProfileListHeader.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UserInfoCache.h"
#import "UINavigationBar+CustomHeight.h"


@interface FeedProfileListTVC ()<FeedTableViewDelegate,UITableViewDelegate>

@property (nonatomic) FeedTableViewController *profileListFeed;
@property (nonatomic) NSMutableArray *channelsUserFollowing;
@property (nonatomic) NSMutableArray *channelsRecentlyUpdated;
@property (nonatomic) Channel *currentUserChannel;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UIImageView * noInternetState;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionUpdate:)
                                                 name:INTERNET_CONNECTION_NOTIFICATION
                                               object:nil];
    
    if(![[InternetConnectionMonitor sharedInstance] isThereConnectivity]){
        [self updateNetworkStateView:[[InternetConnectionMonitor sharedInstance] isThereConnectivity]];
    }
}

-(void)networkConnectionUpdate:(NSNotification *)not{
    NSNumber * connectivity =  [not userInfo][INTERNET_CONNECTION_KEY];
    [self updateNetworkStateView:[connectivity boolValue]];
}

-(void)updateNetworkStateView:(BOOL)thereIsConnectivity{
    if(thereIsConnectivity){
        if(!self.noInternetState) return;
        [self.noInternetState removeFromSuperview];
        self.noInternetState = nil;
        [self refreshListOfContent];

        
    }else{
        
        if(self.noInternetState) return;
        self.noInternetState = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.noInternetState setImage:[UIImage imageNamed:NO_INTERNET_ICON]];
        [self.view addSubview:self.noInternetState];
        [self.tableView reloadData];
        
    }
    
}
-(void) formatNavigationItem {
	self.navigationItem.title = @"Profile List";
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}



-(void)viewWillAppear:(BOOL)animated{
   if([[InternetConnectionMonitor sharedInstance] isThereConnectivity])[self refreshListOfContent];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
//    [self.logoBar removeFromSuperview];

    NSInteger startIndex = (indexPath.section == 0) ? indexPath.row : indexPath.row + self.channelsRecentlyUpdated.count;

    [self.profileListFeed setAndRefreshWithList:[self getCombinedChannelList] withStartIndex:startIndex];
	[self.navigationController pushViewController:self.profileListFeed animated:YES];
    [self.tableView setScrollEnabled:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.noInternetState) ? 0: 2;//if there is no internet then don't present anything
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
//	self.navigationController.navigationBar.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT);
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
//    if(self.logoBar){
//        [self.view bringSubviewToFront:self.logoBar];
//    }
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

-(void)goToDiscover {
    [self.delegate goToDiscover];
}

-(void) refreshListOfContent {
    self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel];
    //todo: change how getfollowersandfollowing is used everywhere (also make sure one instance of updating followers is used)
    [self.currentUserChannel getChannelsFollowingWithCompletionBlock:^{
        
        //No channels have been previously loaded
        self.channelsUserFollowing = [NSMutableArray arrayWithArray: [self.currentUserChannel channelsUserFollowing]];
        [self.channelsUserFollowing sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Channel * leftObj = obj1;
            Channel * rightObj = obj2;
            
            return [[leftObj userName] caseInsensitiveCompare:[rightObj userName]];
        }];
        [self findUpdatedPosts];
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
