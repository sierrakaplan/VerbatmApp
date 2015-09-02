//
//  singleArticlePresenter.h
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POVView : UIScrollView
-(instancetype)initWithFrame:(CGRect)frame andArticleList: (NSMutableArray *) articlePages;
@end
