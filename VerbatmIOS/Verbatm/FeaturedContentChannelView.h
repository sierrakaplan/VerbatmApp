//
//  FeaturedContentChannelView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeaturedChannelViewDelegate <NSObject>

-(void) channelSelected: (Channel*)channel;
-(void) channelFollowed:(Channel *)channel;

@end

@interface FeaturedContentChannelView : UIView

@property (weak, nonatomic) id<FeaturedChannelViewDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel*)channel
				andPostObject: (PFObject *)post andPages: (NSArray *) pages;

-(void) onScreen;

-(void) offScreen;

-(void) almostOnScreen;

@end
