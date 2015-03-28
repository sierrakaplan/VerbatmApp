//
//  v_multiplePhoto.m
//  Verbatm
//
//  Created by Iain Usiri on 3/24/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "v_multiplePhoto.h"
#import "verbatmCustomPinchView.h"
#import "verbatmCustomImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ELEMENT_TOP_OFFSET 10 //the gap between pinvhviews and the top of the screen
#define BETWEEN_ELEMENT_OFFSET 10 //the gap between pinchviews on the left and right
#define RADIUS ((self.SV_PhotoList.frame.size.height/2)- ELEMENT_TOP_OFFSET)

@interface v_multiplePhoto ()

@property (weak, nonatomic) IBOutlet verbatmCustomImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIScrollView *SV_PhotoList;

@end


@implementation v_multiplePhoto


-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSMutableArray *) photos
{
    
    //load from Nib file...this initializes the background view and all its subviews
    self = [[[NSBundle mainBundle] loadNibNamed:@"v_multiplePhoto" owner:self options:nil]firstObject];
    if(self)
    {
        [self setPhotoFrom:photos];
        if(photos.count >1)[self fillScrollView:photos];//if there are many photos then we have a scrollview
    }
    
    return self;
}

-(void) setPhotoFrom: (NSArray *) photos
{
    self.mainImage.contentMode = UIViewContentModeScaleAspectFill;
    self.mainImage.image = (UIImage*)photos.firstObject;
    self.mainImage.layer.masksToBounds = YES;
    self.mainImage.userInteractionEnabled = YES;
}



//fills our scrollview with pinch views of our media list
-(void) fillScrollView:(NSMutableArray *) photos
{
    for (UIImage * image in photos)
    {
        verbatmCustomPinchView * pv = [[verbatmCustomPinchView alloc] initWithRadius:RADIUS withCenter:[self getNextCenter] Images:@[image] videoData:nil andText:nil];
        [self addTapGesture:pv];
        [self.SV_PhotoList addSubview:pv];
    }
}


-(void) addTapGesture: (UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectTapped:)];
    [view addGestureRecognizer:tap];
}


//when a pv is tapped we swap it's image for the one on display
-(void) pinchObjectTapped:(UITapGestureRecognizer *) gesture
{
    verbatmCustomPinchView * pv = (verbatmCustomPinchView *) gesture.view;
    
    verbatmCustomPinchView * new_pv = [[verbatmCustomPinchView alloc] initWithRadius:RADIUS withCenter:pv.center Images: @[self.mainImage.image] videoData:nil andText:nil];
    [pv removeFromSuperview];
    [self.SV_PhotoList addSubview:new_pv];
    
    NSArray * photos = [pv getPhotos];
    [self setPhotoFrom: photos];
}


//calculates the next center point for the next pinch view using the last pinch view
-(CGPoint) getNextCenter
{
    if(!self.SV_PhotoList.subviews.count)return CGPointMake((BETWEEN_ELEMENT_OFFSET+RADIUS), (RADIUS + ELEMENT_TOP_OFFSET));
    
    UIView * pv = self.SV_PhotoList.subviews.lastObject;
    int x_cord = pv.frame.origin.x+ RADIUS*3 + BETWEEN_ELEMENT_OFFSET;//we multiply the radius by 3 because the next center is a diameter and a half (plus offset) from the x origin of the last
    int y_cord = RADIUS + ELEMENT_TOP_OFFSET;
    return CGPointMake(x_cord, y_cord);
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
