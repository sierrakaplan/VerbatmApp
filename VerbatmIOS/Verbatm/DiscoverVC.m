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
#import "FeedQueryManager.h"
#import "DiscoverVC.h"
#import "FeaturedContentCellView.h"
#import "Follow_BackendManager.h"
#import "Notifications.h"
#import "ProfileVC.h"
#import "SearchResultsVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface DiscoverVC() <UIScrollViewDelegate, FeaturedContentCellViewDelegate,
ExploreChannelCellViewDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SearchResultsVC *searchResultsController;

@property (strong, nonatomic) NSMutableArray *exploreChannels;
@property (strong, nonatomic) NSMutableArray *featuredChannels;

@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;

@property (nonatomic) BOOL loadingMoreChannels;
@property (nonatomic) BOOL refreshing;


#define HEADER_HEIGHT 50.f
#define HEADER_FONT_SIZE 25.f
#define CELL_HEIGHT 350.f

#define LOAD_MORE_CUTOFF 3

#define ONBOARDING_TEXT @"Start Following Some Blogs!"

@end

@implementation DiscoverVC

@dynamic refreshControl;

- (void) awakeFromNib {
#pragma clang diagnostic ignored "-Wunused-value"
	[self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.loadingMoreChannels = NO;
	self.refreshing = NO;
	[self formatTableView];

	if (!self.onboardingBlogSelection) {
		[self setUpSearchController];
	}

	[self addRefreshFeature];
	[self refreshChannels];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearViews)
												 name:NOTIFICATION_FREE_MEMORY_DISCOVER object:nil];
	[self setNeedsStatusBarAppearanceUpdate];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!_featuredChannels || !_exploreChannels) {
		[self refreshChannels];
	}
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self offScreen];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(BOOL) prefersStatusBarHidden {
	return NO;
}

-(void) formatTableView {
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.delegate = self;
	UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:DISCOVER_BACKGROUND]];
	[self.tableView setBackgroundView:backgroundView];
	self.tableView.backgroundView.layer.zPosition -= 1;
	[self.view setBackgroundColor:[UIColor clearColor]];
	//avoid covering status bar and last item in uitableview
	UIEdgeInsets inset = UIEdgeInsetsMake(STATUS_BAR_HEIGHT, 0, TAB_BAR_HEIGHT + STATUS_BAR_HEIGHT + 50.f, 0);
	self.tableView.contentInset = inset;
	self.tableView.scrollIndicatorInsets = inset;
}

-(void) setUpSearchController {
	self.searchResultsController = [[SearchResultsVC alloc] init];
	self.searchResultsController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.searchController = [[UISearchController alloc] initWithSearchResultsController: self.searchResultsController];
	self.searchController.searchResultsUpdater = self.searchResultsController;
	self.tableView.tableHeaderView = self.searchController.searchBar;
	self.definesPresentationContext = YES;
	self.searchController.searchBar.barTintColor = [UIColor clearColor];
	self.searchController.searchBar.tintColor = [UIColor whiteColor];
	self.searchController.searchBar.backgroundColor = [UIColor clearColor];
	self.searchController.searchBar.backgroundImage = [UIImage new];
	//	self.searchController.searchBar.scopeButtonTitles = @[@"Users", @"Blogs"];
}

-(void) clearViews {
	for (UITableViewCell *cellView in [self.tableView visibleCells]) {
		[(ExploreChannelCellView*)cellView offScreen];
		[(ExploreChannelCellView*)cellView clearViews];
	}
	self.loadingMoreChannels = NO;
	self.refreshing = NO;
	self.exploreChannels = nil;
	self.featuredChannels = nil;
	[self.tableView reloadData];
	self.exploreChannels = nil;
	self.featuredChannels = nil;
}

-(void) offScreen {
	for (UITableViewCell *cellView in [self.tableView visibleCells]) {
		[(ExploreChannelCellView*)cellView offScreen];
	}
}

-(void) refreshChannels {
	if (self.refreshing) return;
	self.refreshing = YES;
	self.loadingMoreChannels = NO;
	if (![self.refreshControl isRefreshing]) [self.loadMoreSpinner startAnimating];
	[[FeedQueryManager sharedInstance] loadFeaturedChannelsWithCompletionHandler:^(NSArray *featuredChannels) {
		self.featuredChannels = nil;
		[self.featuredChannels addObjectsFromArray:featuredChannels];
		[self.tableView reloadData];
		self.refreshing = NO;
	}];
	[[FeedQueryManager sharedInstance] refreshExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
		self.exploreChannels = nil;
		[self.refreshControl endRefreshing];
		[self.loadMoreSpinner stopAnimating];
		[self.exploreChannels addObjectsFromArray: exploreChannels];
		[self.tableView reloadData];
		self.refreshing = NO;
	}];
}

-(void) loadMoreChannels {
	self.loadingMoreChannels = YES;
	[self.loadMoreSpinner startAnimating];
	[[FeedQueryManager sharedInstance] loadMoreExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
		[self.loadMoreSpinner stopAnimating];
		if (exploreChannels.count) {
			[self.exploreChannels addObjectsFromArray: exploreChannels];
			[self.tableView reloadData];
			self.loadingMoreChannels = NO;
		}
	}];
}

-(void)addRefreshFeature{
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshChannels) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];

	self.loadMoreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.loadMoreSpinner.hidesWhenStopped = YES;
	self.tableView.tableFooterView = self.loadMoreSpinner;
}

-(void) channelSelected:(Channel *)channel {
	BOOL isCurrentUserChannel = [[channel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
	if(!self.onboardingBlogSelection &&
	   !isCurrentUserChannel){
		ProfileVC * userProfile = [[ProfileVC alloc] init];
		userProfile.isCurrentUserProfile = isCurrentUserChannel;
		userProfile.isProfileTab = NO;
		userProfile.ownerOfProfile = channel.channelCreator;
		userProfile.channel = channel;
		[self presentViewController:userProfile animated:YES completion:nil];
	}

}

#pragma mark - Table View delegate methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.onboardingBlogSelection) return 1;
//	return 2;
	return 1;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	if(self.onboardingBlogSelection){
		return ONBOARDING_TEXT;
	} else {

//		if (section == 0) {
//			return @"Featured";
//		} else {
//			return @"Discover";
//		}
		return @"Discover";
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return HEADER_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 1.f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	// Background color
	view.tintColor = [UIColor clearColor];
	// Text Color
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	[header.textLabel setTextColor:[UIColor whiteColor]];
	[header.textLabel setFont:[UIFont fontWithName:BOLD_FONT size:HEADER_FONT_SIZE]];

	if(self.onboardingBlogSelection){
		[header.textLabel setText:ONBOARDING_TEXT];
	}else{
//		if (section == 0) {
//			[header.textLabel setText:@"Featured"];
//		} else {
			[header.textLabel setText:@"Discover"];
//		}
	}
	[header.textLabel setTextAlignment:NSTextAlignmentCenter];
	[header.textLabel setLineBreakMode:NSLineBreakByClipping];

	for (UIView *subview in header.subviews) {
		if ([subview isKindOfClass:[UIImageView class]]) {
			CGRect frame = CGRectMake(10.f, 0.f, header.bounds.size.width - 20.f, header.bounds.size.height);
			subview.frame = frame;
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.exploreChannels.count;
//	}else{
//		switch (section) {
//			case 0:
//				return 1;
//			case 1:
//				return self.exploreChannels.count;
//			default:
//				return 0;
//		}
//	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return CELL_HEIGHT;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// All cells should be non selectable
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld%ld", (long)indexPath.section, (long)indexPath.row % 10]; // reuse cells every 10
//	if (indexPath.section == 1 || self.onboardingBlogSelection) {
		ExploreChannelCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[ExploreChannelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			cell.delegate = self;
		}
		Channel *channel = [self.exploreChannels objectAtIndex: indexPath.row];
		if (cell.channelBeingPresented != channel) {
			[cell clearViews];
			[cell presentChannel: channel];
		}
		[cell onScreen];

		if (self.exploreChannels.count - indexPath.row <= LOAD_MORE_CUTOFF &&
			!self.loadingMoreChannels && !self.refreshing) {
			[self loadMoreChannels];
		}
		return cell;
//	} else {
//		FeaturedContentCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//		if(cell == nil) {
//			cell = [[FeaturedContentCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//			cell.delegate = self;
//		}
//		if (!cell.alreadyPresented && self.featuredChannels.count > 0) {
//			//Only one featured content cell
//			[cell presentChannels: self.featuredChannels];
//		}
//
//		[cell onScreen];
//		return cell;
//	}
}

//todo: Stop videos (to make scrolling smooth)
-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

//todo: Play videos
- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound) {
		if (indexPath.section == 1 || self.onboardingBlogSelection) {
			[(ExploreChannelCellView*)cell offScreen];

		} else {
			[(FeaturedContentCellView*)cell offScreen];
		}
	}
}

-(CGFloat) getVisibileCellIndex{
	return self.tableView.contentOffset.y / CELL_HEIGHT;
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray *) exploreChannels {
	if (!_exploreChannels) {
		_exploreChannels =[[NSMutableArray alloc] init];
	}
	return _exploreChannels;
}

-(NSMutableArray *) featuredChannels {
	if (!_featuredChannels) {
		_featuredChannels = [[NSMutableArray alloc] init];
	}
	return _featuredChannels;
}


-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
