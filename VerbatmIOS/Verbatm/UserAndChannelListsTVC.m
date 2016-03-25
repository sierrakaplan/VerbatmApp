//
//  UserAndChannelListsTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChannelOrUsernameCV.h"
#import "CustomNavigationBar.h"

#import "Channel_BackendObject.h"

#import "ProfileVC.h"
#import "ParseBackendKeys.h"

#import "PostCollectionViewCell.h"

#import "Styles.h"
#import "SizesAndPositions.h"

#import "UserAndChannelListsTVC.h"

#import "QuartzCore/QuartzCore.h"

@interface UserAndChannelListsTVC ()<CustomNavigationBarDelegate>

@property (nonatomic) CustomNavigationBar * navBar;

@property (nonatomic) NSMutableArray * channelsToDisplay;

@property (nonatomic) NSMutableArray * usersToDisplay;//catch all array -- can be used for any of the usecases to store a list of users

@property (nonatomic) BOOL shouldDisplayFollowers;

@property (nonatomic) id postInformationToPresent;
@property (nonatomic) BOOL isLikeInformation;//if it is set at no then  it's share information

@property (nonatomic) id userInfoOnDisplay;//the user whose data we are displaying

@property (nonatomic) BOOL presentAllChannels;

#define CHANNEL_CELL_ID @"channel_cell_id"
@end


@implementation UserAndChannelListsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setTableViewHeader];
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self addRefreshFeature];
}


-(void)addRefreshFeature{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self presentAllVerbatmChannels];
     });
    
    [refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate methods (view customization) -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CHANNEL_USER_LIST_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.channelsToDisplay){
        //this is some list of channels
        
        NSInteger objectIndex = indexPath.row - self.presentAllChannels;
        
        Channel * channel = [self.channelsToDisplay objectAtIndex:objectIndex];
        PFUser * user = [channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
        [user fetchIfNeededInBackgroundWithBlock:^
         (PFObject * _Nullable object, NSError * _Nullable error) {
             if(object){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self presentProfileForUser:(PFUser *)object withStartChannel:channel];
                });
             }
        }];
    }else {
    }
}



-(void)presentProfileForUser:(PFUser *) user
            withStartChannel:(Channel *) startChannel{
    
    ProfileVC *  userProfile = [[ProfileVC alloc] init];
    userProfile.isCurrentUserProfile = NO;
    userProfile.userOfProfile = user;
    userProfile.startChannel = startChannel;
    
    [self presentViewController:userProfile animated:YES completion:^{
    }];
    
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
    //todo: load a list of users that have shared this post then reload the list
}


//show which users are being followed by userId
-(void)presentWhoIsFollowedBy:(id)userId {
	//todo:
    //Start to download a list of users who follow this particular user then reload the table
}

//presents every channel in verbatm
-(void)presentAllVerbatmChannels{
    self.presentAllChannels = YES;
    
    [Channel_BackendObject getAllChannelsButNoneForUser:[PFUser currentUser] withCompletionBlock:^
     (NSMutableArray * channels) {
         if(self.channelsToDisplay.count)[self.channelsToDisplay removeAllObjects];
         [self.channelsToDisplay addObjectsFromArray:channels];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }];
}

//Gives us the channels to display and if we should show the users that follow them then
-(void)presentChannelsForUser:(id) userId shouldDisplayFollowers:(BOOL) displayFollowers {
    self.userInfoOnDisplay = userId;
    self.shouldDisplayFollowers = displayFollowers;
    //TO-DO
    //if(user == current logged in usere){
    //get logged in user channels and save them in our array
    
    //}else{ // download that users information then reload the page
    //}
}


-(void)setTableViewHeader{
    if(self.presentAllChannels){
        
    }else {
        //temporary list view and should be removable
        CGRect navBarFrame = CGRectMake(0, 0, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT);
        self.navBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:ADK_NAV_BAR_COLOR];
        [self.navBar createLeftButtonWithTitle:@"CLOSE" orImage:nil];
        self.navBar.delegate = self;
        //it can be a navigation bar that lets us go back
        [self.view addSubview:self.navBar];
        [self.view bringSubviewToFront:self.navBar];
    }
}

//user wants to exit
-(void) leftButtonPressed{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        //nothing to execute
    }];
}

-(UILabel *) getHeaderTitleForViewWithText:(NSString *) text{
    
    CGRect labelFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width + 10, USER_CELL_VIEW_HEIGHT);
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    titleLabel.backgroundColor = [UIColor whiteColor];
 
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
                                                [UIColor blackColor],
                                            NSFontAttributeName:
                                                [UIFont fontWithName:INFO_LIST_HEADER_FONT size:INFO_LIST_HEADER_FONT_SIZE],
                                            NSParagraphStyleAttributeName:paragraphStyle};

    NSAttributedString * titleAttributed = [[NSAttributedString alloc] initWithString:text attributes:informationAttribute];
    
    [titleLabel setAttributedText:titleAttributed];

    return titleLabel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.channelsToDisplay.count + self.presentAllChannels);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChannelOrUsernameCV *cell = [tableView dequeueReusableCellWithIdentifier:CHANNEL_CELL_ID];
    
    if(!cell) {
        cell = [[ChannelOrUsernameCV alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHANNEL_CELL_ID isChannel:YES isAChannelThatIFollow:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    if(self.presentAllChannels){
        if(indexPath.row == 0){
            //set this tile as the header
            [cell setHeaderTitle];
        }else if (indexPath.row > 0){
            NSInteger objectIndex = (indexPath.row -1);
            Channel *channel = [self.channelsToDisplay objectAtIndex:objectIndex];
			PFObject *creator = [[channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
            NSString *userName = [creator valueForKey:VERBATM_USER_NAME_KEY];
            [cell setChannelName:channel.name andUserName: userName];
        }
    }else{
        Channel * channel = [self.channelsToDisplay objectAtIndex:indexPath.row];
		PFObject *creator = [[channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
		NSString *userName = [creator valueForKey:VERBATM_USER_NAME_KEY];
        [cell setChannelName:channel.name andUserName: userName];
    }
    
    return cell;
}


#pragma mark - Lazy Instantiation -


-(NSMutableArray *) channelsToDisplay{
    if(!_channelsToDisplay)_channelsToDisplay = [[NSMutableArray alloc] init];
    return _channelsToDisplay;
}

@end
