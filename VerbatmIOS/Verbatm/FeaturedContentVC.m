//
//  FeaturedContentVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import "ExploreChannelCellView.h"
#import "FeaturedContentVC.h"
#import "FeaturedContentCellView.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface FeaturedContentVC() <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *exploreChannels;
@property (strong, nonatomic) NSMutableArray *featuredChannels;

#define HEADER_HEIGHT 50.f

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

	[self loadChannels];

	//avoid covering last item in uitableview
	UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, CUSTOM_NAV_BAR_HEIGHT, 0);
	self.tableView.contentInset = inset;
	self.tableView.scrollIndicatorInsets = inset;
}

-(void) loadChannels {
	[Channel_BackendObject getAllChannelsButNoneForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray *allChannels) {
		[self.featuredChannels addObjectsFromArray:allChannels];
		[self.exploreChannels addObjectsFromArray:allChannels];
		//todo: fix this algorithm
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
		//todo: update each type of content
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
	if (indexPath.section == 0) {
		return 350.f; //todo
	} else {
		return 360.f;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//todo: select a channel
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld%ld", (long)indexPath.section, (long)indexPath.row];
	if (indexPath.section == 0) {
		FeaturedContentCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[FeaturedContentCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		} else {
			[cell removeFromSuperview];
		}
		[cell presentChannels: self.featuredChannels];
		return cell;
	} else {
		ExploreChannelCellView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if(cell == nil) {
			cell = [[ExploreChannelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		} else {
			[cell removeFromSuperview];
		}
		Channel *channel = [self.exploreChannels objectAtIndex: indexPath.row];
		[cell presentChannel:channel];
		return cell;
	}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// Don't let headers remain anchored
	if (scrollView.contentOffset.y <= HEADER_HEIGHT && scrollView.contentOffset.y>=0) {
		scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
	} else if (scrollView.contentOffset.y >= HEADER_HEIGHT) {
		scrollView.contentInset = UIEdgeInsetsMake(-HEADER_HEIGHT, 0, 0, 0);
	}
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
