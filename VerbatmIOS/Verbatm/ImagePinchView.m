//
//  ImagePinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ImagePinchView.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "TextOverMediaView.h"

#import "UIView+Effects.h"
#import "UIImage+ImageEffectsAndTransforms.h"
#import "MediaSessionManager.h"
@import AVFoundation;
@import Photos;

@interface ImagePinchView()

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) UIImageView *imageView;

#pragma mark Encoding Keys

#define CREATE_FILTERED_IMAGES_QUEUE_KEY "create_filtered_images_queue"
#define IMAGE_KEY @"image_key"
#define FILTER_INDEX_KEY @"filter_index_key"
#define CONTENT_OFFSET_X_KEY @"content_offset_x_key"
#define CONTENT_OFFSET_Y_KEY @"content_offset_y_key"
#define PHASSET_IDENTIFIER_KEY @"image_phasset_local_id"

@end

@implementation ImagePinchView

-(instancetype)initWithRadius:(CGFloat)radius withCenter:(CGPoint)center andImage:(UIImage*)image
	andPHAssetLocalIdentifier: (NSString*) localIdentifier {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		if(!image) return self;
		self.phAssetLocalIdentifier = localIdentifier;
		//todo: center image beginning
		self.imageContentOffset = CGPointZero;
		[self initWithImage:image andSetFilteredImages:YES];
	}
	return self;
}

-(void) initWithImage:(UIImage*)image andSetFilteredImages: (BOOL) setFilters {
	if (image == nil) return;
	[self.background addSubview:self.imageView];
	self.containsImage = YES;
	self.image = image;
	self.filteredImages = [[NSMutableArray alloc] init];
	//original photo
	[self.filteredImages addObject:self.image];
	[self renderMedia];
}

-(void) putNewImage:(UIImage*)image{
	if(!image)return;
	if(!_imageView) {
		[self.background addSubview:self.imageView];
	}
	self.containsImage = YES;
	self.image = image;
	self.filterImageIndex = 0;
	self.filteredImages = nil;
	self.filteredImages = [[NSMutableArray alloc] init];
	//original photo
	[self.filteredImages addObject:self.image];
	[self renderMedia];
}

#pragma mark - Render Media -

-(void)renderMedia {
	self.imageView.frame = self.background.frame;
	[self.imageView setImage:[self getImage]];
	[self addEditIcon];
}

#pragma mark - Get or Change Image -

//warns the pinchview that it is getting published -- so it can
//release all the excess media that it has in order to clear up some
//space (prevents crashing)
-(void)publishingPinchView {
	@autoreleasepool {
		[self.filteredImages removeAllObjects];
		self.filteredImages = nil;
		self.image = nil;
		[self.imageView removeFromSuperview];
		self.imageView = nil;
	}
}

//todo
-(AnyPromise *) getImageDataWithHalfSize:(BOOL)half {
	return [self getLargerImageWithHalfSize:half].then(^(UIImage *largerImage) {
		return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSData* imageData = UIImagePNGRepresentation(largerImage);
				resolve (imageData);
			});
		}];
	});
}

-(UIImage*) getImage {
	return self.filteredImages[self.filterImageIndex];
}

-(AnyPromise *) getLargerImageWithHalfSize:(BOOL)half; {

	PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.phAssetLocalIdentifier] options:nil];
	PHAsset* imageAsset = fetchResult.firstObject;
    __weak ImagePinchView * weakSelf = self;
	weakSelf.imageName = [imageAsset valueForKey:@"filename"];
	CGSize size = half ? HALF_SCREEN_SIZE : FULL_SCREEN_SIZE;
	PHImageRequestOptions *options = [PHImageRequestOptions new];
	options.synchronous = YES;
	options.resizeMode = PHImageRequestOptionsResizeModeFast;
	options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[PHImageManager defaultManager] requestImageForAsset:imageAsset targetSize:size contentMode:PHImageContentModeAspectFill
                  options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
					  //todo:
                      image = [image imageByScalingAndCroppingForSize: CGSizeMake(size.width, size.height)];

                      if(weakSelf.beingPublished){
                          dispatch_async(dispatch_get_main_queue(), ^{
                              resolve([weakSelf getImageScreenshotWithText:image inHalf:half]);
                          });
                      } else {
                          resolve(image);
                      }  
            }];
        });
	}];
	return promise;
}

-(UIImage *) getOriginalImage{
	return self.filteredImages[0];
}


/* media, text, textYPosition, textColor, textAlignment, textSize */
-(NSArray*) getPhotosWithText {
   return @[@[[self getImage], @"", @(0),
                   self.textColor, @(0), @(0)]];
}

//todo: set size to actual size of current screen so positioning isn't wrong
-(UIImage *)getImageScreenshotWithText:(UIImage *)image inHalf:(BOOL)half {
	@autoreleasepool {
		CGSize size = half ? HALF_SCREEN_SIZE : FULL_SCREEN_SIZE;
		CGRect frame = CGRectMake(0.f, 0.f, size.width, size.height);
        
		TextOverMediaView* textAndImageView = [[TextOverMediaView alloc] initWithFrame:frame andImage:image
																	  andContentOffset:self.imageContentOffset];
		BOOL textColorBlack = [self.textColor isEqual:[UIColor blackColor]];
		NSString * textToCapture = self.text;

		[textAndImageView setText: textToCapture
				 andTextYPosition: [self.textYPosition floatValue]
				andTextColorBlack: textColorBlack
				 andTextAlignment: (NSTextAlignment) ([self.textAlignment integerValue])
					  andTextSize: [self.textSize floatValue] andFontName:self.fontName];
        
		[textAndImageView showText:YES];
		[textAndImageView.textView setHidden:NO];
		[textAndImageView bringSubviewToFront:textAndImageView.textView];

		UIImage * screenShot = [textAndImageView getViewScreenshot];
		textAndImageView = nil;
		return screenShot;
	}
}

-(void)changeImageToFilterIndex:(NSInteger)filterIndex {
	if(filterIndex < 0 || filterIndex >= [self.filteredImages count]) {
		return;
	}
	self.filterImageIndex = filterIndex;
	[self renderMedia];
}

-(NSInteger) getTotalPiecesOfMedia {
	return 1;
}

#pragma mark - Filters -

//return array of uiimage with filter from image
-(void)createFilteredImagesFromImage:(UIImage *)image {
	NSArray* filterNames = [UIImage getPhotoFilters];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSData  * imageData = UIImagePNGRepresentation(image);
		//Background Thread
		for (NSString* filterName in filterNames) {
			@autoreleasepool {
				CIImage *beginImage =  [CIImage imageWithData: imageData];
				CIContext *context = [CIContext contextWithOptions:nil];
				CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues: kCIInputImageKey, beginImage, nil];
				CIImage *outputImage = [filter outputImage];
				CGImageRef CGImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
				UIImage* imageWithFilter = [UIImage imageWithCGImage:CGImageRef];
				CGImageRelease(CGImageRef);

				dispatch_async(dispatch_get_main_queue(), ^{
					[self.filteredImages addObject:imageWithFilter];
				});
			}
		}
	});
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:UIImagePNGRepresentation(self.image) forKey:IMAGE_KEY];
	[coder encodeObject:[NSNumber numberWithInteger:self.filterImageIndex] forKey:FILTER_INDEX_KEY];
	[coder encodeObject:[NSNumber numberWithFloat:self.imageContentOffset.x] forKey:CONTENT_OFFSET_X_KEY];
	[coder encodeObject:[NSNumber numberWithFloat:self.imageContentOffset.y] forKey:CONTENT_OFFSET_Y_KEY];
	[coder encodeObject: self.phAssetLocalIdentifier forKey:PHASSET_IDENTIFIER_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData* imageData = [decoder decodeObjectForKey:IMAGE_KEY];
		UIImage* image = [UIImage imageWithData:imageData];
		NSNumber* filterImageIndexNumber = [decoder decodeObjectForKey:FILTER_INDEX_KEY];
		NSNumber* contentOffsetX = [decoder decodeObjectForKey:CONTENT_OFFSET_X_KEY];
		NSNumber* contentOffsetY = [decoder decodeObjectForKey:CONTENT_OFFSET_Y_KEY];
		self.phAssetLocalIdentifier = [decoder decodeObjectForKey:PHASSET_IDENTIFIER_KEY];
		[self initWithImage:image andSetFilteredImages:YES];
		self.imageContentOffset = CGPointMake(contentOffsetX.floatValue, contentOffsetY.floatValue);
		[self changeImageToFilterIndex:filterImageIndexNumber.integerValue];
	}
	return self;
}

#pragma mark - Lazy Instantiation

-(UIImageView*)imageView {
	if(!_imageView) {
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		_imageView.layer.masksToBounds = YES;
	}
	return _imageView;
}

@end
