//
//  UserAndChannelListsTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "ChannelOrUsernameCV.h"

#import "SizesAndPositions.h"

#import "UserAndChannelListsTVC.h"

@interface UserAndChannelListsTVC ()
@property (nonatomic) NSMutableArray * channelsToDisplay;

@property (nonatomic) NSMutableArray * usersToDisplay;//catch all array -- can be used for any of the usecases to store a list of users

@property (nonatomic) BOOL shouldDisplayFollowers;

@property (nonatomic) id postInformationToPresent;
@property (nonatomic) BOOL isLikeInformation;//if it is set at no then  it's share information

@property (nonatomic) id userInfoOnDisplay;//the user whose data we are displaying

#define CHANNEL_CELL_ID @"channel_cell_id"
@end


@implementation UserAndChannelListsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate methods (view customization) -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return THREAD_SCROLLVIEW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - Public methods to set -
//show which users like this post
-(void) presentUserLikeInformationForPost:(id) post {
    self.postInformationToPresent = post;
    self.isLikeInformation = YES;
    //download list of users that like this post -- then reload the list
}

//show which uses shared this post
-(void) presentUserShareInformationForPost:(id) post {
    self.postInformationToPresent = post;
    self.isLikeInformation = NO;
    //load a list of users that have shared this post then reload the list
}


//show which users are being followed by userId
-(void)showWhoIsFollowedBy:(id)userId {
    
    //TO-DO
    //Start to download a list of users who follow this particular user then reload the table
    
}

//presents every channel in verbatm
-(void)showAllVerbatmChannels{
    ///temp
    self.usersToDisplay = [[NSMutableArray alloc] init];
    for(int i = 0; i < 20 ; i ++){
        [self.usersToDisplay addObject:@"Iain Usiri"];
    }

}



//Gives us the channels to display and if we should show the users that follow them then
-(void)displayChannelsForUser:(id) userId shouldDisplayFollowers:(BOOL) displayFollowers {
    self.userInfoOnDisplay = userId;
    self.shouldDisplayFollowers = displayFollowers;
    
    //TO-DO
    //if(user == current logged in usere){
    //get logged in user channels and save them in our array
    
    //}else{ // download that users information then reload the page
    //}
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.channelsToDisplay){ //if we have multiple channels to display then we need to break it up into sections
        return self.channelsToDisplay.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.channelsToDisplay){
        Channel * currChannel = self.channelsToDisplay[section];
        return [currChannel.numberOfFollowers integerValue];
    }
    return self.usersToDisplay.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChannelOrUsernameCV *cell = [tableView dequeueReusableCellWithIdentifier:CHANNEL_CELL_ID];
    
    if(!cell) {
        cell = [[ChannelOrUsernameCV alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHANNEL_CELL_ID isChannel:YES isAChannelThatIFollow:NO];
    }
    
    [cell setCellTextTitle:@"Iain Usiri"];
    return cell;

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
