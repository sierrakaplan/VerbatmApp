//
//  verbatmCustomScrollView.m
//  Verbatm
//
//  Created by Iain Usiri on 9/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomScrollView.h"

@implementation verbatmCustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    UITouch * touch =[touches anyObject];
    NSSet * tellem = event.allTouches;
    
    if(([tellem count] >=2) && (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseStationary))
    {
        for (UIView * new_view in self.pageElements)
        {
            if([new_view isKindOfClass:[UITextView class]])
            {
                ((UITextView *)new_view).selectable = NO;
            }
        }
    }else if ([tellem count] <2)
    {
        for (UIView * new_view in self.pageElements)
        {
            if([new_view isKindOfClass:[UITextView class]])
            {
                ((UITextView *)new_view).selectable = YES;
            }
        }
    }
    
        return YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
