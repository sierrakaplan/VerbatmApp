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

@interface ArticleListVC () <UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate, POVLoadManagerDelegate>


#pragma mark - Table View + data -

@property (strong, nonatomic) FeedTableView *povListView;
@property (strong, nonatomic) POVLoadManager *povLoader;

#pragma mark - Publishing POV -

@property (strong, nonatomic) FeedTableViewCell* povPublishingPlaceholderCell;
@property (nonatomic) BOOL povPublishing;
@property (nonatomic) BOOL loadingPOVs;


#pragma mark - Refresh -

//this cell is inserted in the top of the listview when pull down to refresh
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (atomic) BOOL pullDownInProgress;
//tells you whether or not we have started a timer to animate
@property (atomic) BOOL refreshInProgress;

#define FEED_CELL_ID @"feed_cell_id"
#define FEED_CELL_ID_PUBLISHING  @"feed_cell_id_publishing"

#define NUM_POVS_IN_SECTION 4
#define RELOAD_THRESHOLD -10
@end

@implementation ArticleListVC

- (void) viewDidLoad {
	[super viewDidLoad];
	[self initPovListView];
	[self registerForNotifications];
    [self setRefreshAnimator];
    self.pullDownInProgress = NO;
    self.refreshInProgress = NO;
    self.loadingPOVs = NO;
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(povPublished)
												 name:NOTIFICATION_POV_PUBLISHED
											   object:nil];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshFeed];
}

-(void) initPovListView {
	self.povListView.delegate = self;
	self.povListView.dataSource = self;
	[self.view addSubview:self.povListView];
}


#pragma mark - Setting POV Load Manager -

-(void) setPovLoadManager:(POVLoadManager *) povLoader {
	self.povLoader = povLoader;
	self.povLoader.delegate = self;
	[self.povLoader loadMorePOVs: NUM_POVS_IN_SECTION];
}

#pragma mark - Table View Delegate methods (view customization) -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return STORY_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.refreshInProgress) { return; }
	if(self.povPublishing && indexPath.row == 0) { return; }
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
		[cell setContentWithUsername:@"User Name" andTitle: povInfo.title andCoverImage: povInfo.coverPhoto];
		cell.indexPath = indexPath;
		cell.delegate = self;
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark - Feed Table View Cell Delegate methods -

-(void) successfullyPinchedTogetherCell: (FeedTableViewCell *)cell {
	[self viewPOVOnCell: cell];
}

#pragma mark - Viewing POV -

//one of the POV's in the list has been clicked
-(void) viewPOVOnCell: (FeedTableViewCell*) cell {
	NSLog(@"Viewing POV \"%@\"", cell.title);
	[self.delegate displayPOVOnCell:cell withLoadManager: self.povLoader];
}

#pragma mark - Show POV publishing -
//Called on it by parent view controller to let it know that a user
// has published a POV and to show the loading animation until the POV
// has actually published
-(void) showPOVPublishingWithTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {
	self.povPublishing = YES;
	self.povPublishingPlaceholderCell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID_PUBLISHING];
	[self.povPublishingPlaceholderCell setLoadingContentWithUsername:@"User Name" andTitle: title andCoverImage:coverPic];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.povListView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

// Method called from Notification sent by the model to let it know that
// a pov has published so that it can refresh the feed
-(void) povPublished {
    [self refreshFeed];
}

#pragma mark - Refresh feed -
// Tells pov loader to reload POV's completely (removing all those previously loaded and getting the first page again)
-(void) refreshFeed {
	[self.povLoader reloadPOVs: NUM_POVS_IN_SECTION];
}

//Delagate method from povLoader informing us the the list has been refreshed. So the content length is the same
-(void) povsRefreshed {
    if(self.povPublishing){
        self.povPublishing = NO;
		[self.povPublishingPlaceholderCell stopActivityIndicator];
        self.povPublishingPlaceholderCell = nil;
    }
    [self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    if(self.refreshControl.isRefreshing)[self.refreshControl endRefreshing];
}

//Delegate method from the povLoader, letting this list know more POV's have loaded so that it can refresh
-(void) morePOVsLoaded {
    if(self.loadingPOVs)self.loadingPOVs = NO;
	[self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Pull to refresh Feed Animation -
-(void)setRefreshAnimator{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.povListView addSubview:self.refreshControl];
}

-(void)refresh:(UIRefreshControl *)refreshControl {
    if(self.povPublishing){
        [refreshControl endRefreshing];
    }else{
        [self refreshFeed];
    }
}



#pragma mark - Infinite Scroll -
//when the user is at the bottom of the screen and is pulling up more articles load
-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //when the user has reached the very bottom of the feed and pulls we load more articles into the feed
    if (scrollView.contentOffset.y +scrollView.frame.size.height + RELOAD_THRESHOLD > scrollView.contentSize.height) {
        if(!self.loadingPOVs){
            self.loadingPOVs = YES;
            [self.povLoader loadMorePOVs: NUM_POVS_IN_SECTION];
        }
    }
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
		_povListView = [[FeedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	}
	return _povListView;
}


@end
