//
//  TextOverAve.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "TextOverAVEView.h"
#import "Styles.h"
#import "UIEffects.h"
#import "SizesAndPositions.h"

@interface TextOverAVEView()

@property (nonatomic) BOOL allowScrolling;

@property (strong,nonatomic) UITextView * textView;
@property (strong,nonatomic) UIView* blockScrollingView;

@end

@implementation TextOverAVEView

-(id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
//		[UIEffects createBlurViewOnView:self];
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];

		self.textView = [[UITextView alloc] init];
		[self setTextViewFrame];
		[self formatTextView];
		[self.textView setScrollEnabled:YES];
		[self addSubview:self.textView];

		self.blockScrollingView = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:self.blockScrollingView];

		self.allowScrolling = NO;
	}
	return self;
}

-(void) layoutSubviews {
	self.blockScrollingView.frame = self.bounds;
	[self setTextViewFrame];
}

-(void)formatTextView {
	self.textView.textColor = [UIColor TEXT_AVE_COLOR];
	[self.textView setFont:[UIFont fontWithName:TEXT_AVE_FONT size:TEXT_AVE_FONT_SIZE]];
	self.textView.backgroundColor = [UIColor clearColor];
	self.textView.userInteractionEnabled = YES;
	[self.textView setEditable:NO];
	[self.textView setScrollEnabled:YES];
	self.textView.showsVerticalScrollIndicator = NO;
	self.textView.textAlignment = NSTextAlignmentCenter;
}

-(void) setText:(NSString*)text {
	self.textView.text = text;
	self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

-(float) getHeightOfText {
	return [UIEffects measureHeightOfUITextView:self.textView];
}

-(void) setTextViewFrame {
	CGRect frameWithTopBottomBorder = CGRectMake(self.bounds.origin.x + TEXT_OVER_AVE_BORDER, self.bounds.origin.y + TEXT_OVER_AVE_BORDER, self.bounds.size.width - TEXT_OVER_AVE_BORDER*2, self.bounds.size.height - TEXT_OVER_AVE_BORDER - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f);

	self.textView.frame = frameWithTopBottomBorder;

//	self.textView.frame = CGRectMake(self.bounds.origin.x + TEXT_OVER_AVE_BORDER, self.bounds.origin.y, self.bounds.size.width - TEXT_OVER_AVE_BORDER*2, self.bounds.size.height);
}

-(void) enableScrollingWithIndicator:(BOOL)showsIndicator {
	self.textView.showsVerticalScrollIndicator = showsIndicator;
	self.allowScrolling = YES;
	[self.blockScrollingView removeFromSuperview];
}

-(void) disableScrolling {
	self.textView.showsVerticalScrollIndicator = NO;
	self.allowScrolling = NO;
	[self addSubview:self.blockScrollingView];
}

-(BOOL) scrollingAllowed {
	return self.allowScrolling;
}

@end
