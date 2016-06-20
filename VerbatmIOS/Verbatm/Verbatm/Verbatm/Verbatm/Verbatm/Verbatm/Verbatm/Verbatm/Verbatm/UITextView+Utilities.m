//
//  UITextView+Utilities.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UITextView+Utilities.h"

@implementation UITextView (Utilities)

- (CGFloat) measureContentHeight {
	CGSize textViewSize = [self sizeThatFits:CGSizeMake(self.frame.size.width, FLT_MAX)];
	return textViewSize.height;
}

- (void) disableSpellCheck {
	[self resignFirstResponder];
	self.autocorrectionType = UITextAutocorrectionTypeNo;
	[self becomeFirstResponder];
}

@end
