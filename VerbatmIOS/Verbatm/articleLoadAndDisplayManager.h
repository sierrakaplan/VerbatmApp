//
//  articleLoadAndDisplayManager.h
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "singleArticlePresenter.h"

/*This class manages the entire article stream as well as turning them into presentable views*/

@protocol articleLoadAndDisplayProtocol <NSObject>
-(void)rightArticleDidLoad:(singleArticlePresenter *) articleView;
-(void)leftArticleDidLoad:(singleArticlePresenter *) articleView;
@end

@interface articleLoadAndDisplayManager : NSObject
@property (strong, nonatomic) id<articleLoadAndDisplayProtocol> articleLDDelegate;
@property (strong, nonatomic, readonly) NSArray * articleList;

/*These two functions instruct our model to load and provide the next article to the left or right of the one presented
 They do not return anything and are reacted to through the protocol described above
 */
-(void)getRightArticle;
-(void)getLeftArticle;
-(BOOL)fetchArticleWithIndex:(NSInteger) index withFrame:(CGRect)frame onCompletion:(void(^)(singleArticlePresenter *))completionBlock;
-(void)reloadArticleListWithCompletionBlock:(void (^)(void))onCompletion;
@end
