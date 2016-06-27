//
//  FeedTableCell.m
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTableCell.h"
#import "ProfileVC.h"
@interface FeedTableCell ()
@property (nonatomic) ProfileVC * currentProfile;
@end


@implementation FeedTableCell



-(void)presentProfileForChannel:(Channel *) channel{
    
    if(self.currentProfile){
        [self.currentProfile clearOurViews];
        @autoreleasepool {
            self.currentProfile = nil;
        }
    }
    
    self.currentProfile = [[ProfileVC alloc] init];
    self.currentProfile.isCurrentUserProfile = NO;
    self.currentProfile.isProfileTab = NO;
    self.currentProfile.ownerOfProfile = channel.channelCreator;
    self.currentProfile.channel = channel;
    [self addSubview:self.currentProfile.view];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
