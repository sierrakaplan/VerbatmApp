//
//  articleDispalyViewController.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "verbatmCustomPinchView.h"

@interface articleDispalyViewController : UIViewController
@property (nonatomic, strong) NSMutableArray * Objects;//either pinchObjects or Pages
-(void) clearArticle;
@end
