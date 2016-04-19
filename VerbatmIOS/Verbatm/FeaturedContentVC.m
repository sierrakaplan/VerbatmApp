//
//  FeaturedContentVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import "ExploreChannelCellView.h"
#import "FeedQueryManager.h"
#import "FeaturedContentVC.h"
#import "FeaturedContentCellView.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface FeaturedContentVC() <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *exploreChannels;
@property (strong, nonatomic) NSMutableArray *featuredChannels;

#define HEADER_HEIGHT 50.f
#define CELL_HEIGHT 350.f

@end

@implementation FeaturedContentVC

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.delegate = self;
	[self addRefreshFeature];

	//avoid covering last item in uitableview
	//todo: change this when bring back search bar
	UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, TAB_BAR_HEIGHT + STATUS_BAR_HEIGHT, 0);
	self.tableView.contentInset = inset;
	self.tableView.scrollIndicatorInsets = inset;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	[self.view addSubview:self.tableView];
	[self loadChannels];
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	//Free all memory
	self.exploreChannels = nil;
	self.featuredChannels = nil;
//	[self.tableView removeFromSuperview];
}

-(void) loadChannels {
	[[FeedQueryManager sharedInstance] loadFeaturedChannelsWithCompletionHandler:^(NSArray *featuredChannels) {
		[self.featuredChannels addObjectsFromArray:featuredChannels];
		[self.tableView reloadData];
	}];
	[[FeedQueryManager sharedInstance] refreshExploreChannelsWithCompletionHandler:^(NSArray *exploreChannels) {
		[self.exploreChannels addObjectsFromArray: exploreChannels];
		[self.tableView reloadData];
	}];
}

-(void)addRefreshFeature{
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadChannels];
	});

	[refreshControl endRefreshing];
}

#pragma mark - Table View delegate methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *sectionName;
	switch (section) {
		case 0:
			sectionName = NSLocalizedString(@"Featured Content", @"Featured Content");
			break;
		case 1:
			sectionName = NSLocalizedString(@"Explore", @"Explore");
			break;
		default:
			sectionName = @"";
			break;
	}
	return sectionName;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return HEADER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	// Background color
	view.tintColor = [UIColor blackColor];
	// Text Color
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	[header.textLabel setTextColor:[UIColor whiteColor]];
	//todo: make constant
	[header.textLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:20.f]];
	[header.textLabel setTextAlignment:NSTextAlignmentCenter];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//todo: select a channel
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld%ld", (long)indexPath.section, (long)indexPath.row % 10]; // reuse cells every 10
	if (indexPath.section == 0) {
		FeaturedContentCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[FeaturedContentCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		}
		if (!cell.alreadyPresented && self.featuredChannels.count > 0) {
			//Only one featured content cell
			[cell presentChannels: self.featuredChannels];
		}

		[cell onScreen];
		return cell;
	} else {
		Channel *channel = [self.exploreChannels objectAtIndex: indexPath.row];
		ExploreChannelCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[ExploreChannelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		}
		if (cell.channelBeingPresented != channel && self.exploreChannels.count > 0){
			[cell clearViews];
			[cell presentChannel: channel];
		}
		[cell onScreen];
		return cell;
	}
}

//Pause videos
-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

// Play videos
- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// Don't let headers remain anchored
	if (scrollView.contentOffset.y <= HEADER_HEIGHT && scrollView.contentOffset.y>=0) {
		scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
	} else if (scrollView.contentOffset.y >= HEADER_HEIGHT) {
		scrollView.contentInset = UIEdgeInsetsMake(-HEADER_HEIGHT, 0, 0, 0);
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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


@end
