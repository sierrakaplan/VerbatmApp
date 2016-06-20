//
//  PublishingDialogue.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 2/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PublishingDialogueDelegate <NSObject>

-(void) exitButtonPressed;

-(void) share: (NSArray*) socialMediaChoices;

@end

@interface PublishingDialogue : UIView

@property (strong, nonatomic) id<PublishingDialogueDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andChannel: (NSString*) channel;

@end
