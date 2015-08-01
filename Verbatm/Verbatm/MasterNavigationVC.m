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

@interface MasterNavigationVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *masterSV;
@property (weak, nonatomic) IBOutlet UIView *adkContainer;
@property (weak, nonatomic) IBOutlet UIView *articleListContainer;
@property (nonatomic) NSInteger lastViewIndex;//stores the index of the view that brings up the article display in order to aid our return
@property (nonatomic, strong) NSMutableArray * pagesToDisplay;
@property (nonatomic, strong) NSMutableArray * pinchViewsToDisplay;
@property (nonatomic) CGPoint previousGesturePoint;

@property (strong, nonatomic) NSTimer * animationTimer;
@property (strong,nonatomic) UIImageView* animationView;

#define ANIMATION_DURATION 0.5
#define NUMBER_OF_CHILD_VCS 3
#define LEFT_FRAME self.view.bounds
#define RIGHT_FRAME CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)

#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5
@end

@implementation MasterNavigationVC

+ (BOOL) inTestingMode {
	return NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view insertSubview: self.verbatmCameraView atIndex:0];
	// Do any additional setup after loading the view.
	[self formatVCS];
	[self registerForNavNotifications];
	[self setUpEdgePanGestureRecognizers];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self login];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

//creates the camera view with the preview session
-(VerbatmCameraView*)verbatmCameraView
{
	if(!_verbatmCameraView){
		_verbatmCameraView = [[VerbatmCameraView alloc]initWithFrame: self.view.bounds];
	}
	return _verbatmCameraView;
}

-(MediaSessionManager*)sessionManager
{
	if(!_sessionManager){
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

-(void)setUpEdgePanGestureRecognizers {
	UIScreenEdgePanGestureRecognizer* edgePanR = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(enterADK:)];
	edgePanR.edges =  UIRectEdgeRight;
	UIScreenEdgePanGestureRecognizer* edgePanL = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(exitADK:)];
	edgePanL.edges =  UIRectEdgeLeft;
	[self.view addGestureRecognizer: edgePanR];
	[self.view addGestureRecognizer: edgePanL];
}


//swipping left from right
-(void) enterADK:(UIScreenEdgePanGestureRecognizer *)sender {
	//we want only one finger doing anything when exiting
	if([sender numberOfTouches] >1) return;
	if(self.masterSV.contentOffset.x == self.view.frame.size.width) return;

	switch(sender.state) {
		case UIGestureRecognizerStateBegan: {
			self.previousGesturePoint  = [sender locationOfTouch:0 inView:self.view];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			CGPoint current_point= [sender locationOfTouch:0 inView:self.view];;
			int diff = current_point.x - self.previousGesturePoint.x;
			self.previousGesturePoint = current_point;
			self.masterSV.contentOffset = CGPointMake(self.masterSV.contentOffset.x + (-1 *diff), 0);
			break;
		}
		case UIGestureRecognizerStateEnded: {
			[self adjustSV];
			break;
		}
		default:
			return;
	}
}

//swipping right from left
- (void)exitADK:(UIScreenEdgePanGestureRecognizer *)sender {

	//this is here because this sense the left edge pan gesture- so we need to catch it and send it upstream
	if(super.articleCurrentlyViewing) {
		//we send the signal back up to it's superview to be handled
		[super exitDisplay:sender];
		return;
	}
	if(self.masterSV.contentOffset.x == 0) return;
	//we want only one finger doing anything when exiting
	if([sender numberOfTouches] >1) return;

	switch(sender.state) {
		case UIGestureRecognizerStateBegan: {
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDE_KEYBOARD
																object:nil
															  userInfo:nil];
			self.previousGesturePoint  = [sender locationOfTouch:0 inView:self.view];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			CGPoint currentPoint = [sender locationOfTouch:0 inView:self.view];;

			int diff = currentPoint.x - self.previousGesturePoint.x;
			self.previousGesturePoint = currentPoint;
			self.masterSV.contentOffset = CGPointMake(self.masterSV.contentOffset.x + (-1 *diff), 0);
			break;
		}
		case UIGestureRecognizerStateEnded: {
			[self adjustSV];
			break;
		}
		default:
			return;
	}
}


-(void)adjustSV {
	if(self.masterSV.contentOffset.x > (self.view.frame.size.width/2)) {
		//bring ADK into View
		[UIView animateWithDuration:ANIMATION_DURATION animations:^{
			self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
		}completion:^(BOOL finished) {
			if(finished) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_KEYBOARD
																	object:nil
																  userInfo:nil];
			}
		}];
	}else {
		//bring List into View
		[UIView animateWithDuration:ANIMATION_DURATION animations:^{
			self.masterSV.contentOffset = CGPointMake(0, 0);
		}completion:^(BOOL finished) {
		}];
	}
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
		self.animationView.frame = CGRectMake(0, 0, 0, 0);

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


-(void)formatVCS {
	self.masterSV.frame = self.view.bounds;
	self.masterSV.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);//enable horizontal scroll
	self.masterSV.contentOffset = CGPointMake(0, 0);//start at the left
	self.articleListContainer.frame = LEFT_FRAME;
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


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	//return supported orientation masks
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//catches the unwind segue
- (IBAction)done:(UIStoryboardSegue *)segue{
}



@end
