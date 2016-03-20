//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"

#import "CreateNewChannelView.h"
#import "Channel_BackendObject.h"

#import "Durations.h"

#import "GTLVerbatmAppVerbatmUser.h"

#import "LocalPOVs.h"

#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"

#import "POVScrollView.h"
#import "ProfileVC.h"
#import "ProfileNavBar.h"
#import "POVLoadManager.h"
#import "PostListVC.h"
//#import "POVListScrollViewVC.h"

#import "Post_BackendObject.h"
#import "POVView.h"
#import "PublishingProgressManager.h"

#import "SharePOVView.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "SettingsVC.h"

#import "UIView+Effects.h"
#import "UserManager.h"

@interface ProfileVC() <ArticleDisplayVCDelegate, ProfileNavBarDelegate,UIScrollViewDelegate,CreateNewChannelViewProtocol, POVScrollViewDelegate, SharePOVViewDelegate, PublishingProgressProtocol>

@property (strong, nonatomic) PostListVC * postListVC;

@property (nonatomic, strong) ProfileNavBar* profileNavBar;
@property (nonatomic) CGRect profileNavBarFrameOnScreen;
@property (nonatomic) CGRect profileNavBarFrameOffScreen;
@property (nonatomic) BOOL contentCoveringScreen;

@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic, strong) NSString * currentThreadInView;

@property (strong, nonatomic) NSArray* channels;

@property (strong, nonatomic) CreateNewChannelView * createNewChannelView;
@property (nonatomic) UIView * darkScreenCover;
@property (nonatomic) SharePOVView * sharePOVView;
@property (nonatomic) Channel_BackendObject * channelBackendManager;

#pragma mark Publishing

@property (nonatomic, strong) UIView* publishingProgressView;
@property (nonatomic, strong) NSProgress* publishingProgress;
@property (nonatomic, strong) UIProgressView* progressBar;

#define PROFILE_BACKGROUND_IMAGE @"d1"

@end

@implementation ProfileVC
-(void) viewDidLoad {
	[super viewDidLoad];
	self.contentCoveringScreen = YES;
    //this is where you'd fetch the threads
    [self getChannelsWithCompletionBlock:^{
        [self addPostListVC];
        [self createNavigationBar];
        [self addClearScreenGesture];
    }];
    self.view.clipsToBounds = YES;
}


//this is where downloading of channels should happen
-(void) getChannelsWithCompletionBlock:(void(^)())block{
    [Channel_BackendObject getChannelsForUser:self.userOfProfile withCompletionBlock:
     ^(NSMutableArray * channels) {
        self.channels = channels;
        block();
    }];
}

-(void) viewWillAppear:(BOOL)animated{
    if(self.postListVC)[self.postListVC continueVideoContent];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.postListVC)[self.postListVC stopAllVideoContent];
}

//-(void) createAndAddListVC{
//    self.postListVC = [[POVListScrollViewVC alloc] init];
//    self.postListVC.listOwner = self.userOfProfile;
//    if(self.startChannel){
//        self.postListVC.channelForList = self.startChannel ;
//    }else{
//        self.postListVC.channelForList = [self.channels firstObject];
//    }
//    
//    self.postListVC.listType = listChannel;
//    self.postListVC.isHomeProfileOrFeed = self.isCurrentUserProfile;
//    if(self.profileNavBar)[self.view insertSubview:self.postListVC.view belowSubview:self.profileNavBar];
//    else [self.view addSubview:self.postListVC.view];
//}



-(void) addPostListVC {
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [flowLayout setMinimumInteritemSpacing:0.3];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:self.view.frame.size];
    self.postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
    self.postListVC.listOwner = self.userOfProfile;
    if(self.startChannel){
        self.postListVC.channelForList = self.startChannel;
    }else{
        self.postListVC.channelForList = [self.channels firstObject];
    }

    self.postListVC.listType = listChannel;
    self.postListVC.isHomeProfileOrFeed = self.isCurrentUserProfile;
    if(self.profileNavBar)[self.view insertSubview:self.postListVC.view belowSubview:self.profileNavBar];
    else[self.view addSubview:self.postListVC.view];
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

-(void) createNavigationBar {
    //frame when on screen
    self.profileNavBarFrameOnScreen = CGRectMake(0.f, 0.f, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT + ARROW_EXTENSION_BAR_HEIGHT);
    //frame when off screen
	self.profileNavBarFrameOffScreen = CGRectMake(0.f, - (PROFILE_NAV_BAR_HEIGHT+ ARROW_EXTENSION_BAR_HEIGHT), self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT + ARROW_EXTENSION_BAR_HEIGHT);
    
    self.profileNavBar = [[ProfileNavBar alloc]
                          initWithFrame:self.profileNavBarFrameOnScreen
                          andChannels:self.channels
                          startChannel:self.startChannel
                          andUser:self.userOfProfile
                          isCurrentLoggedInUser:self.isCurrentUserProfile];
    
    self.profileNavBar.delegate = self;
    [self.view addSubview:self.profileNavBar];
    [self.view bringSubviewToFront:self.profileNavBar];
} 


-(void)addClearScreenGesture{
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
}



#pragma mark -POV ScrollView custom delegate -

-(void) povLikeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo{
    //sierra TODO
    //code to register a like/dislike from the user
}

-(void) povshareButtonSelectedForPOVInfo:(PovInfo *) povInfo{
    [self presentShareSelectionViewStartOnChannels:NO];
    
}


#pragma mark POVListScrollView Delegate -
-(void) shareOptionSelectedForParsePostObject: (PFObject* ) pov{
    [self presentHeadAndFooter:YES];
    [self presentShareSelectionViewStartOnChannels:NO];
}

#pragma mark - Profile Nav Bar Delegate Methods -

//current user selected to follow a channel
-(void) followOptionSelected{
    
}


-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels{
    if(self.sharePOVView){
        [self.sharePOVView removeFromSuperview];
        self.sharePOVView = nil;
    }
    
    CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
    CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
    self.sharePOVView = [[SharePOVView alloc] initWithFrame:offScreenFrame shouldStartOnChannels:startOnChannels];
    self.sharePOVView.delegate = self;
    [self.view addSubview:self.sharePOVView];
    [self.view bringSubviewToFront:self.sharePOVView];
    [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
        self.sharePOVView.frame = onScreenFrame;
    }];
}

-(void)removeSharePOVView{
    if(self.sharePOVView){
        CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
        
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.sharePOVView.frame = offScreenFrame;
        }completion:^(BOOL finished) {
            if(finished){
                [self.sharePOVView removeFromSuperview];
                self.sharePOVView = nil;
            }
        }];
    }
}

//current user wants to see their own followers
-(void) followersOptionSelected{
    [self.delegate presentFollowersListMyID:nil];//to-do
}

//current user wants to see who they follow
-(void) followingOptionSelected {
    [self.delegate presentWhoIFollowMyID:nil];//to-do
}

-(void) settingsButtonClicked {
    [self performSegueWithIdentifier:SETTINGS_PAGE_MODAL_SEGUE sender:self];
    
}

//ProfileNavBarDelegate protocol
-(void) createNewChannel {
    if(!self.createNewChannelView){
        [self darkenScreen];
        CGFloat viewHeight = self.view.frame.size.height/2.f -
        (CHANNEL_CREATION_VIEW_WALLOFFSET_X *7);
        
        CGRect newChannelViewFrame = CGRectMake(CHANNEL_CREATION_VIEW_WALLOFFSET_X, CHANNEL_CREATION_VIEW_Y_OFFSET, self.view.frame.size.width - (CHANNEL_CREATION_VIEW_WALLOFFSET_X *2),viewHeight);
        self.createNewChannelView = [[CreateNewChannelView alloc] initWithFrame:newChannelViewFrame];
        self.createNewChannelView.delegate = self;
        [self.view addSubview:self.createNewChannelView];
        [self.view bringSubviewToFront:self.createNewChannelView];
    }

}

-(void)darkenScreen{
    if(!self.darkScreenCover){
        self.darkScreenCover = [[UIView alloc] initWithFrame:self.view.bounds];
        self.darkScreenCover.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        [self.view addSubview:self.darkScreenCover];
    }
}

-(void) removeScreenDarkener{
    if(self.darkScreenCover){
        [self.darkScreenCover removeFromSuperview];
        self.darkScreenCover = nil;
    }
}

-(void) cancelCreation {
    [self clearChannelCreationView];
    [self presentHeadAndFooter:NO];
}

-(void) createChannelWithName:(NSString *) channelName {
    //save the channel name and create it in the backend
    //upate the scrollview to present a new channel
    
    Channel * newChannel = [self.channelBackendManager createChannelWithName:channelName];
    [self.profileNavBar newChannelCreated:newChannel];
    [self clearChannelCreationView];
}

-(void)clearChannelCreationView{
    if(self.createNewChannelView){
        [self removeScreenDarkener];
        [self.createNewChannelView removeFromSuperview];
        self.createNewChannelView = nil;
    }
}


#pragma mark -Share Seletion View Protocol -
-(void)cancelButtonSelected{
    [self removeSharePOVView];
}

-(void)sharePostWithComment:(NSString *) comment{
    //todo--sierra
    //code to share post to facebook etc
    
    [self removeSharePOVView];
    
}

#pragma mark -Navigate profile-
//the current user has selected the back button
-(void)exitCurrentProfile {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)newChannelSelected:(Channel *) channel{
    [self.postListVC changeCurrentChannelTo:channel];
}

// updates tab and content
-(void) selectChannel: (Channel *) channel {
	[self.profileNavBar selectChannel: channel];
	[self.postListVC changeCurrentChannelTo:channel];
}

-(void) switchStoryListToThread:(NSString *) newChannel{
    [self.postDisplayVC cleanUp];
    [self.postDisplayVC presentContentWithPOVType:POVTypeUser andChannel:newChannel];
}

-(void) presentHeadAndFooter:(BOOL) shouldShow {
    if(shouldShow) {
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            [self.profileNavBar setFrame:[self getProfileNavBarFrameOffScreen:YES]];
        }];
        [self.delegate showTabBar:NO];
        self.contentCoveringScreen = NO;
        [self.postListVC footerShowing:NO];
    } else {
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            [self.profileNavBar setFrame:[self getProfileNavBarFrameOffScreen:NO]];
        }];
        [self.delegate showTabBar:YES];
        self.contentCoveringScreen = YES;
        [self.postListVC footerShowing:YES];
        
    }
}

-(void)clearScreen:(UIGestureRecognizer *) tapGesture {
    if (self.contentCoveringScreen) {
       [self presentHeadAndFooter:YES];
    } else {
        [self presentHeadAndFooter:NO];
        
    }
}

-(CGRect)getProfileNavBarFrameOffScreen:(BOOL) getOffScreenFrame {
    if(getOffScreenFrame){
        return CGRectMake(0, -1 * self.profileNavBar.frame.size.height,
                          self.profileNavBar.frame.size.width,
                          self.profileNavBar.frame.size.height);
    } else {
        return CGRectMake(0, 0,
                          self.profileNavBar.frame.size.width,
                          self.profileNavBar.frame.size.height);
    }
}

-(void) offScreen {
    [self.postDisplayVC offScreen];
}

-(void) onScreen {
    [self.postDisplayVC onScreen];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:SETTINGS_PAGE_MODAL_SEGUE]){
        // Get reference to the destination view controller
        SettingsVC * vc = [segue destinationViewController];
        
        //set the username of the currently logged in user
        vc.userName  = [[PFUser currentUser] valueForKey:USER_USER_NAME_KEY];
    }
}

#pragma mark - Publishing -

-(void) showPublishingProgress {
	self.publishingProgressView = nil;
	self.publishingProgress = [[PublishingProgressManager sharedInstance] progressAccountant];
	[[PublishingProgressManager sharedInstance] setDelegate:self];
	Channel * currentPublishingChannel = [[PublishingProgressManager sharedInstance] currentPublishingChannel];
	if ([[PublishingProgressManager sharedInstance] newChannelCreated]) {
		[self.profileNavBar newChannelCreated: currentPublishingChannel];
		[[PublishingProgressManager sharedInstance] setNewChannelCreated:NO];
	}
	[self selectChannel: currentPublishingChannel];
	[self.profileNavBar addSubview: self.publishingProgressView];
}

#pragma mark Publishing Progress Manager Delegate methods

-(void) publishingComplete {
	NSLog(@"Publishing Complete!");
	[self.publishingProgressView removeFromSuperview];

	[self.postListVC reloadCurrentChannel];
}

-(void) publishingFailed {
	//TODO: tell user publishing failed
	NSLog(@"PUBLISHING FAILED");
}

#pragma mark - Article Display Delegate methods -

-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo {
	// do nothing
}

#pragma mark - Lazy Instantiation -

-(Channel_BackendObject *) channelBackendManager {
	if(!_channelBackendManager) {
		_channelBackendManager = [[Channel_BackendObject alloc] init];
	}
	return _channelBackendManager;
}

-(UIView*) publishingProgressView {
	if (!_publishingProgressView) {
		_publishingProgressView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.profileNavBar.frame.size.height,
																		   self.view.frame.size.width, 10.f)];
		[_publishingProgressView setBackgroundColor:[UIColor blackColor]];
		self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressBar setFrame:CGRectMake(5.f, 5.f, self.view.frame.size.width - 10.f, self.progressBar.frame.size.height)];
		if ([self.progressBar respondsToSelector:@selector(setObservedProgress:)]) {
			[self.progressBar setObservedProgress: self.publishingProgress];
		} else {
			[self.publishingProgress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
		}
		[_publishingProgressView addSubview: self.progressBar];
	}
	return _publishingProgressView;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.publishingProgress && [keyPath isEqualToString:@"completedUnitCount"] ) {
		[self.progressBar setProgress:self.publishingProgress.fractionCompleted animated:YES];
	}
}

@end
