//
//  verbatmAtilcleList_TableViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmAtilcleList_TableViewController.h"
#import "verbatmArticle_TableViewCell.h"
#import "verbatmArticleAquirer.h"
#import "Article.h"
#import "Page.h"
#import "v_Analyzer.h"
#import "articleDispalyViewController.h"
@interface verbatmAtilcleList_TableViewController ()
@property (strong, nonatomic) NSArray * articles;
@property  (nonatomic) NSInteger selectedArticleIndex;
@end

@implementation verbatmAtilcleList_TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.articles = [verbatmArticleAquirer downloadAllArticles];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

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
    verbatmArticle_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleView" forIndexPath:indexPath];
    
    NSInteger index =indexPath.row;
    Article * article = self.articles[index];
    
    if(index % 3 == 0) cell.backgroundColor = [UIColor purpleColor];
    else if(index % 2==0)cell.backgroundColor = [UIColor yellowColor];
    else cell.backgroundColor = [UIColor greenColor];
    
    cell.sandwich.text = article.sandwich;
    cell.author.text = [article getAuthor];
    cell.articleTitle.text = article.title;
    return cell;
}


-(void) viewArticle
{
    //make sure there is at least one pinch object available
     [self performSegueWithIdentifier:@"viewArticleSegue" sender:self];
}

//we know the only segue here is the viewarticlesegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController * vc = [segue destinationViewController];
    
    NSArray * pages = [self.articles[self.selectedArticleIndex] getAllPages];
    
    NSMutableArray * pincObjetsArray = [[NSMutableArray alloc]init];
    
    //get pinch views for our array
    for (Page * page in pages)
    {
        
        //here the radius and the center dont matter because this is just a way to wrap our data for the analyser
        verbatmCustomPinchView * pv = [page getPinchObjectWithRadius:0 andCenter:CGPointMake(0, 0)];
        [pincObjetsArray addObject:pv];
    }
    
    v_Analyzer * analyser = [[v_Analyzer alloc]init];
    NSMutableArray * presenterViews = [analyser processPinchedObjectsFromArray:pincObjetsArray withFrame:self.view.frame];
    ((articleDispalyViewController *)vc).pinchedObjects = presenterViews;
}
#pragma mark Orientation
- (NSUInteger)supportedInterfaceOrientations
{
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
