//
//  AdjustTextFontToolBar.h
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AdjustTextFontToolBarDelegate <NSObject>

-(void)changeTextFontToFont:(NSString *) fontName;

@end

@interface AdjustTextFontToolBar : UIView
    @property(nonatomic,weak) id<AdjustTextFontToolBarDelegate> delegate;
@end
