//
//  TextOverAve.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "TextOverAVEView.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "UITextView+Utilities.h"

/* NOT IN  USE! */

@interface TextOverAVEView() <UITextViewDelegate>

@property (nonatomic) BOOL allowScrolling;

@property (strong,nonatomic) UITextView * textView;
@property (strong,nonatomic) UIView* blockScrollingView;

@end

@implementation TextOverAVEView

-(id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
//		[UIEffects createBlurViewOnView:self];
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
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

-(void) setText:(NSString*)text {
	self.textView.text = text;
	self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

-(float) getHeightOfText {
	float heightWithoutBorder = [self.textView measureContentHeight];
	return heightWithoutBorder + TEXT_OVER_AVE_BORDER*2;
}

-(void) setTextViewFrame {
	CGRect textViewFrameWithTopBorder = CGRectMake(self.bounds.origin.x + TEXT_OVER_AVE_BORDER, self.bounds.origin.y + TEXT_OVER_AVE_BORDER, self.bounds.size.width - TEXT_OVER_AVE_BORDER*2, self.bounds.size.height - TEXT_OVER_AVE_BORDER - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f);
	self.textView.frame = textViewFrameWithTopBorder;
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

#pragma mark - Lazy Instantiation -

-(UITextView*) textView {
	if (!_textView) {
		CGRect textViewFrameWithTopBorder = CGRectMake(self.bounds.origin.x + TEXT_OVER_AVE_BORDER, self.bounds.origin.y + TEXT_OVER_AVE_BORDER, self.bounds.size.width - TEXT_OVER_AVE_BORDER*2, self.bounds.size.height - TEXT_OVER_AVE_BORDER - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f);
		_textView = [[UITextView alloc] initWithFrame: textViewFrameWithTopBorder];
		_textView.textColor = [UIColor TEXT_AVE_COLOR];
		[_textView setFont:[UIFont fontWithName:DEFAULT_FONT size:TEXT_AVE_FONT_SIZE]];
		_textView.backgroundColor = [UIColor clearColor];
		_textView.userInteractionEnabled = YES;
		[_textView setEditable:NO];
		[_textView setScrollEnabled:YES];
		_textView.showsVerticalScrollIndicator = NO;
		_textView.textAlignment = NSTextAlignmentCenter;
	}
	return _textView;
}

@end
