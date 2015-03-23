//
//  VIEW_TESTERViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 3/23/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VIEW_TESTERViewController.h"
#import "verbatmPhotoVideoAve.h"
#import "verbatmCustomImageView.h"
@interface VIEW_TESTERViewController ()
@property (strong, nonatomic) verbatmPhotoVideoAve* pv_ave;

@end

@implementation VIEW_TESTERViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    verbatmCustomImageView * IV = [[verbatmCustomImageView alloc] initWithImage:<#(UIImage *)#>];
    
    
    // Do any additional setup after loading the view.
    self.pv_ave = [[verbatmPhotoVideoAve alloc]initWithFrame:self.view.frame Image:<#(verbatmCustomImageView *)#> andVideo:<#(verbatmCustomImageView *)#>]
    
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
