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

//this is set by the edit content view.
//it's also formatted etc by the edit content view
@property (nonatomic, strong) UITextView * textView;


-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andImage:(UIImage*)image;

//change which filter is applied
-(void)changeImageToFilterIndex:(NSInteger)filterIndex;

//returns the image with its current filter 
-(UIImage*) getImage;
//returns the image without any filter - guaranteed to be unfiltered
-(UIImage *) getOriginalImage;
//replaces the current image with this image
-(void) putNewImage:(UIImage*)image;
@end
