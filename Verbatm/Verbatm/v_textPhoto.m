//
//  v_textPhoto.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_textPhoto.h"
#import "ILTranslucentView.h"

@interface v_textPhoto()
@property (strong, nonatomic) v_textview* textLayer;
@property (strong, nonatomic) UIView* bgBlur;
@property (strong, nonatomic) UIVisualEffectView* bgBlurImage;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) BOOL isTitle;
@property (nonatomic) CGRect absoluteFrame;
#define BORDER 20
#define EXTRA  5
#define MIN_WORDS 20
#define DEFAULT_FONT_FAMILY @"ArialMT"
#define DEFAULT_FONT_SIZE 28
@end
@implementation v_textPhoto

-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andText:(NSString*)text
{
    
    if((self = [super initWithImage:image])){
        //Lay over the text
        //image = [self blur:image];
        self.frame = frame;
        
        //UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
         //self.bgBlurImage = [[UIVisualEffectView  alloc]initWithEffect:blur];
        self.bgBlurImage.frame = self.frame;
        //self.bgBlurImage.alpha = 0.8;
        [self addSubview:self.bgBlurImage];
        
        self.textLayer = [[v_textview alloc]initWithFrame: self.bounds];
        [self.textLayer setTextViewText: text];
        [self addSubview: self.textLayer];
        
        
        [self checkWordCount:text];
        [self setSizesToFit];
        self.userInteractionEnabled = YES;
        self.textLayer.backgroundColor = [UIColor clearColor];
        self.textLayer.showsVerticalScrollIndicator = NO;
        
        self.textLayer.textAlignment = NSTextAlignmentJustified;
        [self bringSubviewToFront:self.textLayer];        
    }
    return self;
}

- (UIImage*) blur:(UIImage*)theImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:3.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

-(void)checkWordCount:(NSString*)text
{
    int words = 0;
    NSArray * string_array = [text componentsSeparatedByString: @" "];
    words += [string_array count];
    //Make sure to discount blanks in the array
    for (NSString * string in string_array)
    {
        if([string isEqualToString:@""] && words != 0) words--;
    }
    //make sure that the last word is complete by having a space after it
    if(![[string_array lastObject] isEqualToString:@""]) words --;
    if(words <= MIN_WORDS){
        self.isTitle = YES;
        [self.textLayer setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
    }else{
        //Add the blur
        self.bgBlur = [[UIView alloc] initWithFrame: self.bounds];
        self.bgBlur.backgroundColor = [UIColor blackColor];
        self.bgBlur.alpha = 0.7;
        [self insertSubview:self.bgBlur belowSubview:self.textLayer];
    }
}

-(void)addSwipeGesture
{
    if(self.isTitle)return;
//    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(repositionTextLayer:)];
//    self.lastPoint = CGPointZero;
//    [self.superview addGestureRecognizer:panGesture];
    UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc]initWithTarget:self action: @selector(repositionTextLayer:)];
    swiper.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swiper];
    UISwipeGestureRecognizer* swiperL = [[UISwipeGestureRecognizer alloc]initWithTarget:self action: @selector(repositionTextLayer:)];
    swiper.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swiperL];
}

-(void)repositionTextLayer:(UISwipeGestureRecognizer*)sender
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        if(!self.textLayer.hidden) return;
        [animation setSubtype:kCATransitionFromLeft];
    }else{
        if(self.textLayer.hidden)return;
        [animation setSubtype:kCATransitionFromRight];
    }
    self.textLayer.hidden = !self.textLayer.hidden;
    self.bgBlur.hidden = !self.bgBlur.hidden;
    [self.bgBlur.layer addAnimation:animation forKey: @"transition"];
    [self.textLayer.layer addAnimation:animation forKey: @"transition"];
}


////remember to fade as the text is pulled up and down
//-(void)repositionTextLayer:(UIPanGestureRecognizer*)sender
//{
//    CGPoint translation = [sender translationInView:self];
//    if(sender.state == UIGestureRecognizerStateBegan){
//        if(translation.x > 0 && !self.textLayer.hidden){
//            return;
//        }
//        if(translation.x <  0 && self.textLayer.hidden) return;
//        if(translation.x > 0){
//            self.textLayer.hidden = NO;
//            self.bgBlur.hidden = NO;
//            self.bgBlurImage.hidden = NO;
//        }
//        self.lastPoint = translation;
//        return;
//    }else if(sender.state == UIGestureRecognizerStateEnded){
//        self.lastPoint = translation;
//        [UIView animateWithDuration:0.2 animations:^{
//            int x_location = self.bgBlur.frame.origin.x + self.bgBlur.frame.size.width;
//            int mid_pt = self.frame.origin.x + (self.frame.size.width)/2;
//            if(x_location > mid_pt){
//                [self resetFrames];
//            }else{
//                self.textLayer.hidden = YES;
//                self.bgBlur.hidden = YES;
//                self.bgBlurImage.hidden = YES;
//                self.textLayer.frame = CGRectOffset(self.absoluteFrame, - self.frame.size.width, 0);
//                self.bgBlur.frame = CGRectOffset(self.bounds, - self.frame.size.width, 0);
//                self.bgBlurImage.frame = CGRectOffset(self.bounds, - self.frame.size.width, 0);
//            }
//        } completion:^(BOOL finished) {
//             self.lastPoint = CGPointZero;
//        }];
//        return;
//    }
//    self.bgBlur.frame = CGRectOffset(self.bgBlur.frame, translation.x - self.lastPoint.x, 0);
//    if(self.frame.origin.x < self.bgBlur.frame.origin.x){
//        [self resetFrames];
//        self.lastPoint = CGPointZero;
//        return;
//    }
//    self.bgBlurImage.frame = CGRectOffset(self.bgBlurImage.frame, translation.x - self.lastPoint.x, 0);
//    self.textLayer.frame = CGRectOffset(self.textLayer.frame, translation.x - self.lastPoint.x, 0);
//    self.lastPoint = translation;
//}

-(void)resetFrames
{
    self.textLayer.frame = self.absoluteFrame;
    self.bgBlur.frame = self.bounds;
    self.bgBlurImage.frame = self.bounds;
}

/*This function sets the textLayer's size to fit superview's frame.
 *It ensures that the text layer is always centered in the super view and 
 *it text fits in perfectly.
 */
-(void)setSizesToFit
{
    self.textLayer.textAlignment = NSTextAlignmentCenter;
    CGRect this_frame = self.textLayer.frame;
    this_frame.origin.y += BORDER;
    this_frame.origin.x += BORDER;
    this_frame.size.width -= 2*BORDER;
    self.textLayer.frame = this_frame;
    [self.textLayer sizeToFit];
    if(self.textLayer.frame.size.height > self.frame.size.height - 2*BORDER){
        this_frame.size.height = self.frame.size.height - 2*BORDER;
        self.textLayer.frame = this_frame;
        self.absoluteFrame = this_frame;
    }else if (!self.isTitle){
        int translate = self.frame.size.height/2 - (self.textLayer.frame.size.height/2 + self.textLayer.frame.origin.y);
        self.textLayer.frame = CGRectOffset(self.textLayer.frame, 0, translate);
        self.absoluteFrame = self.textLayer.frame;
        return;
    }
}
@end
