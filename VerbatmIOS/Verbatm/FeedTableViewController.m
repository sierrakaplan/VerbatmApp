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
#import "SizesAndPositions.h"
#import "VerbatmNavigationController.h"

@interface FeedTableViewController () <FeedCellDelegate>

@property(nonatomic) NSMutableArray *followingProfileList;
@property (nonatomic) Channel *currentUserChannel;
@property (nonatomic) ProfileVC *nextProfileToPresent;
@property (nonatomic) NSInteger nextProfileIndex;
@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) NSInteger startIndex;

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
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.tableView.allowsSelection = NO;
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarStyleClearWithTextColor:[UIColor whiteColor]];
	if(self.startIndex >= 0) {
		NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.startIndex inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:NO];
	}
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (self.isMovingFromParentViewController || self.isBeingDismissed) {
		[self.navigationController setNavigationBarHidden:YES];
		[self.delegate exitProfileList];
	}
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
}

-(void)setAndRefreshWithList:(NSMutableArray *) channelList withStartIndex:(NSInteger) startIndex{
    [self.followingProfileList removeAllObjects];
    self.followingProfileList = channelList;
	self.startIndex = startIndex;
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
	CGFloat height = self.view.frame.size.height;
	return height;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = self.view.frame.size.height;
	return height;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];

	if(self.nextProfileToPresent){
		[self.nextProfileToPresent clearOurViews];
		self.nextProfileToPresent = nil;
	}
}

#pragma mark - Table view data source


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
    [feedCell updateDateOfLastPostSeen];
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


#pragma mark - Feed Cell Protocol -

-(void) showNavBar:(BOOL)show {
    [self.tableView setScrollEnabled:show];
	[self.navigationController setNavigationBarHidden:show];
}

-(void) pushViewController:(UIViewController *)viewController {
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
