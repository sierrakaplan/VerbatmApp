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
        if(!image)return self;
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

-(void) putNewImage:(UIImage*)image{
    if(!image)return;
    if(!_imageView) {
        [self.background addSubview:self.imageView];
    }
    self.containsImage = YES;
    self.image = image;
    self.filterImageIndex = 0;
    self.filteredImages = nil;
    [self setFilteredPhotos];
    [self renderMedia];
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
    //[self createFilteredImagesFromImageData:self.image andFilterNames:filterNames];
}

//return array of uiimage with filter from image
-(void)createFilteredImagesFromImageData:(UIImage *)image andFilterNames:(NSArray*)filterNames{
    ImagePinchView * __weak weakSelf = self;
    // Create a block operation with our saves
    NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
        NSData  * imageData = UIImagePNGRepresentation(image);
        //Background Thread
        for (NSString* filterName in filterNames) {
            CIImage *beginImage =  [CIImage imageWithData: imageData];
            CIContext *context = [CIContext contextWithOptions:nil];
            CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues: kCIInputImageKey, beginImage, nil];
            CIImage *outputImage = [filter outputImage];
            CGImageRef CGImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
            UIImage* imageWithFilter = [UIImage imageWithCGImage:CGImageRef];
            CGImageRelease(CGImageRef);
            [weakSelf.filteredImages addObject:imageWithFilter];
        }
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:saveOp];
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
