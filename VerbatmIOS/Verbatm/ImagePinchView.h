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

@property (strong, nonatomic) NSMutableArray* filteredImages;
@property (nonatomic) NSInteger filterImageIndex;
@property (strong, nonatomic) NSString* phAssetLocalIdentifier;
@property (nonatomic) CGSize largeSize;

-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andImage:(UIImage*)image
	andPHAssetLocalIdentifier: (NSString*) localIdentifier andLargerSize: (CGSize)largeSize;

-(void) initWithImage:(UIImage*)image andSetFilteredImages: (BOOL) setFilters;

//change which filter is applied
-(void)changeImageToFilterIndex:(NSInteger)filterIndex;

-(AnyPromise*) getImageData;

//returns the image with its current filter 
-(UIImage*) getImage;

-(AnyPromise *) getLargerImageWithSize: (CGSize) size;

//returns the image without any filter - guaranteed to be unfiltered
-(UIImage *) getOriginalImage;

//replaces the current image with this image
-(void) putNewImage:(UIImage*)image;
//warns the pinchview that it is getting published -- so it can
//release all the excess media that it has in order to clear up some
//space (prevents crashing)
-(void)publishingPinchView;
@end
