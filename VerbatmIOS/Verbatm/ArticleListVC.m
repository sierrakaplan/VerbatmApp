//
//  verbatmArticleListControlerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleListVC.h"
#import "articleLoadAndDisplayManager.h"
#import "ArticleAquirer.h"
#import "Article.h"
#import "Page.h"
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

#define VIEW_ARTICLE_SEGUE @"viewArticleSegue"

@interface ArticleListVC ()<UITableViewDataSource, UITableViewDelegate>
    @property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
    @property (strong, nonatomic) UIButton *composeStoryButton;
    @property (nonatomic) BOOL cellSet;
    //we maintain the cell height so that we can set the height of the placeholderCell
    @property (nonatomic) CGFloat cellHeight;
    @property (weak, nonatomic) IBOutlet UILabel *listTitle;
    @property (strong, nonatomic) FeedTableView *storyListView;
    //this cell is inserted in the top of the listview
	@property (strong,nonatomic) FeedTableViewCell* placeholderCell;
    @property BOOL pullDownInProgress;
    //tells you wether or not we have started a timer to animate
    @property (atomic) BOOL refreshInProgress;
    @property  (nonatomic) NSInteger selectedArticleIndex;
    @property (strong, nonatomic) articleLoadAndDisplayManager * articleLoadManger;
    #define SHC_ROW_HEIGHT 20.f
@end

@implementation ArticleListVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self addBlurView];
	[self initStoryListView];
	//[self addComposeStoryButton];
	[self registerForNavNotifications];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self refreshFeed];
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

-(void) initStoryListView {
	self.storyListView = [[FeedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[self.storyListView setBackgroundColor:[UIColor clearColor]];
    self.storyListView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.storyListView.dataSource = self;
	self.storyListView.delegate = self;
	self.placeholderCell = [[FeedTableViewCell alloc] init];
	[self.view addSubview:self.storyListView];
}

-(void) addBlurView {
//	[self.view insertSubview: self.verbatmCameraView atIndex:0];
	UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	UIImage* backgroundImage = [UIImage imageNamed:@"placeholder_background_image"];
	backgroundImageView.image = backgroundImage;
    backgroundImageView.clipsToBounds = YES;
	[backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
	[self.view insertSubview:backgroundImageView atIndex:0];

	UIView* blurView = [[UIView alloc] initWithFrame:self.view.bounds];
	[UIEffects createBlurViewOnView:blurView withStyle:UIBlurEffectStyleDark];
	[self.view addSubview:blurView];
}

-(void) addComposeStoryButton {
	UIColor* buttonColor = [UIColor colorWithWhite:1 alpha:0.6];
	self.composeStoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect composeStoryButtonFrame = CGRectMake(self.view.bounds.size.width - COMPOSE_STORY_BUTTON_SIZE - COMPOSE_STORY_BUTTON_OFFSET,
												self.view.bounds.size.height - COMPOSE_STORY_BUTTON_SIZE - COMPOSE_STORY_BUTTON_OFFSET,
												COMPOSE_STORY_BUTTON_SIZE, COMPOSE_STORY_BUTTON_SIZE);
	[self.composeStoryButton setFrame: composeStoryButtonFrame];
	self.composeStoryButton.backgroundColor = buttonColor;
	self.composeStoryButton.layer.cornerRadius = COMPOSE_STORY_BUTTON_SIZE/2.f;

	//set attributed title
	UIColor *labelColor = [UIColor COMPOSE_STORY_BUTTON_LABEL_COLOR];
	UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:COMPOSE_STORY_BUTTON_LABEL_FONT_SIZE];
	[self.composeStoryButton setTitle:COMPOSE_STORY_BUTTON_LABEL forState:UIControlStateNormal];
	[self.composeStoryButton setTitleColor:labelColor forState:UIControlStateNormal];

	self.composeStoryButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.composeStoryButton.titleLabel.numberOfLines = 2;
	self.composeStoryButton.titleLabel.textColor = labelColor;
	self.composeStoryButton.titleLabel.font = labelFont;

	[self.composeStoryButton addTarget:self action:@selector(composeStory:) forControlEvents:UIControlEventTouchUpInside];

	float originDiff = (COMPOSE_STORY_OUTER_CIRCLE_SIZE - COMPOSE_STORY_BUTTON_SIZE)/2.f;
	CGRect outerCircleViewFrame = CGRectMake(composeStoryButtonFrame.origin.x - originDiff, composeStoryButtonFrame.origin.y - originDiff, COMPOSE_STORY_OUTER_CIRCLE_SIZE, COMPOSE_STORY_OUTER_CIRCLE_SIZE);
	UIView* outerCircleView = [[UIView alloc] initWithFrame:outerCircleViewFrame];
	outerCircleView.backgroundColor = [UIColor clearColor];
	outerCircleView.layer.cornerRadius = COMPOSE_STORY_OUTER_CIRCLE_SIZE/2.f;
	outerCircleView.layer.borderColor = [UIColor whiteColor].CGColor;
	outerCircleView.layer.borderWidth = COMPOSE_STORY_OUTER_CIRCLE_BORDER_WIDTH;

	[self.view addSubview: outerCircleView];
	[self.view addSubview:self.composeStoryButton];
}


-(void)registerForNavNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:NOTIFICATION_REFRESH_FEED object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLoadManger:) name:NOTIFICATION_PROPOGATE_ARTICLELOAGMANAGER object: nil];
}


-(void)setLoadManger:(NSNotification *)notification{
    NSDictionary * dict = [notification userInfo];
    id am = [dict get];
    self.articleLoadManger =
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedArticleIndex = indexPath.row;
    [self viewArticle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(!self.cellHeight)self.cellHeight =TITLE_LABLE_HEIGHT +4*FEED_TEXT_GAP +USERNAME_LABLE_HEIGHT;
//    return self.cellHeight;
    return 100;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_ID];
	if (cell == nil) {
		cell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID];
	}
    NSInteger index = indexPath.row;
    if(!self.pullDownInProgress){
        //configure cell
        Article * article = self.articleLoadManger.articleList[index];
        [cell setContentWithUsername:[article getAuthorUsername] andTitle:article.title];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if(self.refreshInProgress && index ==0){
        //this means that the cell is an animation place-holder
        [cell setContentWithUsername:@"" andTitle:@""];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

//compose story button has been clicked - sending this to the master navigator
- (void) composeStory: (id)sender {
    NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_SHOW_ADK object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

//one of the articles in the list have been clicked
-(void) viewArticle {
    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:self.articleLoadManger.articleList[self.selectedArticleIndex], ARTICLE_KEY_FOR_NOTIFICATION, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_ARTICLE
                                                        object:nil
                                                      userInfo:Info];
}



#pragma mark - Refresh Feed Animation -

//when the user starts pulling down the article list we should insert the placeholder with the animating view
-(void) scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView {
    NSLog(@"Begin dragging");
    self.pullDownInProgress = scrollView.contentOffset.y <= 0.0f;
    if (self.pullDownInProgress) {
        [self.storyListView insertSubview:self.placeholderCell atIndex:0];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float offset_y =scrollView.contentOffset.y ;
    if (offset_y <=  (-1 * self.cellHeight)) {
        [self createRefreshAnimationOnScrollview:scrollView];
    }
}

//sets the frame of the placeholder cell and also adjusts the frame of the placeholder cell
-(void)createRefreshAnimationOnScrollview:(UIScrollView *)scrollView {
    //maintain location of placeholder
    float heightToUse = (fabs(scrollView.contentOffset.y)< self.cellHeight && self.pullDownInProgress) ? fabs(scrollView.contentOffset.y) : self.cellHeight;
    float y_cord = (self.pullDownInProgress) ? scrollView.contentOffset.y : 0;
    self.placeholderCell.frame = CGRectMake(0,y_cord ,self.storyListView.frame.size.width, heightToUse);
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
    
}

-(void)loadContentIntoView{
    if(self.refreshInProgress)[self removeAnimatingView];
    //if the refresh is in progress we call this in removeAnimatingView
    if(!self.refreshInProgress)[self.storyListView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger count = self.articleLoadManger.articleList.count;
    count += (self.pullDownInProgress) ? 1 : 0;
    return count;
}


-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    float offset_y =scrollView.contentOffset.y ;
    if (self.pullDownInProgress &&  offset_y <=  (-1 * self.cellHeight)) {
        [self addFinalAnimationTile];
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
        [self.storyListView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self refreshFeed];
    }
}

-(void)removeAnimatingView{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.storyListView.contentOffset = CGPointMake(0,self.cellHeight);
        self.placeholderCell.frame = CGRectMake(self.placeholderCell.frame.origin.x, (-1 * self.cellHeight), self.placeholderCell.frame.size.width, self.placeholderCell.frame.size.height);
    }completion:^(BOOL finished) {
        [self.placeholderCell removeFromSuperview];
        self.refreshInProgress = NO;
        self.storyListView.contentOffset = CGPointMake(0,0);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.storyListView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self stopActivityIndicator];
        [self.storyListView reloadSectionIndexTitles];
    }];
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

//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void) removeStatusBar{
    //remove the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}



@end
