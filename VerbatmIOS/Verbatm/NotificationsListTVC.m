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

@interface NotificationsListTVC () <NotificationTableCellProtocol,NotificationPostPreviewProtocol>
@property (nonatomic) BOOL shouldAnimateViews;
@property (nonatomic) NSMutableArray * parseNotificationObjects;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) UIImageView * backgroundView;
@property (nonatomic)  CustomNavigationBar * headerBar;

@property (nonatomic)NotificationPostPreview * postPreview;

@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) BOOL currentlyBeingViewed;
@property (nonatomic) BOOL cellSelected;

#define CUSTOM_BAR_HEIGHT 35.f
#define LIST_BAR_Y_OFFSET -15.f
@end

@implementation NotificationsListTVC

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
    [self addRefreshFeature];
    [self refreshNotifications];
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NOTIFICATIONS_LIST_BACKGROUND]];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.frame = self.view.bounds;
    
     UIEdgeInsets inset = UIEdgeInsetsMake((LIST_BAR_Y_OFFSET+ STATUS_BAR_HEIGHT + CUSTOM_BAR_HEIGHT), 0, CUSTOM_BAR_HEIGHT, 0);
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
    
    
    [self.tableView setBackgroundView:self.backgroundView];
    self.tableView.backgroundView.layer.zPosition -= 1;
    
    [self createHeader];
}

-(void)viewWillAppear:(BOOL)animated{
    if(self.isFirstLoad){
        self.isFirstLoad = NO;
    }else{
        [self refreshNotifications];
    }
    [self.delegate removeNotificationIndicator];
    self.currentlyBeingViewed = YES;
    self.cellSelected = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.currentlyBeingViewed = NO;
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void)createHeader{
    CGRect navBarFrame = CGRectMake(0.f, -(LIST_BAR_Y_OFFSET + STATUS_BAR_HEIGHT + CUSTOM_BAR_HEIGHT), self.view.frame.size.width, STATUS_BAR_HEIGHT+ CUSTOM_BAR_HEIGHT);
    
    self.headerBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:CHANNEL_LIST_HEADER_BACKGROUND_COLOR];
    [self.headerBar createMiddleButtonWithTitle:@"Notifications" blackText:YES largeSize:YES];
    [self.tableView addSubview:self.headerBar];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.tableView){
        
         self.headerBar.frame = CGRectMake(0.f, scrollView.contentOffset.y, self.view.frame.size.width, STATUS_BAR_HEIGHT+ CUSTOM_BAR_HEIGHT);
        [self.tableView bringSubviewToFront:self.headerBar];
        
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self refreshNotifications];
    [refreshControl endRefreshing];
}

-(void)refreshNotifications{
    if(!self.refreshing){
        self.refreshing = YES;
        [Notification_BackendManager getNotificationsForUserAfterDate:nil withCompletionBlock:^(NSArray * notificationObjects) {
            [self.parseNotificationObjects removeAllObjects];
            [self.parseNotificationObjects addObjectsFromArray:notificationObjects];
            self.refreshing = NO;
            [self.tableView reloadData];
            if (!self.currentlyBeingViewed ) {
                [self findNewNotifications];
            }
        }];
    }
}


-(void)findNewNotifications{
    BOOL foundNewNotification = NO;
    for(PFObject * notification in self.parseNotificationObjects){
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


-(void)addRefreshFeature{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CHANNEL_USER_LIST_CELL_HEIGHT;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)exitPreview{
    [self removePreview];
}


-(void)getMoreNotifications{
    PFObject * lastObject =[self.parseNotificationObjects lastObject];
    NSDate * lastDate = [lastObject createdAt];
    if(!self.refreshing){
        self.refreshing = YES;
        [Notification_BackendManager getNotificationsForUserAfterDate:lastDate withCompletionBlock:^(NSArray * notifications) {
            if(notifications && notifications.count > 1){
                NSMutableArray * indexPaths = [[NSMutableArray alloc] init];
                for(int i =0; i < notifications.count; i++){
                    [indexPaths addObject:[NSIndexPath indexPathForRow: i + self.parseNotificationObjects.count inSection:0]];
                    
                }
                 [self.parseNotificationObjects addObjectsFromArray:notifications];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                self.refreshing = NO;
            }
        }];
    }
    
    
    
}


-(void)presentPost:(PFObject *)postObject andChannel:(Channel *) channel{
    
    PFQuery * query = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
    [query whereKey:POST_CHANNEL_ACTIVITY_POST equalTo:postObject];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!self.postPreview){
                self.postPreview = [[NotificationPostPreview alloc] initWithFrame:CGRectMake(self.view.frame.size.width,self.tableView.contentOffset.y, self.view.frame.size.width, self.view.frame.size.height)];
                self.postPreview.delegate = self;
                [self.postPreview presentPost:[objects firstObject] andChannel:channel];
                [self.view addSubview:self.postPreview];
                [UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
                    self.postPreview.frame = self.view.bounds;
                }];
                [self.delegate notificationListHideTabBar:YES];
            }
        });
    }];
    
}

-(void)removePreview{
    self.cellSelected = NO;
    if(self.postPreview){
        [UIView animateWithDuration:PINCHVIEW_DROP_ANIMATION_DURATION animations:^{
            self.postPreview.frame = CGRectMake(self.view.frame.size.width,self.tableView.contentOffset.y, self.view.frame.size.width, self.view.frame.size.height);
        }completion:^(BOOL finished) {
            if(finished){
                [self.postPreview clearViews];
                self.postPreview = nil;
                [self.postPreview removeFromSuperview];
                self.tableView.scrollEnabled = YES;
                [self.delegate notificationListHideTabBar:NO];
            }
        }];
    }
}

#pragma mark -Notifications Cell protocol-
-(void)presentPostSentFromCell:(NotificationTableCell *)cell{
    [self presentPost:[cell objectId] andChannel:cell.channel];

}


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
-(void)presentUserBlogSentFromCell:(NotificationTableCell *)cell{
    
    [self presentBlogFromCell: cell];
}


-(void)presentProfileForUser:(PFUser *) user
            withStartChannel:(Channel *) startChannel{
    if(![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]){
        ProfileVC *  userProfile = [[ProfileVC alloc] init];
        userProfile.isCurrentUserProfile = NO;
        userProfile.isProfileTab = NO;
        userProfile.ownerOfProfile = user;
        userProfile.channel = startChannel;
        [self presentViewController:userProfile animated:YES completion:nil];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(!self.cellSelected){
        self.cellSelected = YES;
        if(cell.notificationType == Like){
             self.tableView.scrollEnabled = NO;
             [self presentPost:[cell objectId] andChannel:cell.channel];
        }else{
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

-(void)setNotificationOnCell:( NotificationTableCell *)cell notificationObject:(PFObject *)notification{
    NotificationType notType = [(NSNumber *)[notification valueForKey:NOTIFICATION_TYPE] intValue];
    PFUser * notificationSender = [notification valueForKey:NOTIFICATION_SENDER];
    PFObject * postActivityObject = [notification valueForKey:NOTIFICATION_POST];
    [postActivityObject fetchInBackground];
    
    
    [Channel_BackendObject getChannelsForUser:notificationSender withCompletionBlock:^(NSMutableArray * userChannels) {
        if(userChannels){
            dispatch_async(dispatch_get_main_queue(), ^{
                Channel * channel = [userChannels firstObject];
                [cell presentNotification:notType withChannel:channel andObjectId:postActivityObject];
            });
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row >= self.parseNotificationObjects.count) return nil;
    
    NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
    NotificationTableCell *cell =  (NotificationTableCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell){
        cell = [[NotificationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.row >= (self.parseNotificationObjects.count - 5.f)){
        [self getMoreNotifications];
    }
    [self setNotificationOnCell:cell notificationObject:self.parseNotificationObjects[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

-(NSMutableArray *)parseNotificationObjects{
    if(!_parseNotificationObjects)_parseNotificationObjects = [[NSMutableArray alloc] init];
        return _parseNotificationObjects;
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
