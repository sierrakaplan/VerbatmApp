//
//  v_textPhoto.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TextAVE.h"


@interface TextPhotoAVE : UIImageView
-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andText:(NSString*)text;
//must be added after the supet view is set
-(void)addSwipeGesture;
@end
