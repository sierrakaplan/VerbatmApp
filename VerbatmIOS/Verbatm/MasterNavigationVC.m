//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "articleLoadAndDisplayManager.h"
#import <AVFoundation/AVAudioSession.h>
#import "Identifiers.h"
#import "Icons.h"
#import "internetConnectionMonitor.h"
#import "MasterNavigationVC.h"
#import "MediaSessionManager.h"
#import "Notifications.h"
#import "VerbatmUser.h"
#import "VerbatmCameraView.h"

#import "ProfileVC.h"
#import "FeedVC.h"
#import "MediaDevVC.h"


@interface MasterNavigationVC () <NavButtonsDelegate>
@property (weak, nonatomic) IBOutlet UIView * profileContainer;
@property (weak, nonatomic) IBOutlet UIView * adkContainer;
@property (weak, nonatomic) IBOutlet UIView * feedContainer;

//Child view controllers
@property (strong,nonatomic) ProfileVC* profileVC;
@property (strong,nonatomic) FeedVC* feedVC;
@property (strong,nonatomic) MediaDevVC* mediaDevVC;

@property (weak, nonatomic) IBOutlet UIScrollView * masterSV;

@property (nonatomic, strong) NSMutableArray * pagesToDisplay;
@property (nonatomic, strong) NSMutableArray * pinchViewsToDisplay;
@property (nonatomic) CGPoint previousGesturePoint;

@property (strong, nonatomic) NSTimer * animationTimer;
@property (strong,nonatomic) UIImageView* animationView;

@property (strong, nonatomic) internetConnectionMonitor * connectionMonitor;
@property (strong, nonatomic) articleLoadAndDisplayManager * articleLoadManager;

#define ANIMATION_DURATION 0.5
#define NUMBER_OF_CHILD_VCS 3
#define LEFT_FRAME self.view.bounds
#define CENTER_FRAME CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
#define RIGHT_FRAME CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height)
#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5

#define ID_FOR_FEEDVC @"feed_vc"
#define ID_FOR_MEDIADEVVC @"media_dev_vc"
#define ID_FOR_PROFILEVC @"profile_vc"

@end

@implementation MasterNavigationVC

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	[self getAndFormatVCs];
	[self formatMainScrollView];

    self.connectionMonitor = [[internetConnectionMonitor alloc] init];
    self.articleLoadManager = [[articleLoadAndDisplayManager alloc] init];
    [self propogateArticleLoadManager];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self login];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - Getting and formatting child view controllers -

//lays out all the containers in the right position and also sets the appropriate
//offset for the master SV
-(void) getAndFormatVCs {
	self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_FEEDVC];
	self.feedVC.navButtonsDelegate = self;
	self.mediaDevVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_MEDIADEVVC];
	self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_PROFILEVC];

	self.profileContainer.frame = LEFT_FRAME;
	self.feedContainer.frame = CENTER_FRAME;
	self.adkContainer.frame = RIGHT_FRAME;
}

-(void) formatMainScrollView {
	self.masterSV.frame = self.view.bounds;
	self.masterSV.contentSize = CGSizeMake(self.view.frame.size.width* 3, 0);
	self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
}

#pragma mark - Nav Buttons Pressed Delegate -

//nav button is pressed - so we move the SV left to the profile
-(void) profileButtonPressed {
	[self showProfile];
}

//nav button is pressed so we move the SV right to the ADK
-(void) adkButtonPressed {
	[self showADK];
}

// Scrolls the main scroll view over to reveal the ADK
-(void) showADK {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width * 2, 0);
	}];
}

-(void) showProfile {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(0, 0);
	}];
}

// Scrolls the main scroll view over to reveal the feed
-(void) showFeed {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(0, 0);
	}completion:^(BOOL finished) {
		if(finished) {
			//TODO: set article published animation only when article actually publishes
//			[self articlePublishedAnimation];
			[self.feedVC refreshFeed];
		}
	}];
}

#pragma mark - Animations - 

//article published sucessfully
-(void)articlePublishedAnimation {
	if(self.animationView.frame.size.width) return;
	self.animationView.image = [UIImage imageNamed:PUBLISHED_ANIMATION_ICON];
	self.animationView.frame = self.view.bounds;
	[self.view addSubview:self.animationView];
	if(!self.animationView.alpha)self.animationView.alpha = 1;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeAnimationView) userInfo:nil repeats:YES];
}

//insert title
//TODO: Move this to the ContentDevVC
-(void)insertTitleAnimation {
	if(self.animationView.frame.size.width) return;
	self.animationView.image = [UIImage imageNamed:TITLE_NOTIFICATION_ANIMATION];
	self.animationView.frame = self.view.bounds;
	if(!self.animationView.alpha)self.animationView.alpha = 1;
	[self.view addSubview:self.animationView];
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_UNTIL_ANIMATION_CLEAR target:self selector:@selector(removeAnimationView) userInfo:nil repeats:YES];
}

-(void) removeAnimationView {
	[UIView animateWithDuration:ANIMATION_NOTIFICATION_DURATION animations:^{
		self.animationView.alpha=0;
	}completion:^(BOOL finished) {
		self.animationView.frame = CGRectMake(0,0,0,0);
	}];
}


//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden {
	return YES;
}

-(void) removeStatusBar {
	//remove the status bar
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
		// iOS 7
		[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
	} else {
		// iOS 6
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	}
}

#pragma mark - Article Presentation - 

//this function is called by our listView and it passes a block for us to handle the reload
-(void)reloadArticleList: (NSNotification *) notification{
}


/*we send a copy of this instance to the different classes that need to reference it in order to process
 articles. Right now it's ArticleListVC*/
-(void)propogateArticleLoadManager{
//    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:@[self.articleLoadManager],KEY_ARTICLELOAGMANAGER, nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROPOGATE_ARTICLELOAGMANAGER
//                                                        object:nil
//                                                      userInfo:Info];
}


#pragma mark - Handle Login -

-(void) login {
	if(![VerbatmUser currentUser]) {
		[self bringUpSignUp];
	}
}

//brings up the login page if there is no user logged in
-(void)bringUpSignUp {
	[self performSegueWithIdentifier:BRING_UP_SIGNIN_SEGUE sender:self];
}

#pragma mark - handle
-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
	//return supported orientation masks
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//catches the unwind segue - do nothing
- (IBAction)done:(UIStoryboardSegue *)segue {
}


#pragma mark - Lazy Instantiation -

//lazy instantiation
-(UIImageView *)animationView {
    if(!_animationView)_animationView = [[UIImageView alloc] init];
    return _animationView;
}

@end
