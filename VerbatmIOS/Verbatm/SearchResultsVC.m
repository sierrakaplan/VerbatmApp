//
//  SearchResultsVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/1/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "SearchResultsVC.h"

#import <Crashlytics/Crashlytics.h>
#import "ParseBackendKeys.h"
#import <Parse/PFObject.h>
#import <Parse/PFQuery.h>
#import "ProfileVC.h"

#define SEARCH_RESULTS_LIMIT 50

@interface SearchResultsVC ()

@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) PFQuery *currentQuery;

@end

@implementation SearchResultsVC

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	NSString *searchText = searchController.searchBar.text;
	[self filterResults: searchText];
}

-(void)filterResults:(NSString *)searchTerm {
	PFQuery *channelNameQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
	[channelNameQuery whereKey:CHANNEL_NAME_KEY matchesRegex:searchTerm modifiers:@"i"];
	PFQuery *channelCreatorQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
	[channelCreatorQuery whereKey:CHANNEL_CREATOR_NAME_KEY matchesRegex:searchTerm modifiers:@"i"];
	if (self.currentQuery) [self.currentQuery cancel];
	self.currentQuery = [PFQuery orQueryWithSubqueries:@[channelNameQuery, channelCreatorQuery]];
	[self.currentQuery orderByDescending:CHANNEL_NUM_FOLLOWS];
	self.currentQuery.limit = SEARCH_RESULTS_LIMIT;
	[self.currentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
		} else {
			if (objects.count) {
				[self.view setBackgroundColor:[UIColor blueColor]];
			} else {
				[self.view setBackgroundColor:[UIColor blackColor]];
			}
			self.searchResults = objects;
			[self.tableView reloadData];
		}
	}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	} else {
		[cell removeFromSuperview];
	}
	PFObject *result = self.searchResults[indexPath.row];
	[result[CHANNEL_CREATOR_KEY] fetchIfNeededInBackground];
	NSString *userName = result[CHANNEL_CREATOR_NAME_KEY];
	NSString *blogText = result[CHANNEL_NAME_KEY];
	if(userName) {
		blogText = [blogText stringByAppendingString:@" by "];
		blogText = [blogText stringByAppendingString:userName];
	}
	[cell.textLabel setText: blogText];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PFObject *channelObj = self.searchResults[indexPath.row];
	Channel *channel = [[Channel alloc] initWithChannelName:channelObj[CHANNEL_NAME_KEY]
												   andParseChannelObject:channelObj
													   andChannelCreator:channelObj[CHANNEL_CREATOR_KEY]];
	ProfileVC * userProfile = [[ProfileVC alloc] init];
	userProfile.isCurrentUserProfile = channel.channelCreator == [PFUser currentUser];
	userProfile.isProfileTab = NO;
	userProfile.ownerOfProfile = channel.channelCreator;
	userProfile.channel = channel;
	[self presentViewController:userProfile animated:YES completion:^{
	}];
}

@end
