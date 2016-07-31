//
//  GridView.m
//  Verbatm
//
//  Created by Iain Usiri on 7/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "GridView.h"




#define LINES_SEPERATOR 140.f
#define LINE_COLOR [UIColor grayColor]
#define LINE_WIDTH 1.f
@implementation GridView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        UIView * verticalLines = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - LINES_SEPERATOR)/2.f, -2.f, LINES_SEPERATOR,frame.size.height + 4.f)];
        
         UIView * horizontalLines = [[UIView alloc] initWithFrame:CGRectMake(-2.f, (frame.size.height - LINES_SEPERATOR)/2.f,frame.size.width + 4.f, LINES_SEPERATOR)];
        
        verticalLines.layer.borderWidth = horizontalLines.layer.borderWidth = LINE_WIDTH;
        verticalLines.layer.borderColor = horizontalLines.layer.borderColor = LINE_COLOR.CGColor;
        [self addSubview:verticalLines];
        [self addSubview:horizontalLines];
    }
    
    return self;
    
}







/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
