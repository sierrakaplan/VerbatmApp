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
#import "UtilityFunctions.h"

@interface FeedTableViewController ()<FeedCellDelegate>

@property(nonatomic) NSMutableArray *followingProfileList;
@property (nonatomic) Channel *currentUserChannel;
@property (nonatomic) ProfileVC *nextProfileToPresent;
@property (nonatomic) NSInteger nextProfileIndex;
@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation FeedTableViewController

@dynamic refreshControl;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView registerClass:[FeedTableCell class] forCellReuseIdentifier:@"FeedTableCell"];
	[self refreshListOfContent];
	self.view.backgroundColor = [UIColor blackColor];
	self.tableView.pagingEnabled = YES;
	self.tableView.allowsSelection = NO;
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self setNeedsStatusBarAppearanceUpdate];
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshListOfContent) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	// Stop downloading any images we were downloading
	[[UtilityFunctions sharedInstance] cancelAllSharedSessionDataTasks];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(void)reloadCellsOnScreen{
	NSArray * visibleCell = [self.tableView visibleCells];

	if(visibleCell && visibleCell.count){
		FeedTableCell * cell = [visibleCell firstObject];
		[cell presentProfileForChannel:self.currentUserChannel];
	}
}

-(void) refreshListOfContent {
	if (self.tableView.contentOffset.y > (self.view.frame.size.height - 20.f)) {
		[self.tableView setContentOffset:CGPointZero animated:YES];
	}
	self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel];

	//todo: change how getfollowersandfollowing is used everywhere (also make sure one instance of updating followers is used)
	[self.currentUserChannel getFollowersAndFollowingWithCompletionBlock:^{
		[self.refreshControl endRefreshing];
		//No channels have been previously loaded
		if (!self.followingProfileList || !self.followingProfileList.count) {
			self.followingProfileList = [NSMutableArray arrayWithArray: [self.currentUserChannel channelsUserFollowing]];
			[self.tableView reloadData];
			return;
		}

		//Only update indices that have changed (remove channels not followed and add channels user is newly following)
		NSMutableArray *newChannels = [NSMutableArray arrayWithArray: [self.currentUserChannel channelsUserFollowing]];
		NSMutableArray *removedChannels = [NSMutableArray arrayWithArray: self.followingProfileList];

		// First remove channels user is no longer following
		[self removeObjectsFromArrayOfChannels:removedChannels inArray:newChannels];
		NSMutableArray *removedIndices = [[NSMutableArray alloc] init];
		NSMutableIndexSet *removedIndexSet = [[NSMutableIndexSet alloc] init];
		//Note: this is slow but there will probably be few removed indices and alternatives are too complex
		for (Channel *channel in removedChannels) {
			NSUInteger removedIndex = [self.followingProfileList indexOfObject: channel];
			[removedIndices addObject:[NSIndexPath indexPathForRow:removedIndex inSection:0]];
			[removedIndexSet addIndex: removedIndex];
		}

		//Load newer channels that user is following
		[self removeObjectsFromArrayOfChannels:newChannels inArray:self.followingProfileList];
		NSMutableArray *addedIndices = [[NSMutableArray alloc] init];
		NSMutableIndexSet *addedIndexSet = [[NSMutableIndexSet alloc] init];
		//Note: this is slow but there will probably be few removed indices and alternatives are too complex
		for (Channel *channel in newChannels) {
			NSUInteger addedIndex = [[self.currentUserChannel channelsUserFollowing] indexOfObject: channel];
			[addedIndices addObject:[NSIndexPath indexPathForRow:addedIndex inSection:0]];
			[addedIndexSet addIndex: addedIndex];
		}

		if ([removedIndices count]) {
			[self.followingProfileList removeObjectsAtIndexes: removedIndexSet];
			[self.tableView deleteRowsAtIndexPaths:removedIndices withRowAnimation:UITableViewRowAnimationTop];
		}
		if ([addedIndices count]) {
			[self.followingProfileList insertObjects:newChannels atIndexes: addedIndexSet];
			[self.tableView insertRowsAtIndexPaths:addedIndices withRowAnimation:UITableViewRowAnimationTop];
		}
	}];
}

//todo: move to utility functions - make work for any pfobject
//Compares Channel* objects by their PFObject ids
-(void) removeObjectsFromArrayOfChannels:(NSMutableArray*)receivingArray inArray:(NSArray*)otherArray{
	if (receivingArray == otherArray) {
		[receivingArray removeAllObjects];
		return;
	}
	for (Channel *channel in otherArray) {
		for (int i = 0; i < receivingArray.count; i++) {
			Channel *otherChannel = receivingArray[i];
			if ([channel.parseChannelObject.objectId isEqualToString:otherChannel.parseChannelObject.objectId]) {
				[receivingArray removeObjectAtIndex: i];
				break;
			}
		}
	}
}

#pragma mark - Table View Delegate methods (view customization) -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return self.view.frame.size.height;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];

	if(self.nextProfileToPresent){
		[self.nextProfileToPresent clearOurViews];
		self.nextProfileToPresent = nil;
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
	return self.followingProfileList.count;
}

-(void)prepareNextPostFromNextIndex:(NSInteger) nextIndex{

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		if(nextIndex < self.followingProfileList.count) {

			Channel * nextChannel = self.followingProfileList[nextIndex];
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
		[cell presentProfileForChannel:self.followingProfileList[indexPath.row]];
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
