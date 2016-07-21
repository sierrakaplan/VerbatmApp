//
//  onBoardingViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/11/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "OnBoardingViewController.h"

@interface OnBoardingViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *svImageHolder;

@end

@implementation OnBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.svImageHolder.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
