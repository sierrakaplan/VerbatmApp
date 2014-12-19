//
//  v_textPhoto.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "v_textview.h"


@interface v_textPhoto : UIImageView
-(id)initWithImage:(UIImage *)image andText:(NSString*)text;
@end
