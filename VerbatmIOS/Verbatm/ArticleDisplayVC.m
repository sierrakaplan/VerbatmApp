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

#import "Page.h"
#import "POVDisplayScrollView.h"
#import "POVLoadManager.h"
#import "PagesLoadManager.h"
#import "POVView.h"
#import "PovInfo.h"

#import "UIEffects.h"
#import "UpdatingPOVManager.h"

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
@property (strong, nonatomic) UpdatingPOVManager* updatingPOVManager;

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

#define ACTIVITY_ANIMATION_Y 100
@end

@implementation ArticleDisplayVC

- (void)viewDidLoad {
	[super viewDidLoad];
	//TODO: should always have 4 stories in memory (two in the direction of scroll, current, and one back)
	self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
	[self.view addSubview: self.scrollView];
	self.pageLoadManager.delegate = self;
}


// When user clicks story, loads one behind it and the two ahead
-(void) loadStory: (NSInteger) index fromLoadManager: (POVLoadManager*) loadManager {
	self.povLoadManager = loadManager;
	PovInfo* povInfo = [self.povLoadManager getPOVInfoAtIndex:index];
	NSNumber* povID = povInfo.identifier;
	[self.pageLoadManager loadPagesForPOV: povID];
	[self.povIDs addObject: povID];
	POVView* povView = [[POVView alloc] initWithFrame: self.view.bounds];

	CoverPhotoAVE* coverAVE = [[CoverPhotoAVE alloc] initWithFrame:self.view.bounds andImage:povInfo.coverPhoto andTitle: povInfo.title];
	[povView renderNextAve:coverAVE withIndex:[NSNumber numberWithInteger:0]];
	[self.scrollView addSubview: povView];
	[self.povViews addObject: povView];
    self.activityIndicator = [UIEffects startActivityIndicatorOnView:self.view andCenter: CGPointMake(self.view.center.x, ACTIVITY_ANIMATION_Y)
                                                            andStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor blackColor];
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

	AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc] init];
	for (Page* page in pages) {
		[analyzer getAVEFromPage: page withFrame: self.view.bounds].then(^(UIView* ave) {
			NSInteger pageIndex = page.indexInPOV+1; // bc cover page +1
			// When first page loads, show down arrow
			if (pageIndex == 1) {
				[povView addDownArrowButton];
				[povView addLikeButtonWithDelegate:self andSetPOVID: povID];
				[UIEffects stopActivityIndicator:self.activityIndicator];
				self.activityIndicator = nil;
			}
			[povView renderNextAve: ave withIndex: [NSNumber numberWithInteger:pageIndex]];
		}).catch(^(NSError* error) {
			NSLog(@"Error loading page: %@", error.description);
		});
	}
}

#pragma mark - POVView Delegate (Like button) -

-(void) likeButtonLiked:(BOOL)liked onPOVWithID:(NSNumber *)povID {
	[self.updatingPOVManager povWithId:povID wasLiked: liked];
	
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
	if ([self.activityIndicator isAnimating]) {
		[UIEffects stopActivityIndicator:self.activityIndicator];
	}
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

-(UpdatingPOVManager*) updatingPOVManager {
	if (!_updatingPOVManager) {
		_updatingPOVManager = [[UpdatingPOVManager alloc] init];
	}
	return _updatingPOVManager;
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
