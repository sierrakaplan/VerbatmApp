//
//  verbatmAppNavigatorViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmAppNavigatorViewController.h"
#import "verbatmMediaPageViewController.h"
#import "verbatmArticleAquirer.h"
@interface verbatmAppNavigatorViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *baseNavigator_SV;
@property (weak, nonatomic) IBOutlet UIView *listContainer;
@property (weak, nonatomic) IBOutlet UIView *ADK_container;

#pragma mark - view controllers
//@property (strong,nonatomic) verbatmContentPageViewController* vc_contentPage;

@end

//class to be implemented later
@implementation verbatmAppNavigatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)formatSV
{
    self.baseNavigator_SV.frame = self.view.bounds;
    self.baseNavigator_SV.contentSize = CGSizeMake(self.view.frame.size.width * 2, 0);
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
