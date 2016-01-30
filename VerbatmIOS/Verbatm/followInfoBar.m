//
//  followInfoBar.m
//  Verbatm
//
//  Created by Iain Usiri on 1/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "followInfoBar.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "Styles.h"
#import "SizesAndPositions.h"
#import "Notifications.h"

@interface followInfoBar ()

@property (nonatomic) UIButton * myFollowers;
@property (nonatomic) UIButton * whoIAmFollowing;


@end

@implementation followInfoBar


-(instancetype)initWithFrame:(CGRect)frame WithNumberOfFollowers:(NSNumber *) myFollowers andWhoIFollow:(NSNumber *) whoIFollow {
    self = [super initWithFrame:frame];
    if(self){
        [self createButtonsWithNumberOfFollowers:myFollowers andWhoIFollow:whoIFollow];
        [self registerForNotifications];
        [self formatView];
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
    /*the user has logged in so we can update their follower info*/
    
    NSNumber * numberOfFollowers = [[PFUser currentUser] valueForKey:USER_NUMBER_OF_FOLLOWERS];
    NSNumber * numberFollowing = [[PFUser currentUser] valueForKey:USER_NUMBER_OF_FOLLOWING];
    
    [self createButtonsWithNumberOfFollowers:numberOfFollowers andWhoIFollow:numberFollowing];
    
}

-(void)formatView{
    
    [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
    
    //[self setBackgroundColor:CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED];
    self.clipsToBounds = YES;
}


-(void)createButtonsWithNumberOfFollowers:(NSNumber *) myFollowers andWhoIFollow:(NSNumber *) whoIFollow{
    
    CGRect myFollowersFrame = CGRectMake(0.f,0.f, self.frame.size.width/2.f, THREAD_SCROLLVIEW_HEIGHT);
    
    CGRect whoIAmFollowingFrame = CGRectMake(self.frame.size.width/2.f,0.f, self.frame.size.width/2.f, THREAD_SCROLLVIEW_HEIGHT);
    
    if(self.myFollowers){
        [self.myFollowers removeFromSuperview];
        [self.whoIAmFollowing removeFromSuperview];
        self.myFollowers = nil;
        self.whoIAmFollowing = nil;
    }
    
    self.myFollowers = [self getInfoViewWithTitle:@"Follower(s)" andNumber:myFollowers andViewFrame:myFollowersFrame andSelectionSelector:@selector(myFollowersListSelected)];
    self.whoIAmFollowing = [self getInfoViewWithTitle:@"Following" andNumber:whoIFollow andViewFrame:whoIAmFollowingFrame andSelectionSelector:@selector(whoIAmFollowingSeleceted)];
    
    [self addSubview:self.myFollowers];
    [self addSubview:self.whoIAmFollowing];
}



//note -- selector is for when the button is pressed
-(UIButton *) getInfoViewWithTitle:(NSString *) title andNumber:(NSNumber *) number andViewFrame:(CGRect) viewFrame andSelectionSelector:(SEL) selector{
    
    CGRect titleFrame = CGRectMake(0.f,0.f, self.frame.size.width/2.f, THREAD_SCROLLVIEW_HEIGHT/2.f);
    
    CGRect numberFrame = CGRectMake(0.f,THREAD_SCROLLVIEW_HEIGHT/2.f, self.frame.size.width/2.f, THREAD_SCROLLVIEW_HEIGHT/2.f);
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
                                                [UIColor blackColor],
                                            NSFontAttributeName:
                                                [UIFont fontWithName:TAB_BAR_FOLLOWERS_FOLLOWING_INFO_FONT size:TAB_BAR_FOLLOWERS_FOLLOWING_INFO_FONT_SIZE],
                                            NSParagraphStyleAttributeName:paragraphStyle};
    
    
    //create bolded number
    NSString * numberString = (number) ? [number stringValue] : @"0";
    
    NSAttributedString * numberAttributed = [[NSAttributedString alloc] initWithString:numberString attributes:informationAttribute];
    
    NSAttributedString * titleAttributed = [[NSAttributedString alloc] initWithString:title attributes:informationAttribute];
    
    
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setAttributedText:titleAttributed];
    
    

    UILabel * numberLabel = [[UILabel alloc] initWithFrame:numberFrame];
    [numberLabel setBackgroundColor:[UIColor clearColor]];
    [numberLabel setAttributedText:numberAttributed];
    
    
    UIButton * baseView = [[UIButton alloc]initWithFrame:viewFrame];
    [baseView setBackgroundColor:[UIColor clearColor]];
    [baseView addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
 
    
    
    [baseView addSubview:titleLabel];
    [baseView addSubview:numberLabel];
    
    //add thin white border
    baseView.layer.borderWidth = 0.3;
    baseView.layer.borderColor = [UIColor whiteColor].CGColor;

    return baseView;
}


//list of people that follow me and the channels
-(void)myFollowersListSelected{
    //to-do
    [self.delegate showWhoIsFollowingMeSelected];
}

//list of people that I follow
-(void)whoIAmFollowingSeleceted{
    //to-do
    [self.delegate showWhoIAmFollowingSelected];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
