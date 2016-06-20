//
//  Intro_Instruction_Notification_View.h
//  Verbatm
//
//  Created by Iain Usiri on 3/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Used to present the three intro instructions FEED/ADK/Profile
 Just pass the screen center and a type
 And the view will manage the rest -- note that the view will
 notify the delegate (should be the superview) when it is done and 
 faded out so that it's removed from it's superview;
 
 We expect that new view is created per notification -- not to be recycled
 */


@protocol Intro_Notification_Delegate <NSObject>

//means remove from super view
-(void)notificationDoneAnimatingOut;

@end

typedef enum NotificationTypes{
    Feed = 0,
    Profile = 1,
    ADK = 2,
} NotificationType;

@interface Intro_Instruction_Notification_View : UIImageView

-(instancetype)initWithCenter:(CGPoint) center andType:(NotificationType) type;
@property (nonatomic, weak) id<Intro_Notification_Delegate> custom_delegate;


@end
