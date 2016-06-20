//
//  UIScrollView+Effects.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Effects)

//let users know there is another page by bouncing a tiny bit and then bouncing back
- (void) scrollViewNotificationBounceForNextPage:(BOOL)nextPage inYDirection:(BOOL)yDirection;

@end
