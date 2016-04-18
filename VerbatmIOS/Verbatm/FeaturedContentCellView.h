//
//  FeaturedContentCellView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedContentCellView : UITableViewCell

@property (nonatomic) BOOL alreadyPresented;

-(void)presentChannels:(NSArray*) channels;

-(void)onScreen;

-(void)offScreen;

@end
