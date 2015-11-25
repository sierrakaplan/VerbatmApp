 //
//  ArticleDisplayVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/14/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"
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

#import "UpdatingPOVManager.h"
#import "UIView+Effects.h"

@interface ArticleDisplayVC () < LikeButtonDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) POVDisplayScrollView* scrollView;

//array of POVView's currently on scrollview
@property (strong, nonatomic) NSMutableArray* povViews;

//needs to associate which pov id is at which index
@property (strong, nonatomic) NSMutableArray* povIDs;

//Should not retain strong reference to the load manager since the
//ArticleListVC also contains a reference to it
@property (weak, nonatomic) POVLoadManager* povLoadManager;


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
}

// When user clicks story, loads one behind it and the two ahead
-(void) loadStoryAtIndex: (NSInteger) index fromLoadManager: (POVLoadManager*) loadManager {
	self.povLoadManager = loadManager;
    PovInfo* povInfo = [self.povLoadManager getPOVInfoAtIndex:index];
    POVView* povView = [[POVView alloc] initWithFrame: self.view.bounds andPOVInfo:povInfo];
	[self.scrollView addSubview: povView];
	[self.povViews addObject: povView];
    [[Analytics getSharedInstance]storyStartedViewing:povInfo.title];
    [self loadNextStories];
}


#pragma mark -manage multiple stories present-


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //[self loadNextStories];
}



// When user scrolls to a new story, loads the next two in that
// direction of scroll
-(void) loadNextStories {
    
    NSInteger numPOVS = [self.povLoadManager getNumberOfPOVsLoaded];
    
    NSInteger currentPageIndex = self.scrollView.contentOffset.x/self.view.frame.size.width;
    NSInteger leftPOVIndex = currentPageIndex - 1;
    NSInteger rightPOVIndex = currentPageIndex + 1;
    if(currentPageIndex == 0) {
       //we are on the first page so load the next two
        PovInfo* povInfo1 = [self.povLoadManager getPOVInfoAtIndex:rightPOVIndex];
        PovInfo* povInfo2 = [self.povLoadManager getPOVInfoAtIndex:rightPOVIndex + 1];
        if(povInfo1){
            POVView* povView = [[POVView alloc] initWithFrame: [self getFrameForPovAtIndex:rightPOVIndex] andPOVInfo:povInfo1];
            [self.povViews insertObject:povView atIndex:rightPOVIndex];
            [self.scrollView addSubview:povView];
        }
        if(povInfo2){
            POVView* povView = [[POVView alloc] initWithFrame: [self getFrameForPovAtIndex:rightPOVIndex + 1] andPOVInfo:povInfo2];
            [self.povViews insertObject:povView atIndex:rightPOVIndex + 1];
            [self.scrollView addSubview:povView];
        }
    }else if (currentPageIndex > 0) {
        //we are on the second page so the next one is already loaded
        if(self.povViews[leftPOVIndex] == [NSNull null]){
            PovInfo* povInfo = [self.povLoadManager getPOVInfoAtIndex:leftPOVIndex];
            POVView* povView = [[POVView alloc] initWithFrame: [self getFrameForPovAtIndex:leftPOVIndex] andPOVInfo:povInfo];
            [self.povViews insertObject:povView atIndex:leftPOVIndex];
            
            [self.scrollView addSubview:povView];
        }
        if(self.povViews[rightPOVIndex] == [NSNull null]){
            PovInfo* povInfo = [self.povLoadManager getPOVInfoAtIndex:rightPOVIndex];
            POVView* povView = [[POVView alloc] initWithFrame: [self getFrameForPovAtIndex:rightPOVIndex] andPOVInfo:povInfo];
            [self.povViews insertObject:povView atIndex:rightPOVIndex];
            [self.scrollView addSubview:povView];
        }
    }
    
    [self updateScrollview];
}



-(CGRect) getFrameForPovAtIndex:(NSInteger) index{
    return CGRectMake(index * self.view.frame.size.width, 0.f, self.view.frame.size.width, self.view.frame.size.height);
}


//makes the size as large as there are views
-(void)updateScrollview{
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.povViews.count, 0);
}


#pragma mark - POVView Delegate (Like button) -

-(void) likeButtonLiked:(BOOL)liked onPOV: (PovInfo*) povInfo {
	[self.updatingPOVManager povWithId:povInfo.identifier wasLiked: liked];
	[self.delegate userLiked:liked POV:povInfo];
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
		[self.activityIndicator stopAnimating];
	}
    [[Analytics getSharedInstance] storyEndedViewing];
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
        _scrollView.delegate = self;
	}
	return _scrollView;
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
