//
//  articleLoadAndDisplayManager.h
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "singleArticlePresenter.h"

/*
 ArticleLoadAndDisplay handles the downloading of articles as well as the entire list of articles being presented.
 It is the class that links all our views to the other Modal classes as it pertains to managing articles already saved in our DB.
 */
@protocol articleLoadAndDisplayProtocol <NSObject>
    /*informs the delegate that the left/right article relative tot he current presented article is being shown*/
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
