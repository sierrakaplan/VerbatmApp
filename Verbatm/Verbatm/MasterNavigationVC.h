//
//  verbatmMasterNavigationViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleDisplayVC.h"

@interface MasterNavigationVC : ArticleDisplayVC
    @property(strong, nonatomic) NSMutableArray * pinchObjects;

	+ (BOOL) inTestingMode;
@end
