//
//  DiscoverCollectionViewCell.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Channel;

@interface DiscoverCollectionViewCell : UICollectionViewCell

@property (weak, readonly) Channel *channelBeingPresented;

-(void) clearViews;
-(void)presentChannel:(Channel *) channel;

@end
