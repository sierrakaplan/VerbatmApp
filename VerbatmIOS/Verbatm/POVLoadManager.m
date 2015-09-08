//
//  POVLoadManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/7/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVLoadManager.h"

@interface POVLoadManager()

@property (strong, nonatomic, readwrite) NSArray * articleList;
//always 3 large. The present one is always the middle one
@property (strong, nonatomic) NSMutableArray * fullDownloadedArticleList;
@property (nonatomic) NSInteger currentPresentingIndex;

@end

@implementation POVLoadManager

////the starting index should be the index of the view that was just tapped first
////it tells us what is being presented first
//-(instancetype)initWithArticleList: (NSArray *) articleList andStartingIndex: (NSInteger) startingIndex{
//    self = [super init];
//    if(self){
//        self.articleList = articleList;
//        self.currentPresentingIndex = startingIndex;
//    }
//    return self;
//}
/*

-(void) getPinchViewsFromArticle:(Article *)article withFrame:(CGRect)frame onCompletion:(void(^)(POVView *))completionBlock {
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
			NSMutableArray * pageArray = [[NSMutableArray alloc]init];
			//get pinch views for our array
			for (Page * page in pages) {
				//here the radius and the center dont matter because this is just a way to wrap our data for the analyser
				PinchView * pinchView = [page getPinchObjectWithRadius:0 andCenter:CGPointMake(0, 0)];
				if (!pinchView) {
					NSLog(@"Pinch view from parse should not be nil.");
					return;
				}
				[pageArray addObject:pinchView];
			}

			POVView * presenter = [[POVView alloc] initWithFrame:frame andAVES:pageArray];
			completionBlock(presenter);
		});
	});
}

-(BOOL)fetchArticleWithIndex:(NSInteger) index withFrame:(CGRect)frame onCompletion:(void(^)(POVView *))completionBlock {

	//if the index is out of bounds then we exit without downloading
	if(index < 0 || index >= self.articleList.count) return false;
	[self getPinchViewsFromArticle:self.articleList[index] withFrame:frame onCompletion:completionBlock];
	return true;
}


-(void)reloadArticleListWithCompletionBlock:(void (^)(void))onCompletion {
	//we want to download the articles again and then load them to the page
	[ArticleAquirer downloadAllArticlesWithBlock:^(NSArray *articles){
		NSArray *sortedArticles;
		sortedArticles = [articles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
			NSDate *first = ((Article*)a).createdAt;
			NSDate *second = ((Article*)b).createdAt;
			return [second compare:first];
		}];
		self.articleList = sortedArticles;

		onCompletion();
	}];
}

-(NSMutableArray *)getPagesFromPinchViews: (NSMutableArray *) pinchViews {
	return pinchViews;
	//AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc]init];
	//return [analyzer processPinchedObjectsFromArray:pinchViews withFrame:self.view.frame];
}

*/

-(NSArray *)articleList{
	if (!_articleList) {
		_articleList = @[];
	}
	return _articleList;

}

@end
