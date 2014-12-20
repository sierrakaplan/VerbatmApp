//
//  v_textview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_textview.h"
#import "ILTranslucentView.h"

@implementation v_textview

-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])){
        self.editable = NO;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor blackColor];
        [self addObserver:self forKeyPath: @"contentSize" options: (NSKeyValueObservingOptionNew) context:NULL];
    }
    return self;
}

-(void)setTextViewText:(NSString*)text
{
    self.text = text;
    self.textColor = [UIColor whiteColor];
    [self setFont:[UIFont fontWithName:@"ArialMT" size:17]];
}

-(void)setTextViewAttributedText:(NSMutableAttributedString*)text
{
    self.attributedText = text;
}


//Pulled from stack overflow.
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    if ([tv contentSize].height < [tv bounds].size.height) {
        tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
}

@end
