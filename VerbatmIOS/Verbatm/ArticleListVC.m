//
//  verbatmArticleListControlerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleListVC.h"
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

#import "POVLoadManager.h"
#import "GTLVerbatmAppPOVInfo.h"

@interface ArticleListVC () <UITableViewDelegate, UITableViewDataSource, POVLoadManagerDelegate>


#pragma mark - Table View + data -

@property (strong, nonatomic) FeedTableView *povListView;
@property (strong, nonatomic) POVLoadManager *povLoader;

#pragma mark - Refresh -

//this cell is inserted in the top of the listview
@property (strong,nonatomic) FeedTableViewCell* placeholderCell;
@property (atomic) BOOL pullDownInProgress;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
//tells you whether or not we have started a timer to animate
@property (atomic) BOOL refreshInProgress;


#define FEED_CELL_ID @"feed_cell_id"
#define NUM_POVS_IN_SECTION 6

@end

@implementation ArticleListVC

- (void) viewDidLoad {
    [super viewDidLoad];
	[self initStoryListView];
	[self registerForNotifications];
}

-(void) registerForNotifications {
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

-(void) setPovLoadManager:(POVLoadManager *) povLoader {
	self.povLoader = povLoader;
	self.povLoader.delegate = self;
	[self.povLoader loadPOVs: NUM_POVS_IN_SECTION];
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
	// TODO: enter POV viewing list
}

#pragma mark - Table View Data Source methods (model) -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [self.povLoader getNumberOfPOVsLoaded];
	count += (self.pullDownInProgress) ? 1 : 0;
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_ID];
    if (cell == nil) {
		cell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID];
	}

	NSInteger index = indexPath.row;

	//configure cell
	if (self.refreshInProgress && index ==0 ){
		//TODO: animation placeholder
	} else {
		GTLVerbatmAppPOVInfo* povInfo = [self.povLoader getPOVInfoAtIndex: index];
		//TODO: set way to get username and cover image from povLoader
		[cell setContentWithUsername:@"User Name" andTitle: povInfo.title andCoverImage:[UIImage imageNamed:@"demo_image"]];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //}
    return cell;
}

#pragma mark - Refresh Feed Animation -

//when the user starts pulling down the article list we should insert the placeholder with the animating view
-(void) scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView {
    NSLog(@"Begin dragging");
    self.pullDownInProgress = scrollView.contentOffset.y <= 0.0f;
    if (self.pullDownInProgress) {
        [self.povListView insertSubview:self.placeholderCell atIndex:0];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float offset_y =scrollView.contentOffset.y ;
    if (offset_y <=  (-1 * STORY_CELL_HEIGHT)) {
        [self createRefreshAnimationOnScrollview:scrollView];
    }
}

//sets the frame of the placeholder cell and also adjusts the frame of the placeholder cell
-(void)createRefreshAnimationOnScrollview:(UIScrollView *)scrollView {
    //maintain location of placeholder
    float heightToUse = (fabs(scrollView.contentOffset.y) < STORY_CELL_HEIGHT && self.pullDownInProgress) ? fabs(scrollView.contentOffset.y) : STORY_CELL_HEIGHT;
    float y_cord = (self.pullDownInProgress) ? scrollView.contentOffset.y : 0;
    self.placeholderCell.frame = CGRectMake(0,y_cord ,self.povListView.frame.size.width, heightToUse);
    [self startActivityIndicator];
}

//creates an activity indicator on our placeholder view
//shifts the frame of the indicator if it's on the screen
-(void)startActivityIndicator {
    //add animation indicator here
    //Create and add the Activity Indicator to splashView
    if(!self.activityIndicator.isAnimating){
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.alpha = 1.0;
        self.activityIndicator.hidesWhenStopped = YES;
        [self.placeholderCell addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }
    self.activityIndicator.center = CGPointMake(self.placeholderCell.frame.size.width/2, self.placeholderCell.frame.size.height/2);
}

-(void)stopActivityIndicator {
    if(!self.activityIndicator.isAnimating) return;
    [self.activityIndicator stopAnimating];
}


-(void)refreshFeed {
	[self loadContentIntoView];
}

-(void) morePOVsLoaded {
	[self loadContentIntoView];
}

-(void)loadContentIntoView{
    if(self.refreshInProgress) {
		[self removeAnimatingView];
	}
	[self.povListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    float offset_y =scrollView.contentOffset.y ;
    if (self.pullDownInProgress &&  offset_y <=  (-1 * STORY_CELL_HEIGHT)) {
        // [self addFinalAnimationTile];
    }
    
    
    //    if (self.pullDownInProgress && - scrollView.contentOffset.y > SHC_ROW_HEIGHT) {
    //        [self addFinalAnimationTile];
    //    }
    //they are no longer pulling this down
    self.pullDownInProgress = false;
}

-(void)addFinalAnimationTile{
    
    if(!self.refreshInProgress){
        self.refreshInProgress = YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.povListView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self refreshFeed];
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
        [self stopActivityIndicator];
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
