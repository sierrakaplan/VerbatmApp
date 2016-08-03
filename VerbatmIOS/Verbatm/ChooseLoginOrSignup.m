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
#import "Styles.h"
#import "SizesAndPositions.h"
#import "UserManager.h"

@interface ChooseLoginOrSignup()

@property (nonatomic) UIButton * loginButton;
@property (nonatomic) UIButton * signUpButton;
@property (nonatomic) UILabel * orLabel;

@end

@implementation ChooseLoginOrSignup

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self createActionButtions];
        [self addSubview:self.orLabel];
    }
    return self;
}

-(void)createActionButtions{

    CGRect topFrame = CGRectMake((self.frame.size.width - LOGIN_BUTTON_WIDTH)/2.f,
								 TOP_BUTTON_YOFFSET, LOGIN_BUTTON_WIDTH, LOGIN_BUTTON_HEIGHT);
    
    CGRect bottomFrame = CGRectMake((self.frame.size.width - LOGIN_BUTTON_WIDTH)/2.f, topFrame.origin.y +
                                    topFrame.size.height + SIGN_UP_BUTTON_GAP, LOGIN_BUTTON_WIDTH, LOGIN_BUTTON_HEIGHT);
    
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

-(UILabel *)orLabel{
    if(!_orLabel){
        
        CGFloat baseYFacebookButton = self.loginButton.frame.origin.y + self.loginButton.frame.size.height;
        CGFloat yPos = baseYFacebookButton + (self.signUpButton.frame.origin.y - baseYFacebookButton)/2.f;
        _orLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x - 25.f,  yPos - 25.f, 50.f, 50.f)];
        [_orLabel setText:@"OR"];
        [_orLabel setBackgroundColor:[UIColor clearColor]];
        [_orLabel setTextColor:[UIColor whiteColor]];
        [_orLabel setFont:[UIFont fontWithName:BOLD_FONT size:HEADER_TEXT_SIZE]];
    }
    return _orLabel;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
