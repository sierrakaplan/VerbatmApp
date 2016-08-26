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

#import "ParseBackendKeys.h"
#import "ProfileListHeader.h"
#import "ProfileVerbatmLogoBar.h"
#import "Styles.h"

#import "UserInfoCache.h"

@interface FeedProfileListTVC ()<FeedTableViewDelegate,UITableViewDelegate>
@property (nonatomic) FeedTableViewController * profileListFeed;
@property (nonatomic) NSMutableArray * channelsUserFollowing;
@property (nonatomic) NSMutableArray * channelsRecentlyUpdated;
@property (nonatomic) Channel * currentUserChannel;
@property (nonatomic) ProfileVerbatmLogoBar * logoBar;
@end

#define CELL_HEIGHT 75.f
#define HEADER_TITLE_HEIGHT 60.f

@implementation FeedProfileListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[FeedListTableViewCell class] forCellReuseIdentifier:@"FeedListTableViewCell"];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    
    //avoid covering last item in uitableview
    UIEdgeInsets inset = UIEdgeInsetsMake(CELL_HEIGHT, 0, 0, 0);
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
    [self createLogoBar];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshListOfContent) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshListOfContent];
    if(self.logoBar)[self.view bringSubviewToFront:self.logoBar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)createLogoBar{
    self.logoBar = [[ProfileVerbatmLogoBar alloc] initWithFrame:CGRectMake(0.f, -1 * CELL_HEIGHT, self.view.frame.size.width, CELL_HEIGHT)];
    [self.tableView addSubview:self.logoBar];
}

-(void)findUpdatedPosts{
    [self.channelsRecentlyUpdated removeAllObjects];
    for(Channel * channel in self.channelsUserFollowing){
        if([channel.followObject[FOLLOW_LATEST_POST_DATE]compare:[channel dateOfMostRecentChannelPost]] == NSOrderedAscending){
            [self.channelsRecentlyUpdated addObject:channel];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView bringSubviewToFront:self.logoBar];
    CGRect newNavBarFrame = CGRectMake(0.f, scrollView.contentOffset.y, self.logoBar.frame.size.width, self.logoBar.frame.size.height);;
    self.logoBar.frame = newNavBarFrame;
}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ProfileListHeader *view = [[ProfileListHeader alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    [view setHeaderTitleWithSectionIndex:section];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEADER_TITLE_HEIGHT;
}



-(NSMutableArray *)getCombinedChannelList{
    
    NSMutableArray * newList = [[NSMutableArray alloc] init];
    [newList addObjectsFromArray:self.channelsRecentlyUpdated];
    [newList addObjectsFromArray:self.channelsUserFollowing];
    return newList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.logoBar removeFromSuperview];
    
    NSInteger startIndex = (indexPath.section == 0) ? indexPath.row : indexPath.row + self.channelsRecentlyUpdated.count;
    
    [self.profileListFeed setAndRefreshWithList:[self getCombinedChannelList] withStartIndex:startIndex];
    [self.view addSubview:self.profileListFeed.view];
    [self.tableView setScrollEnabled:NO];
    [self.delegate showTabBar:NO];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0){
        return self.channelsRecentlyUpdated.count;
    }
    
    return (self.channelsUserFollowing) ? self.channelsUserFollowing.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedListTableViewCell"];
    
    if(cell == nil) {
        cell = [[FeedListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FeedListTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else {
        [cell removeFromSuperview];
    }
    
    NSInteger objectIndex = indexPath.row;
    
    Channel *channel = (indexPath.section == 0) ? [self.channelsRecentlyUpdated objectAtIndex:objectIndex]: [self.channelsUserFollowing objectAtIndex:objectIndex];
    [cell presentChannel:channel isSelected:(indexPath.section == 0)];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if(self.logoBar){
        [self.view bringSubviewToFront:self.logoBar];
    }
}


#pragma mark -ProfileTableList Protocol-
-(void)exitProfileList{
    [self findUpdatedPosts];
    [self.tableView reloadData];
    [self.tableView insertSubview:self.logoBar belowSubview:self.profileListFeed.view];
    [self.profileListFeed.view removeFromSuperview];
    self.profileListFeed = nil;
    [self.tableView setScrollEnabled:YES];
    [self.delegate showTabBar:YES];
}
-(void) showTabBar: (BOOL) show{
    [self.delegate showTabBar:show];
}

-(void)goToDiscover{
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
            
            return [[leftObj name] caseInsensitiveCompare:[rightObj name]];
        }];
        [self findUpdatedPosts];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

#pragma mark -Lazy Instantiation-


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
