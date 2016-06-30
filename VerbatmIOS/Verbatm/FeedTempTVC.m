//
//  FeedTempTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 6/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTempTVC.h"
#import "UserInfoCache.h"
#import "Channel.h"
#import "ProfileVC.h"
#import "FeedTableViewCell.h"


@interface FeedTempTVC ()
@property(nonatomic) NSMutableArray * FollowingProfileList;
@property (nonatomic) Channel * currentUserChannel;
@property (nonatomic) ProfileVC * nextProfileToPresent;
@property (nonatomic) NSInteger nextProfileIndex;

#define FEEDCELL_REUSE_IDENTIFIER @"FeedTableCell"
@end

@implementation FeedTempTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[FeedTableViewCell class] forCellReuseIdentifier:FEEDCELL_REUSE_IDENTIFIER];
    [self prepareListOfContent];
    self.tableView.pagingEnabled = YES;
    self.tableView.allowsSelection = NO;
    
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//get list of channels the profile is following
-(void)prepareListOfContent{
    self.currentUserChannel = [[UserInfoCache sharedInstance] getUserChannel] ;
    
    [self.currentUserChannel getFollowersAndFollowingWithCompletionBlock:^{
        self.FollowingProfileList = [self.currentUserChannel channelsUserFollowing];
        [self.tableView reloadData];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentUserChannel.channelsUserFollowing.count;
}

#pragma mark - Table View Delegate methods (view customization) -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height;
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
        self.nextProfileToPresent.profileInFeed = YES;
        self.nextProfileToPresent.isCurrentUserProfile = NO;
        self.nextProfileToPresent.isProfileTab = NO;
        self.nextProfileToPresent.ownerOfProfile = nextChannel.channelCreator;
        self.nextProfileToPresent.channel = nextChannel;
        [self.nextProfileToPresent loadContentToPostList];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEEDCELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.delegate = self;
    if(self.nextProfileToPresent && indexPath.row == self.nextProfileIndex){
        [cell setProfileAlreadyLoaded:self.nextProfileToPresent];
    }else{
        [cell presentProfileForChannel:self.FollowingProfileList[indexPath.row]];
    }
    self.nextProfileIndex = indexPath.row + 1;
    [self prepareNextPostFromNextIndex:self.nextProfileIndex];
    return cell;}


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
