//
//  followInfoBar.m
//  Verbatm
//
//  Created by Iain Usiri on 1/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FollowInfoBar.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "Styles.h"
#import "SizesAndPositions.h"
#import "Notifications.h"

@interface FollowInfoBar ()

@property (nonatomic, strong) UIButton *myFollowersButton;
@property (nonatomic, strong) UIButton *whoIAmFollowingButton;

@property (nonatomic, strong) UILabel *myFollowersLabel;
@property (nonatomic, strong) UILabel *followingLabel;

@end

@implementation FollowInfoBar


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self createButtons];
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
    [self createButtons];
}

-(void) formatView{
    
    [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
    
    //[self setBackgroundColor:CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED];
    self.clipsToBounds = YES;
}


-(void) createButtons {
    
    CGRect myFollowersButtonFrame = CGRectMake(0.f,0.f, self.frame.size.width/2.f, USER_CELL_VIEW_HEIGHT);
    
    CGRect whoIAmFollowingButtonFrame = CGRectMake(self.frame.size.width/2.f,0.f, self.frame.size.width/2.f, USER_CELL_VIEW_HEIGHT);
    
    if(self.myFollowersButton){
        [self.myFollowersButton removeFromSuperview];
        [self.whoIAmFollowingButton removeFromSuperview];
        self.myFollowersButton = nil;
        self.whoIAmFollowingButton = nil;
    }
    
    self.myFollowersButton = [self getInfoViewWithTitle:@"Follower(s)" andViewFrame:myFollowersButtonFrame andSelectionSelector:@selector(myFollowersButtonListSelected)];
    self.whoIAmFollowingButton = [self getInfoViewWithTitle:@"Following" andViewFrame:whoIAmFollowingButtonFrame andSelectionSelector:@selector(whoIAmFollowingButtonSeleceted)];
    
    [self addSubview:self.myFollowersButton];
    [self addSubview:self.whoIAmFollowingButton];
}


//note -- selector is for when the button is pressed
-(UIButton *) getInfoViewWithTitle:(NSString *) title andViewFrame:(CGRect) viewFrame andSelectionSelector:(SEL) selector{
    
    CGRect titleFrame = CGRectMake(0.f,0.f, self.frame.size.width/2.f, USER_CELL_VIEW_HEIGHT/2.f);
    
    CGRect numberFrame = CGRectMake(0.f,USER_CELL_VIEW_HEIGHT/2.f, self.frame.size.width/2.f, USER_CELL_VIEW_HEIGHT/2.f);
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
                                                [UIColor blackColor],
                                            NSFontAttributeName: CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT_ATTRIBUTE,
                                            NSParagraphStyleAttributeName:paragraphStyle};

    //create bolded number
    NSString * numberString = @"0";
    NSAttributedString * numberAttributed = [[NSAttributedString alloc] initWithString:numberString attributes:informationAttribute];
    NSAttributedString * titleAttributed = [[NSAttributedString alloc] initWithString:title attributes:informationAttribute];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setAttributedText:titleAttributed];
    

    UILabel * numberLabel = [[UILabel alloc] initWithFrame:numberFrame];
    [numberLabel setBackgroundColor:[UIColor clearColor]];
    [numberLabel setAttributedText:numberAttributed];
	if ([title isEqualToString:@"Follower(s)"]) self.myFollowersLabel = numberLabel;
	if ([title isEqualToString:@"Following"]) self.followingLabel = numberLabel;
    
    
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

-(void) setNumFollowers: (NSNumber*) numFollowers {
	NSMutableAttributedString *currentFollowersLabelText = [[NSMutableAttributedString alloc]
															initWithAttributedString: self.myFollowersLabel.attributedText];
	NSString *numFollowersString = [numFollowers stringValue];
	[currentFollowersLabelText.mutableString setString: numFollowersString];
	[self.myFollowersLabel setAttributedText: currentFollowersLabelText];
}

-(void) setNumFollowing: (NSNumber*) numFollowing {

	NSMutableAttributedString *currentFollowersLabelText = [[NSMutableAttributedString alloc]
															initWithAttributedString: self.followingLabel.attributedText];
	NSString *numFollowingString = [numFollowing stringValue];
	[currentFollowersLabelText.mutableString setString: numFollowingString];
	[self.followingLabel setAttributedText: currentFollowersLabelText];
}

//list of people that follow me and the channels
-(void)myFollowersButtonListSelected{
    [self.delegate showWhoIsFollowingMeSelected];
}

//list of people that I follow
-(void)whoIAmFollowingButtonSeleceted{
    [self.delegate showWhoIAmFollowingButtonSelected];
}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
