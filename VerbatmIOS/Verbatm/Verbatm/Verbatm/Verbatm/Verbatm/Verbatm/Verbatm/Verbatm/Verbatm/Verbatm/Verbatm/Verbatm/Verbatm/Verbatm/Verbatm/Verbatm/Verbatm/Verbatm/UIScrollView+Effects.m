//
//  UIScrollView+Effects.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UIScrollView+Effects.h"

#define SCROLLVIEW_BOUNCE_NOTIFICATION_DURATION 0.4f
#define SCROLLVIEW_BOUNCE_OFFSET 60.f

@implementation UIScrollView (Effects)

- (void) scrollViewNotificationBounceForNextPage:(BOOL)nextPage inYDirection:(BOOL)yDirection {
	float bounceOffset = nextPage ? SCROLLVIEW_BOUNCE_OFFSET : -SCROLLVIEW_BOUNCE_OFFSET;
	[UIView animateWithDuration:SCROLLVIEW_BOUNCE_NOTIFICATION_DURATION/2.f animations:^{
		CGPoint newContentOffset = yDirection ? CGPointMake(self.contentOffset.x, self.contentOffset.y + bounceOffset) : CGPointMake(self.contentOffset.x + bounceOffset, self.contentOffset.y);
		self.contentOffset = newContentOffset;
	}completion:^(BOOL finished) {
		if(finished) {
			[UIView animateWithDuration:SCROLLVIEW_BOUNCE_NOTIFICATION_DURATION/2.f animations:^{
				CGPoint newContentOffset = yDirection ? CGPointMake(self.contentOffset.x, self.contentOffset.y - bounceOffset) : CGPointMake(self.contentOffset.x - bounceOffset, self.contentOffset.y);
				self.contentOffset = newContentOffset;
			}completion:^(BOOL finished) {
				if(finished) {
				}
			}];
		}
	}];
}

@end
