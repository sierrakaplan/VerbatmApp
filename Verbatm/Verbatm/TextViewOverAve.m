//
//  TextOverAve.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "TextViewOverAve.h"
#import "Styles.h"

@interface TextViewOverAve()  <UITextViewDelegate>

@property (nonatomic) BOOL allowScrolling;

@end

@implementation TextViewOverAve

-(id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		self.textColor = [UIColor TEXT_AVE_COLOR];
		[self setFont:[UIFont fontWithName:TEXT_AVE_FONT size:TEXT_AVE_FONT_SIZE]];

		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		[self setEditable:NO];
		[self setScrollEnabled:YES];
		self.allowScrolling = NO;
		self.showsVerticalScrollIndicator = NO;
		self.textAlignment = NSTextAlignmentCenter;
		[self setDelegate:self];
	}
	return self;
}

-(void) enableScrollingWithIndicator:(BOOL)showsIndicator {
	self.showsVerticalScrollIndicator = showsIndicator;
	self.allowScrolling = YES;
}

-(void) disableScrolling {
	self.showsVerticalScrollIndicator = NO;
	self.allowScrolling = NO;
}

-(void) scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView {
}

-(void) scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

@end
