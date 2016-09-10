//
//  CommentingViewController.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/30/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChannelOrUsernameCV.h"
#import "Comment.h"
#import "Commenting_BackendObject.h"
#import "CommentingKeyboardToolbar.h"
#import "CommentingViewController.h"
#import "MasterNavigationVC.h"
#import "VerbatmNavigationController.h"

@interface CommentingViewController() <UITableViewDelegate, UITableViewDataSource, CommentingKeyboardToolbarProtocol>

@property (nonatomic) PFObject *postObject;
@property (strong, nonatomic) UITableView *tableView;
// Fixed position at bottom of screen
@property (nonatomic) CommentingKeyboardToolbar *commentingKeyboard;

@property (nonatomic) UIActivityIndicatorView *loadMoreSpinner;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL refreshing;

@property (nonatomic) NSMutableArray * commentObjectList;

#define COMMENTING_TEXT @"Comments"
#define COMMENTING_KEYBOARD_HEIGHT 50.f
@end

@implementation CommentingViewController

-(instancetype) initForPost: (PFObject*)post {
	self = [super init];
	if (self) {
		self.postObject = post;
	}
	return self;
}

-(void) viewDidLoad {
	[super viewDidLoad];
	self.refreshing = NO;
	[self setNavigationItem];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview: self.tableView];
	[self.view addSubview: self.commentingKeyboard];
	[self addRefreshFeature];
	if (![self.refreshControl isRefreshing]) {
		[self.loadMoreSpinner startAnimating];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShowOrHide:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShowOrHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	[self refreshData];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// Set all navigation bar and tab bar formatting here:
	[(MasterNavigationVC*)self.tabBarController showTabBar:NO];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarBackgroundColor:[UIColor whiteColor]];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarShadowColor:[UIColor lightGrayColor]];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor blackColor]];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) setNavigationItem {
	self.navigationItem.title = COMMENTING_TEXT;
}


#pragma mark - Loading comments -


-(void) refreshData {
	if (self.refreshing) return;
	self.refreshing = YES;
	[Commenting_BackendObject getCommentsForObject:self.postObject withCompletionBlock:^(NSArray * parseCommentObjects) {
		self.commentObjectList = (parseCommentObjects == nil) ? [[NSMutableArray alloc] init] : [NSMutableArray arrayWithArray:parseCommentObjects];
		[self.loadMoreSpinner stopAnimating];
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
		self.refreshing = NO;
	}];
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
	[self refreshData];
}

#pragma mark - Table view delegate methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.commentObjectList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	Comment * comment = [self.commentObjectList objectAtIndex: indexPath.row];
	return [ChannelOrUsernameCV getHeightForCellFromCommentObject:comment];
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

	Comment * comment = [self.commentObjectList objectAtIndex: indexPath.row];
	[cell presentComment:comment];

	return cell;
}

#pragma mark - Adding new comment -

-(void)keyboardDidShowOrHide:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardEndFrame;

	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];


	CGFloat yPosKeyboardWithTableViewCord = keyboardEndFrame.origin.y + self.tableView.contentOffset.y;

	CGRect newFrame = self.commentingKeyboard.frame;
	newFrame.origin.y = yPosKeyboardWithTableViewCord - (self.commentingKeyboard.frame.size.height) - self.navigationController.navigationBar.frame.size.height;
	self.commentingKeyboard.frame = newFrame;

	[UIView commitAnimations];
}

-(void)doneButtonSelectedWithFinalString:(NSString *) commentString{
	Comment * newComment  = [[Comment alloc] initWithString:commentString andPostObject:self.postObject];
	[self.commentObjectList addObject:newComment];
	[self.tableView reloadData];
}

#pragma mark - Lazy Instantiation -

-(UITableView*) tableView {
	if (!_tableView) {
		_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
		_tableView.backgroundColor = [UIColor whiteColor];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	}
	return _tableView;
}

-(CommentingKeyboardToolbar*) commentingKeyboard {
	if (!_commentingKeyboard) {
		CGRect frame = CGRectMake(0.f, self.view.frame.size.height - COMMENTING_KEYBOARD_HEIGHT -
								  self.navigationController.navigationBar.frame.size.height,
								  self.view.frame.size.width, COMMENTING_KEYBOARD_HEIGHT);
		_commentingKeyboard = [[CommentingKeyboardToolbar alloc] initWithFrame:frame];
		_commentingKeyboard.delegate = self;
	}
	return _commentingKeyboard;
}

@end
