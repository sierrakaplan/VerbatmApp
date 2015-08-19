//
//  verbatmArticleListControlerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleListVC.h"
#import "MasterNavigationVC.h"
#import "FeedTableViewCell.h"
#import "FeedTableView.h"
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

#define VIEW_ARTICLE_SEGUE @"viewArticleSegue"

@interface ArticleListVC ()<UITableViewDataSource, UITableViewDelegate>

    @property (strong, nonatomic) FeedTableView *storyListView;
	@property (strong,nonatomic) FeedTableViewCell* placeholderCell;
    @property (strong, nonatomic) NSArray * articles;
    @property (strong, nonatomic) UIButton *composeStoryButton;
    @property (weak, nonatomic) IBOutlet UILabel *listTitle;
    @property  (nonatomic) NSInteger selectedArticleIndex;
	@property BOOL pullDownInProgress;

    #define SHC_ROW_HEIGHT 20.f
@end

@implementation ArticleListVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self addBlurView];
	[self initStoryListView];
	[self addComposeStoryButton];
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

-(void) scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView {
	NSLog(@"Begin dragging");
	self.pullDownInProgress = scrollView.contentOffset.y <= 0.0f;
	if (self.pullDownInProgress) {
		[self.storyListView insertSubview:self.placeholderCell atIndex:0];
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.pullDownInProgress && scrollView.contentOffset.y <= 0.0f) {
		//maintain location of placeholder
		self.placeholderCell.frame = CGRectMake(0, - scrollView.contentOffset.y - SHC_ROW_HEIGHT,
											self.storyListView.frame.size.width, SHC_ROW_HEIGHT);
		//TODO: add spinning thing
		self.placeholderCell.alpha = MIN(1.0f, - scrollView.contentOffset.y / SHC_ROW_HEIGHT);
	} else {
		self.pullDownInProgress = false;
	}
}

-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (self.pullDownInProgress && - scrollView.contentOffset.y > SHC_ROW_HEIGHT) {
		[self refreshFeed];
		NSLog(@"refreshing feed from pull down");
	}
	self.pullDownInProgress = false;
	[self.placeholderCell removeFromSuperview];
}

-(void)registerForNavNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:NOTIFICATION_REFRESH_FEED object: nil];
}

-(void)refreshFeed {
    //we want to download the articles again and then load them to the page
    [ArticleAquirer downloadAllArticlesWithBlock:^(NSArray *articles) {
		NSArray *sortedArticles;
		sortedArticles = [articles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
			NSDate *first = ((Article*)a).createdAt;
			NSDate *second = ((Article*)b).createdAt;
			return [second compare:first];
		}];
		self.articles = sortedArticles;
        [self.storyListView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.articles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedArticleIndex = indexPath.row;
    [self viewArticle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TITLE_LABLE_HEIGHT +4*FEED_TEXT_GAP +USERNAME_LABLE_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_ID];
	if (cell == nil) {
		cell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FEED_CELL_ID];
	}
    
	//configure cell
    NSInteger index = indexPath.row;
    Article * article = self.articles[index];
    [cell setContentWithUsername:[article getAuthorUsername] andTitle:article.title];
    return cell;
}

- (void) composeStory: (id)sender {
    NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_SHOW_ADK object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

//one of the articles in the list have been clicked
-(void) viewArticle {
    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:self.articles[self.selectedArticleIndex], ARTICLE_KEY_FOR_NOTIFICATION, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_ARTICLE
                                                        object:nil
                                                      userInfo:Info];
}


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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
