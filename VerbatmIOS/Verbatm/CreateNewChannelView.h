//
//  CreateNewChannelView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 View that prompts the user to enter a name for their channel or cancel
 */

@protocol CreateNewChannelViewProtocol <NSObject>
-(void) cancelCreation;
-(void) createChannelWithName:(NSString *) channelName;
@end

@interface CreateNewChannelView : UIView

@property (nonatomic, weak) id <CreateNewChannelViewProtocol> delegate;

@end
