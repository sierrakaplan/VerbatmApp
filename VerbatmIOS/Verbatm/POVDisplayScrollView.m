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
		
	}
	return self;
}

// When user clicks story, loads one behind it and the two ahead
-(void) loadStory: (NSInteger) index {

}

// When user scrolls to a new story, loads the next two in that
// direction of scroll
-(void) loadNextTwoStories: (NSInteger) index {

}


@end
