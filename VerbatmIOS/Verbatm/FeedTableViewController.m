//
//  FeedTableViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTableViewController.h"
#import "FeedTableCell.h"
#import "UserInfoCache.h"
#import "Channel.h"
#import "ProfileVC.h"

@interface FeedTableViewController ()<FeedCellDelegate>


@property(nonatomic) NSMutableArray * FollowingProfileList;
@property (nonatomic) Channel * currentUserChannel;
@property (nonatomic) ProfileVC * nextProfileToPresent;
@property (nonatomic) NSInteger nextProfileIndex;
@property (nonatomic) BOOL isFirstTime;
@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[FeedTableCell class] forCellReuseIdentifier:@"FeedTableCell"];
    [self refreshListOfContent];
    self.tableView.pagingEnabled = YES;
    self.tableView.allowsSelection = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.isFirstTime = YES;
}

-(void)reloadCellsOnScreen{
    NSArray * visibleCell = [self.tableView visibleCells];
    
    if(visibleCell && visibleCell.count){
        FeedTableCell * cell = [visibleCell firstObject];
        [cell presentProfileForChannel:self.currentUserChannel];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!self.isFirstTime)[self.tableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    NSArray * visibleCell = [self.tableView visibleCells];
    if(visibleCell && visibleCell.count){
        FeedTableCell * cell = [visibleCell firstObject];
        [cell clearProfile];
    }
    self.isFirstTime = NO;
}

-(void)refreshListOfContent{
    self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel] ;
    
    if(self.FollowingProfileList){
        [self.FollowingProfileList removeAllObjects];
        self.FollowingProfileList = nil;
    }
    
    [self.currentUserChannel getFollowersAndFollowingWithCompletionBlock:^{
        self.FollowingProfileList = [self.currentUserChannel channelsUserFollowing];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View Delegate methods (view customization) -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    @autoreleasepool {
        if(self.nextProfileToPresent){
            [self.nextProfileToPresent clearOurViews];
            self.nextProfileToPresent = nil;
        }
    }
}

#pragma mark - Table view data source

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //[self.delegate showTabBar:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.FollowingProfileList.count;
}

-(void)prepareNextPostFromNextIndex:(NSInteger) nextIndex{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(nextIndex < self.FollowingProfileList.count) {
            
            Channel * nextChannel = self.FollowingProfileList[nextIndex];
            if(self.nextProfileToPresent){
                @autoreleasepool {
                    self.nextProfileToPresent = nil;
                }
            }
            
            self.nextProfileToPresent = [[ProfileVC alloc] init];
            self.nextProfileToPresent.profileInFeed = YES;
            self.nextProfileToPresent.isCurrentUserProfile = NO;
            self.nextProfileToPresent.isProfileTab = NO;
            self.nextProfileToPresent.ownerOfProfile = nextChannel.channelCreator;
            self.nextProfileToPresent.channel = nextChannel;
            [self.nextProfileToPresent loadContentToPostList];
            
        }
    });
    
}
- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedTableCell *feedCell = (FeedTableCell *) cell;
    [feedCell clearProfile];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableCell" forIndexPath:indexPath];
    cell.delegate = self;
    if(self.nextProfileToPresent && indexPath.row == self.nextProfileIndex){
        [cell setProfileAlreadyLoaded:self.nextProfileToPresent];
    }else{
        [cell presentProfileForChannel:self.FollowingProfileList[indexPath.row]];
    }
     self.nextProfileIndex = indexPath.row + 1;
    [self prepareNextPostFromNextIndex:self.nextProfileIndex];
    return cell;
}


#pragma mark -Feed Cell Protocol-
-(void)shouldHideTabBar:(BOOL) shouldHide{
    [self.delegate showTabBar:!shouldHide];
    self.tableView.scrollEnabled = !shouldHide;
}

@end
