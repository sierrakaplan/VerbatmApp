//
//  LogIntoAccount.h
//  Verbatm
//
//  Created by Iain Usiri on 7/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LogIntoAccountProtocol <NSObject>

-(void)textNotAlphaNumericaLoginAccount;

-(void)passwordIsOnlySpaces;

-(void)loginUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber andPassword:(NSString *)password;

-(void)goBackSelectedLoginAccount;

@end


@interface LogIntoAccount : UIView
@property (nonatomic) id<LogIntoAccountProtocol>delegate;
@end
