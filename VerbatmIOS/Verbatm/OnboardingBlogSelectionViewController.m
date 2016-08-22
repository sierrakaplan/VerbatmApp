//
//  onboardingBlogSelectionViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 6/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "OnboardingBlogSelectionViewController.h"
#import "DiscoverVC.h"
#import "SizesAndPositions.h"
#import "StoryboardVCIdentifiers.h"
#import "Icons.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "Styles.h"

@interface OnboardingBlogSelectionViewController () <OnboardingBlogsDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UILabel *headerLabel;

#define HEADER_VIEW_HEIGHT STATUS_BAR_HEIGHT + 60.f
#define DONE_BUTTON_WIDTH 70.f
#define HEADER_Y_OFFSET 10.f
#define HEADER_X_OFFSET 5.f

@end

@implementation OnboardingBlogSelectionViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundImage];
	[self.view addSubview: self.headerView];
    self.tableContainerView.frame = CGRectMake(0.f, HEADER_VIEW_HEIGHT,
                                               self.view.frame.size.width, self.view.frame.size.height);
    self.tableContainerView.backgroundColor = [UIColor clearColor];
    [self addListVC];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)addListVC{
    DiscoverVC *followingScreen = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    followingScreen.onboardingBlogSelection = YES;
	followingScreen.onboardingDelegate = self;
    [self.tableContainerView addSubview:followingScreen.view];
    [self addChildViewController:followingScreen];
    [followingScreen didMoveToParentViewController:self];
    [self addDoneButton];
	[self addHeaderLabel];
}

-(void)addDoneButton {
    CGRect buttomFrame = CGRectMake(self.view.frame.size.width - (DONE_BUTTON_WIDTH + HEADER_X_OFFSET), HEADER_Y_OFFSET + STATUS_BAR_HEIGHT,
									DONE_BUTTON_WIDTH, HEADER_VIEW_HEIGHT - (HEADER_Y_OFFSET*2) - STATUS_BAR_HEIGHT);
    
    UIButton * done = [[UIButton alloc] initWithFrame:buttomFrame];
    [done addTarget:self action:@selector(exitDiscover) forControlEvents:UIControlEventTouchUpInside];
    [done setTitle:@"DONE" forState:UIControlStateNormal];
	done.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
	done.layer.borderWidth = 3.f;
	done.layer.cornerRadius = 3.f;
	[done.titleLabel setFont:[UIFont fontWithName:BOLD_FONT size: 14.f]]; //todo
    [self.headerView addSubview:done];
}

-(void) addHeaderLabel {
	CGFloat headerLabelWidth = self.view.frame.size.width - (DONE_BUTTON_WIDTH + HEADER_X_OFFSET)*2;
	self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((DONE_BUTTON_WIDTH + HEADER_X_OFFSET),
																	 HEADER_Y_OFFSET + STATUS_BAR_HEIGHT, headerLabelWidth,
																	 HEADER_VIEW_HEIGHT - (HEADER_Y_OFFSET*2) - STATUS_BAR_HEIGHT)];
	self.headerLabel.text = @"Discover";
	[self.headerLabel setFont:[UIFont fontWithName:BOLD_FONT size: 20.f]]; //todo
	[self.headerLabel setTextColor:[UIColor whiteColor]];
	[self.headerLabel setTextAlignment:NSTextAlignmentCenter];
	[self.headerView addSubview: self.headerLabel];
}

// Onboarding delegate method
-(void) followingFriends {
	self.headerLabel.text = @"Follow your friends!";
}

-(void)exitDiscover{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		[[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:USER_FTUE];
		[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(error) {
				[[Crashlytics sharedInstance] recordError:error];
			}
		}];
    }];
}

-(void) addBackgroundImage {
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image =[UIImage imageNamed:DISCOVER_BACKGROUND];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:backgroundView belowSubview:self.tableContainerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation -

-(UIView*) headerView {
	if (!_headerView) {
		_headerView = [[UIView alloc] initWithFrame: CGRectMake(0.f, 0.f, self.view.frame.size.width, HEADER_VIEW_HEIGHT)];
		[_headerView setBackgroundColor:[UIColor colorWithRed:0.13 green:0.34 blue:0.6 alpha:1.f]];
	}
	return _headerView;
}

@end
