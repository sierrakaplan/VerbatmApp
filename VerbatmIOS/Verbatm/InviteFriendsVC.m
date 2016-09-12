//
//  InviteFriendsVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "InviteFriendCell.h"
#import "InviteFriendsVC.h"
#import "FeedQueryManager.h"
#import "MasterNavigationVC.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "Styles.h"
#import "VerbatmNavigationController.h"
#import <Parse/PFQuery.h>

@import Contacts;

@interface InviteFriendsVC() <MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *phoneNumbers;
@property (nonatomic) NSMutableArray *contacts;
@property (nonatomic) NSMutableArray *selectedNumbers;

#define CELL_HEIGHT 60.f
#define SEND_INVITES_BUTTON_HEIGHT 100.f
#define SEND_INVITES_FONT_SIZE 24.f

@end

@implementation InviteFriendsVC

-(void) viewDidLoad {
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.navigationItem.title = @"Invite Friends";
	[self.view addSubview: self.tableView];
	[self addSendInvitesButton];
	[self loadContacts];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[(MasterNavigationVC*)self.tabBarController showTabBar:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarBackgroundColor:[UIColor whiteColor]];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarShadowColor:[UIColor lightGrayColor]];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor blackColor]];
}

-(void) loadContacts {
	CNContactStore *contactStore = [[CNContactStore alloc] init];
	CNEntityType entityType = CNEntityTypeContacts;
	if([CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined) {
		// Request access for entity type returns on arbitrary queue
		[contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (granted && error == nil) {
					[self displayContactsFromContactStore:contactStore];
				} else if (!granted) {
					[self contactsNotAuthorized];
				} else {
					//todo: error handling
				}
			});
		}];
	} else if([CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized) {
		[self displayContactsFromContactStore:contactStore];
	} else {
		[self contactsNotAuthorized];
	}
}

-(void) addSendInvitesButton {
	UIButton *sendInvitesButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height - SEND_INVITES_BUTTON_HEIGHT - 60.f,
																			 self.view.frame.size.width, SEND_INVITES_BUTTON_HEIGHT)];
	sendInvitesButton.backgroundColor = [UIColor blackColor];
	sendInvitesButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[sendInvitesButton setTitle:@"Send Invites" forState:UIControlStateNormal];
	sendInvitesButton.titleLabel.font = [UIFont fontWithName:REGULAR_FONT size:SEND_INVITES_FONT_SIZE];
	[sendInvitesButton addTarget:self action:@selector(sendInvites) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview: sendInvitesButton];
}

-(void) displayContactsFromContactStore:(CNContactStore*)store {
	//keys with fetching properties
	id<CNKeyDescriptor> nameKeys = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
	NSArray *keys = @[CNContactPhoneNumbersKey, nameKeys];
	NSString *containerId = store.defaultContainerIdentifier;
	NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
	NSError *error;
	NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
	if (error) {
		//todo: error handling
	} else {
		NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
		self.contacts = [[NSMutableArray alloc] init];
		for (CNContact *contact in cnContacts) {
			// copy data to my custom Contacts class.
			for (CNLabeledValue *phoneNumberKey in contact.phoneNumbers) {
				CNPhoneNumber *phoneNumber = phoneNumberKey.value;
				if (phoneNumberKey.label == CNLabelPhoneNumberMobile ||
					phoneNumberKey.label == CNLabelPhoneNumberiPhone) {
					NSString *plainPhoneNumber = [[phoneNumber.stringValue componentsSeparatedByCharactersInSet:
												   [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
												  componentsJoinedByString:@""];
					if (![plainPhoneNumber isEqualToString:[PFUser currentUser].username]) {
						[phoneNumbers addObject: plainPhoneNumber];
						[self.contacts addObject: contact];
					}
					break;
				}
			}
		}
		PFQuery *friendQuery = [PFUser query];
		[friendQuery whereKey:@"username" containedIn: phoneNumbers];
		// findObjects will return a list of PFUsers that are friends with the current user
		[friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friendUsers, NSError * _Nullable error) {
			if (!error && friendUsers.count) {
				for (PFUser *friend in friendUsers) {
					NSInteger friendIndex = [phoneNumbers indexOfObject:friend.username];
					[phoneNumbers removeObjectAtIndex: friendIndex];
					[self.contacts removeObjectAtIndex: friendIndex];
				}
			}
			self.phoneNumbers = phoneNumbers;
			[self.tableView reloadData];
		}];
	}
}

-(void) contactsNotAuthorized {
	//todo: show "share this link" instead
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return CELL_HEIGHT;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.contacts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"cell,%ld", (long)indexPath.row];
	InviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[InviteFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	CNContact *contact = self.contacts[indexPath.row];
	NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
	NSString *phoneNumber;
	for (CNLabeledValue *phoneNumberKey in contact.phoneNumbers) {
		CNPhoneNumber *cnphoneNumber = phoneNumberKey.value;
		if (phoneNumberKey.label == CNLabelPhoneNumberMobile ||
			phoneNumberKey.label == CNLabelPhoneNumberiPhone) {
			phoneNumber = cnphoneNumber.stringValue;
			break;
		}
	}
	[cell setContactName:name andPhoneNumber:phoneNumber];
	return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *phoneNumber = self.phoneNumbers[indexPath.row];
	InviteFriendCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell toggleButton];
	if (cell.buttonIsSelected) {
		[self.selectedNumbers addObject: phoneNumber];
	} else {
		[self.selectedNumbers removeObject: phoneNumber];
	}
}

-(void) sendInvites {
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	NSString *message = @"Follow me on the visual storytelling app Verbatm! Download here:";
	NSString *appStoreUrl = @" itms://itunes.apple.com/us/app/verbatm/id1015766146?mt=8";
	controller.body = [message stringByAppendingString: appStoreUrl];
	controller.messageComposeDelegate = self;
	controller.recipients = self.selectedNumbers;
	[self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Message delegate -

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:^{

	}];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) selectedNumbers {
	if (!_selectedNumbers) {
		_selectedNumbers = [[NSMutableArray alloc] init];
	}
	return _selectedNumbers;
}

@end
