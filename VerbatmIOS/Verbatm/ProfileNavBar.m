//
//  profileNavBar.m
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ButtonScrollView.h"

#import "CustomScrollingTabBar.h"
#import "CustomNavigationBar.h"
#import "Channel.h"

#import "Durations.h"

#import "followInfoBar.h"

#import "Icons.h"

#import "ProfileNavBar.h"
#import "ProfileInformationBar.h"
#import "ParseBackendKeys.h"

#import "SizesAndPositions.h"
#import "Styles.h"


@interface ProfileNavBar () <CustomScrollingTabBarDelegate, ProfileInformationBarProtocol, followInfoBarDelegate>

@property (nonatomic, strong) ProfileInformationBar * profileHeader;
@property (nonatomic, strong) CustomScrollingTabBar* threadNavScrollView;

@property (nonatomic) followInfoBar * followInfoBar;

@property (nonatomic, strong) UIView * arrowExtension;

@property (nonatomic) CGRect followersInfoFrameOpen;
@property (nonatomic) CGRect followersInfoFrameClosed;

@property (nonatomic) CGPoint panLastLocation;//used to help change size of view dynamically

#define THREAD_BAR_BUTTON_FONT_SIZE 17.f

#define SETTINGS_BUTTON_SIZE 40.f
#define SETTINGS_BUTTON_OFFSET 10.f


@end

@implementation ProfileNavBar

//expects an array of thread names (nsstring)
-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *)channels andUser:(PFUser *)profileUser isCurrentLoggedInUser:(BOOL) isCurrentUser{
    self = [super initWithFrame:frame];
    if(self){
        [self createProfileHeaderWithUserName:[profileUser valueForKey:USER_USER_NAME_KEY] isCurrentUser:isCurrentUser];
		[self.threadNavScrollView displayTabs:channels];
        [self createFollowersInfoViewWithUser:profileUser];
        [self createArrowExtesion];
        [self createPanGesture];
        [self createTapGesture];
    }
    return self;
}


-(void)newChannelCreated:(Channel *)channel{
    if(channel){
        [self.threadNavScrollView addNewChannelToList:channel];
    }
}



-(void)createFollowersInfoViewWithUser:(PFUser *) profileUser {
    
    NSNumber * numberOfFollowers = [profileUser valueForKey:USER_NUMBER_OF_FOLLOWERS];
    NSNumber * numberFollowing = [profileUser valueForKey:USER_NUMBER_OF_FOLLOWING];
    
    self.followersInfoFrameClosed = CGRectMake(0.f, self.threadNavScrollView.frame.origin.y +
                                      self.threadNavScrollView.frame.size.height,
                                      self.frame.size.width, 0);
    self.followersInfoFrameOpen = CGRectMake(0.f, self.threadNavScrollView.frame.origin.y +
                                                self.threadNavScrollView.frame.size.height,
                                                self.frame.size.width, THREAD_SCROLLVIEW_HEIGHT);
    
    //to-do -- get the number of people I follow here and the number of people that follow me

    self.followInfoBar = [[followInfoBar alloc] initWithFrame:self.followersInfoFrameClosed WithNumberOfFollowers:numberOfFollowers andWhoIFollow:numberFollowing];
    self.followInfoBar.delegate = self;
    [self addSubview:self.followInfoBar];
}



-(void)createTapGesture{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)createPanGesture{
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    panGesture.maximumNumberOfTouches = 1;//for one finger panning
    [self addGestureRecognizer:panGesture];
}


-(void)userDidTap:(UIPanGestureRecognizer *) pan{
    if(self.followInfoBar.frame.size.height == self.followersInfoFrameOpen.size.height){
        //the bar is greater than halfway open
        [self snapViewDown:NO];
    }else{
        [self snapViewDown:YES];
    }
}


-(void)userDidPan:(UIPanGestureRecognizer *) pan{
    
    if(pan.state == UIGestureRecognizerStateBegan){
        if(pan.numberOfTouches != 1) return;
        self.panLastLocation = [pan locationOfTouch:0 inView:self];
    }else if (pan.state == UIGestureRecognizerStateChanged){
        if(pan.numberOfTouches != 1) return;
        CGPoint currentPoint = [pan locationOfTouch:0 inView:self];
        CGFloat diff = currentPoint.y - self.panLastLocation.y;
        self.panLastLocation = currentPoint;
        CGFloat newFollowerFrameHeight = self.followInfoBar.frame.size.height + diff;
        
        if(newFollowerFrameHeight >= 0){
            
            if(newFollowerFrameHeight >= self.followersInfoFrameOpen.size.height){
                
                self.followInfoBar.frame = self.followersInfoFrameOpen;
                
            }else{

                CGRect followInfoBarFrame = CGRectMake(self.followInfoBar.frame.origin.x,
                                                  self.followInfoBar.frame.origin.y,
                                                  self.followInfoBar.frame.size.width,
                                                  newFollowerFrameHeight);

                self.followInfoBar.frame = followInfoBarFrame;
                
            }
            
            CGRect arrowBarFrame = CGRectMake(self.arrowExtension.frame.origin.x,
                                              self.followInfoBar.frame.origin.y +
                                              self.followInfoBar.frame.size.height,
                                              self.arrowExtension.frame.size.width,
                                              self.arrowExtension.frame.size.height);
            self.arrowExtension.frame = arrowBarFrame;
            [self adjustOurOwnFrame];
            
        }
    }else {
        if(self.followInfoBar.frame.size.height >= self.followersInfoFrameOpen.size.height/2.f){
            //the bar is greater than halfway open
            [self snapViewDown:YES];
        }else{
            [self snapViewDown:NO];
        }
    }
}


-(void)snapViewDown:(BOOL) down{
    if(down){
        [UIView animateWithDuration:SNAP_ANIMATION_DURATION animations:^{
            self.followInfoBar.frame = self.followersInfoFrameOpen;
            CGRect arrowBarFrame = CGRectMake(self.arrowExtension.frame.origin.x,
                                              self.followInfoBar.frame.origin.y +
                                              self.followInfoBar.frame.size.height,
                                              self.arrowExtension.frame.size.width,
                                              self.arrowExtension.frame.size.height);
            self.arrowExtension.frame = arrowBarFrame;
            [self adjustOurOwnFrame];
        }];
    }else{
        [UIView animateWithDuration:SNAP_ANIMATION_DURATION animations:^{
            self.followInfoBar.frame = self.followersInfoFrameClosed;
            CGRect arrowBarFrame = CGRectMake(self.arrowExtension.frame.origin.x,
                                              self.followInfoBar.frame.origin.y +
                                              self.followInfoBar.frame.size.height,
                                              self.arrowExtension.frame.size.width,
                                              self.arrowExtension.frame.size.height);
            self.arrowExtension.frame = arrowBarFrame;
            [self adjustOurOwnFrame];
        }];
    }
}



-(void)adjustOurOwnFrame{
    CGRect selfFrame = CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  self.arrowExtension.frame.origin.y +
                                  self.arrowExtension.frame.size.height);
    
    self.frame = selfFrame;
}


-(void)createArrowExtesion{
    CGRect arrowBarFrame = CGRectMake(0.f, self.followInfoBar.frame.origin.y +
                                      self.followInfoBar.frame.size.height,
                                      self.frame.size.width, ARROW_EXTENSION_BAR_HEIGHT);
    
    UIColor * arrowBarBackgroundColor = CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED;
    self.arrowExtension = [[UIView alloc] initWithFrame:arrowBarFrame];
    [self.arrowExtension setBackgroundColor:arrowBarBackgroundColor];
    
    
    CGRect arrowFrame = CGRectMake(self.frame.size.width/2.f - (ARROW_FRAME_WIDTH/2), ARROW_IMAGE_WALL_OFFSET, ARROW_FRAME_WIDTH, ARROW_FRAME_HEIGHT - (ARROW_IMAGE_WALL_OFFSET*2));
    UIImage * arrowImage = [UIImage imageNamed:@"down_arrow_white"];
    
    UIImageView * arrowView = [[UIImageView alloc] initWithImage:arrowImage];
    [arrowView setFrame:arrowFrame];
    [self.arrowExtension addSubview:arrowView];
    [self addSubview:self.arrowExtension];
}

-(void) createProfileHeaderWithUserName: (NSString*) userName isCurrentUser:(BOOL) isCurrentUser{
    
    CGRect barFrame = CGRectMake(0.f, 0.f, self.bounds.size.width, PROFILE_HEADER_HEIGHT);
    self.profileHeader = [[ProfileInformationBar alloc] initWithFrame:barFrame andUserName:userName isCurrentUser:isCurrentUser];
    self.profileHeader.delegate = self;
    [self addSubview:self.profileHeader];
}

-(void)backButtonSelected{
    [self.delegate exitCurrentProfile];
}

-(void)settingsButtonSelected {
    [self.delegate settingsButtonClicked];
}

//told when the follow/followers button is selected
-(void)followButtonSelected {
    [self.delegate followOptionSelected];
}


#pragma mark -Follow Infor Bar Delegate-

//present the people that follow the current user and the specific channels
-(void)showWhoIsFollowingMeSelected {
    [self.delegate followersOptionSelected];
}

//show the people that I am following
-(void)showWhoIAmFollowingSelected {
    [self.delegate followingOptionSelected];
}


#pragma mark - CustomScrollingTabBarDelegate methods -

-(void) tabPressedWithChannel:(Channel *)channel {
	[self.delegate newChannelSelected:channel];
}

-(void) createNewChannel{
    //pass information to our delegate
    [self.delegate createNewChannel];
}

#pragma mark - Lazy Instantation -

-(UIScrollView*) threadNavScrollView {
	if (!_threadNavScrollView) {
		_threadNavScrollView = [[CustomScrollingTabBar alloc] initWithFrame:CGRectMake(0.f, self.profileHeader.frame.origin.y + PROFILE_HEADER_HEIGHT,
																			  self.frame.size.width, THREAD_SCROLLVIEW_HEIGHT)];

		_threadNavScrollView.customScrollingTabBarDelegate = self;
		[self addSubview: _threadNavScrollView];
	}
	return _threadNavScrollView;
}

@end
