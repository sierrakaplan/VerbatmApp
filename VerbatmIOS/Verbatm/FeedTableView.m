//
//  FeedTableView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/31/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "FeedTableView.h"

@implementation FeedTableView

-(id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:style];
	if (self) {
		[self formatSelf];
	}
	return self;
}

-(void) formatSelf {
	[self setBackgroundColor:[UIColor clearColor]];
	self.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
}

@end
