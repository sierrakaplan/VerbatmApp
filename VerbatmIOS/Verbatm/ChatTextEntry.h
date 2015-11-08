//
//  ChatTextEntry.h
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Styles.h"
#import "SizesAndPositions.h"

@protocol ChatTextEntryProtocol <NSObject>
//user clicked send so this message should be sent by the delegate
-(void)sendMessage:(NSString *) message;

@end

@interface ChatTextEntry : UIView
@property (nonatomic, strong) id<ChatTextEntryProtocol> delegate;
-(instancetype)initWithFrame:(CGRect)frame;
@end


