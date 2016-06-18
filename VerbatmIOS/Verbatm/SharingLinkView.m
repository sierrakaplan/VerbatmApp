//
//  SharingLinkView.m
//  Verbatm
//
//  Created by Iain Usiri on 6/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "SharingLinkView.h"
#import "SharingLinkActionView.h"

@interface SharingLinkView ()

@property (nonatomic) SharingLinkActionView * actionView;

@end



@implementation SharingLinkView


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        [self formatView];
        [self presentActionView];
    }
    return self;
}


-(void) formatView {
    [self setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.8]];
}

-(void) presentActionView {
    self.actionView = [[SharingLinkActionView alloc] initWithFrame:CGRectMake(20.f, 100.f, self.frame.size.width - 40.f, 200.f)];
    [self addSubview:self.actionView];
}








/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
