//
//  FeedTableViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTableViewController.h"
#import "FeedTableCell.h"
#import "UserInfoCache.h"
#import "Channel.h"
#import "ProfileVC.h"

@interface FeedTableViewController ()<FeedCellDelegate>


@property(nonatomic) NSMutableArray * FollowingProfileList;
@property (nonatomic) Channel * currentUserChannel;
@property (nonatomic) ProfileVC * nextProfileToPresent;
@property (nonatomic) NSInteger nextProfileIndex;
@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[FeedTableCell class] forCellReuseIdentifier:@"FeedTableCell"];
    [self prepareListOfContent];
    self.tableView.pagingEnabled = YES;
    self.tableView.allowsSelection = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray * visibleCell = [self.tableView visibleCells];
    
    if(visibleCell && visibleCell.count){
        FeedTableCell * cell = [visibleCell firstObject];
        [cell reloadProfile];
    }
}

-(void)prepareListOfContent{
    self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel] ;
    
    [self.currentUserChannel getFollowersAndFollowingWithCompletionBlock:^{
        self.FollowingProfileList = [self.currentUserChannel channelsUserFollowing];
        [self.tableView reloadData];
    }];
}




-(void)creatProfile{
//    ProfileVC * userProfile = [[ProfileVC alloc] init];
//    userProfile.isCurrentUserProfile = channel.channelCreator == [PFUser currentUser];
//    userProfile.isProfileTab = NO;
//    userProfile.ownerOfProfile = channel.channelCreator;
//    userProfile.channel = channel;
}



//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
//    FeedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    [cell presentProfileForChannel:self.FollowingProfileList[indexPath.row]];
//    return cell;
//}

#pragma mark - Table View Delegate methods (view customization) -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.delegate showTabBar:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.FollowingProfileList.count = %d", self.FollowingProfileList.count);
    return self.FollowingProfileList.count;
}

-(void)prepareNextPostFromNextIndex:(NSInteger) nextIndex{
    
    if(nextIndex < self.FollowingProfileList.count){
        Channel * nextChannel = self.FollowingProfileList[nextIndex];
        if(self.nextProfileToPresent){
            @autoreleasepool {
                self.nextProfileToPresent = nil;
            }
        }
        self.nextProfileToPresent = [[ProfileVC alloc] init];
        self.nextProfileToPresent.isCurrentUserProfile = NO;
        self.nextProfileToPresent.isProfileTab = NO;
        //self.nextProfileToPresent.delegate = self;
        self.nextProfileToPresent.ownerOfProfile = nextChannel.channelCreator;
        self.nextProfileToPresent.channel = nextChannel;
        [self.nextProfileToPresent loadContentToPostList];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableCell" forIndexPath:indexPath];
    cell.delegate = self;
    if(self.nextProfileToPresent && indexPath.row == self.nextProfileIndex){
        [cell setProfileAlreadyLoaded:self.nextProfileToPresent];
    }else{
        [cell presentProfileForChannel:self.FollowingProfileList[indexPath.row]];
    }
     self.nextProfileIndex = indexPath.row + 1;
    [self prepareNextPostFromNextIndex:self.nextProfileIndex];
    return cell;
}


#pragma mark -Feed Cell Protocol-
-(void)shouldHideTabBar:(BOOL) shouldHide{
    [self.delegate showTabBar:!shouldHide];
    self.tableView.scrollEnabled = !shouldHide;
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
