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

@interface ArticleDisplayVC () <UIScrollViewDelegate, POVLoadManagerDelegate>

@property (strong, nonatomic) POVDisplayScrollView* scrollView;

//array of POVView's currently on scrollview
@property (strong, nonatomic) NSMutableArray* povViews;

//needs to associate which pov id is at which index
@property (strong, nonatomic) NSMutableArray* povIDs;

//Should not retain strong reference to the load manager since the
//ArticleListVC also contains a reference to it
@property (strong, nonatomic) POVLoadManager* povLoadManager;

// In charge of updating information about a pov (number of likes, etc.)
@property (strong, nonatomic) UpdatingPOVManager* updatingPOVManager;

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

@property (nonatomic) NSInteger currentIndexInView;

#define ACTIVITY_ANIMATION_Y 100
#define NUM_POVS_IN_SECTION 20
#define NUM_POVS_LOADED_BEFORE 2
#define NUM_POVS_LOADED_AFTER 2
@end

@implementation ArticleDisplayVC

- (void)viewDidLoad {
	[super viewDidLoad];
	//TODO: should always have 4 stories in memory (two in the direction of scroll, current, and one back)
	self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
	[self.view addSubview: self.scrollView];
}

-(void) presentContentWithPOVType: (POVType) povType andChannel:(NSString *) channel{
    if(povType == POVTypeUser){
        //will be changed to show different people on
        NSNumber* aishwaryaId = [NSNumber numberWithLongLong:5432098273886208];
        self.povLoadManager = [[POVLoadManager alloc] initWithUserId: aishwaryaId andChannel:channel];
        self.povLoadManager.delegate = self;
        [self.povLoadManager reloadPOVs: NUM_POVS_IN_SECTION];
    }else{
        self.povLoadManager = [[POVLoadManager alloc] initWithType:povType];
        self.povLoadManager.delegate = self;
        [self.povLoadManager reloadPOVs: NUM_POVS_IN_SECTION];
    }
}


// When user clicks story, loads one behind it and the two ahead
-(void) loadStoryFromStart {
    self.currentIndexInView = 0;//So that the first screen plays
    [self preparePOVatIndex:0];
    [self playViewOnScreen];
    //[self loadNextStoriesWithNumberOfPOVsBefore:NUM_POVS_LOADED_BEFORE andNumberOfPOVsAfter:NUM_POVS_LOADED_AFTER];


    //    [[Analytics getSharedInstance]storyStartedViewing:povInfo.title];

}

-(void)createLoadManger{
    
}


#pragma mark - Load Manger Profile -

//load manager protocol
-(void) povsRefreshed{
    [self loadStoryFromStart];
     [self updateScrollview];
}

// Successfully loaded more POV's
-(void) morePOVsLoaded: (NSInteger) numLoaded {
     [self updateScrollview];
}
// Was unable to load more POV's for some reason
-(void) failedToLoadMorePOVs{
    
}
// Was unable to refresh POV's for some reason
-(void) povsFailedToRefresh{
    
}

#pragma mark -manage multiple stories present-

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self playViewOnScreen];
    [self loadNextStoriesWithNumberOfPOVsBefore:NUM_POVS_LOADED_BEFORE andNumberOfPOVsAfter:NUM_POVS_LOADED_AFTER];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

-(void)playViewOnScreen{
    NSInteger indexOfViewBeingDisplayed = self.scrollView.contentOffset.x/self.view.frame.size.width;
    if(indexOfViewBeingDisplayed == self.currentIndexInView){
        [self loadNextStoriesWithNumberOfPOVsBefore:NUM_POVS_LOADED_BEFORE andNumberOfPOVsAfter:NUM_POVS_LOADED_AFTER];
    }else{
        if(self.povViews[self.currentIndexInView] != [NSNull null]){
            [(POVView *)self.povViews[self.currentIndexInView] povOffScreen];
        }
        if(self.povViews[indexOfViewBeingDisplayed] != [NSNull null]){
            [(POVView *)self.povViews[indexOfViewBeingDisplayed] povOnScreen];
            self.currentIndexInView = indexOfViewBeingDisplayed;
        }else{
            [self preparePOVatIndex:indexOfViewBeingDisplayed];
            [(POVView *)self.povViews[indexOfViewBeingDisplayed] povOnScreen];
        }
    }
}

/*
 Makes sure that there are a certain number of POVs prepared before and after the current view. 
 This makes it easier to load and play videos swiftly.
 
 */
-(void) loadNextStoriesWithNumberOfPOVsBefore:(NSInteger) numPOVsBefore andNumberOfPOVsAfter:(NSInteger) numPOVsAfter {
    NSInteger currentPageIndex = self.scrollView.contentOffset.x/self.view.frame.size.width;
    
    NSInteger minIndex = currentPageIndex - numPOVsBefore;
    NSInteger maxIndex = currentPageIndex + numPOVsAfter;
    
    for(NSInteger i = 0; i < self.povViews.count; i++){
        id currentView = self.povViews[i];
        if((minIndex <= i) && (i <= maxIndex) && (i != currentPageIndex)) {
            if(currentView == [NSNull null]){
                [self preparePOVatIndex:i];
            }
        }else if (i != currentPageIndex){
            if(currentView != [NSNull null]){
                [(POVView *)currentView clearArticle];
                [(POVView *)currentView removeFromSuperview];
                self.povViews[i] = [NSNull null];
            }
        }
    }
}

-(void)preparePOVatIndex:(NSInteger) index {
    PovInfo* povInfo = [self.povLoadManager getPOVInfoAtIndex:index];
    if(povInfo){
        POVView* povView = [[POVView alloc] initWithFrame: [self getFrameForPovAtIndex:index] andPovParseObject:nil];
        [self.povViews replaceObjectAtIndex:index withObject:povView];
        [self.scrollView addSubview:povView];
        [povView preparePOVToBePresented];
    }
}

-(void) dropUnusedPOVExceptleft:(NSInteger) left center:(NSInteger) center right:(NSInteger) right{
    for(int i = 0; i < self.povViews.count; i++){
        @autoreleasepool {
            if((self.povViews[i] != [NSNull null]) && //make sure it's not already null
               ((i != left) && (i != center) && (i != right))){
                
                [(POVView *)self.povViews[i] clearArticle];
                [(POVView *)self.povViews[i] removeFromSuperview];
                self.povViews[i] = [NSNull null];
            }
        }
    }
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



-(void) setPOVArrayToNull{
    for(int i = 0; i < NUM_POVS_IN_SECTION;i++){
        [self.povViews addObject:[NSNull null]];
    }
}

#pragma mark - Clean up -

// Reverses load Article and removes all content
-(void) cleanUp {
    @autoreleasepool {
        for (POVView* povView in self.povViews) {
            [povView clearArticle];
            [povView removeFromSuperview];
        }
        self.povViews = nil;
        self.povIDs = nil;
        if ([self.activityIndicator isAnimating]) {
            [self.activityIndicator stopAnimating];
        }
        self.povLoadManager = nil;
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
		_povViews = [[NSMutableArray alloc] initWithCapacity:NUM_POVS_IN_SECTION];
        [self setPOVArrayToNull];
	}
	return _povViews;
}

-(NSArray*) povIDs {
	if (!_povIDs) {
		_povIDs = [[NSMutableArray alloc] init];
	}
	return _povIDs;
}

-(void)onScreen{
    [self playViewOnScreen];
    [self loadNextStoriesWithNumberOfPOVsBefore:NUM_POVS_LOADED_BEFORE andNumberOfPOVsAfter:NUM_POVS_LOADED_AFTER];
}

-(void)offScreen{
    for(id povView  in self.povViews){
        if([povView isKindOfClass:[POVView class]]){
            [(POVView *)povView povOffScreen];
        }
    }
}


@end
