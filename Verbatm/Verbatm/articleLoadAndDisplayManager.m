//
//  articleLoadAndDisplayManager.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "articleLoadAndDisplayManager.h"
#import "Article.h"
#import "AVETypeAnalyzer.h"
#import "Page.h"

@interface articleLoadAndDisplayManager()
@property (strong, nonatomic) NSMutableArray * articleList;
//always 3 large. The present one is always the middle one
@property (strong, nonatomic) NSMutableArray * fullDownloadedArticleList;
@property (nonatomic) NSInteger currentPresentingIndex;
@end
@implementation articleLoadAndDisplayManager

//the starting index should be the index of the view that was just tapped first
//it tells us what is being presented first
-(instancetype)initWithArticleList: (NSMutableArray *) articleList andStartingIndex: (NSInteger) startingIndex{
    self = [super init];
    if(self){
        self.articleList = articleList;
        self.currentPresentingIndex = startingIndex;
    }
    return self;
}


-(void) getPinchViewsFromArticle:(Article *)article forRight:(BOOL) isRight {
	dispatch_queue_t articleDownload_queue = dispatch_queue_create("articleDisplay", NULL);
	dispatch_async(articleDownload_queue, ^{
		NSArray* pages = [article getAllPages];
		//we sort the pages by their page numbers to make sure everything is in the right order
		//O(nlogn) so should be fine in the long-run ;D
		pages = [pages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			Page * page1 = obj1;
			Page * page2 = obj2;
			if(page1.pagePosition < page2.pagePosition) return -1;
			if(page2.pagePosition > page1.pagePosition) return 1;
			return 0;
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableArray * pinchObjectsArray = [[NSMutableArray alloc]init];
			//get pinch views for our array
			for (Page * page in pages) {
				//here the radius and the center dont matter because this is just a way to wrap our data for the analyser
				PinchView * pinchView = [page getPinchObjectWithRadius:0 andCenter:CGPointMake(0, 0)];
				if (!pinchView) {
					NSLog(@"Pinch view from parse should not be Nil.");
					return;
				}
                [pinchObjectsArray addObject:pinchView];
			}
            [self getPagesFromPinchViews:pinchObjectsArray forRight:isRight];
		});
	});
}

-(NSMutableArray *)getPagesFromPinchViews: (NSMutableArray *) pinchViews forRight:(BOOL) isRight{
    AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc]init];
    return [analyzer processPinchedObjectsFromArray:pinchViews withFrame:self.view.frame];
}


-(NSMutableArray *) fullDownloadedArticleList{
    if(!_fullDownloadedArticleList)_fullDownloadedArticleList = [[NSMutableArray alloc] init];
    return _fullDownloadedArticleList;
}


@end
