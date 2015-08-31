//
//  ArticleDisplayScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayScrollView.h"
#import "UIEffects.h"

@implementation ArticleDisplayScrollView


-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self)  {
		self.pagingEnabled = YES;
		self.scrollEnabled = YES;
		self.canCancelContentTouches = NO;
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		self.bounces = NO;
		self.backgroundColor = [UIColor blackColor];
		[UIEffects addShadowToView:self];
	}
	return self;
}

@end
