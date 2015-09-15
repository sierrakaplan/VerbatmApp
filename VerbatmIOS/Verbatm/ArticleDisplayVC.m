//
//  ArticleDisplayVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/14/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"

@interface ArticleDisplayVC ()

// Dictionary of Arrays of GTLVerbatmAppImage's associated with their Page Id's
@property NSMutableDictionary* imagesInPage;

// Dictionary of Arrays of GTLVerbatmAppVideo's associated with their Page Id's
@property NSMutableDictionary* videosInPage;

@end

@implementation ArticleDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


// When user clicks story, loads one behind it and the two ahead
-(void) loadStory: (NSInteger) index {

}

// When user scrolls to a new story, loads the next two in that
// direction of scroll
-(void) loadNextTwoStories: (NSInteger) index {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
