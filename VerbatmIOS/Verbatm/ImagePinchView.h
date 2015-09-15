//
//  ImagePinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"

@interface ImagePinchView : PinchView

@property (strong, nonatomic) NSMutableArray* filteredImages;
@property (nonatomic) NSInteger filterImageIndex;

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andImage:(UIImage*)image;

//change which filter is applied
-(void)changeImageToFilterIndex:(NSInteger)filterIndex;

//returns the image with its current filter 
-(UIImage*) getImage;
//replaces the current image with this image
-(void) putNewImage:(UIImage*)image;
@end
