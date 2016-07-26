//
//  ChooseLoginOrSignup.h
//  Verbatm
//
//  Created by Iain Usiri on 7/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChooseLoginOrSignupProtocol <NSObject>

-(void)loginChosen;
-(void)signUpChosen;
@end

@interface ChooseLoginOrSignup : UIView
@property (nonatomic, weak) id<ChooseLoginOrSignupProtocol> delegate;
@end
