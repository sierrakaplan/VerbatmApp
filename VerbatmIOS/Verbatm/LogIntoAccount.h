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

-(void)loginUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber;

-(void)goBackSelectedLoginAccount;

@end


@interface LogIntoAccount : UIView
@property (nonatomic) id<LogIntoAccountProtocol>delegate;
@end
