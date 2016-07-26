//
//  AdjustTextAVEBackgroundToolBar.h
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AdjustTextAVEBackgroundToolBarDelegate <NSObject>

-(void)changeImageToImage:(NSString*) imageName;

@end


@interface AdjustTextAVEBackgroundToolBar : UIScrollView
    @property (nonatomic, weak) id<AdjustTextAVEBackgroundToolBarDelegate> toolBarDelegate;
@end
