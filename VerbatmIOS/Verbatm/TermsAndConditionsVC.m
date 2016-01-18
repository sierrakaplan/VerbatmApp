//
//  TermsAndConditionsVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
#import "CustomNavigationBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "TermsAndConditionsVC.h"

@interface TermsAndConditionsVC ()<CustomNavigationBarDelegate>
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsTitle;
@property (weak, nonatomic) IBOutlet UITextView *VerbatmTermsAndConditionsText;
@property (nonatomic) CustomNavigationBar * navigationBar;


#define VIEW_OFFSET_Y 50.f
#define TERMS_CONDITIONS_WALL_OFFSET 15.f

@end

@implementation TermsAndConditionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavigationBar];
    [self positionButtonViews];
}



-(void)createNavigationBar{
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT);
    self.navigationBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:SETTINGS_NAV_BAR_COLOR];
    self.navigationBar.delegate = self;
    [self.navigationBar createLeftButtonWithTitle:@"BACK" orImage:nil];
    [self.view addSubview:self.navigationBar];
}


-(void) positionButtonViews{
    
    CGRect tcTitleFrame = CGRectMake(0, CUSTOM_NAV_BAR_HEIGHT + VIEW_OFFSET_Y,
                                           self.view.frame.size.width,
                                           self.termsAndConditionsTitle.frame.size.height);
    self.termsAndConditionsTitle.frame = tcTitleFrame;
    
    CGRect tcTextFrame = CGRectMake(TERMS_CONDITIONS_WALL_OFFSET,
                                    self.termsAndConditionsTitle.frame.origin.y +
                                    self.termsAndConditionsTitle.frame.size.height +  VIEW_OFFSET_Y,
                                     self.view.frame.size.width - (2*TERMS_CONDITIONS_WALL_OFFSET),
                                     self.VerbatmTermsAndConditionsText.frame.size.height);
    
    self.VerbatmTermsAndConditionsText.frame = tcTextFrame;
    
}




//user selected back so remove view
-(void) leftButtonPressed{
    [self exitSettingsPage];
}

-(void)exitSettingsPage{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        //No code
    }];
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
