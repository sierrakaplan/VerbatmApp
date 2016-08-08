//
//  GridView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "GridView.h"

#define LINES_SEPARATOR 140.f
#define LINE_COLOR [UIColor grayColor]
#define LINE_WIDTH 1.f
#define OFFSET 2.f

@implementation GridView

-(instancetype)initWithFrame:(CGRect)frame{

	self = [super initWithFrame:frame];

	if(self){
		UIView * verticalLines = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - LINES_SEPARATOR)/2.f, -OFFSET,
																		  LINES_SEPARATOR,frame.size.height + OFFSET*2)];

		UIView * horizontalLines = [[UIView alloc] initWithFrame:CGRectMake(-OFFSET, (frame.size.height - LINES_SEPARATOR)/2.f,
																			frame.size.width + OFFSET*2, LINES_SEPARATOR)];

		verticalLines.layer.borderWidth = horizontalLines.layer.borderWidth = LINE_WIDTH;
		verticalLines.layer.borderColor = horizontalLines.layer.borderColor = LINE_COLOR.CGColor;
		[self addSubview:verticalLines];
		[self addSubview:horizontalLines];
	}

	return self;

}

@end
