//
//  onBoardingViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/11/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "onBoardingViewController.h"

@interface onBoardingViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *svImageHolder;

@end

@implementation onBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.svImageHolder.frame = self.view.bounds;
}


-(void)setUpImages{
    
   
    
    
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
