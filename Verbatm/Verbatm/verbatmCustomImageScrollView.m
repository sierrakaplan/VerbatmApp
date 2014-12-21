//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomImageScrollView.h"
#import "verbatmCustomImageView.h"

@interface verbatmCustomImageScrollView ()
@end


@implementation verbatmCustomImageScrollView

-(instancetype) initWithFrame:(CGRect)frame andYOffset: (NSInteger) yoffset
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.contentSize =  CGSizeMake(0, 3*frame.size.height);//make it up and down swipeable
        self.contentOffset = CGPointMake(0,frame.size.height);
        self.backgroundColor = [UIColor blackColor];
        self.frame = frame;
        self.pagingEnabled = YES;
    }
    return self;
}

-(void)addImage: (verbatmCustomImageView *) givenImageView withYOffset: (NSInteger) yoffset
{
    //create a new scrollview to place the images
    
    CGRect frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    
    UIScrollView * scrollview = [[UIScrollView alloc] initWithFrame:frame];
    scrollview.pagingEnabled = YES;
    scrollview.contentSize = CGSizeMake(self.frame.size.width *3, 0);
    scrollview.contentOffset = CGPointMake(self.frame.size.width, 0);
    
    verbatmCustomImageView * image1= [[verbatmCustomImageView alloc]init];
    image1.image = givenImageView.image;
    image1.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [scrollview addSubview:image1];
    
    verbatmCustomImageView * image2= [[verbatmCustomImageView alloc]init];
    image2.image = givenImageView.image;
    image2.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    [scrollview addSubview:image2];
    
    verbatmCustomImageView * image3= [[verbatmCustomImageView alloc]init];
    image3.image = givenImageView.image;
    image3.frame = CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height);
    [scrollview addSubview:image3];
    
    [self creatFilteresForImage:image1 andImage:image2 andImage:image3 fromImage:givenImageView];
    
    [self addSubview:scrollview];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

-(void)creatFilteresForImage: (verbatmCustomImageView *) image1 andImage: (verbatmCustomImageView *) image2 andImage: (verbatmCustomImageView *) image3 fromImage: (verbatmCustomImageView *) openImage
{
    //original "filter"
    ALAssetRepresentation *assetRepresentation = [openImage.asset defaultRepresentation];
    image2.image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                               scale:[assetRepresentation scale]
                                         orientation:UIImageOrientationUp];
    
    
    
    NSData * data = UIImagePNGRepresentation(openImage.image);
    
    
    
    //warm filter
    CIImage *beginImage =  [CIImage imageWithData:data];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues: kCIInputImageKey, beginImage, nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    image3.image = [UIImage imageWithCGImage:cgimg];
    
    //black and white filter
    //warm filter
    CIImage *beginImage1 =  [CIImage imageWithData:data];
    
    CIFilter *filter1 = [CIFilter filterWithName:@"CIPhotoEffectMono"
                                   keysAndValues: kCIInputImageKey, beginImage1, nil];
    
    CIImage *outputImage1 = [filter1 outputImage];
    
    CGImageRef cgimg1 =[context createCGImage:outputImage1 fromRect:[outputImage1 extent]];
    
    image1.image = [UIImage imageWithCGImage:cgimg1];
    
    CGImageRelease(cgimg);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
