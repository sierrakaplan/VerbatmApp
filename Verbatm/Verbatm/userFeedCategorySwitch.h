//
//  userFeedCategorySwitch.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol userFeedCategorySwitchProtocal <NSObject>
//called when the pullCircle is being panned
-(void)pullCircleDidPan:(UIView *)pullCirlce;
//tells a delegate object that the user just switched to trending content
-(void)switchedToTrending;
//tells a delegate object that the user just switched to topics content
-(void)switchedToTopics;
@end

@interface userFeedCategorySwitch : UIView
@property (strong, nonatomic) id<userFeedCategorySwitchProtocal> categorySwitchDelegate;
@end
