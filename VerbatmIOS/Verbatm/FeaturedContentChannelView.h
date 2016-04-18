//
//  FeaturedContentChannelView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedContentChannelView : UIView

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel*)channel
				andPostObject: (PFObject *)post andPages: (NSArray *) pages;

-(void) onScreen;

-(void) offScreen;

-(void) almostOnScreen;

@end
