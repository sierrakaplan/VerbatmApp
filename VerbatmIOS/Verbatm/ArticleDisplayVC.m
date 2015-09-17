//
//  ArticleDisplayVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/14/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "AVETypeAnalyzer.h"

#import "CoverPhotoAVE.h"

#import "GTLVerbatmAppPOVInfo.h"
#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

#import "POVDisplayScrollView.h"
#import "POVLoadManager.h"
#import "PagesLoadManager.h"
#import "POVView.h"

#import "UIEffects.h"
#import "UpdatingManager.h"

@interface ArticleDisplayVC () <PagesLoadManagerDelegate, LikeButtonDelegate>

@property (strong, nonatomic) POVDisplayScrollView* scrollView;

//array of POVView's currently on scrollview
@property (strong, nonatomic) NSMutableArray* povViews;

//needs to associate which pov id is at which index
@property (strong, nonatomic) NSMutableArray* povIDs;

//Should not retain strong reference to the load manager since the
//ArticleListVC also contains a reference to it
@property (weak, nonatomic) POVLoadManager* povLoadManager;

// Load manager in charge of getting page objects and all their media for each pov
@property (strong, nonatomic) PagesLoadManager* pageLoadManager;

// In charge of updating information about a pov (number of likes, etc.)
@property (strong, nonatomic) UpdatingManager* updatingManager;

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;
@end

@implementation ArticleDisplayVC

- (void)viewDidLoad {
	[super viewDidLoad];
	// Should always have 4 stories in memory (two in the direction of scroll, current, and one back)
	self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
	[self.view addSubview: self.scrollView];
	self.pageLoadManager.delegate = self;
}


// When user clicks story, loads one behind it and the two ahead
-(void) loadStory: (NSInteger) index fromLoadManager: (POVLoadManager*) loadManager {
	self.povLoadManager = loadManager;
	GTLVerbatmAppPOVInfo* povInfo = [self.povLoadManager getPOVInfoAtIndex:index];
	NSNumber* povID = povInfo.identifier;
	[self.pageLoadManager loadPagesForPOV: povID];
	[self.povIDs addObject: povID];
	POVView* povView = [[POVView alloc] initWithFrame: self.view.bounds];

	UIImage* coverPic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: povInfo.coverPicUrl]]];
	CoverPhotoAVE* coverAVE = [[CoverPhotoAVE alloc] initWithFrame:self.view.bounds andImage: coverPic andTitle: povInfo.title];
	NSMutableArray* aves = [[NSMutableArray alloc] initWithArray:@[coverAVE]];
	[povView renderAVES: aves];
	[self.scrollView addSubview: povView];
	[self.povViews addObject: povView];
    self.activityIndicator = [UIEffects startActivityIndicatorOnView:self.view andCenter:self.view.center
                                                            andStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

// When user scrolls to a new story, loads the next two in that
// direction of scroll
-(void) loadNextTwoStories: (NSInteger) index {

}

#pragma mark - Page load manager delegate -

-(void) pagesLoadedForPOV:(NSNumber *)povID {
	NSArray* pages = [self.pageLoadManager getPagesForPOV: povID];
	NSInteger povIndex = [self.povIDs indexOfObject: povID];
	POVView* povView = self.povViews[povIndex];

	AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc]init];
	NSMutableArray* aves = [analyzer getAVESFromPages: pages withFrame: self.view.bounds];
	// already should have cover photo ave
	if (aves.count) {
		[povView.pageAves addObjectsFromArray:aves];
	}

	[povView renderAVES: povView.pageAves];
	[povView addLikeButtonWithDelegate:self andSetPOVID: povID];
    [UIEffects stopActivityIndicator:self.activityIndicator];
}

-(void) likeButtonLiked:(BOOL)liked onPOVWithID:(NSNumber *)povID {
	[self.updatingManager povWithId:povID wasLiked: liked];
}



#pragma mark - Clean up -

// Reverses load Article and removes all content
-(void) cleanUp {
	for (POVView* povView in self.povViews) {
		[povView clearArticle];
		[povView removeFromSuperview];
	}
	self.povViews = nil;
	self.povIDs = nil;
}


#pragma mark - Memory warning -

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark - Lazy Instantiation

-(POVDisplayScrollView*) scrollView {
	if (!_scrollView) {
		_scrollView = [[POVDisplayScrollView alloc] initWithFrame:self.view.bounds];
	}
	return _scrollView;
}

-(PagesLoadManager*) pageLoadManager {
	if (!_pageLoadManager) {
		_pageLoadManager = [[PagesLoadManager alloc] init];
	}
	return _pageLoadManager;
}

-(UpdatingManager*) updatingManager {
	if (!_updatingManager) {
		_updatingManager = [[UpdatingManager alloc] init];
	}
	return _updatingManager;
}

-(NSMutableArray*) povViews {
	if (!_povViews) {
		_povViews = [[NSMutableArray alloc] init];
	}
	return _povViews;
}

-(NSArray*) povIDs {
	if (!_povIDs) {
		_povIDs = [[NSMutableArray alloc] init];
	}
	return _povIDs;
}

@end
