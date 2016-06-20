//
//  BlogPopupView.h
//  Verbatm
//
//  Created by Damas on 4/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface BlogPopupView : UIView

-(instancetype) initWithFrame:(CGRect)frame forBlog:(Channel *) channel;

@end
