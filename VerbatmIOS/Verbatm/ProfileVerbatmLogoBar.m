//
//  ProfileVerbatmLogoBar.m
//  Verbatm
//
//  Created by Iain Usiri on 8/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ProfileVerbatmLogoBar.h"
#import "Icons.h"

#define LOGO_SIZE 45.f
#define LOGO_RATIO_WIDTH_HEIGHT (1395.f/1142.f)
@implementation ProfileVerbatmLogoBar



-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.f];
        
        CGFloat xPos = ((frame.size.width - LOGO_SIZE)/2.f);
        CGFloat yPos = 3.f + ((frame.size.height - LOGO_SIZE)/2.f);
        UIImageView * logoView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, LOGO_SIZE * LOGO_RATIO_WIDTH_HEIGHT,LOGO_SIZE)];
        [logoView setImage:[UIImage imageNamed:VERBATM_LOGO]];
        [self addSubview:logoView];
        
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
