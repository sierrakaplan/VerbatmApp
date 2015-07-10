//
//  verbatmPhotoVideoAve.m
//  Verbatm
//
//  Created by Iain Usiri on 2/23/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PhotoVideoAVE.h"
#import "PinchView.h"
#import "VerbatmImageView.h"

@interface PhotoVideoAVE ()
//we only have one image on this view
@property (weak, nonatomic) IBOutlet UIImageView *image;
//we only use this pinchview to show our video
@property (strong, nonatomic) IBOutlet PinchView * videoView;
@property (nonatomic) CGPoint upper_Left_PinchPoint;//either the upper finger in a y directed pinch or the left finger in an x directed pinch
@property (nonatomic) CGPoint lower_Right_PinchPoint;//either the lower finger in a y directed pinch or the right finger in a x direct pinch
@property (nonatomic) bool usingYs;

@property (nonatomic) CGPoint panStartPoint;

#define VIDEO_START_OFFSET 10
#define ELEMENT_OFFSET_DISTANCE 20 //distance between elements on the page
@end

@implementation PhotoVideoAVE

//note- what if we get multiple videos? - this needs to be corrected
-(instancetype) initWithFrame:(CGRect)frame andImageData:(NSData *)imageData andVideo:(NSArray *)video
{
    
    //load from Nib file...this initializes the background view and all its subviews
    self = [[[NSBundle mainBundle] loadNibNamed:@"PhotoVideoAVE" owner:self options:nil]firstObject];    
    if(self)
    {
		UIImage* image = [[UIImage alloc] initWithData:imageData];
        [self.image setImage:image];
        [self formatImage];
		NSMutableArray *media = [[NSMutableArray alloc]init];
		[media addObject: video];
        self.videoView = [[PinchView alloc] initWithRadius:[self getRadius] withCenter:CGPointMake([self getRadius]+VIDEO_START_OFFSET,[self getRadius]+VIDEO_START_OFFSET) andMedia:media];

        self.clipsToBounds = YES;

        [self addSubview:self.videoView];
            self.frame = frame;
        [self.videoView unmuteVideo];
    }
    return self;
}

-(void) formatImage
{
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    //self.image.clipsToBounds = YES;
}

//records the generic frame for any element that is a square and not a pinch view circle
//and its personal scrollview.
-(double)getRadius
{
    return ((self.frame.size.width/3)/2);
}


-(void)addGesturesToVideoView
{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.videoView addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.videoView addGestureRecognizer:pinch];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    
    doubleTap.numberOfTapsRequired = 2;//for double tap
    [self.videoView addGestureRecognizer:doubleTap];
}


//to be completed
-(void) pinch: (UIPinchGestureRecognizer *) gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan && [gesture numberOfTouches]==2)
    {
        CGPoint touch1 = [gesture locationOfTouch:0 inView:self];
        CGPoint touch2 = [gesture locationOfTouch:1 inView:self];
        
        if(fabs(touch1.x -touch2.x) > fabs(touch1.y- touch2.y)) self.usingYs = NO;
        else self.usingYs = YES;
        
        if(self.usingYs)
        {
            if(touch1.y > touch2.y)
            {
                self.upper_Left_PinchPoint = touch2;
                self.lower_Right_PinchPoint = touch1;
            }else
            {
                self.upper_Left_PinchPoint = touch1;
                self.lower_Right_PinchPoint = touch2;
            }
            
        }else
        {
            if(touch1.x > touch2.x)
            {
                self.upper_Left_PinchPoint = touch2;
                self.lower_Right_PinchPoint = touch1;
            }else
            {
                self.upper_Left_PinchPoint = touch1;
                self.lower_Right_PinchPoint =touch2;
            }
        }
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged && [gesture numberOfTouches]==2)
    {
        CGPoint touch1 = [gesture locationOfTouch:0 inView:self];
        CGPoint touch2 = [gesture locationOfTouch:1 inView:self];
        
        if(self.usingYs)
        {
            double diff = ((touch1.y > touch2.y) ? fabs(touch2.y-self.upper_Left_PinchPoint.y)/* + fabs(touch1.y-self.lower_Right_PinchPoint.y)*/ : fabs(touch1.y-self.upper_Left_PinchPoint.y) /*+ fabs(touch2.y-self.lower_Right_PinchPoint.y)*/) ;
            if(gesture.scale > 1) [self.videoView changeWidthTo: (self.videoView.frame.size.width + diff)];
            else [self.videoView changeWidthTo: (self.videoView.frame.size.width - diff)];
        }
    }
}


//sets the size of the video viewer back to default frame
//function only gets called if there is a double tap
-(void) doubleTap:(UITapGestureRecognizer *) gesture
{
        [self.videoView changeWidthTo:([self getRadius]*2)];//we set the frame back to the original size
}


//should move the video view with the users finger on drag
-(void)pan:(UIPanGestureRecognizer *) gesture
{
 
    //make sure we have one finger only
    if(gesture.state == UIGestureRecognizerStateBegan && [gesture numberOfTouches]==1)
    {
        
        self.panStartPoint = [gesture locationOfTouch:0 inView:self];
    }
    
    //make sure we have one finger only
    if(gesture.state == UIGestureRecognizerStateChanged && [gesture numberOfTouches]==1)
    {
        CGPoint currentPoint = [gesture locationOfTouch:0 inView:self];
        
        int x_diff = currentPoint.x - self.panStartPoint.x;
        int y_diff = currentPoint.y - self.panStartPoint.y;
        
        int x_cord = self.videoView.frame.origin.x + x_diff;
        int y_cord = self.videoView.frame.origin.y + y_diff;
        
        [self.videoView setFrame:CGRectMake(x_cord, y_cord,self.videoView.frame.size.width , self.videoView.frame.size.height)];
        self.panStartPoint = currentPoint;
    }
}

-(void) mute
{
    [self.videoView muteVideo];
}

-(void) unmute
{
    [self.videoView unmuteVideo];
}

-(void)onScreen
{
    [self.videoView onScreen];
}
-(void)offScreen
{
    [self.videoView offScreen];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
