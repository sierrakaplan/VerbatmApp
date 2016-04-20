//
//  FeaturedContentCellView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeaturedContentCellViewDelegate <NSObject>

-(void) channelSelected:(Channel*)channel;

@end

@interface FeaturedContentCellView : UITableViewCell

@property (weak, nonatomic) id<FeaturedContentCellViewDelegate> delegate;
@property (nonatomic) BOOL alreadyPresented;

-(void)presentChannels:(NSArray*) channels;

//Makes cell ready to display new content
-(void)clearViews;

-(void)onScreen;

-(void)offScreen;

@end
