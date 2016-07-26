//
//  AdjustTextSizeToolBar.h
//  Verbatm
//
//  Created by Iain Usiri on 7/25/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdjustTextSizeDelegate <NSObject>

-(void)increaseTextSizeDelegate;
-(void)decreaseTextSizeDelegate;

@end

@interface AdjustTextSizeToolBar : UIView
@property (nonatomic, weak) id<AdjustTextSizeDelegate> delegate;
@end
