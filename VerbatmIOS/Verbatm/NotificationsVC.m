//
//  NotificationsVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 5/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "NotificationsVC.h"
#import "Styles.h"

@interface NotificationsVC()

@property (strong, nonatomic) NSMutableArray *notifications;

#define HEADER_HEIGHT 50.f
#define CELL_HEIGHT 40.f
#define HEADER_FONT_SIZE 20.f

@end

@implementation NotificationsVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.delegate = self;

	[self addRefreshFeature];
	[self refreshNotifications];
}

-(void) refreshNotifications {
//todo:
}

-(void)addRefreshFeature{
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshNotifications) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];
}

#pragma mark - Table View delegate methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Notifications";
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return HEADER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	// Background color
	view.tintColor = [UIColor blackColor];
	// Text Color
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	[header.textLabel setTextColor:[UIColor whiteColor]];
	[header.textLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:HEADER_FONT_SIZE]];
	[header.textLabel setTextAlignment:NSTextAlignmentCenter];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.notifications.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return CELL_HEIGHT;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// All cells should be non selectable
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld%ld", (long)indexPath.section, (long)indexPath.row % 10]; // reuse cells every 30

}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) notifications {
	if (!_notifications) {
		_notifications = [[NSMutableArray alloc] init];
	}
	return _notifications;
}


@end
