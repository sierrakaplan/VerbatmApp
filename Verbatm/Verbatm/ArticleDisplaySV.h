//
//  verbatmArticleDisplayCV.h
//  Verbatm
//
//  Created by Iain Usiri on 6/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchView.h"

@interface ArticleDisplaySV : UIScrollView
@property (atomic) BOOL articleCurrentlyViewing;//tells you if an article is currently being presented
- (void)exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender;
@end
