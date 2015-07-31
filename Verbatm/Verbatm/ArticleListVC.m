//
//  verbatmArticleListControlerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleListVC.h"
#import "MasterNavigationVC.h"
#import "ArticleTableViewCell.h"
#import "ArticleAquirer.h"
#import "Article.h"
#import "Page.h"
#import "AVETypeAnalyzer.h"
#import "Notifications.h"
#import "SizesAndPositions.h"
#import "Identifiers.h"
#import "UIEffects.h"
#import "VerbatmCameraView.h"

#define VIEW_ARTICLE_SEGUE @"viewArticleSegue"

@interface ArticleListVC ()<UITableViewDataSource, UITableViewDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *articleListView;
    @property (strong, nonatomic) NSArray * articles;
	@property (strong, nonatomic) VerbatmCameraView* verbatmCameraView;
    @property (weak, nonatomic) IBOutlet UIButton *createArticle_button;
    @property (weak, nonatomic) IBOutlet UILabel *listTitle;
    @property  (nonatomic) NSInteger selectedArticleIndex;
	@property BOOL pullDownInProgress;
@end

@implementation ArticleListVC

//creates the camera view with the preview session
-(VerbatmCameraView*)verbatmCameraView
{
	if(!_verbatmCameraView){
		_verbatmCameraView = [[VerbatmCameraView alloc]initWithFrame:  self.view.frame];
	}
	return _verbatmCameraView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.articleListView.dataSource = self;
    self.articleListView.delegate = self;
    [self setFrames];
	[self addBlurView];
	[self registerForNavNotifications];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self refreshFeed];
}

-(void) addBlurView {
	[self.view insertSubview: self.verbatmCameraView atIndex:0];
	[UIEffects createBlurViewOnView:self.view withStyle:UIBlurEffectStyleDark];
}

-(void) scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView {
	NSLog(@"Begin dragging");
	self.pullDownInProgress = scrollView.contentOffset.y <= 0.0f;
	NSLog(@"%f", scrollView.contentOffset.y);
	if (self.pullDownInProgress) {
		//TODO: placeholder cell should appear
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.pullDownInProgress && scrollView.contentOffset.y <= 0.0f) {
		//TODO: maintain location of placeholder
	} else {
		self.pullDownInProgress = false;
	}
}

-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// TODO: make this the height of a new row
	if (self.pullDownInProgress) {
		[self refreshFeed];
		NSLog(@"refreshing feed from pull down");
	}
	self.pullDownInProgress = false;
	// remove placeholder cell
}

-(void)setFrames {
	self.articleListView.frame = CGRectMake(0,0,self.view.frame.size.width ,self.view.frame.size.height-(ARTICLE_IN_FEED_BUTTON_HEIGHT));
	[self.articleListView setBackgroundColor:[UIColor clearColor]];
    //set button
    self.createArticle_button.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height - ARTICLE_IN_FEED_BUTTON_HEIGHT, self.view.frame.size.width/2, ARTICLE_IN_FEED_BUTTON_HEIGHT);
}

-(void)registerForNavNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:NOTIFICATION_REFRESH_FEED object: nil];
}

//reloads data into the list view
- (IBAction)refreshArticleList:(UIButton *)sender
{
    [self refreshFeed];
}

-(void)refreshFeed
{
    //we want to download the articles again and then load them to the page
    [ArticleAquirer downloadAllArticlesWithBlock:^(NSArray *articles) {
		NSArray *sortedArticles;
		sortedArticles = [articles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
			NSDate *first = ((Article*)a).createdAt;
			NSDate *second = ((Article*)b).createdAt;
			return [second compare:first];
		}];
		self.articles = sortedArticles;
        [self.articleListView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ARTICLE_LIST_CELL forIndexPath:indexPath];
    
    NSInteger index =indexPath.row;
    Article * article = self.articles[index];
    cell.rightTitle.text = article.title;
    return cell;
}
- (IBAction)createArticle:(id)sender
{
    NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_SHOW_ADK object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

//one of the articles in the list have been clicked
-(void) viewArticle
{
    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:self.articles[self.selectedArticleIndex] ,@"article", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_ARTICLE
                                                        object:nil
                                                      userInfo:Info];
}


- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden
{
    return YES;
}



-(void) removeStatusBar
{
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
