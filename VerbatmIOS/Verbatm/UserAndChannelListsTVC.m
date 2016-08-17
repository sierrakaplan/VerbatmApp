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

@interface UserAndChannelListsTVC () <CustomNavigationBarDelegate>
@property (nonatomic) Channel * channelOnDisplay;
@property (nonatomic) PFObject * postObject;
@property (nonatomic) UIView * navBar;

@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSMutableArray * channelsToDisplay;
@property (nonatomic) NSMutableArray * usersToDisplay;//catch all array -- can be used for any of the usecases to store a list of users

@property (nonatomic) NSArray * commentParseObjectList;

@property (nonatomic) BOOL shouldDisplayFollowers;

@property (nonatomic) id postInformationToPresent;
@property (nonatomic) BOOL isLikeInformation;//if it is set at no then  it's share information

@property (nonatomic) id userInfoOnDisplay;//the user whose data we are displaying

@property (nonatomic) BOOL presentAllChannels;
@property (nonatomic) BOOL shouldAnimateViews;

#define CHANNEL_CELL_ID @"channel_cell_id"
#define CUSTOM_CHANNEL_LIST_BAR_HEIGHT 50.f
#define LIKERS_TEXT @"Likes"
#define FOLLOWING_TEXT @"Following"
#define COMMENTING_TEXT @"Comments"

#define FOLLOWERS_TEXT @"Followers"
#define LIST_BAR_Y_OFFSET -15.f

@end


@implementation UserAndChannelListsTVC

@synthesize refreshControl;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	self.tableView.backgroundColor = [UIColor whiteColor];

	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;

	[self setNeedsStatusBarAppearanceUpdate];

	//avoid covering last item in uitableview
	UIEdgeInsets inset = UIEdgeInsetsMake((LIST_BAR_Y_OFFSET+ STATUS_BAR_HEIGHT + CUSTOM_CHANNEL_LIST_BAR_HEIGHT), 0, CUSTOM_CHANNEL_LIST_BAR_HEIGHT, 0);
	self.tableView.contentInset = inset;
	self.tableView.scrollIndicatorInsets = inset;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if(self.navBar){
		[self.view bringSubviewToFront:self.navBar];
	}else{
		[self setTableViewHeader];
	}
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
		if(self.navBar)[self.view bringSubviewToFront:self.navBar];
	}];
}

-(void)viewDidLayoutSubviews{
	[super viewDidLayoutSubviews];
	if(self.navBar){
		[self.view bringSubviewToFront:self.navBar];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
	if(![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]){
		ProfileVC *  userProfile = [[ProfileVC alloc] init];
		BOOL isCurrentUserChannel = [[startChannel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
		userProfile.isCurrentUserProfile = isCurrentUserChannel;
		userProfile.isProfileTab = NO;
		userProfile.ownerOfProfile = user;
		userProfile.channel = startChannel;
		[self presentViewController:userProfile animated:YES completion:nil];
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
        } case CommentList: {
            
            [Commenting_BackendObject getCommentsForObject:post withCompletionBlock:^(NSArray * parseCommentObjects) {
                    self.commentParseObjectList = (parseCommentObjects == nil) ? @[] : parseCommentObjects;
            }];
            
        }
	}
}


// NOT IN USE
-(void)presentAllVerbatmChannels{
	//self.presentAllChannels = YES;
	[Channel_BackendObject getAllChannelsWithCompletionBlock:^(NSMutableArray * channels) {
		if(self.channelsToDisplay.count)[self.channelsToDisplay removeAllObjects];
		[self.channelsToDisplay addObjectsFromArray:channels];
		dispatch_async(dispatch_get_main_queue(), ^{
			self.shouldAnimateViews = YES;
			[self.tableView reloadData];
		});
	}];

}

-(void)setTableViewHeader{
	CGRect navBarFrame = CGRectMake(0.f, -(LIST_BAR_Y_OFFSET + STATUS_BAR_HEIGHT + CUSTOM_CHANNEL_LIST_BAR_HEIGHT), self.view.frame.size.width, STATUS_BAR_HEIGHT+ CUSTOM_CHANNEL_LIST_BAR_HEIGHT);

	CGRect customBarFrame = CGRectMake(0.f, STATUS_BAR_HEIGHT, self.view.frame.size.width, CUSTOM_CHANNEL_LIST_BAR_HEIGHT);

	self.navBar = [[UIView alloc]initWithFrame:navBarFrame];
	self.navBar.backgroundColor = CHANNEL_LIST_HEADER_BACKGROUND_COLOR;

	CustomNavigationBar * customNavBar =  [[CustomNavigationBar alloc] initWithFrame:customBarFrame andBackgroundColor:CHANNEL_LIST_HEADER_BACKGROUND_COLOR];

	[customNavBar createLeftButtonWithTitle:nil orImage:[UIImage imageNamed:BACK_BUTTON_ICON]];

	NSString * navBarMiddleText = FOLLOWERS_TEXT;
	if(self.currentListType == LikersList){
		navBarMiddleText = LIKERS_TEXT;
	}else if (self.currentListType == FollowingList){
		navBarMiddleText = FOLLOWING_TEXT;
	}else if (self.currentListType == CommentList){
        navBarMiddleText = COMMENTING_TEXT;
    }

	[customNavBar createMiddleButtonWithTitle:navBarMiddleText blackText:YES largeSize:YES];

	customNavBar.delegate = self;
	[self.navBar addSubview:customNavBar];
	[self.navBar addShadowToView];
	[self.view addSubview:self.navBar];
	[self.view bringSubviewToFront:self.navBar];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [[CustomNavigationBar alloc] initWithFrame:self.navBar.frame andBackgroundColor:[UIColor whiteColor]];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0.f;
}

// Exiting view
-(void) leftButtonPressed{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

-(UILabel *) getHeaderTitleForViewWithText:(NSString *) text{

	CGRect labelFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width + 10, USER_CELL_VIEW_HEIGHT);
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
	titleLabel.backgroundColor = [UIColor whiteColor];

	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.alignment = NSTextAlignmentCenter;

	NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
												[UIColor clearColor],
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[scrollView bringSubviewToFront:self.navBar];
	self.navBar.frame = CGRectMake(0.f, scrollView.contentOffset.y, self.navBar.frame.size.width, self.navBar.frame.size.height);

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

	if(self.presentAllChannels && indexPath.row == 0) {
		[cell setHeaderTitle];
    } else if(self.commentParseObjectList) {
        
        NSInteger objectIndex = indexPath.row;
        PFObject * post = [self.commentParseObjectList objectAtIndex:objectIndex];
        
        
    } else {
		NSInteger objectIndex = self.presentAllChannels ? (indexPath.row - 1) : indexPath.row;
		Channel *channel = [self.channelsToDisplay objectAtIndex:objectIndex];
		[cell presentChannel:channel];
	}
	if(self.navBar)[self.view bringSubviewToFront:self.navBar];
	return cell;
}


#pragma mark - Lazy Instantiation -


-(NSMutableArray *) channelsToDisplay{
	if(!_channelsToDisplay)_channelsToDisplay = [[NSMutableArray alloc] init];
	return _channelsToDisplay;
}

@end