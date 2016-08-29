//
//  ProfileMoreInfoView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileMoreInfoViewDelegate <NSObject>

-(void) followingButtonPressed;
-(void) followersButtonPressed;

@end

@interface ProfileMoreInfoView : UIView

@property (nonatomic, weak) id<ProfileMoreInfoViewDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andNumFollowers:(NSNumber*)numFollowers
			  andNumFollowing:(NSNumber*)numFollowing andDescription:(NSString*)description;

@end
