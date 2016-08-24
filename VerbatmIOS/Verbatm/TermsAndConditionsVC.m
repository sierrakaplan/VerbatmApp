//
//  TermsAndConditionsVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
#import "CustomNavigationBar.h"
#import "Icons.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "TermsAndConditionsVC.h"
#import "UserSetupParameters.h"

@interface TermsAndConditionsVC ()<CustomNavigationBarDelegate>

@property (nonatomic) CustomNavigationBar *navigationBar;
@property (nonatomic) UIScrollView *scrollView;

@end

@implementation TermsAndConditionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self createNavigationBar];
	self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0.f, CUSTOM_NAV_BAR_HEIGHT,
																	  self.view.frame.size.width,
																	  self.view.frame.size.height - CUSTOM_NAV_BAR_HEIGHT)];
	UIImage *image = [UIImage imageNamed: TERMS_AND_CONDITIONS];
	CGFloat ratio = image.size.height/image.size.width;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f,
																		   self.view.frame.size.width,
																		   ratio * self.view.frame.size.width)];
	imageView.contentMode = UIViewContentModeScaleToFill;
	imageView.image = image;
	self.scrollView.contentSize = imageView.frame.size;
	[self.scrollView addSubview: imageView];
	[self.view addSubview: self.scrollView];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void)createNavigationBar{
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT);
    self.navigationBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:SETTINGS_NAV_BAR_COLOR];
    self.navigationBar.delegate = self;
    [self.navigationBar createLeftButtonWithTitle:@"BACK" orImage:nil];
    [self.view addSubview:self.navigationBar];
}

//user selected back so remove view
-(void) leftButtonPressed{
    [self exitSettingsPage];
}

-(void)exitSettingsPage{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
