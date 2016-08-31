//
//  UserAndChannelListsTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright Â© 2016 Verbatm. All rights reserved.
//


#import "ChannelOrUsernameCV.h"
#import "CustomNavigationBar.h"
#import "Channel_BackendObject.h"
#import "Commenting_BackendObject.h"
#import "CommentingKeyboardToolbar.h"
#import "Comment.h"

#import "Like_BackendManager.h"

#import "ProfileVC.h"
#import "ParseBackendKeys.h"

#import "PostCollectionViewCell.h"

#import "Icons.h"
#import "Styles.h"
#import "SizesAndPositions.h"

#import "UserAndChannelListsTVC.h"
#import "UIView+Effects.h"

#import "QuartzCore/QuartzCore.h"

#import "MasterNavigationVC.h"
#import "VerbatmNavigationController.h"

@interface UserAndChannelListsTVC () <CustomNavigationBarDelegate>

@property (nonatomic) Channel *channelOnDisplay;
@property (nonatomic) PFObject *postObject;

@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSMutableArray *channelsToDisplay;
@property (nonatomic) NSMutableArray *usersToDisplay;//catch all array -- can be used for any of the usecases to store a list of users

@property (nonatomic) BOOL shouldDisplayFollowers;

@property (nonatomic) id postInformationToPresent;
@property (nonatomic) BOOL isLikeInformation;//if it is set at no then  it's share information

@property (nonatomic) id userInfoOnDisplay;//the user whose data we are displaying

@property (nonatomic) BOOL shouldAnimateViews;


#define CHANNEL_CELL_ID @"channel_cell_id"
#define LIKERS_TEXT @"Likes"
#define FOLLOWING_TEXT @"Following"
#define FOLLOWERS_TEXT @"Followers"

@end


@implementation UserAndChannelListsTVC

@synthesize refreshControl;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	self.tableView.backgroundColor = [UIColor whiteColor];

	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.allowsMultipleSelection = NO;
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;

	[self setNeedsStatusBarAppearanceUpdate];
}

-(void) setNavigationItemTitle {
	NSString * navBarMiddleText = FOLLOWERS_TEXT;
	if(self.currentListType == LikersList){
		navBarMiddleText = LIKERS_TEXT;
	}else if (self.currentListType == FollowingList){
		navBarMiddleText = FOLLOWING_TEXT;
	}
	self.navigationItem.title = navBarMiddleText;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
	[(MasterNavigationVC*) self.tabBarController showTabBar:NO];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarBackgroundColor:[UIColor whiteColor]];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor blackColor]];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

#pragma mark - Present List -

-(void)presentList:(ListType) listType forChannel:(Channel *)channel orPost:(PFObject *)post {
	[self addRefreshFeature];
	if (![self.refreshControl isRefreshing]) {
		[self.loadMoreSpinner startAnimating];
	}
	self.currentListType = listType;
	self.channelOnDisplay = channel;
	self.postObject = post;
	[self refreshDataForListType:listType forChannel:channel orPost:post withCompletionBlock:^{
		self.shouldAnimateViews = YES;
		[self.loadMoreSpinner stopAnimating];
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	}];
	[self setNavigationItemTitle];
}

-(void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.shouldAnimateViews) {
		CGFloat direction = (YES) ? 1 : -1;
		cell.transform = CGAffineTransformMakeTranslation(0, cell.bounds.size.height * direction);
		[UIView animateWithDuration:0.4f animations:^{
			cell.transform = CGAffineTransformIdentity;
		}];

		if(cell.bounds.size.height * indexPath.row >= self.view.frame.size.height){
			self.shouldAnimateViews = NO;
		}
	}
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationSlide;
}

-(void)addRefreshFeature{
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];

	self.loadMoreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.loadMoreSpinner.hidesWhenStopped = YES;
	self.tableView.tableFooterView = self.loadMoreSpinner;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self presentList:self.currentListType forChannel:self.channelOnDisplay orPost:self.postObject];
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
	//this is some list of channels

	NSInteger objectIndex = indexPath.row;

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
}

-(void)presentProfileForUser:(PFUser *) user
			withStartChannel:(Channel *) startChannel {
	if(![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
		//todo: push segue
		ProfileVC *  userProfile = [[ProfileVC alloc] init];
		BOOL isCurrentUserChannel = [[startChannel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
		userProfile.isCurrentUserProfile = isCurrentUserChannel;
		userProfile.isProfileTab = NO;
		userProfile.ownerOfProfile = user;
		userProfile.channel = startChannel;
		[self.navigationController pushViewController:userProfile animated:YES];
	}
}

-(void) refreshDataForListType:(ListType)listType forChannel:(Channel *)channel orPost:(PFObject *)post
		   withCompletionBlock:(void(^)(void))block {
	switch (listType) {
		case LikersList: {
			[Like_BackendManager getUsersWhoLikePost:post withCompletionBlock:^(NSArray * users) {
				[Channel getChannelsForUserList:[NSMutableArray arrayWithArray: users] andCompletionBlock:^(NSMutableArray * channelList) {
					self.channelsToDisplay = channelList;
					block();
				}];
			}];
			break;
		} case FollowersList: {
			[channel getFollowersWithCompletionBlock:^{
				[Channel getChannelsForUserList:[channel usersFollowingChannel] andCompletionBlock:^(NSMutableArray * channelList) {
					self.channelsToDisplay = channelList;
					block();
				}];
			}];
			break;
		} case FollowingList: {
			[channel getChannelsFollowingWithCompletionBlock:^{
				self.channelsToDisplay = [NSMutableArray arrayWithArray:[channel channelsUserFollowing]];
				block();
			}];
			break;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0.f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.channelsToDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
	ChannelOrUsernameCV *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

	if(cell == nil) {
		cell = [[ChannelOrUsernameCV alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier isChannel:YES];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	} else {
		[cell removeFromSuperview];
	}

		Channel *channel = [self.channelsToDisplay objectAtIndex: indexPath.row];
		[cell presentChannel:channel];

	return cell;
}


#pragma mark - Lazy Instantiation -


-(NSMutableArray *) channelsToDisplay {
	if(!_channelsToDisplay) _channelsToDisplay = [[NSMutableArray alloc] init];
	return _channelsToDisplay;
}

@end