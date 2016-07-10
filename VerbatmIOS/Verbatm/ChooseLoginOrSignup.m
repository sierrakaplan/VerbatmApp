//
//  ChooseLoginOrSignup.m
//  Verbatm
//
//  Created by Iain Usiri on 7/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChooseLoginOrSignup.h"
#import <Crashlytics/Crashlytics.h>
#import "Icons.h"

#import "SizesAndPositions.h"
#import "UserManager.h"
@interface ChooseLoginOrSignup()
@property (nonatomic) UIButton * loginButton;
@property (nonatomic) UIButton * signUpButton;
@end

#define BUTTON_HEIGHT (TEXT_TOOLBAR_HEIGHT * 2.f)
#define BUTTON_WITDH (BUTTON_HEIGHT * 4.f)

@implementation ChooseLoginOrSignup

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self createActionButtions];
    }
    return self;
}



-(void)createActionButtions{

    CGRect topFrame = CGRectMake((self.frame.size.width- BUTTON_WITDH)/2.f, TOP_BUTTON_YOFFSET, BUTTON_WITDH, BUTTON_HEIGHT);
    
    CGRect bottomFrame = CGRectMake((self.frame.size.width- BUTTON_WITDH)/2.f, topFrame.origin.y +
                                    topFrame.size.height + SIGN_UP_BUTTON_GAP, BUTTON_WITDH, BUTTON_HEIGHT);
    
    self.loginButton = [[UIButton alloc] initWithFrame:topFrame];
    self.signUpButton = [[UIButton alloc] initWithFrame:bottomFrame];
    
    [self.loginButton setImage:[UIImage imageNamed:LOGIN_ICON] forState:UIControlStateNormal];
    [self.signUpButton setImage:[UIImage imageNamed:CREATE_ACCOUNT] forState:UIControlStateNormal];

    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.loginButton];
    [self addSubview:self.signUpButton];
}


-(void)loginButtonPressed{
    [self.delegate loginChosen];
}
-(void)signUpButtonPressed{
    [self.delegate signUpChosen];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
