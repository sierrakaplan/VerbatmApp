//
//  ImagePinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "SingleMediaAndTextPinchView.h"
#import <PromiseKit/PromiseKit.h>

@interface ImagePinchView : SingleMediaAndTextPinchView

@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSMutableArray* filteredImages;
@property (nonatomic) NSInteger filterImageIndex;
@property (nonatomic) CGPoint imageContentOffset; //stores position of image
@property (nonatomic) CGRect imageContentFrame; //stores position of image

@property (strong, nonatomic) NSString* phAssetLocalIdentifier;

-(instancetype)initWithRadius:(CGFloat)radius withCenter:(CGPoint)center andImage:(UIImage*)image
	andPHAssetLocalIdentifier: (NSString*) localIdentifier;

-(void) initWithImage:(UIImage*)image andSetFilteredImages: (BOOL) setFilters;

-(UIImage *)getImageScreenshotWithText:(UIImage *)image inHalf:(BOOL)half;

//change which filter is applied
-(void)changeImageToFilterIndex:(NSInteger)filterIndex;

//Resolves to data for a full screen sized image if half is false, half otherwise
-(AnyPromise*) getImageDataWithHalfSize:(BOOL)half;

//returns the image with its current filter 
-(UIImage*) getImage;

//Returns a full screen sized image if half is false, half otherwise
-(AnyPromise *) getLargerImageWithHalfSize:(BOOL)half;

//returns the image without any filter - guaranteed to be unfiltered
-(UIImage *) getOriginalImage;

//replaces the current image with this image
-(void) putNewImage:(UIImage*)image;

//todo: delete?
//warns the pinchview that it is getting published -- so it can
//release all the excess media that it has in order to clear up some
//space (prevents crashing)
-(void)publishingPinchView;

@end
