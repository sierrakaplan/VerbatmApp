//
//  FollowFriendsVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "DiscoverCollectionViewCell.h"
#import "FeedQueryManager.h"
#import "Follow_BackendManager.h"
#import "FollowFriendsVC.h"
#import "MasterNavigationVC.h"
#import "ProfileVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "VerbatmNavigationController.h"

@interface FollowFriendsVC() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *friendChannels;

@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;

@property (nonatomic) BOOL refreshing;

#define CELL_HEIGHT 130.f
#define CELL_SPACING_LARGE 20.f
#define CELL_WIDTH ((self.view.frame.size.width - CELL_SPACING_LARGE*3)/2.f)

#define EXPLORE_CELL_ID @"explore_cell_id"

@end

@implementation FollowFriendsVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.refreshing = NO;
	self.view.backgroundColor = [UIColor blackColor];
	[self createCollectionView];

	[self addRefreshFeature];
	[self refreshChannels];

	self.navigationItem.title = @"Follow Your Friends";
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
																			 style:self.navigationItem.backBarButtonItem.style
																			target:nil action:nil];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
	[(MasterNavigationVC*)self.tabBarController showTabBar:YES];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*) self.navigationController setNavigationBarTextColor:[UIColor whiteColor]];
	[(VerbatmNavigationController*) self.navigationController setNavigationBarBackgroundColor:[UIColor blackColor]];
	[(VerbatmNavigationController*) self.navigationController setNavigationBarShadowColor:[UIColor lightGrayColor]];
	if (!_friendChannels || !self.friendChannels.count) {
		[self refreshChannels];
	}
}

-(UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
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

//register our custom cell class
-(void)registerClassForCustomCells {
	[self.collectionView registerNib:[UINib nibWithNibName:@"DiscoverCollectionViewCell" bundle:nil]
		  forCellWithReuseIdentifier:EXPLORE_CELL_ID];
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

-(void) refreshChannels {
	if (self.refreshing) return;
	self.refreshing = YES;
	if (![self.refreshControl isRefreshing]) [self.loadMoreSpinner startAnimating];
	[self loadExploreChannels];
}

-(void) loadExploreChannels {
	[[FeedQueryManager sharedInstance] getChannelsForAllFriendsWithCompletionHandler:^(NSArray *friendChannels) {
		//todo: if no friends, show this
		[self.friendChannels removeAllObjects];
		[self.refreshControl endRefreshing];
		[self.loadMoreSpinner stopAnimating];
		[self.friendChannels addObjectsFromArray: friendChannels];
		[self.collectionView reloadData];
		self.refreshing = NO;
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
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.friendChannels.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	DiscoverCollectionViewCell *cell = (DiscoverCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
	Channel *channel = cell.channelBeingPresented;
	[self channelSelected:channel];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
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

		DiscoverCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EXPLORE_CELL_ID
																				 forIndexPath:indexPath];
		Channel *channel = [self.friendChannels objectAtIndex: indexPath.row];
		if (cell.channelBeingPresented != channel) {
			[cell clearViews];
			[cell presentChannel: channel];
		}
		return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if (indexPath.section == 1 && [collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
		//		[(ExploreChannelCellView*)cell offScreen];
	}
}

#pragma mark Follow All

-(void) followAllBlogs {
	for (Channel* channel in self.friendChannels) {
		[Follow_BackendManager currentUserFollowChannel:channel];
	}
}

-(NSMutableArray*) friendChannels {
	if (!_friendChannels) {
		_friendChannels = [[NSMutableArray alloc] init];
	}
	return _friendChannels;
}

@end
