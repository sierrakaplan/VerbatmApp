//
//  BlogPopupView.m
//  Verbatm
//
//  Created by Damas on 4/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "BlogPopupView.h"
#import "Styles.h"
#import "Followers.h"
#define SHARE_BUTTON_HEIGHT 40.f
#define BUTTON_WALL_OFFSET_X  10.f
#define ANIMATION_DURATION 0.5


@interface BlogPopupView ()
@property (nonatomic) Channel *channel;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *topButton;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *deleteButton;
@property (nonatomic) UIButton *followersButton;
@property (nonatomic) UIView *channelInfoBar;
@property (nonatomic) UIView *mainMenuView;
@property (nonatomic) UITextField *channelNameTextField;
@property (nonatomic) Followers *blogFollowers;


@property (nonatomic) CGRect followersFrameOFFSCREEN;
@property (nonatomic) CGRect followersFrameONSCREEN;

@property (nonatomic) CGRect mainFrameOFFSCREEN;
@property (nonatomic) CGRect mainFrameONSCREEN;
@end


@implementation BlogPopupView

-(instancetype) initWithFrame:(CGRect)frame forBlog:(Channel *) channel {
    self = [super initWithFrame:frame];
    if(self){
        self.channel = channel;
        [self formatView];
        [self createListFrames];
        [self createPopupComponents];
    }
    
    return self;
}

-(void) formatView {
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 0.8;
}

-(void)createPopupComponents {
    self.mainMenuView = [[UIView alloc] initWithFrame:self.mainFrameONSCREEN];
    CGRect channelInfoFrame = CGRectMake(0, 0, self.frame.size.width, (self.mainMenuView.frame.size.height)/3);
    self.channelInfoBar = [[UIView alloc] initWithFrame:channelInfoFrame];
    
    CGRect channelLabelFrame = CGRectMake(channelInfoFrame.size.width * 0.125, channelInfoFrame.size.height * 0.125, channelInfoFrame.size.width * 0.75, channelInfoFrame.size.height * 0.5);
    UILabel *channelLabel = [[UILabel alloc] initWithFrame:channelLabelFrame];
    channelLabel .layer.cornerRadius = 10.f;
    [channelLabel setClipsToBounds:YES];
    [channelLabel setBackgroundColor:[UIColor grayColor]];
    [channelLabel setText:self.channel.name];
    [channelLabel setTextAlignment:NSTextAlignmentCenter];
    [channelLabel setCenter:self.channelInfoBar.center];
    
    [self.channelInfoBar addSubview:channelLabel];
    
    
    CGRect deleteFrame = CGRectMake(0, 2 * (self.mainMenuView.frame.size.height - 40.f)/3, self.frame.size.width, self.mainMenuView.frame.size.height/3);
    self.deleteButton = [[UIButton alloc] initWithFrame:deleteFrame];
    [self.deleteButton setTitle:@"Delete Blog" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    CGRect followersFrame = CGRectMake(0, (self.mainMenuView.frame.size.height - 40.f)/3, self.frame.size.width, (self.mainMenuView.frame.size.height - 40.f)/3);
    self.followersButton = [[UIButton alloc] initWithFrame:followersFrame];
    [self.followersButton setTitle:@"Followers" forState:UIControlStateNormal];
    [self.followersButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.followersButton addTarget:self action:@selector(followersButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect cancelButtonFrame = CGRectMake(0, self.frame.size.height - 40.f, self.frame.size.width, SHARE_BUTTON_HEIGHT);
    
    self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    [self.cancelButton  setTitle:@"CANCEL" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelPopupButtonSelected) forControlEvents:UIControlEventTouchUpInside];

    CGRect topBackButtonFrame = CGRectMake(0, 0, 40, SHARE_BUTTON_HEIGHT);
    self.backButton = [[UIButton alloc] initWithFrame:topBackButtonFrame];
    [self.backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.backgroundColor = [UIColor grayColor];
    self.backButton.hidden = YES;
    
    CGRect topButtonFrame = CGRectMake(0, 0, self.frame.size.width, SHARE_BUTTON_HEIGHT);
    
    self.topButton = [[UIButton alloc] initWithFrame:topButtonFrame];
    [self.topButton setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [self.topButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.topButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [self.topButton addTarget:self action:@selector(topButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    self.topButton.hidden = YES;
    

    self .layer.cornerRadius = 10.f;
    self .layer.shadowOpacity = 10.f;
    [self.mainMenuView addSubview:self.deleteButton];
    [self.mainMenuView addSubview:self.followersButton];
    [self.mainMenuView addSubview:self.channelInfoBar];
    [self addSubview:self.mainMenuView];
    [self bringSubviewToFront:self.mainMenuView];
    [self addSubview:self.cancelButton];
    [self addSubview:self.topButton];
    [self addSubview:self.backButton];
}

-(void) topButtonSelected {
    if([self.topButton.titleLabel.text isEqualToString:@""]){
        
    } else {

    }
}

-(void) backButtonSelected {
    self.backButton.hidden = YES;
    self.topButton.hidden = YES;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.mainMenuView.frame = self.mainFrameONSCREEN;
        self.blogFollowers.frame = self.followersFrameOFFSCREEN;
    }];
}

-(void) cancelPopupButtonSelected {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self removeFromSuperview];
    }];
}

-(void) followersButtonSelected {
    [self showFollowers];
}

-(void) deleteButtonSelected {
    
}

-(void) showFollowers{
    self.backButton.hidden = NO;
    self.topButton.hidden = NO;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.mainMenuView.frame = self.mainFrameOFFSCREEN;
            self.blogFollowers.frame = self.followersFrameONSCREEN;
            
        }];
}

-(void)createListFrames{
    self.mainFrameONSCREEN = CGRectMake(0.f, SHARE_BUTTON_HEIGHT,
                                                             self.frame.size.width, self.frame.size.height- (SHARE_BUTTON_HEIGHT * 2.f));
    
    self.mainFrameOFFSCREEN = CGRectMake(- self.frame.size.width * 1.25,
                                                              SHARE_BUTTON_HEIGHT,
                                                              self.frame.size.width, self.frame.size.height- (SHARE_BUTTON_HEIGHT * 2.f));
    
    self.followersFrameOFFSCREEN = CGRectMake(self.frame.size.width * 1.25, self.mainFrameOFFSCREEN.origin.y, self.mainFrameOFFSCREEN.size.width, self.mainFrameOFFSCREEN.size.height);
    
    self.followersFrameONSCREEN = CGRectMake(0.f, self.mainFrameONSCREEN.origin.y, self.mainFrameONSCREEN.size.width, self.mainFrameONSCREEN.size.height);
}

-(Followers *) blogFollowers{
    if(!_blogFollowers){
        _blogFollowers = [[Followers alloc] initWithFrame:self.followersFrameOFFSCREEN forChannel:self.channel];
        [self addSubview:_blogFollowers];
    }
    
    return _blogFollowers;
}


@end
