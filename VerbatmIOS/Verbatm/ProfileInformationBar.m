//
//  profileInformationBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Parse/PFUser.h>
#import "ProfileInformationBar.h"
#import "Notifications.h"
#import "SizesAndPositions.h"
#import "Styles.h"


@interface ProfileInformationBar ()
@property (nonatomic) UILabel * userTitleName;
@property (nonatomic) UIButton * settingsButton;
@property (nonatomic) UIButton * followButton;
@property (nonatomic) BOOL isCurrentUser;

@property (nonatomic) BOOL isFollowigProfileUser;//for cases when they are viewing another profile


#define THREAD_BAR_BUTTON_FONT_SIZE 17.f

#define SETTINGS_BUTTON_SIZE 25.f
#define SETTINGS_BUTTON_WIDTH 100.f


#define BUTTON_WALL_XOFFSET 10.f
#define SETTINGS_ICON_NAME @"settingsIcon"
#define BACK_BUTTON_ICON_NAME @"back_arrow"
#define BAR_CONTENT_COLOR yellowColor
#define FOLLOW_ICON_IMAGE_SELECTED  @"follow_user_image_selected"
#define FOLLOW_ICON_IMAGE_UNSELECTED  @"follow_user_image_unselected"


@end

@implementation ProfileInformationBar

-(instancetype)initWithFrame:(CGRect)frame andUserName: (NSString *) userName isCurrentUser:(BOOL) isCurrentUser{
    
    self =  [super initWithFrame:frame];
    
    if(self){
        
        [self formatView];
        [self createProfileHeaderWithUserName:userName];
        
        if(isCurrentUser){
            [self createSettingsButton];
            
        }else{
            [self createFollowButton];
            [self createBackButton];
        }
        [self registerForNotifications];
    }
    return self;
}


-(void)registerForNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSucceeded:)
                                                 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
                                               object:nil];
}

-(void) loginSucceeded: (NSNotification*) notification {
/*the user has logged in so we can update our username*/
    [self.userTitleName removeFromSuperview];
    self.userTitleName = nil;
    [self createProfileHeaderWithUserName:[[PFUser currentUser] username]];
}

-(void)formatView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
}

-(void) createProfileHeaderWithUserName: (NSString*) userName {
    CGFloat x_point = (BUTTON_WALL_XOFFSET*2) + SETTINGS_BUTTON_SIZE;
    CGFloat width = self.frame.size.width - (BUTTON_WALL_XOFFSET*2) - (SETTINGS_BUTTON_SIZE*2);
    CGFloat height = self.frame.size.height;
    CGFloat y_point = self.center.y - (height/2.f);
    
    self.userTitleName = [[UILabel alloc] initWithFrame:CGRectMake(x_point, y_point,
                                                                       width,height)];
    
    self.userTitleName.text = userName;
    self.userTitleName.textAlignment = NSTextAlignmentCenter;
    self.userTitleName.textColor = VERBATM_GOLD_COLOR;
    self.userTitleName.font = [UIFont fontWithName:HEADER_TEXT_FONT size:HEADER_TEXT_SIZE];
    [self addSubview: self.userTitleName ];
}

-(void)createSettingsButton{
    UIImage * settingsImage = [UIImage imageNamed:SETTINGS_ICON_NAME];

    CGFloat height = SETTINGS_BUTTON_SIZE;
    CGFloat width = height;
    CGFloat frame_x = self.frame.size.width - width - BUTTON_WALL_XOFFSET;
    CGFloat frame_y = self.center.y - (height/2.f);
    
    CGRect iconFrame = CGRectMake(frame_x, frame_y, width, height );
    
    self.settingsButton =  [[UIButton alloc] initWithFrame:iconFrame];
    [self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
    self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.settingsButton addTarget:self action:@selector(settingsButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingsButton];
}



//If it's my profile it's follower(s) and if it's someone else's profile
//it's follow
-(void) createFollowButton{
    
    CGFloat height = SETTINGS_BUTTON_SIZE;
    CGFloat width = (height*436.f)/250.f;
    CGFloat frame_x = self.frame.size.width - width - BUTTON_WALL_XOFFSET;
    CGFloat frame_y = self.center.y - (height/2.f);
    
    CGRect iconFrame = CGRectMake(frame_x, frame_y, width, height);

    
    UIImage * buttonImage = [UIImage imageNamed:((true) ? FOLLOW_ICON_IMAGE_UNSELECTED : FOLLOW_ICON_IMAGE_SELECTED)];
    self.isFollowigProfileUser = NO;//TO-DO how to know if they are following the current user
    self.followButton = [[UIButton alloc] initWithFrame:iconFrame];
    [self.followButton setImage:buttonImage forState:UIControlStateNormal];
    [self.followButton addTarget:self action:@selector(followOrFollowersSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.followButton];
}


-(void)createBackButton{
    UIImage * settingsImage = [UIImage imageNamed:BACK_BUTTON_ICON_NAME];
    
    CGFloat height = SETTINGS_BUTTON_SIZE;
    CGFloat width = height;
    CGFloat frame_x = BUTTON_WALL_XOFFSET;
    CGFloat frame_y = self.center.y - (height/2.f);
    
    CGRect iconFrame = CGRectMake(frame_x, frame_y, width, height);
    
    self.settingsButton =  [[UIButton alloc] initWithFrame:iconFrame];
    [self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
    self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.settingsButton addTarget:self action:@selector(backButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingsButton];

}

-(void) backButtonSelected {
    [self.delegate backButtonSelected];
}

-(void) settingsButtonSelected {
    [self.delegate settingsButtonSelected];
}

-(void) followOrFollowersSelected {
    
    UIImage * newbuttonImage;
    if(self.isFollowigProfileUser){
        newbuttonImage  = [UIImage imageNamed:FOLLOW_ICON_IMAGE_SELECTED ];
        self.isFollowigProfileUser = NO;
    }else{
        newbuttonImage = [UIImage imageNamed:FOLLOW_ICON_IMAGE_UNSELECTED];
        self.isFollowigProfileUser = YES;
    }
    
    [self.followButton setImage:newbuttonImage forState:UIControlStateNormal];
    
    
    
    [self.delegate followButtonSelected];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
