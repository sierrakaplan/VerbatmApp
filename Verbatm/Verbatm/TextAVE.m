//
//  v_textview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "TextAVE.h"
#import "Styles.h"
#import "TextOverAveView.h"
#import "SizesAndPositions.h"
#import "UIEffects.h"

@interface TextAVE()

@property (strong, nonatomic) TextOverAVEView* textViewContainer;
@property (strong, nonatomic) UIView* blurView;

@end
@implementation TextAVE

//provide for a little bit of spacing on top and belows
/*
 *This function initializes the text view to the frame issue
 */
-(id)initWithFrame:(CGRect)frame andText:(NSString*) text{
    if((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor blackColor]];
		self.textViewContainer = [[TextOverAVEView alloc] initWithFrame:self.bounds];
		[self.textViewContainer setText:text];

		CGRect blurViewFrame = CGRectMake(self.bounds.origin.x, TEXT_OVER_AVE_STARTING_HEIGHT, self.bounds.size.width, self.bounds.size.height - TEXT_OVER_AVE_STARTING_HEIGHT);
		self.blurView = [[UIView alloc] initWithFrame:blurViewFrame];
		[self.blurView setBackgroundColor:[UIColor clearColor]];
		[UIEffects createBlurViewOnView:self.blurView withStyle:UIBlurEffectStyleDark];
		[self addSubview:self.textViewContainer];
		[self addSubview:self.blurView];

		// have text view resizable to size of its content or full screen
//		self.textViewContentSize = [self.textViewContainer getHeightOfText];
//		float heightForTextView = self.frame.size.height-TEXT_OVER_AVE_TOP_OFFSET*2;
//		if (self.textViewContentSize < heightForTextView) {
//			heightForTextView = self.textViewContentSize;
//		}
//		self.textViewBottomFrame = CGRectMake(0,TEXT_OVER_AVE_TOP_OFFSET,self.frame.size.width, heightForTextView);
//		[self addSubview:self.textViewContainer];
//
//		if(self.textViewContentSize > TEXT_OVER_AVE_STARTING_HEIGHT) {
//			[self addPullDownBarForText];
//		}
    }
    return self;
}


@end
