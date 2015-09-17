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
#import "Identifiers.h"
#import "UIEffects.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Strings.h"
#import "VerbatmCameraView.h"
#import "MediaSessionManager.h"
#import "MasterNavigationVC.h"
#import "FeedTableViewCell.h"
#import "FeedTableView.h"
#import "RefreshTableViewCell.h"

#import "POVLoadManager.h"
#import "PovInfo.h"

@interface ArticleListVC () <UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate, POVLoadManagerDelegate>


#pragma mark - Table View + data -

@property (strong, nonatomic) FeedTableView *povListView;
@property (strong, nonatomic) POVLoadManager *povLoader;

#pragma mark - Publishing POV -

@property (strong, nonatomic) FeedTableViewCell* povPublishingPlaceholderCell;
@property (nonatomic) BOOL povPublishing;

#pragma mark - Refresh -

//this cell is inserted in the top of the listview when pull down to refresh
@property (strong,nonatomic) RefreshTableViewCell * placeholderCell;
@property (atomic) BOOL pullDownInProgress;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
//tells you whether or not we have started a timer to animate
@property (atomic) BOOL refreshInProgress;


#define FEED_CELL_ID @"feed_cell_id"
#define NUM_POVS_IN_SECTION 6
#define RELOAD_THRESHOLD 15
#define NUM_OF_NEW_POVS_TO_LOAD 15
#define PULL_TO_REFRESH_THRESHOLD (-1 * STORY_CELL_HEIGHT)
@end

@implementation ArticleListVC

- (void) viewDidLoad {
	[super viewDidLoad];
	[self initStoryListView];
	[self registerForNotifications];
}

-(void) registerForNotifications {
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(povPublished)
												 name:NOTIFICATION_POV_PUBLISHED
											   object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void) initStoryListView {
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
	[self viewPOVAtIndex: indexPath.row];
}

//one of the POV's in the list has been clicked
-(void) viewPOVAtIndex: (NSInteger) index {
	PovInfo* povInfo = [self.povLoader getPOVInfoAtIndex: index];
	NSLog(@"Viewing pov %@ ", povInfo.title);
	[self.delegate displayPOVWithIndex: index fromLoadManager: self.povLoader];
}

#pragma mark - Table View Data Source methods (model) -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [self.povLoader getNumberOfPOVsLoaded];
	count += (self.pullDownInProgress) ? 1 : 0;
    count += (self.self.povPublishing) ? 1:0;
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger index = indexPath.row;
	if (self.refreshInProgress && index == 0) {
		return self.placeholderCell;
	}

	FeedTableViewCell *cell;

	//configure cell
	if (self.povPublishing && (index == 0 ||
							   (self.refreshInProgress && index == 1))) {
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

-(void) successfullyPinchedTogetherAtIndexPath:(NSIndexPath *)indexPath {
	[self tableView: self.povListView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Show POV publishing -

//Called on it by parent view controller to let it know that a user
// has published a POV and to show the loading animation until the POV
// has actually published
-(void) showPOVPublishingWithTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {
	self.povPublishing = YES;
	self.povPublishingPlaceholderCell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID];
	[self.povPublishingPlaceholderCell setLoadingContentWithUsername:@"User Name" andTitle: title andCoverImage:coverPic];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.povListView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

// Method called from Notification sent by the model to let it know that
// a pov has published so that it can refresh the feed
-(void) povPublished {
	if (self.povPublishing) {
		[self refreshFeed];
		NSLog(@"Pov published successfully!");
	}
}

#pragma mark - Refresh feed -

// Tells pov loader to reload POV's completely (removing all those previously loaded and getting the first page again)
-(void) refreshFeed {
	[self.povLoader reloadPOVs: NUM_POVS_IN_SECTION];
}

//Delegate method from the povLoader, letting this list know more POV's have loaded so that it can refresh
-(void) morePOVsLoaded {
	if (self.povPublishing) {
		self.povPublishingPlaceholderCell = nil;
		self.povPublishing = NO;
        [self.povListView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Pull to refresh Feed Animation -

//when the user starts pulling down the article list we should insert the placeholder with the animating view
-(void) scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView {
	NSLog(@"Begin dragging");
	self.pullDownInProgress = scrollView.contentOffset.y <= PULL_TO_REFRESH_THRESHOLD;
	if (self.pullDownInProgress) {
         [self refreshFeed];
		[self.povListView insertSubview:self.placeholderCell atIndex:0];
        [NSTimer timerWithTimeInterval:2
                                target:self
                              selector:@selector(refreshFeed)
                              userInfo:nil
                               repeats:NO];
        
	}
}

-(RefreshTableViewCell *)placeholderCell{
    if(!_placeholderCell) _placeholderCell = [[RefreshTableViewCell alloc] init];
	_placeholderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return _placeholderCell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    /*Pulls down past point to refresh*/
//	float offset_y =scrollView.contentOffset.y ;
//	if (offset_y <=  (-1 * STORY_CELL_HEIGHT)) {
//    }
}

//sets the frame of the placeholder cell and also adjusts the frame of the placeholder cell
-(void)createRefreshAnimationOnScrollview:(UIScrollView *)scrollView {
	//maintain location of placeholder
	float heightToUse = (fabs(scrollView.contentOffset.y) < STORY_CELL_HEIGHT && self.pullDownInProgress) ? fabs(scrollView.contentOffset.y) : STORY_CELL_HEIGHT;
	float y_cord = (self.pullDownInProgress) ? scrollView.contentOffset.y : 0;
	self.placeholderCell.frame = CGRectMake(0,y_cord ,self.povListView.frame.size.width, heightToUse);
	
}


-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //when the user has reached the very bottom of the feed and pulls we load more articles into the feed
    if (scrollView.contentOffset.y +scrollView.frame.size.height + RELOAD_THRESHOLD > scrollView.contentSize.height) {
        [self.povLoader loadMorePOVs:NUM_OF_NEW_POVS_TO_LOAD];
    }
}

-(void)addFinalAnimationTile{
	if(!self.refreshInProgress){
		self.refreshInProgress = YES;
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.povListView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
	}
}

-(void)removeAnimatingView{
	[UIView animateWithDuration:0.5 animations:^{
		self.povListView.contentOffset = CGPointMake(0, STORY_CELL_HEIGHT);
		self.placeholderCell.frame = CGRectMake(self.placeholderCell.frame.origin.x, (-1 * STORY_CELL_HEIGHT),
												self.placeholderCell.frame.size.width,
												self.placeholderCell.frame.size.height);
	}completion:^(BOOL finished) {
		[self.placeholderCell removeFromSuperview];
		self.refreshInProgress = NO;
		self.povListView.contentOffset = CGPointMake(0,0);
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.povListView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		//[self stopActivityIndicator];
		[self.povListView reloadSectionIndexTitles];
	}];
}


#pragma mark - Miscellaneous -
- (NSUInteger) supportedInterfaceOrientations {
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
