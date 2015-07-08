//
//  verbatmCustomScrollView.m
//  Verbatm
//
//  Created by Iain Usiri on 9/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmScrollView.h"

@implementation VerbatmScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//Iain
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    UITouch * touchObject =[touches anyObject];
    NSSet * allTouchEvents = event.allTouches;
    
    //If this is a pinch gesture make the tiles unslectable 
    if(([allTouchEvents count] >=2) && (touchObject.phase == UITouchPhaseBegan || touchObject.phase == UITouchPhaseStationary))
    {
        for (UIView * new_view in self.pageElements)
        {
            if([new_view isKindOfClass:[UITextView class]])
            {
                ((UITextView *)new_view).selectable = NO;
            }
        }
    }
    
    return YES;
}


//Iain
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Make sure that after any touch cancels- all the elements are selectable
    for (UIView * new_view in self.pageElements)
    {
        if([new_view isKindOfClass:[UITextView class]])
        {
            ((UITextView *)new_view).selectable = YES;
        }
    }

}

//Iain
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Make sure that after any touch ends- all the elements are selectable
        for (UIView * new_view in self.pageElements)
        {
            if([new_view isKindOfClass:[UITextView class]])
            {
                ((UITextView *)new_view).selectable = YES;
            }
        }
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
