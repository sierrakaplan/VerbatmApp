//
//  FollowFriendsVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/19/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FollowFriendsVC.h"
#import "FollowFriendCell.h"

@interface FollowFriendsVC()

@property (nonatomic) NSMutableArray *friendUsers;

@end

@implementation FollowFriendsVC

-(void) viewDidLoad {
	[super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.friendUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
	FollowFriendCell *cell = (FollowFriendCell*)[tableView dequeueReusableCellWithIdentifier:identifier];

	if (cell == nil) {
		cell = [[FollowFriendCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
//	[cell presentFriend: self.friendUsers[indexPath.row]];

	return cell;
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) friendUsers {
	if (!_friendUsers) {
		_friendUsers = [[NSMutableArray alloc] init];
	}
	return _friendUsers;
}

@end
