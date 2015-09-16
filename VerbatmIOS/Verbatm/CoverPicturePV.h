//
//  CoverPicturePV.h
//  Verbatm
//
//  Created by Iain Usiri on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ImagePinchView.h"

@interface CoverPicturePV : ImagePinchView
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andImage:(UIImage*)image;
-(void) setNewImageWith: (UIImage*) image;
-(UIImage*) getImage;
-(void) removeImage;
@end
