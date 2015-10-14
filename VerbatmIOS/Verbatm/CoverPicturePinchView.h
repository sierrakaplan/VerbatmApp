//
//  CoverPicturePV.h
//  Verbatm
//
//  Pinch View that holds a cover picture
//

#import "ImagePinchView.h"

@interface CoverPicturePinchView : ImagePinchView

-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andImage:(UIImage*)image;

-(void) setNewImage: (UIImage*) image;

-(UIImage*) getImage;

-(void) removeImage;

@end
