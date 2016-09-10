//
//  DisocverVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import "ExploreChannelCellView.h"
#import "Icons.h"
#import "InviteFriendsVC.h"
#import "FeedQueryManager.h"
#import "DiscoverVC.h"
#import "FeaturedContentCellView.h"
#import "FollowFriendsCell.h"
#import "FollowFriendsVC.h"
#import "Follow_BackendManager.h"
#import "MasterNavigationVC.h"
#import "Notifications.h"
#import "ProfileVC.h"
#import "SearchResultsVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "VerbatmNavigationController.h"

@interface DiscoverVC() <UIScrollViewDelegate, ExploreChannelCellViewDelegate, UICollectionViewDelegate,
UICollectionViewDataSource>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SearchResultsVC *searchResultsController;

@property (nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *exploreChannels;

@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;

@property (nonatomic) BOOL loadingMoreChannels;
@property (nonatomic) BOOL refreshing;

#define HEADER_FONT_SIZE 25.f

#define LOAD_MORE_CUTOFF 3

#define MIN_FRIEND_CHANNELS 0

#define FRIEND_INVITE_CELL_HEIGHT 50.f
#define CELL_HEIGHT 130.f
#define CELL_SPACING_LARGE 20.f
#define CELL_WIDTH ((self.view.frame.size.width - CELL_SPACING_LARGE*3)/2.f)

#define EXPLORE_CELL_ID @"explore_cell_id"
#define SHOW_FRIEND_CELL_ID @"friend_cell_id"

@end

@implementation DiscoverVC

- (void)viewDidLoad {
	[super viewDidLoad];
	self.loadingMoreChannels = NO;
	self.refreshing = NO;
	self.view.backgroundColor = [UIColor blackColor];
	[self setUpSearchController];
	[self createCollectionView];

	[self addRefreshFeature];
	[self refreshChannels];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearViews)
												 name:NOTIFICATION_FREE_MEMORY_DISCOVER object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChannels)
												 name:NOTIFICATION_REFRESH_DISCOVER object:nil];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
																			 style:self.navigationItem.backBarButtonItem.style
																			target:nil action:nil];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
	[(MasterNavigationVC*)self.tabBarController showTabBar:YES];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*) self.navigationController setNavigationBarBackgroundColor:[UIColor blackColor]];
	[(VerbatmNavigationController*) self.navigationController setNavigationBarShadowColor:[UIColor lightGrayColor]];
	if (!_exploreChannels || !self.exploreChannels.count) {
		[self refreshChannels];
	}
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self offScreen];
}

//register our custom cell class
-(void)registerClassForCustomCells {
	[self.collectionView registerClass:[ExploreChannelCellView class] forCellWithReuseIdentifier:EXPLORE_CELL_ID];
	[self.collectionView registerClass:[FollowFriendsCell class] forCellWithReuseIdentifier:SHOW_FRIEND_CELL_ID];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(BOOL) prefersStatusBarHidden {
	return NO;
}

-(void) setUpSearchController {
	self.searchResultsController = [[SearchResultsVC alloc] init];
	self.searchResultsController.verbatmTabBarController = (MasterNavigationVC*)self.tabBarController;
	self.searchResultsController.verbatmNavigationController = (VerbatmNavigationController*)self.navigationController;
	self.searchController = [[UISearchController alloc] initWithSearchResultsController: self.searchResultsController];
	self.searchController.searchResultsUpdater = self.searchResultsController;
	self.searchController.hidesNavigationBarDuringPresentation = NO;
	self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
	self.navigationItem.titleView = self.searchController.searchBar;
	self.definesPresentationContext = YES;
	[self formatSearchBar: self.searchController.searchBar];
	//	self.searchController.searchBar.scopeButtonTitles = @[@"Users", @"Blogs"];
}

-(void) createCollectionView {
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout: [self getFlowLayout]];
	[self.view addSubview: self.collectionView];
	self.collectionView.showsVerticalScrollIndicator = NO;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.allowsMultipleSelection = NO;
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	//	UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:DISCOVER_BACKGROUND]];
	//	[self.tableView setBackgroundView:backgroundView];
	//	self.tableView.backgroundView.layer.zPosition -= 1;
	self.collectionView.backgroundColor = [UIColor blackColor];
	//avoid covering status bar and last item in uitableview
	UIEdgeInsets inset = UIEdgeInsetsMake(STATUS_BAR_HEIGHT, CELL_SPACING_LARGE, TAB_BAR_HEIGHT + STATUS_BAR_HEIGHT, CELL_SPACING_LARGE);
	self.collectionView.contentInset = inset;
	self.collectionView.scrollIndicatorInsets = inset;
	[self registerClassForCustomCells];
}

-(UICollectionViewFlowLayout * )getFlowLayout {
	UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	[flowLayout setMinimumInteritemSpacing:CELL_SPACING_LARGE];
	[flowLayout setMinimumLineSpacing:CELL_SPACING_LARGE];
	[flowLayout setItemSize: CGSizeMake(CELL_WIDTH, CELL_HEIGHT)];
	[flowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.f, 20.f, 0.f)];
	return flowLayout;
}

-(void) formatSearchBar:(UISearchBar*)searchBar {
	searchBar.barTintColor = [UIColor whiteColor];
	searchBar.tintColor = [UIColor whiteColor];
	//	searchBar.backgroundColor = [UIColor blackColor];
	//	searchBar.backgroundImage = [UIImage new];
}

-(void) clearViews {
	for (NSIndexPath *indexPath in [self.collectionView indexPathsForVisibleItems]) {
		if (indexPath.section == 1) {
			ExploreChannelCellView *cellView = (ExploreChannelCellView*)[self.collectionView
																		 cellForItemAtIndexPath:indexPath];
			[(ExploreChannelCellView*)cellView clearViews];
		}
	}
	self.loadingMoreChannels = NO;
	self.refreshing = NO;
	_exploreChannels = nil;
	[self.collectionView reloadData];
}

-(void) offScreen {
	for (NSIndexPath *indexPath in [self.collectionView indexPathsForVisibleItems]) {
		if (indexPath.section == 1) {
			//			ExploreChannelCellView *cellView = (ExploreChannelCellView*)[self.collectionView
			//																		 cellForItemAtIndexPath:indexPath];
			//			[(ExploreChannelCellView*)cellView offScreen];
		}
	}
}

-(void) refreshChannels {
	if (self.refreshing) return;
	self.refreshing = YES;
	self.loadingMoreChannels = NO;
	if (![self.refreshControl isRefreshing]) [self.loadMoreSpinner startAnimating];
	[self loadExploreChannels];
}

-(void) loadExploreChannels {
	[[FeedQueryManager sharedInstance] refreshExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
		[self.exploreChannels removeAllObjects];
		[self.refreshControl endRefreshing];
		[self.loadMoreSpinner stopAnimating];
		[self.exploreChannels addObjectsFromArray: exploreChannels];
		[self.collectionView reloadData];
		self.refreshing = NO;
	}];
}

-(void) loadMoreChannels {
	if (self.refreshing) return;
	self.loadingMoreChannels = YES;
	[self.loadMoreSpinner startAnimating];
	[[FeedQueryManager sharedInstance] loadMoreExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
		[self.loadMoreSpinner stopAnimating];
		if (exploreChannels.count) {
			[self.exploreChannels addObjectsFromArray: exploreChannels];
			[self.collectionView reloadData];
			self.loadingMoreChannels = NO;
		}
	}];
}

-(void)addRefreshFeature{
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshChannels) forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:self.refreshControl];

	self.loadMoreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.loadMoreSpinner.hidesWhenStopped = YES;
	//todo: add supplementary view for load more
	//	self.collectionView. = self.loadMoreSpinner;
}

//todo: different view controller for onboarding
-(void) channelSelected:(Channel *)channel {
	ProfileVC * userProfile = [[ProfileVC alloc] init];
	userProfile.ownerOfProfile = channel.channelCreator;
	userProfile.channel = channel;
	[self.navigationController pushViewController:userProfile animated:YES];
}

#pragma mark - Collection view delegate methods -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 2; // Invite friends/view friends section + discover cells section
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	// Invite friends/view friends section
	if (section == 0) {
		return 2;
	} else {
		return self.exploreChannels.count;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	//todo:
	if (section == 0) {
		if (row == 0) {
			[self presentInviteFriendsView];
		} else {
			[self showFollowFriendsView];
		}
	} else if (section == 1) {
		ExploreChannelCellView *cell = (ExploreChannelCellView*)[self.collectionView cellForItemAtIndexPath:indexPath];
		Channel *channel = cell.channelBeingPresented;
		[self channelSelected:channel];
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	if (section == 0) {
		return CGSizeMake(self.view.frame.size.width, FRIEND_INVITE_CELL_HEIGHT);
	} else {
		return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
	}
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
							layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	if (section == 0) {
		return CELL_SPACING_LARGE;
	} else {
		return CELL_SPACING_LARGE;
	}
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
				   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	if (section == 0) {
		return 1.f;
	} else {
		return CELL_SPACING_LARGE;
	}
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0) {
		FollowFriendsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SHOW_FRIEND_CELL_ID forIndexPath:indexPath];
		if (row == 0) {
			[cell setLabelText:@"Invite friends to join Verbatm" andImage:[UIImage imageNamed:INVITE_FRIENDS_ICON]];
		} else {
			[cell setLabelText:@"Follow friends on Verbatm" andImage:[UIImage imageNamed:FOLLOW_FRIENDS_ICON]];
		}
		return cell;
	} else {
		ExploreChannelCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EXPLORE_CELL_ID
																				 forIndexPath:indexPath];
		Channel *channel = [self.exploreChannels objectAtIndex: indexPath.row];
		if (cell.channelBeingPresented != channel) {
			[cell clearViews];
			[cell presentChannel: channel];
		}
		if (self.exploreChannels.count - indexPath.row <= LOAD_MORE_CUTOFF &&
			!self.loadingMoreChannels && !self.refreshing) {
			[self loadMoreChannels];
		}
		return cell;
	}
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if (indexPath.section == 1 && [collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
		//		[(ExploreChannelCellView*)cell offScreen];
	}
}

#pragma mark - Invite friends -

-(void) presentInviteFriendsView {
	InviteFriendsVC *inviteFriendsVC = [[InviteFriendsVC alloc] init];
	[self.navigationController pushViewController:inviteFriendsVC animated:YES];
}

-(void) showFollowFriendsView {
	FollowFriendsVC *followFriendsVC = [[FollowFriendsVC alloc] init];
	[self.navigationController pushViewController:followFriendsVC animated:YES];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray *) exploreChannels {
	if (!_exploreChannels) {
		_exploreChannels =[[NSMutableArray alloc] init];
	}
	return _exploreChannels;
}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
