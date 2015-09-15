//
//  ArticleDisplayVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/14/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"

#import "GTLVerbatmAppPOVInfo.h"
#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

#import "POVDisplayScrollView.h"
#import "POVLoadManager.h"
#import "POVView.h"

@interface ArticleDisplayVC ()

@property (strong, nonatomic) POVDisplayScrollView* scrollView;

//array of POVView's currently on scrollview
@property (strong, nonatomic) NSMutableArray* povViews;

//Should not retain strong reference to the load manager since the
//ArticleListVC also contains a reference to it
@property (weak, nonatomic) POVLoadManager* loadManager;

// Dictionary of Arrays of GTLVerbatmAppImage's associated with their Page Id's
@property NSMutableDictionary* imagesInPage;

// Dictionary of Arrays of GTLVerbatmAppVideo's associated with their Page Id's
@property NSMutableDictionary* videosInPage;

@end

@implementation ArticleDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
	// Should always have 4 stories in memory (two in the direction of scroll, current, and one back)
	self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*4, self.view.bounds.size.height);
}


// When user clicks story, loads one behind it and the two ahead
-(void) loadStory: (NSInteger) index fromLoadManager: (POVLoadManager*) loadManager {
	self.loadManager = loadManager;
	GTLVerbatmAppPOVInfo* povInfo = [self.loadManager getPOVInfoAtIndex:index];
	NSNumber* povID = povInfo.identifier;
}

// When user scrolls to a new story, loads the next two in that
// direction of scroll
-(void) loadNextTwoStories: (NSInteger) index {

}

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




@end
