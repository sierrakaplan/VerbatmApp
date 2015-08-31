//
//  verbatmArticleDisplayCV.h
//  Verbatm
//
//  Created by Iain Usiri on 6/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchView.h"

/* Manges the presentation of 3 articles (singleArticlePresenter objects)  and communicates with the aritcleLoadandDisplayManager class. 
 Every time a user scrolls right we load the next singleArticlePresenter from the aritcleLoadandDisplayManager.
 */
@interface ArticleDisplayVC : UIViewController
@property (atomic) BOOL articleCurrentlyViewing;//tells you if an article is currently being presented
- (void)exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender;
@end
