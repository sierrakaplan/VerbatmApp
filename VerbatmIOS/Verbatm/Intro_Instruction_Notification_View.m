//
//  Intro_Instruction_Notification_View.m
//  Verbatm
//
//  Created by Iain Usiri on 3/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Intro_Instruction_Notification_View.h"
#import "SizesAndPositions.h"
#import "Durations.h"

#define FEED_NOTIFICATION_IMAGE @"Feed Notification"
#define ADK_NOTIFICATION_IMAGE @"ADK Notification"
#define PROFILE_NOTIFICATION_IMAGE @"Profile Notification"

#define ANIMATION_NOTIFICAITON_DURATION 3.f

#define INTRO_TIMER_DURATION 20.f

@interface Intro_Instruction_Notification_View () <UIGestureRecognizerDelegate>
@end

@implementation Intro_Instruction_Notification_View


-(instancetype)initWithCenter:(CGPoint) center andType:(NotificationType) type{

    CGRect frame  = CGRectMake(0.f, 0.f, INTRO_NOTIFICATION_SIZE, INTRO_NOTIFICATION_SIZE);
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self.layer setCornerRadius:10.f];
        self.center = center;
        [self addTapGestureToView];
        [self createNotificationFromType:type];
        
    }

    return  self;
}

-(void)createNotificationFromType:(NotificationType) type{
    
    UIImage * notificationImage;

    if(type == Feed){
        notificationImage = [UIImage imageNamed:FEED_NOTIFICATION_IMAGE];
        
    }else if (type == Profile){
        notificationImage = [UIImage imageNamed:PROFILE_NOTIFICATION_IMAGE];
        
    }else if(type == ADK){
        notificationImage = [UIImage imageNamed:ADK_NOTIFICATION_IMAGE];
        
    }
    [self setImage:notificationImage];
    
    [self beginFadeTimer];
}

-(void)addTapGestureToView{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notAcceptedByUser:)];
	tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    [self setUserInteractionEnabled:YES];
}

-(void)notAcceptedByUser:(UITapGestureRecognizer *) tap{
    self.alpha = 0.f;
    [self.custom_delegate notificationDoneAnimatingOut];
   
}

-(void)beginFadeTimer{
    [NSTimer scheduledTimerWithTimeInterval:INTRO_TIMER_DURATION target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
}

-(void)fadeOut{
    return;
    [UIView animateWithDuration:ANIMATION_NOTIFICAITON_DURATION animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        if(finished){
            [self.custom_delegate notificationDoneAnimatingOut];
        }
    }];
}


@end
