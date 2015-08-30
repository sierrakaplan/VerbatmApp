//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "MasterNavigationVC.h"
#import "VerbatmUser.h"
#import "Notifications.h"
#import "Identifiers.h"
#import "Icons.h"
#import "VerbatmCameraView.h"
#import "MediaSessionManager.h"
#import "internetConnectionMonitor.h"
#import <AVFoundation/AVAudioSession.h>
@interface MasterNavigationVC ()
@property (weak, nonatomic) IBOutlet UIView *profileVcContainer;

@property (weak, nonatomic) IBOutlet UIScrollView *masterSV;
@property (weak, nonatomic) IBOutlet UIView *adkContainer;
@property (weak, nonatomic) IBOutlet UIView *articleListContainer;
//stores the index of the view that brings up the article display in order to aid our return
@property (weak, nonatomic) IBOutlet UIButton *profileNavButton;
@property (weak, nonatomic) IBOutlet UIButton *adkNavButton;
@property (nonatomic) NSInteger lastViewIndex;
@property (nonatomic, strong) NSMutableArray * pagesToDisplay;
@property (nonatomic, strong) NSMutableArray * pinchViewsToDisplay;
@property (nonatomic) CGPoint previousGesturePoint;

@property (strong, nonatomic) NSTimer * animationTimer;
@property (strong,nonatomic) UIImageView* animationView;

@property (strong, nonatomic) internetConnectionMonitor * connnectionMinitor;


#define ANIMATION_DURATION 0.5
#define NUMBER_OF_CHILD_VCS 3
#define LEFT_FRAME self.view.bounds
#define CENTER_FRAME CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
#define RIGHT_FRAME CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height)


#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5

#define NAVICON_WALL_OFFSET 10 //distance between icons and the side of the screen
#define NAVICON_WIDTH 75 //frame width
#define NAVICON_HEIGHT 100 //frame height
@end

@implementation MasterNavigationVC

+ (BOOL) inTestingMode {
	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view insertSubview: self.verbatmCameraView atIndex:0];
	// Do any additional setup after loading the view.
	[self formatVCS];
	[self registerForNavNotifications];    
    self.connnectionMinitor = [[internetConnectionMonitor alloc] init];
    [self positionNavViews];
   
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self login];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

//position the nav views in appropriate places and set frames
-(void)positionNavViews {
    self.profileNavButton.frame = CGRectMake(self.view.frame.size.width + NAVICON_WALL_OFFSET, self.view.frame.size.height - NAVICON_WALL_OFFSET -
                                    NAVICON_HEIGHT, NAVICON_WIDTH, NAVICON_HEIGHT);
    self.adkNavButton.frame = CGRectMake((self.view.frame.size.width*2) - NAVICON_WALL_OFFSET - NAVICON_WIDTH,
                                         self.profileNavButton.frame.origin.y, NAVICON_WIDTH, NAVICON_HEIGHT);
    
    [self.profileNavButton removeFromSuperview];
    [self.adkNavButton removeFromSuperview];
    
    [self.masterSV addSubview:self.profileNavButton];
    [self.masterSV addSubview:self.adkNavButton];
    [self.masterSV bringSubviewToFront:self.profileNavButton];
    [self.masterSV bringSubviewToFront:self.adkNavButton];
}


//creates the camera view with the preview session
-(VerbatmCameraView*)verbatmCameraView{
	if(!_verbatmCameraView) {
		_verbatmCameraView = [[VerbatmCameraView alloc]initWithFrame: self.view.bounds];
	}
	return _verbatmCameraView;
}

-(MediaSessionManager*)sessionManager {
	if(!_sessionManager) {
		_sessionManager = [[MediaSessionManager alloc] initSessionWithView:self.verbatmCameraView];
	}
	return _sessionManager;
}

-(void)registerForNavNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showADK:) name:NOTIFICATION_SHOW_ADK object: nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveArticleDisplay:) name:NOTIFICATION_EXIT_ARTICLE_DISPLAY object: nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showArticleList:) name:NOTIFICATION_EXIT_CONTENTPAGE object: nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertTitleAnimation) name:NOTIFICATION_INFO_IS_BLANK_ANIMATION object: nil];
}


-(void) showADK: (NSNotification *) notification {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
	}completion:^(BOOL finished) {
	}];
}

-(void)showArticleList:(NSNotification *)notification {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(0, 0);
	}completion:^(BOOL finished) {
		if(finished) {
			[self articlePublishedAnimation];
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLEAR_CONTENTPAGE
																object:nil userInfo:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_FEED
																object:nil
															  userInfo:nil];
		}
	}];
}


//no longer being done
-(void)leaveArticleDisplay: (NSNotification *) notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self dismissViewControllerAnimated:YES completion:nil];
}

//article published sucessfully
-(void)articlePublishedAnimation {
	if(self.animationView.frame.size.width) return;
	self.animationView.image = [UIImage imageNamed:PUBLISHED_ANIMATION_ICON];
	self.animationView.frame = self.view.bounds;
	[self.view addSubview:self.animationView];
	if(!self.animationView.alpha)self.animationView.alpha = 1;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeAnimationView) userInfo:nil repeats:YES];
}


-(void)removeAnimationView {
	[UIView animateWithDuration:ANIMATION_NOTIFICATION_DURATION animations:^{
		self.animationView.alpha=0;
	}completion:^(BOOL finished) {
		self.animationView.frame = CGRectMake(0,0,0,0);
	}];
}



//insert title
-(void)insertTitleAnimation {
	if(self.animationView.frame.size.width) return;
	self.animationView.image = [UIImage imageNamed:TITLE_NOTIFICATION_ANIMATION];
	self.animationView.frame = self.view.bounds;
	if(!self.animationView.alpha)self.animationView.alpha = 1;
	[self.view addSubview:self.animationView];
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_UNTIL_ANIMATION_CLEAR target:self selector:@selector(removeAnimationView) userInfo:nil repeats:YES];
}



//lazy instantiation
-(UIImageView *)animationView {
    if(!_animationView)_animationView = [[UIImageView alloc] init];
	return _animationView;
}


//lays out all the containers in the right position and also sets the appropriate
//offset for the master SV
-(void)formatVCS {
	self.masterSV.frame = self.view.bounds;
	self.masterSV.contentSize = CGSizeMake(self.view.frame.size.width* 3, 0);//enable horizontal scroll
	self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);//start at the center
    self.profileVcContainer.frame = LEFT_FRAME;
	self.articleListContainer.frame = CENTER_FRAME;
	self.adkContainer.frame = RIGHT_FRAME;
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

#pragma mark - Nav Buttons Pressed -
//nav button is pressed so we move the SV right to the ADK
- (IBAction)moveToAdk:(UIButton *)sender {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width * 2, 0);
    }];
    
}

//nav button is pressed - so we move the SV left to the profile
- (IBAction)moveToProfile:(id)sender {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.masterSV.contentOffset = CGPointMake(0, 0);
    }];
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

@end
