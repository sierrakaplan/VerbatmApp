//
//  FeedTableCell.m
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedTableCell.h"
@interface FeedTableCell ()<ProfileVCDelegate>
@property (nonatomic) ProfileVC * currentProfile;
@end


@implementation FeedTableCell



-(void)setProfileAlreadyLoaded:(ProfileVC *) newProfile{
    if(self.currentProfile){
        [self.currentProfile clearOurViews];
        @autoreleasepool {
            self.currentProfile = nil;
        }
    }
    self.currentProfile = newProfile;
    self.currentProfile.delegate = self;
    [self addSubview:self.currentProfile.view];
    self.clipsToBounds = YES;
}

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
    self.currentProfile.delegate = self;
    self.currentProfile.ownerOfProfile = channel.channelCreator;
    self.currentProfile.channel = channel;
    [self addSubview:self.currentProfile.view];
}


-(void) showTabBar:(BOOL) show{
    [self.delegate shouldHideTabBar:!show];
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
