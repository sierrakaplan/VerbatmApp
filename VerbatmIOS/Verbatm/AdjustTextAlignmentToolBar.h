//
//  AdjustTextAlignmentToolBar.h
//  Verbatm
//
//  Created by Iain Usiri on 7/25/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdjustTextAlignmentToolBarDelegate <NSObject>

-(void)alignTextLeft;
-(void)alignTextRight;
-(void)alignTextCenter;

@end

@interface AdjustTextAlignmentToolBar : UIView

@property(nonatomic) id<AdjustTextAlignmentToolBarDelegate> delegate;

@end
