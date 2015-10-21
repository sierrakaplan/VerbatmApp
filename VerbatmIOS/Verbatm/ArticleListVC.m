//
//  verbatmArticleListControlerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleListVC.h"
#import "ArticleDisplayVC.h"
#import "AVETypeAnalyzer.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "Notifications.h"
#import "SizesAndPositions.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Strings.h"
#import "VerbatmCameraView.h"
#import "MediaSessionManager.h"
#import "MasterNavigationVC.h"
#import "FeedTableViewCell.h"
#import "FeedTableView.h"

#import "POVLoadManager.h"
#import "PovInfo.h"

#import "UserManager.h"
#import "UIView+Effects.h"

@interface ArticleListVC () <UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate, POVLoadManagerDelegate>


#pragma mark - Table View + data -

@property (strong, nonatomic) FeedTableView *povListView;
@property (strong, nonatomic) POVLoadManager *povLoader;
@property (nonatomic) CGPoint recentContentOffset;

#pragma mark - Publishing POV -

@property (strong, nonatomic) FeedTableViewCell* povPublishingPlaceholderCell;
@property (nonatomic) BOOL povPublishing;

#pragma mark - Refresh -

@property (atomic) BOOL pullDownInProgress;
//this cell is inserted in the top of the listview when pull down to refresh
//tells you whether or not we have started a timer to animate
@property (atomic) BOOL refreshInProgress;
@property (strong,nonatomic) UIRefreshControl *reloadingRefreshControl;

@property (nonatomic) BOOL loadingMorePOVsInProgress;
@property (strong, nonatomic) UIActivityIndicatorView *loadingMoreActivityIndicator;

@property (atomic) BOOL povsRefreshedForFirstTime;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

#define FEED_CELL_ID @"feed_cell_id"
#define FEED_CELL_ID_PUBLISHING  @"feed_cell_id_publishing"

#define NUM_POVS_IN_SECTION 6
#define RELOAD_THRESHOLD (STORY_CELL_HEIGHT*2 + 10)

@end

@implementation ArticleListVC

- (void) viewDidLoad {
	[super viewDidLoad];
	[self initPovListView];
	[self registerForNotifications];
    [self setRefreshAnimator];
	[self initializeVariables];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.povListView.contentOffset = CGPointZero;
	[self refreshFeedForFirstTime];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.recentContentOffset = self.povListView.contentOffset;
	self.povListView.contentOffset = CGPointZero;
	[super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	self.povListView.contentOffset = CGPointMake(0, self.recentContentOffset.y);
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(povPublished)
												 name:NOTIFICATION_POV_PUBLISHED
											   object:nil];
   	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionUpdate:)
                                                 name:INTERNET_CONNECTION_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshFeed)
												 name:NOTIFICATION_REFRESH_FEEDS
											   object:nil];
}

-(void) initPovListView {
	self.povListView.delegate = self;
	self.povListView.dataSource = self;
	self.povListView.tableFooterView = self.loadingMoreActivityIndicator;
	self.loadingMoreActivityIndicator.center = self.povListView.center;
	[self.view addSubview:self.povListView];
}

-(void) initializeVariables {
	self.pullDownInProgress = NO;
	self.refreshInProgress = NO;
	self.loadingMorePOVsInProgress = NO;
	self.recentContentOffset = CGPointZero;
}

#pragma mark - Setting POV Load Manager -

-(void) setPovLoadManager:(POVLoadManager *) povLoader {
	self.povLoader = povLoader;
	self.povLoader.delegate = self;
	[self refreshFeedForFirstTime];
}

#pragma mark - Table View Delegate methods (view customization) -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return STORY_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.refreshInProgress) { return; }
	if(self.povPublishing && indexPath.row == 0) {
        return;
    }
	// Tell cell it was selected so it can animate being pinched together before it calls
	// delegate method to be selected
	FeedTableViewCell* cell = (FeedTableViewCell*)[self.povListView cellForRowAtIndexPath:indexPath];
	[cell wasSelected];
}

#pragma mark - Table View Data Source methods (model) -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [self.povLoader getNumberOfPOVsLoaded];
    count += (self.povPublishing) ? 1:0;
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
	FeedTableViewCell *cell;
    BOOL publishingNoRefresh = (self.povPublishing && (index == 0));
	if (publishingNoRefresh) {
		cell = self.povPublishingPlaceholderCell;
    } else {
		cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_ID];
		if (cell == nil) {
			cell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID];
		}
        
		PovInfo* povInfo;
		if (self.povPublishingPlaceholderCell) {
			povInfo = [self.povLoader getPOVInfoAtIndex: index-1];
		} else {
			povInfo = [self.povLoader getPOVInfoAtIndex: index];
		}
		// check if user likes this story
		BOOL currentUserLikesStory = [[UserManager sharedInstance] currentUserLikesStory:povInfo];
		[cell setContentWithUsername:povInfo.userName andTitle: povInfo.title andCoverImage: povInfo.coverPhoto
					  andDateCreated:povInfo.datePublished andNumLikes:povInfo.numUpVotes
				  likedByCurrentUser:currentUserLikesStory];
		cell.indexPath = indexPath;
		cell.delegate = self;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark - Notify cell that current user has liked or unliked it -

-(void) userHasLikedPOV: (BOOL) liked withPovInfo: (PovInfo*) povInfo {
	NSInteger povIndex = [self.povLoader getIndexOfPOV: povInfo];
	if (povIndex == NSNotFound) return;
	[self.povLoader currentUserLiked:liked povInfo:povInfo];
	FeedTableViewCell* povCell = [self.povListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:povIndex inSection:0]];
	[povCell updateCellLikedByCurrentUser:liked withNewNumLikes: povInfo.numUpVotes.longLongValue];
}

#pragma mark - Feed Table View Cell Delegate methods -

-(void) successfullyPinchedTogetherCell: (FeedTableViewCell *)cell {
	[self viewPOVOnCell: cell];
}

#pragma mark - Viewing POV -

//one of the POV's in the list has been clicked
-(void) viewPOVOnCell: (FeedTableViewCell*) cell {
	[self.delegate displayPOVOnCell:cell withLoadManager: self.povLoader];
}

#pragma mark - Show POV publishing -

//Called on it by parent view controller to let it know that a user
// has published a POV and to show the loading animation until the POV
// has actually published
-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic
					andProgressObject: (NSProgress*) publishingProgress {
    if(self.povPublishing){
        //there is another one being published so we will exit for now
        return;
    }

    self.povPublishing = YES;
	self.povPublishingPlaceholderCell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID_PUBLISHING];
	[self.povPublishingPlaceholderCell setPublishingContentWithUsername:userName andTitle: title andCoverImage:coverPic andProgressObject:publishingProgress];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.povListView beginUpdates];
    [self.povListView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.povListView endUpdates];
}

// Method called from Notification sent by the model to let it know that
// a pov has published so that it can refresh the feed
-(void) povPublished {
    [self.povLoader reloadPOVs: NUM_POVS_IN_SECTION];
}

#pragma mark - Refresh feed -

-(void) refreshFeedForFirstTime {
	if (!self.povsRefreshedForFirstTime) {
		[self.activityIndicator startAnimating];
		[self refreshFeed];
		self.povsRefreshedForFirstTime = YES;
	}
}

-(void) refreshNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_REFRESH_FEEDS object:nil];
}

// Tells pov loader to reload POV's completely (removing all those previously loaded and getting the first page again)
// To refresh all feeds and not just this, call refreshNotification not refreshFeed
-(void) refreshFeed {
    if(self.refreshInProgress) return;
    self.refreshInProgress = YES;
	[self.povLoader reloadPOVs: NUM_POVS_IN_SECTION];
}

#pragma mark - POVLoadManager Delegate methods -

//Delegate method from povLoader informing us the the list has been refreshed. So the content length is the same
-(void) povsRefreshed {
	[self endRefreshing];
	[self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

//delegate method from povLoader - called if call to refresh failed usually for internet reasons
-(void)povsFailedToRefresh{
	[self endRefreshing];
	//TODO: tell user somehow that these failed to refresh
    [self.delegate failedToRefreshFeed];
}

// If the activity indicator showing the first refresh is going, stops it
// If the refresh control at the top is going, stops it
// If there was a publishing placeholder cell removes it
-(void)endRefreshing {
	self.refreshInProgress = NO;
	if ([self.activityIndicator isAnimating]) {
		[self.activityIndicator stopAnimating];
	}
	if(self.reloadingRefreshControl.isRefreshing) {
		[self.reloadingRefreshControl endRefreshing];
	}
	if(self.povPublishing) {
		self.povPublishing = NO;
		self.povPublishingPlaceholderCell = nil;
	}
}

//Delegate method from the povLoader, letting this list know more POV's have loaded so that it can refresh
-(void) morePOVsLoaded {
    self.loadingMorePOVsInProgress = NO;
	if ([self.loadingMoreActivityIndicator isAnimating]) {
		[self.loadingMoreActivityIndicator stopAnimating];
	}
	[self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void) failedToLoadMorePOVs {
	//TODO: tell user somehow that these failed to load more
	self.loadingMorePOVsInProgress = NO;
	if ([self.loadingMoreActivityIndicator isAnimating]) {
		[self.loadingMoreActivityIndicator stopAnimating];
	}
	[self.delegate failedToRefreshFeed];
}

#pragma mark - Pull to refresh Feed Animation -

-(void)setRefreshAnimator {
    self.reloadingRefreshControl = [[UIRefreshControl alloc] init];
    [self.reloadingRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.povListView addSubview:self.reloadingRefreshControl];
}

-(void)refresh:(UIRefreshControl *)refreshControl {
    if(self.povPublishing || self.loadingMorePOVsInProgress){
        [refreshControl endRefreshing];
    } else {
        [self refreshNotification];
    }
}

#pragma mark - Infinite Scroll -

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //change the contentsize
    [self.povListView endUpdates];
    self.povListView.contentSize = CGSizeMake(self.povListView.contentSize.width,
                                              ([self.povLoader getNumberOfPOVsLoaded] * STORY_CELL_HEIGHT ) + 80 + NAV_BAR_HEIGHT);

	//when the user has reached the very bottom of the feed and pulls we load more articles into the feed
	if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - RELOAD_THRESHOLD) {
		if(!self.loadingMorePOVsInProgress && !self.refreshInProgress) {
			self.loadingMorePOVsInProgress = YES;
			[self.loadingMoreActivityIndicator startAnimating];
			[self.povLoader loadMorePOVs: NUM_POVS_IN_SECTION];
		}
	}
}

#pragma mark - Network Connection -
-(void)networkConnectionUpdate: (NSNotification *) notification{
    NSDictionary * userInfo = [notification userInfo];
    BOOL thereIsConnection = [self isThereConnectionFromString:[userInfo objectForKey:INTERNET_CONNECTION_KEY]];
	if (thereIsConnection) {
		[self refreshFeedForFirstTime];
	}
}

-(BOOL)isThereConnectionFromString:(NSString *) key{
    if([key isEqualToString:@"YES"]){
        return YES;
    }
    return NO;
}

#pragma mark - Miscellaneous -
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	//return supported orientation masks
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//for ios8+ To hide the status bar
-(BOOL)prefersStatusBarHidden{
	return YES;
}

#pragma mark - Lazy Instantiation -

-(FeedTableView*) povListView {
	if (!_povListView) {
		_povListView = [[FeedTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	}
	return _povListView;
}

-(UIActivityIndicatorView*) activityIndicator {
	if (!_activityIndicator) {
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicator.color = [UIColor grayColor];
		_activityIndicator.hidesWhenStopped = YES;
		_activityIndicator.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 1.f/3.f);
		[self.view addSubview:_activityIndicator];
		[self.view bringSubviewToFront:_activityIndicator];
	}
	return _activityIndicator;
}

-(UIActivityIndicatorView*) loadingMoreActivityIndicator {
	if (!_loadingMoreActivityIndicator) {
		_loadingMoreActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		_loadingMoreActivityIndicator.color = [UIColor grayColor];
		_loadingMoreActivityIndicator.hidesWhenStopped = YES;
	}
	return _loadingMoreActivityIndicator;
}


@end
