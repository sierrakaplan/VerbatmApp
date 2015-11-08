//
//  ChatCell.m
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ChatCell.h"
#import "SizesAndPositions.h"
#import "Styles.h"
@implementation ChatCell

//isUs asks if the message is from the current logged in user
-(instancetype) initWithText:(NSString *) text screenWidth:(CGFloat) width isLoggedInUser:(BOOL) isUs{
    self = [super init];
    if(self){
        self.text = text;
        [self setFont:[UIFont fontWithName:DEFAULT_FONT size:TEXT_AVE_FONT_SIZE]];
        if(isUs){
            self.backgroundColor = [UIColor blueColor];
            self.textColor = [UIColor whiteColor];
        }else{
            self.backgroundColor = [UIColor lightGrayColor];
            self.textColor = [UIColor blackColor];
        }
        [self setOurFrameFromWidth:width];
        self.selectable = NO;
        self.editable = NO;
        //[self sizeToFit];
    }
    return self;
}

-(void)setOurFrameFromWidth:(CGFloat) width{
    CGFloat fixedWidth = width - CHAT_CELL_WALL_OFFSET;
    CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    self.frame = newFrame;
}

@end
