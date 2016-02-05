//
//  ChannelButtons.h
//  Verbatm
//
//  Created by Iain Usiri on 11/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//


/*
 These are the buttons in the profile tab bar that show that chanenl and the number of followers it has
 */
#import <UIKit/UIKit.h>

@interface ChannelButtons : UIButton

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel;

@property (nonatomic, readonly) NSString * channelName;
//offers a suggested width realtive to the sizes of the labels
@property (nonatomic, readonly) CGFloat suggestedWidth;


@property (nonatomic, readonly) Channel * currentChannel;

-(void)markButtonAsSelected;
-(void)markButtonAsUnselected;
@end

