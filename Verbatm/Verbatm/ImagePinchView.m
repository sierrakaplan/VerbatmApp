//
//  ImagePinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ImagePinchView.h"
#import "UIEffects.h"

@interface ImagePinchView()

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) UIImageView *imageView;

#pragma mark Encoding Keys

#define IMAGE_KEY @"image"

@end

@implementation ImagePinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andImage:(UIImage*)image {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self initWithImage:image];
	}
	return self;
}

-(void) initWithImage:(UIImage*)image {
	[self.background addSubview:self.imageView];
	self.containsImage = YES;
	self.image = image;
	[self setFilteredPhotos];
	[self renderMedia];
}

#pragma mark - Lazy Instantiation

-(UIImageView*)imageView {
	if(!_imageView) _imageView = [[UIImageView alloc] init];
	_imageView.contentMode = UIViewContentModeCenter;
	_imageView.layer.masksToBounds = YES;
	return _imageView;
}

#pragma mark - Render Media -

//This should be overriden in subclasses
-(void)renderMedia {
	self.imageView.frame = self.background.frame;
	[self displayMedia];
}

//This function displays the media on the view.
-(void)displayMedia {
	[self.imageView setImage:[self getImage]];
}

#pragma mark - Get Change Image -

-(UIImage*) getImage {
	return self.filteredImages[self.filterImageIndex];
}

//overriding
-(NSArray*) getPhotos {
	return @[[self getImage]];
}

-(void)changeImageToFilterIndex:(NSInteger)filterIndex {
	if(filterIndex < 0 || filterIndex >= [self.filteredImages count]) {
		NSLog(@"Filtered image index out of range");
		return;
	}
	self.filterImageIndex = filterIndex;
	[self renderMedia];
}

#pragma mark - Filters -

-(void) setFilteredPhotos {
	NSArray* filterNames = [UIEffects getPhotoFilters];
	self.filteredImages = [[NSMutableArray alloc] initWithCapacity:[filterNames count]+1];
	//original photo
	[self.filteredImages addObject:self.image];
	[self createFilteredImagesFromImageData:UIImagePNGRepresentation(self.image) andFilterNames:filterNames];
}

//return array of uiimage with filter from image
-(void)createFilteredImagesFromImageData:(NSData*)imageData andFilterNames:(NSArray*)filterNames{

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		//Background Thread
		for (NSString* filterName in filterNames) {
			CIImage *beginImage =  [CIImage imageWithData: imageData];
			CIContext *context = [CIContext contextWithOptions:nil];
			CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues: kCIInputImageKey, beginImage, nil];
			CIImage *outputImage = [filter outputImage];
			CGImageRef cgImg = [context createCGImage:outputImage fromRect:[outputImage extent]];
			UIImage* imageWithFilter = [UIImage imageWithCGImage:cgImg];
			CGImageRelease(cgImg);
			[self.filteredImages addObject:imageWithFilter];
		}
		dispatch_async(dispatch_get_main_queue(), ^(void){
			//Run UI Updates
		});
	});
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:UIImagePNGRepresentation(self.image) forKey:IMAGE_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData* imageData = [decoder decodeObjectForKey:IMAGE_KEY];
		UIImage* image = [UIImage imageWithData:imageData];
		[self initWithImage:image];
	}
	return self;
}

@end
