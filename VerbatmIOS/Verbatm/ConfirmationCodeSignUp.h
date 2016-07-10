//
//  ConfirmationCodeSignUp.h
//  Verbatm
//
//  Created by Iain Usiri on 7/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ConfirmationCodeSignUpDelegate <NSObject>
-(void)resendCodeSelectedConfirmationCode;
-(void)goBackSelectedConfirmationCode;
-(void)codeSubmittedConfirmationCode:(NSString *) enteredCode;
@end

@interface ConfirmationCodeSignUp : UIView
@property (nonatomic) NSString * phoneNumberEntered;
@property (nonatomic, weak) id<ConfirmationCodeSignUpDelegate> delagate;
-(void)setPhoneNumberEntered:(NSString *)phoneNumberEntered;
@end
