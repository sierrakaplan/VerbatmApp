//
//  v_photoVideo.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface v_photoVideo : UIImageView
-(id)initWithFrame:(CGRect)frame Assets:(NSArray*)assetList andImage:(UIImage*)image;
-(void)createLongPressGesture;
@end
