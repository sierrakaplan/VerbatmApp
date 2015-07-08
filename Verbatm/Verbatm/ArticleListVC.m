//
//  verbatmArticleListControlerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleListVC.h"
#import "MasterNavigationVC.h"
#import "verbatmArticle_TableViewCell.h"
#import "verbatmArticleAquirer.h"
#import "Article.h"
#import "Page.h"
#import "Analyzer.h"
#define VIEW_ARTICLE_SEGUE @"viewArticleSegue"
#define NOTIFICATION_SHOW_ADK @"notification_showADK"
#define NOTIFICATION_SHOW_ARTICLE @"notification_showArticle"

#define BUTTON_HEIGHT 50
#define TOP_OFFSET 30
#define TITLE_LIST_OFFSET 30

@interface ArticleListVC ()<UITableViewDataSource, UITableViewDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *articleListView;
    @property (strong, nonatomic) NSArray * articles;
    @property (weak, nonatomic) IBOutlet UIButton *createArticle_button;
    @property (weak, nonatomic) IBOutlet UIButton *refreshArticle_button;
    @property (weak, nonatomic) IBOutlet UILabel *listTitle;
    @property  (nonatomic) NSInteger selectedArticleIndex;
@end

@implementation ArticleListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.articleListView.dataSource = self;
    self.articleListView.delegate = self;
    [self setFrames];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //we want to download the articles again and then load them to the page
    [verbatmArticleAquirer downloadAllArticlesWithBlock:^(NSArray *ourObjects) {
        self.articles = ourObjects;
        [self.articleListView reloadData];
    }];
    
}

-(void)setFrames
{
    //set button
    self.createArticle_button.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height - BUTTON_HEIGHT, self.view.frame.size.width/2, BUTTON_HEIGHT);
    self.refreshArticle_button.frame =CGRectMake(0, self.view.frame.size.height - BUTTON_HEIGHT, self.view.frame.size.width/2, BUTTON_HEIGHT);
    self.articleListView.frame = CGRectMake(0,0,self.view.frame.size.width ,self.view.frame.size.height-(BUTTON_HEIGHT));
}

//reloads data into the list view
- (IBAction)refreshArticleList:(UIButton *)sender
{
    [self refreshFeed];
}

-(void)refreshFeed
{
    //we want to download the articles again and then load them to the page
    [verbatmArticleAquirer downloadAllArticlesWithBlock:^(NSArray *ourObjects) {
        self.articles = ourObjects;
        [self.articleListView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.articles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedArticleIndex = indexPath.row;
    [self viewArticle];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    verbatmArticle_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleListCell" forIndexPath:indexPath];
    
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


#pragma mark Orientation
- (NSUInteger)supportedInterfaceOrientations
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
