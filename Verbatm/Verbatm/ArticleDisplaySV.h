//
//  verbatmArticleDisplayCV.h
//  Verbatm
//
//  Created by Iain Usiri on 6/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchView.h"
#import "articleLoadAndDisplayManager.h"
@interface ArticleDisplaySV : UIScrollView
-(void)presentArticleWithStartingIndex:(NSInteger) index;
//these two are here so the functions can be called in a block
-(void)startActivityIndicator;
-(void)stopActivityIndicator;

-(instancetype)initWithFrame:(CGRect)frame andArticleLoadManager:
(articleLoadAndDisplayManager *) articleManager;
@end
