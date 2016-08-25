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
#import "Icons.h"


@interface FeedTableViewController () <FeedCellDelegate>

@property(nonatomic) NSMutableArray *followingProfileList;
@property (nonatomic) Channel *currentUserChannel;
@property (nonatomic) ProfileVC *nextProfileToPresent;
@property (nonatomic) NSInteger nextProfileIndex;
@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) UIImageView * emptyFeedNotification;

@property (nonatomic) BOOL contentInFullScreen;

#define REFRESH_DISTANCE 20.f

@end

@implementation FeedTableViewController

@dynamic refreshControl;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView registerClass:[FeedTableCell class] forCellReuseIdentifier:@"FeedTableCell"];
	self.view.backgroundColor = [UIColor blackColor];
	self.tableView.pagingEnabled = YES;
	self.tableView.allowsSelection = NO;
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self setNeedsStatusBarAppearanceUpdate];
//self.refreshControl = [[UIRefreshControl alloc] init];
//[self.refreshControl addTarget:self action:@selector(refreshListOfContent) forControlEvents:UIControlEventValueChanged];
//[self.tableView addSubview:self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self refreshListOfContent];
}

-(void)viewWillDisappear:(BOOL)animated {

}

-(UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(BOOL) prefersStatusBarHidden {
	return self.contentInFullScreen;
}

-(void)reloadCellsOnScreen{
	NSArray * visibleCell = [self.tableView visibleCells];
	if(visibleCell && visibleCell.count) {
		FeedTableCell * cell = [visibleCell firstObject];
		[cell presentProfileForChannel:self.currentUserChannel];
	}
}

-(void) refreshListOfContent {

	if (self.tableView.contentOffset.y > (self.view.frame.size.height - REFRESH_DISTANCE)) {
		[self.tableView setContentOffset:CGPointZero animated:YES];
	}
    [self.delegate refreshListOfContent];
    
//	self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel];
//
//	//todo: change how getfollowersandfollowing is used everywhere (also make sure one instance of updating followers is used)
//	[self.currentUserChannel getChannelsFollowingWithCompletionBlock:^{
//		[self.refreshControl endRefreshing];
//		if ([self.currentUserChannel channelsUserFollowing].count > 0) {
//			[self removeEmptyFeedNotification];
//		} else {
//			[self notifyNotFollowingAnyone];
//			return;
//		}
//
//		//No channels have been previously loaded
//		if (!self.followingProfileList || !self.followingProfileList.count) {
//			self.followingProfileList = [NSMutableArray arrayWithArray: [self.currentUserChannel channelsUserFollowing]];
//			[self.tableView reloadData];
//			return;
//		}
//
//		//Only update indices that have changed (remove channels not followed and add channels user is newly following)
//		NSMutableArray *newChannels = [NSMutableArray arrayWithArray: [self.currentUserChannel channelsUserFollowing]];
//		NSMutableArray *removedChannels = [NSMutableArray arrayWithArray: self.followingProfileList];
//
//		// First remove channels user is no longer following
//		[self removeObjectsFromArrayOfChannels:removedChannels inArray:newChannels];
//		NSMutableArray *removedIndices = [[NSMutableArray alloc] init];
//		NSMutableIndexSet *removedIndexSet = [[NSMutableIndexSet alloc] init];
//		//Note: this is slow but there will probably be few removed indices and alternatives are too complex
//		for (Channel *channel in removedChannels) {
//			NSUInteger removedIndex = [self indexOfChannel:channel inArray:self.followingProfileList];
//			[removedIndices addObject:[NSIndexPath indexPathForRow:removedIndex inSection:0]];
//			[removedIndexSet addIndex: removedIndex];
//		}
//
//		//Load newer channels that user is following
//		NSArray *remainingChannels = [self removeObjectsFromArrayOfChannels:newChannels inArray:self.followingProfileList];
//		NSMutableArray *addedIndices = [[NSMutableArray alloc] init];
//		NSMutableIndexSet *addedIndexSet = [[NSMutableIndexSet alloc] init];
//        
//		//Note: this is slow but there will probably be few removed indices and alternatives are too complex
//		for (Channel *channel in newChannels) {
//			NSUInteger addedIndex = [self indexOfChannel:channel inArray:[self.currentUserChannel channelsUserFollowing]];
//			[addedIndices addObject:[NSIndexPath indexPathForRow:addedIndex inSection:0]];
//			[addedIndexSet addIndex: addedIndex];
//		}
//
//		if ([removedIndices count]) {
//			[self.followingProfileList removeObjectsAtIndexes: removedIndexSet];
//			[self.tableView deleteRowsAtIndexPaths:removedIndices withRowAnimation:UITableViewRowAnimationTop];
//		}
//		if ([addedIndices count]) {
//			[self.followingProfileList insertObjects:newChannels atIndexes: addedIndexSet];
//			[self.tableView insertRowsAtIndexPaths:addedIndices withRowAnimation:UITableViewRowAnimationTop];
//		}
//
//		// Reordering channels
//		for (Channel *channel in remainingChannels) {
//			NSUInteger newIndex = [self indexOfChannel:channel inArray:[self.currentUserChannel channelsUserFollowing]];
//			NSUInteger oldIndex = [self indexOfChannel:channel inArray:self.followingProfileList];
//
//			// Only need to move the channels that have moved up
//			if (newIndex < oldIndex) {
//				NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
//				NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
//				[self.followingProfileList removeObjectAtIndex: oldIndex];
//				[self.followingProfileList insertObject:channel atIndex:newIndex];
//				[self.tableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
//			}
//		}
//
//	}];
}


-(void)setAndRefreshWithList:(NSMutableArray *) channelList withStartIndex:(NSInteger) startIndex{
    [self.followingProfileList removeAllObjects];
    self.followingProfileList = channelList;
    if(startIndex >= 0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:startIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:NO];
    }
    [self.tableView reloadData];
}

//Compares Channel* objects by their PFObject ids
//Returns array of removed channels
-(NSArray*) removeObjectsFromArrayOfChannels:(NSMutableArray*)receivingArray inArray:(NSArray*)otherArray {
	NSMutableArray *removedChannels = [[NSMutableArray alloc] init];
	if (receivingArray == otherArray) {
		[receivingArray removeAllObjects];
		return otherArray;
	}
	for (Channel *channel in otherArray) {
		for (int i = 0; i < receivingArray.count; i++) {
			Channel *otherChannel = receivingArray[i];
			if ([channel.parseChannelObject.objectId isEqualToString:otherChannel.parseChannelObject.objectId]) {
				[removedChannels addObject: receivingArray[i]];
				[receivingArray removeObjectAtIndex: i];
				break;
			}
		}
	}
	return removedChannels;
}

-(NSUInteger) indexOfChannel: (Channel*)channel inArray:(NSArray*)array {
	for (NSUInteger i = 0; i < array.count; i++) {
		Channel *otherChannel = array[i];
		if ([channel.parseChannelObject.objectId isEqualToString:otherChannel.parseChannelObject.objectId]) {
			return i;
		}
	}
	return NSNotFound;
}

-(void)notifyNotFollowingAnyone {
	if(!self.emptyFeedNotification){
		self.emptyFeedNotification = [[UIImageView alloc] initWithFrame:self.view.bounds];
		[self.emptyFeedNotification setImage:[UIImage imageNamed:FEED_NOTIFICATION_ICON]];
		[self.view addSubview:self.emptyFeedNotification];
		[self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDiscover)]];
		self.tableView.allowsSelection = YES;
	}
}

-(void)goToDiscover{
	if(self.emptyFeedNotification){
		[self.delegate goToDiscover];
	}
}

-(void)removeEmptyFeedNotification{
	if(self.emptyFeedNotification){
		[self.emptyFeedNotification removeFromSuperview];
		self.emptyFeedNotification = nil;
	}
	self.tableView.allowsSelection = NO;
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
	if(nextIndex < self.followingProfileList.count) {
		Channel * nextChannel = self.followingProfileList[nextIndex];
		BOOL isCurrentUserChannel = [[nextChannel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
		self.nextProfileToPresent = nil;
		self.nextProfileToPresent = [[ProfileVC alloc] init];
		self.nextProfileToPresent.profileInFeed = YES;
		self.nextProfileToPresent.isCurrentUserProfile = isCurrentUserChannel;
		self.nextProfileToPresent.isProfileTab = NO;
		self.nextProfileToPresent.ownerOfProfile = nextChannel.channelCreator;
		self.nextProfileToPresent.channel = nextChannel;
	}
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
	} else {
		[cell presentProfileForChannel:self.followingProfileList[indexPath.row]];
	}
	self.nextProfileIndex = indexPath.row + 1;
	[self prepareNextPostFromNextIndex:self.nextProfileIndex];
	[self removeEmptyFeedNotification];
	return cell;
}


#pragma mark -Feed Cell Protocol-
-(void)shouldHideTabBar:(BOOL) shouldHide{
	self.tableView.scrollEnabled = !shouldHide;
	self.contentInFullScreen = shouldHide;
	[self setNeedsStatusBarAppearanceUpdate];
}
-(void)exitProfile{
    [self.delegate exitProfileList];
}

@end
