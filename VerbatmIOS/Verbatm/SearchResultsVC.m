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

#define SEARCH_RESULTS_LIMIT 50

@interface SearchResultsVC ()

@property (strong, nonatomic) NSArray *searchResults;

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
	PFQuery *query = [PFQuery orQueryWithSubqueries:@[channelNameQuery, channelCreatorQuery]];
	[query orderByDescending:CHANNEL_NUM_FOLLOWS];
	query.limit = SEARCH_RESULTS_LIMIT;
	[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
		} else {
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
	NSString *userName = result[CHANNEL_CREATOR_NAME_KEY];
	NSString *blogText = result[CHANNEL_NAME_KEY];
	if(userName) {
		blogText = [blogText stringByAppendingString:@" by "];
		blogText = [blogText stringByAppendingString:userName];
	}
	[cell.textLabel setText: blogText];
	return cell;
}

@end
