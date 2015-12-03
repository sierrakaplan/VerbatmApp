//
//  POVDisplayScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVDisplayScrollView.h"

@implementation POVDisplayScrollView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor blackColor];
		self.scrollEnabled = YES;
		self.pagingEnabled = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
	}
	return self;
}


@end
