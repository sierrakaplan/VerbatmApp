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

@interface NotificationsListTVC ()
@property (nonatomic) BOOL shouldAnimateViews;
@property (nonatomic) NSMutableArray * parseNotificationObjects;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) UIImageView * backgroundView;
@property (nonatomic)  CustomNavigationBar * headerBar;




#define CUSTOM_BAR_HEIGHT 50.f
#define LIST_BAR_Y_OFFSET -15.f
@end

@implementation NotificationsListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldAnimateViews = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self addRefreshFeature];
    [self refreshNotifications];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NOTIFICATIONS_LIST_BACKGROUND]];
    
     UIEdgeInsets inset = UIEdgeInsetsMake((LIST_BAR_Y_OFFSET+ STATUS_BAR_HEIGHT + CUSTOM_BAR_HEIGHT), 0, CUSTOM_BAR_HEIGHT, 0);
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
    
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    [self createHeader];
}


-(void)createHeader{
    CGRect navBarFrame = CGRectMake(0.f, -(LIST_BAR_Y_OFFSET + STATUS_BAR_HEIGHT + CUSTOM_BAR_HEIGHT), self.view.frame.size.width, STATUS_BAR_HEIGHT+ CUSTOM_BAR_HEIGHT);
    
    self.headerBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:CHANNEL_LIST_HEADER_BACKGROUND_COLOR];
    [self.headerBar createMiddleButtonWithTitle:@"Navigation" blackText:YES largeSize:YES];
    [self.tableView addSubview:self.headerBar];
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.tableView){
        
         self.headerBar.frame = CGRectMake(0.f, scrollView.contentOffset.y, self.view.frame.size.width, STATUS_BAR_HEIGHT+ CUSTOM_BAR_HEIGHT);
        [self.tableView bringSubviewToFront:self.headerBar];
        
        self.backgroundView.frame = CGRectMake(0.f, scrollView.contentOffset.y, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
        
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
        }];
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
    id postId = [notification valueForKey:NOTIFICATION_POST];
    [Channel_BackendObject getChannelsForUser:notificationSender withCompletionBlock:^(NSMutableArray * userChannels) {
        if(userChannels){
            dispatch_async(dispatch_get_main_queue(), ^{
                Channel * channel = [userChannels firstObject];
                [cell presentNotification:notType withChannel:channel andObjectId:postId];
            });
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row >= self.parseNotificationObjects.count) return nil;
    
    NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
    NotificationTableCell *cell =  (NotificationTableCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell){
    }else{
        cell = [[NotificationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
