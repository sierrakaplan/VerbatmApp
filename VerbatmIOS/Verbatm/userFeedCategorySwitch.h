//
//  userFeedCategorySwitch.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/*
 Simple view that lets the user switch between a trending and topics label. Any delegate is informed
 as this switch takes place and at its end.
 */

#import <UIKit/UIKit.h>

@protocol userFeedCategorySwitchProtocal <NSObject>
//called when the pullCircle is being panned
//the positionRatio gives you the postion of the xOrigin of the Pan Circle
//normalized by the total width of the view. In turn it ranges from 0-1
//0 is if it's on the left and 1 is if it's on the right
-(void)pullCircleDidPan:(CGFloat)pullCirlcePostionRatio;
//tells a delegate object that the user just switched to trending content
-(void)switchedToTrending;
//tells a delegate object that the user just switched to topics content
-(void)switchedToTopics;
@end

@interface userFeedCategorySwitch : UIView
@property (strong, nonatomic) id<userFeedCategorySwitchProtocal> categorySwitchDelegate;
@end
