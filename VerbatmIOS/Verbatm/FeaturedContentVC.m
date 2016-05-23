//
//  FeaturedContentVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import "ExploreChannelCellView.h"
#import "Icons.h"
#import "FeedQueryManager.h"
#import "FeaturedContentVC.h"
#import "FeaturedContentCellView.h"
#import "Follow_BackendManager.h"
#import "Notifications.h"
#import "ProfileVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface FeaturedContentVC() <UIScrollViewDelegate, FeaturedContentCellViewDelegate,
ExploreChannelCellViewDelegate>

@property (strong, nonatomic) NSMutableArray *exploreChannels;
@property (strong, nonatomic) NSMutableArray *featuredChannels;

@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL loadingMoreChannels;
@property (nonatomic) BOOL refreshing;

#define HEADER_HEIGHT 50.f
#define HEADER_FONT_SIZE 20.f
#define CELL_HEIGHT 350.f

#define LOAD_MORE_CUTOFF 3

@end

@implementation FeaturedContentVC

@dynamic refreshControl;

- (void) awakeFromNib {
	[self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.loadingMoreChannels = NO;
	self.refreshing = NO;
	self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.delegate = self;
	[self.view setBackgroundColor:[UIColor clearColor]];
	[self.tableView setBackgroundColor:[UIColor clearColor]];

	//avoid covering last item in uitableview
	//todo: change this when bring back search bar
	UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, TAB_BAR_HEIGHT + STATUS_BAR_HEIGHT, 0);
	self.tableView.contentInset = inset;
	self.tableView.scrollIndicatorInsets = inset;

	[self addRefreshFeature];
	[self refreshChannels];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearViews) name:NOTIFICATION_FREE_MEMORY_DISCOVER object:nil];
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
	[[FeedQueryManager sharedInstance] loadFeaturedChannelsWithCompletionHandler:^(NSArray *featuredChannels) {
		self.featuredChannels = nil;
		[self.featuredChannels addObjectsFromArray:featuredChannels];
		[self.tableView reloadData];
		self.refreshing = NO;
	}];
	[[FeedQueryManager sharedInstance] refreshExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
		self.exploreChannels = nil;
		[self.refreshControl endRefreshing];
		[self.exploreChannels addObjectsFromArray: exploreChannels];
		[self.tableView reloadData];
		self.refreshing = NO;
	}];
}

-(void) loadMoreChannels {
	self.loadingMoreChannels = YES;
	[[FeedQueryManager sharedInstance] loadMoreExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
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
}

-(void) channelSelected:(Channel *)channel {
	ProfileVC * userProfile = [[ProfileVC alloc] init];
	userProfile.isCurrentUserProfile = channel.channelCreator == [PFUser currentUser];
	userProfile.isProfileTab = NO;
	userProfile.userOfProfile = channel.channelCreator;
	userProfile.startChannel = channel;
	[self presentViewController:userProfile animated:YES completion:^{
	}];
}

#pragma mark - Table View delegate methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
//	UIImageView *imageView;
//	if (section == 0) {
//		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"featured_header"]];
//	} else {
//		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"explore_header"]];
//	}
//	imageView.frame = header.bounds;
//	imageView.contentMode = UIViewContentModeScaleAspectFit;
//	[header addSubview: imageView];
//	return header;
//}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Featured";
	} else {
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
	[header.textLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:HEADER_FONT_SIZE]];
	if (section == 0) {
		[header.textLabel setText:@"Featured"];
	} else {
		[header.textLabel setText:@"Discover"];
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
	switch (section) {
		case 0:
			return 1;
		case 1:
			return self.exploreChannels.count;
		default:
			return 0;
	}
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
	if (indexPath.section == 0) {
		FeaturedContentCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[FeaturedContentCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			cell.delegate = self;
		}
		if (!cell.alreadyPresented && self.featuredChannels.count > 0) {
			//Only one featured content cell
			[cell presentChannels: self.featuredChannels];
		}

		[cell onScreen];
		return cell;
	} else {
		ExploreChannelCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[ExploreChannelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			cell.delegate = self;
		}
		if (self.exploreChannels.count > indexPath.row) {
			Channel *channel = [self.exploreChannels objectAtIndex: indexPath.row];
			if (cell.channelBeingPresented != channel) {
				[cell clearViews];
				[cell presentChannel: channel];
			}
		}
		[cell onScreen];

		if (self.exploreChannels.count - indexPath.row <= LOAD_MORE_CUTOFF &&
			!self.loadingMoreChannels && !self.refreshing) {
			[self loadMoreChannels];
		}
		return cell;
	}
}

//Pause videos
-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

// Play videos
- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound) {
		if (indexPath.section == 0) {
			[(FeaturedContentCellView*)cell offScreen];
		} else {
			[(ExploreChannelCellView*)cell offScreen];
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
