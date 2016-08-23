//
//  CreateAccount.h
//  Verbatm
//
//  Created by Iain Usiri on 7/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CreateAccountProtocol <NSObject>
-(void)phoneNumberWrongFormatCreateAccount;
-(void)verbatmNameWrongFormatCreateAccount;

-(void)signUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber andName:(NSString *) verbatmName;
-(void)errorInSignInWithError:(NSString *)error;
-(void)goBackSelectedCreateAccount;

@end

@interface CreateAccount : UIView

@property (nonatomic,weak) id<CreateAccountProtocol> delegate;


@end
