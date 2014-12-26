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
//The first object in the list will be the last to be shown in the Article 
@property (strong, nonatomic) NSMutableArray* pinchedObjects;
@end
