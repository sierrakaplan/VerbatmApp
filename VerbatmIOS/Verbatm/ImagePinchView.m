//
//  ImagePinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ImagePinchView.h"
#import "UIImage+ImageEffectsAndTransforms.h"

@interface ImagePinchView()

@property (strong, nonatomic) UIImage* imageToPublish;


@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) UIImageView *imageView;

#pragma mark Encoding Keys

#define CREATE_FILTERED_IMAGES_QUEUE_KEY "create_filtered_images_queue"
#define IMAGE_KEY @"image_key"
#define FILTER_INDEX_KEY @"filter_index_key"

@end

@implementation ImagePinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andImage:(UIImage*)image {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
        if(!image) return self;
		[self initWithImage:image andSetFilteredImages:YES];
        self.imageToPublish = nil;
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
//	if (setFilters) [self createFilteredImagesFromImage:self.image];
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
//	[self createFilteredImagesFromImage:self.image];
    [self renderMedia];
}

#pragma mark - Render Media -

-(void)renderMedia {
	self.imageView.frame = self.background.frame;
	[self.imageView setImage:[self getImage]];
}

#pragma mark - Get or Change Image -

//warns the pinchview that it is getting published -- so it can
//release all the excess media that it has in order to clear up some
//space (prevents crashing)
-(void)publishingPinchView{
    self.imageToPublish = [self getImage];
    @autoreleasepool {
       [self.filteredImages removeAllObjects];
        self.filteredImages = nil;
        self.image = nil;
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
}

-(UIImage*) getImage {
	return self.filteredImages[self.filterImageIndex];
}

-(UIImage *) getOriginalImage{
    return self.filteredImages[0];
}

/* media, text, textYPosition, textColor, textAlignment, textSize */
-(NSArray*) getPhotosWithText {
	
    UIImage * imageToReturn = (self.imageToPublish) ? self.imageToPublish : [self getImage];
    
    return @[@[imageToReturn, self.text, self.textYPosition,
			   self.textColor, self.textAlignment, self.textSize]];
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
			//todo: stop this
//			NSLog(@"Adding filtered photo.");
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

//todo: add other text data
- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:UIImagePNGRepresentation(self.image) forKey:IMAGE_KEY];
	[coder encodeObject:[NSNumber numberWithInteger:self.filterImageIndex] forKey:FILTER_INDEX_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData* imageData = [decoder decodeObjectForKey:IMAGE_KEY];
		UIImage* image = [UIImage imageWithData:imageData];
		NSNumber* filterImageIndexNumber = [decoder decodeObjectForKey:FILTER_INDEX_KEY];
		[self initWithImage:image andSetFilteredImages:YES];
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
