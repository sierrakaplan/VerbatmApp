//
//  SearchResultsVC.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/1/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VerbatmNavigationController;
@class MasterNavigationVC;

@interface SearchResultsVC : UITableViewController <UISearchResultsUpdating>

@property (nonatomic) VerbatmNavigationController *verbatmNavigationController;
@property (nonatomic) MasterNavigationVC *verbatmTabBarController;

@end
