//
//  ChatNameTableViewCell.m
//  Verbatm
//
//  Created by Iain Usiri on 11/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ChatNameTableViewCell.h"
#import "Styles.h"
#import "SizesAndPositions.h"

@interface ChatNameTableViewCell ()
@end


@implementation ChatNameTableViewCell

-(void)setUnreadMessage:(BOOL)unreadMessage{
    
    if(unreadMessage){
        self.backgroundColor = [UIColor greenColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
    _unreadMessage = unreadMessage;
}



-(void)layoutSubviews{
    [self formatLabel];
}


-(void)formatLabel{
    [self.userName setFont:[UIFont fontWithName:USERNAME_FONT size:USERNAME_FONT_SIZE]];
    self.userName.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.userName.backgroundColor = [UIColor clearColor];
    [self addSubview:self.userName];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
