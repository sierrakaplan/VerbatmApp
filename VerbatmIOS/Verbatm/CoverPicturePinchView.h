//
//  CoverPicturePinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ImagePinchView.h"

@interface CoverPicturePinchView : PinchView

-(void) setImage: (UIImage*) image;
-(UIImage*) getImage;
-(void) removeImage;

@end
