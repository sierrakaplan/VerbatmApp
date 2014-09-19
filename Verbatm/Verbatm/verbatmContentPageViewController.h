//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface verbatmContentPageViewController : UIViewController
@property(nonatomic,strong) NSString * sandWhichWhereString;
@property(nonatomic,strong) NSString * sandWhichWhatString;
@property(nonatomic,strong) NSString * articleContentString;
@property(nonatomic,strong) NSString * articleTitleString;
@property (strong, nonatomic) NSMutableArray * pageElements; //elements added to the scrollview- excludes uitextfields
@end
