//
//  verbatmPhotoVideoAve.m
//  Verbatm
//
//  Created by Iain Usiri on 2/23/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmPhotoVideoAve.h"
#import "verbatmCustomPinchView.h"
#import "verbatmCustomImageView.h"

@interface verbatmPhotoVideoAve ()
//we only have one image on this view
@property (weak, nonatomic) IBOutlet UIImageView *image;
//we only use this pinchview to show our video
@property (strong, nonatomic) IBOutlet verbatmCustomPinchView * videoView;
@property (nonatomic) CGPoint upperPinchPoint;
@property (nonatomic) CGPoint lowerPinchPoint;
@property (nonatomic) bool usingYs;


#define ELEMENT_OFFSET_DISTANCE 20 //distance between elements on the page
@end

@implementation verbatmPhotoVideoAve


-(instancetype) initWithFrame:(CGRect)frame Image: (verbatmCustomImageView *) image andVideo: (verbatmCustomImageView *) video
{
    
    //load from Nib file...this initializes the background view and all its subviews
    self = [[[NSBundle mainBundle] loadNibNamed:@"PhotoVideoAve" owner:self options:nil]firstObject];    
    if(self)
    {
        self.image.image = image.image;
        self.videoView = [[verbatmCustomPinchView alloc] initWithRadius:[self getRadius] withCenter:CGPointMake([self getRadius]/2,[self getRadius]/2) andMedia:@[video]];
        [self addSubview:self.videoView];
            self.frame = frame;
    }
    return self;
}

//records the generic frame for any element that is a square and not a pinch view circle
//and its personal scrollview.
-(double)getRadius
{
    CGSize defaultPersonalScrollViewFrameSize_closedElement = CGSizeMake(self.frame.size.width, ((self.frame.size.height*2)/5));
    
    return (defaultPersonalScrollViewFrameSize_closedElement.height - ELEMENT_OFFSET_DISTANCE)/2;
}

-(void)addGesturesToVideoView
{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.videoView addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.videoView addGestureRecognizer:pinch];
    
    
    
}


//to be completed
-(void) pinch: (UIPinchGestureRecognizer *) gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan && [gesture numberOfTouches]==2)
    {
        CGPoint touch1 = [gesture locationOfTouch:0 inView:self];
        CGPoint touch2 = [gesture locationOfTouch:1 inView:self];
        
        
        if(abs(touch1.x -touch2.x) > abs(touch1.y- touch2.y)) self.usingYs = NO;
        else self.usingYs = YES;
        
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged && [gesture numberOfTouches]==2)
    {
        CGPoint touch1 = [gesture locationOfTouch:0 inView:self];
        CGPoint touch2 = [gesture locationOfTouch:1 inView:self];
        
        
    }
    
}

//should move the video view with the users finger on drag
-(void)pan:(UIPanGestureRecognizer *) gesture
{
 
    //make sure we have one finger only
    if(gesture.state == UIGestureRecognizerStateChanged && [gesture numberOfTouches]==1)
    {
        [self.videoView specifyCenter:[gesture locationOfTouch:0 inView:self]];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
