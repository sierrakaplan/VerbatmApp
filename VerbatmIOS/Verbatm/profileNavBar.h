//
//  profileNavBar.h
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol profileNavBarDelegate <NSObject>
-(void)newChannelSelectedWithName:(NSString *) channelName;
@end

@interface profileNavBar : UIView
-(instancetype) initWithFrame:(CGRect)frame andThreads:(NSArray *) threads andUserName:(NSString *) userName;
@property (nonatomic, strong) id<profileNavBarDelegate> delegate;
@end


