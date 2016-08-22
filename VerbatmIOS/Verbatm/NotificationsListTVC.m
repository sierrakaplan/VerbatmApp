//
//  NotificationsListTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 7/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "NotificationsListTVC.h"
#import "SizesAndPositions.h"
#import "NotificationTableCell.h"
#import "Notification_BackendManager.h"
#import "ParseBackendKeys.h"
#import "Channel_BackendObject.h"
#import "Channel.h"
#import "Styles.h"
#import "CustomNavigationBar.h"
#import "ProfileVC.h"
#import <Parse/PFQuery.h>
#import "NotificationPostPreview.h"
#import "Durations.h"
#import "Icons.h"
#import "UserAndChannelListsTVC.h"

@interface NotificationsListTVC () <NotificationPostPreviewProtocol>

@property (nonatomic) BOOL shouldAnimateViews;
@property (nonatomic) NSMutableArray *parseNotificationObjects;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) CustomNavigationBar * headerBar;
@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;
@property (nonatomic) NotificationPostPreview * postPreview;

@property (nonatomic) UIImageView * noNotificationsNotification;

@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) BOOL currentlyBeingViewed;
@property (nonatomic) BOOL cellSelected;

#define CUSTOM_BAR_HEIGHT 35.f

@end

@implementation NotificationsListTVC

@synthesize refreshControl;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.shouldAnimateViews = YES;
	self.isFirstLoad = YES;
	self.view.backgroundColor = [UIColor whiteColor];
	self.tableView.backgroundColor = [UIColor whiteColor];

	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.allowsSelection = YES;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;

	UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NOTIFICATIONS_LIST_BACKGROUND]];
	[self.tableView setBackgroundView:backgroundView];
	self.tableView.backgroundView.layer.zPosition -= 1;
	[self.view setBackgroundColor:[UIColor clearColor]];

	[self addRefreshFeature];
	[self refreshNotifications];

	UIEdgeInsets inset = UIEdgeInsetsMake(CUSTOM_BAR_HEIGHT + STATUS_BAR_HEIGHT, 0, CUSTOM_BAR_HEIGHT, 0);
	self.tableView.contentInset = inset;

	[self createHeader];
}

-(void)viewWillAppear:(BOOL)animated {
	if(self.isFirstLoad) {
		self.isFirstLoad = NO;
	}
	[self.delegate removeNotificationIndicator];
	self.currentlyBeingViewed = YES;
	self.cellSelected = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
	self.currentlyBeingViewed = NO;
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void)createHeader {
	CGRect navBarFrame = CGRectMake(0.f, self.tableView.contentOffset.y, self.view.frame.size.width, STATUS_BAR_HEIGHT + CUSTOM_BAR_HEIGHT);

	self.headerBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:CHANNEL_LIST_HEADER_BACKGROUND_COLOR];
	[self.headerBar createMiddleButtonWithTitle:@"Notifications" blackText:YES largeSize:YES];
	[self.view addSubview: self.headerBar];

	self.loadMoreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.loadMoreSpinner.hidesWhenStopped = YES;
	self.tableView.tableFooterView = self.loadMoreSpinner;
}

-(void)presentNoNotificationView {
	if(!self.noNotificationsNotification) {
		self.noNotificationsNotification = [[UIImageView alloc]initWithImage:[UIImage imageNamed:NOTIFICATIONS_EMPTY_ICON]];
		[self.noNotificationsNotification setFrame:self.view.bounds];
		[self.view addSubview:self.noNotificationsNotification];
	}
}

-(void)removeNoNotificationView {
	if(self.noNotificationsNotification){
		[self.noNotificationsNotification removeFromSuperview];
		self.noNotificationsNotification = nil;
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if(scrollView == self.tableView){
		self.headerBar.frame = CGRectMake(0.f, scrollView.contentOffset.y, self.headerBar.frame.size.width, self.headerBar.frame.size.height);
	}
}

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self refreshNotifications];
}

-(void)refreshNotifications {
	if(self.refreshing) return;
	self.refreshing = YES;
	if (![self.refreshControl isRefreshing]) [self.loadMoreSpinner startAnimating];
	[Notification_BackendManager getNotificationsForUserAfterDate:nil withCompletionBlock:^(NSArray * notificationObjects) {
		self.parseNotificationObjects = [NSMutableArray arrayWithArray:notificationObjects];
		self.refreshing = NO;
		[self.loadMoreSpinner stopAnimating];
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
		if (!self.currentlyBeingViewed ) {
			[self findNewNotifications];
		}
		if(notificationObjects.count == 0){
			[self presentNoNotificationView];
		}else{
			[self removeNoNotificationView];
		}
	}];
}

-(void)findNewNotifications {
	BOOL foundNewNotification = NO;
	for(PFObject * notification in self.parseNotificationObjects) {
		NSNumber * isNew = [notification valueForKey:NOTIFICATION_IS_NEW];
		if([isNew boolValue]){
			if(!foundNewNotification){
				foundNewNotification = NO;
				[self.delegate showNotificationIndicator];
			}
			[notification setValue:[NSNumber numberWithBool:NO] forKey:NOTIFICATION_IS_NEW];
			[notification saveInBackground];
		}
	}
}

-(void)addRefreshFeature {
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview: self.refreshControl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return CHANNEL_USER_LIST_CELL_HEIGHT;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)exitPreview {
	[self removePreview];
}

-(void)presentCommentListForPost:(PFObject *)post {
    UserAndChannelListsTVC *commentorsListVC = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    [commentorsListVC presentList:CommentList forChannel:nil orPost:post];
    [self presentViewController:commentorsListVC animated:YES completion:nil];
}

-(void) showWhoLikesThePostFromNotifications:(PFObject *) post {
    UserAndChannelListsTVC *likersListVC = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    [likersListVC presentList:LikersList forChannel:nil orPost:post];
    [self presentViewController:likersListVC animated:YES completion:nil];
}

-(void) getMoreNotifications {
	PFObject * lastObject =[self.parseNotificationObjects lastObject];
	NSDate * lastDate = [lastObject createdAt];
	if(self.refreshing) return;
	self.refreshing = YES;
	[self.loadMoreSpinner startAnimating];
	[Notification_BackendManager getNotificationsForUserAfterDate:lastDate withCompletionBlock:^(NSArray * notifications) {
		[self.loadMoreSpinner stopAnimating];
		if(notifications && notifications.count > 1) {
			NSMutableArray * indexPaths = [[NSMutableArray alloc] init];
			for(int i =0; i < notifications.count; i++){
				[indexPaths addObject:[NSIndexPath indexPathForRow: i + self.parseNotificationObjects.count inSection:0]];
			}
			[self.parseNotificationObjects addObjectsFromArray:notifications];
			[self.tableView beginUpdates];
			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
			[self.tableView endUpdates];
			self.refreshing = NO;
			if(self.parseNotificationObjects.count == 0){
				[self presentNoNotificationView];
			}else{
				[self removeNoNotificationView];
			}
		}
	}];
}

-(void)presentPost:(PFObject *)postObject andChannel:(Channel *) channel{

	if(postObject && channel){
        if(!self.postPreview){
            self.postPreview = [[NotificationPostPreview alloc] initWithFrame:CGRectMake(0.f,self.tableView.contentOffset.y + self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
            self.postPreview.delegate = self;
            [self.postPreview presentPost:postObject andChannel:channel];
            [self.view addSubview:self.postPreview];
            [self.view bringSubviewToFront:self.postPreview];
            [UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
                self.postPreview.frame = CGRectMake(0.f, self.tableView.contentOffset.y, self.view.frame.size.width, self.view.frame.size.height);
            }];
            [self.delegate notificationListHideTabBar:YES];
        }
	}
}

-(void)removePreview{
	self.cellSelected = NO;
	if(self.postPreview){
		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			self.postPreview.frame = CGRectMake(0.f,self.tableView.contentOffset.y + self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
		}completion:^(BOOL finished) {
			if(finished){
				[self.postPreview clearViews];
				[self.postPreview removeFromSuperview];
				self.tableView.scrollEnabled = YES;
				[self.delegate notificationListHideTabBar:NO];
                self.postPreview = nil;
			}
		}];
	}
}

#pragma mark - Notifications Cell protocol -

-(void)presentBlogFromCell:(NotificationTableCell *)cell{
	Channel * channel = cell.channel;
	PFUser * user = [channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];

	if(![[user objectId]isEqualToString:[[PFUser currentUser] objectId]]){
		[user fetchIfNeededInBackgroundWithBlock:^
		 (PFObject * _Nullable object, NSError * _Nullable error) {
			 if(object){
				 dispatch_async(dispatch_get_main_queue(), ^{
					 [self presentProfileForUser:(PFUser *)object withStartChannel:channel];
				 });
			 }
		 }];
	}
}



-(void)presentProfileForUser:(PFUser *) user
			withStartChannel:(Channel *) startChannel{
	if(![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]){
		ProfileVC * userProfile = [[ProfileVC alloc] init];
		userProfile.isCurrentUserProfile = NO;
		userProfile.isProfileTab = NO;
		userProfile.ownerOfProfile = user;
		userProfile.channel = startChannel;
		[self presentViewController:userProfile animated:YES completion:nil];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(!self.cellSelected){
        self.cellSelected = YES;
        if(!(cell.notificationType & (NotificationTypeNewFollower|NotificationTypeFriendJoinedVerbatm))){
             self.tableView.scrollEnabled = NO;
             [self presentPost:[cell parseObject] andChannel:cell.channel];
        } else {
            [self presentBlogFromCell: cell];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.parseNotificationObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if(indexPath.row >= self.parseNotificationObjects.count) return nil;

	NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
	NotificationTableCell *cell =  (NotificationTableCell *)[tableView dequeueReusableCellWithIdentifier:identifier];

	if(cell == nil) {
		cell = [[NotificationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	if(indexPath.row >= (self.parseNotificationObjects.count - 5.f)){
		[self getMoreNotifications];
	}

	[self setNotificationOnCell:cell notificationObject:self.parseNotificationObjects[indexPath.row]];
	[self removeNoNotificationView];
	return cell;
}

-(void)setNotificationOnCell:( NotificationTableCell *)cell notificationObject:(PFObject *)notification {
	NotificationType notType = [(NSNumber *)[notification valueForKey:NOTIFICATION_TYPE] intValue];
	PFUser *notificationSender = [notification valueForKey:NOTIFICATION_SENDER];
	PFObject *postActivityObject = [notification valueForKey:NOTIFICATION_POST];
	[postActivityObject fetchInBackground];

	[Channel_BackendObject getChannelsForUser:notificationSender withCompletionBlock:^(NSMutableArray * userChannels) {
		if(userChannels && userChannels.count){
			dispatch_async(dispatch_get_main_queue(), ^{
				Channel * channel = [userChannels firstObject];
				[cell presentNotification:notType withChannel:channel andParseObject:postActivityObject];
			});
		} else {
			//Error where user doesn't have channel

		}
	}];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.shouldAnimateViews) {
		CGFloat direction = (YES) ? 1 : -1;
		cell.transform = CGAffineTransformMakeTranslation(0, cell.bounds.size.height * direction);
		[UIView animateWithDuration:0.4f animations:^{
			cell.transform = CGAffineTransformIdentity;
		}];

		if(cell.bounds.size.height * indexPath.row >= self.view.frame.size.height) {
			self.shouldAnimateViews = NO;
		}
	}
}

-(NSMutableArray *)parseNotificationObjects {
	if(!_parseNotificationObjects)_parseNotificationObjects = [[NSMutableArray alloc] init];
	return _parseNotificationObjects;
}

@end
