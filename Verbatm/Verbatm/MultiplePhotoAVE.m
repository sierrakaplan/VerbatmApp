//
//  v_multiplePhoto.m
//  Verbatm
//
//  Created by Iain Usiri on 3/24/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "MultiplePhotoAVE.h"
#import "PinchView.h"
#import "VerbatmImageView.h"
#import "TextAVE.h"
#import "BaseArticleViewingExperience.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ELEMENT_TOP_OFFSET 10 //the gap between pinvhviews and the top of the screen
#define BETWEEN_ELEMENT_OFFSET 10 //the gap between pinchviews on the left and right
#define RADIUS ((self.SV_PhotoList.frame.size.height/2)- ELEMENT_TOP_OFFSET)

@interface MultiplePhotoAVE ()

#pragma mark - textview properties -
@property (strong, nonatomic) UIVisualEffectView* bgBlurImage;
@property (nonatomic) CGPoint lastPoint;
@property (strong, nonatomic) UIView* pullBarView;
@property (strong, nonatomic) UIView* whiteBorderBar;

@property (nonatomic) BOOL isTitle;
@property (nonatomic) CGRect absoluteFrame;

@property (nonatomic) BOOL textShowing;

#pragma mark - photoview properties-

@property (weak, nonatomic) IBOutlet VerbatmImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIScrollView *SV_PhotoList;

@end


@implementation MultiplePhotoAVE


-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSMutableArray *) photos
{
    
    //load from Nib file...this initializes the background view and all its subviews
    self = [[[NSBundle mainBundle] loadNibNamed:@"MultiplePhotoAVE" owner:self options:nil]firstObject];
    if(self)
    {
        self.frame = frame;
        [self setPhotoFrom:photos];
        if(photos.count >1)[self fillScrollView:photos];//if there are many photos then we have a scrollview
        if(photos.count == 1)
        {
            [self bringSubviewToFront:self.mainImage];
            self.mainImage.frame = frame;
            self.SV_PhotoList.frame = CGRectZero;//make sure it's zero'd so that it doesnt show at all
        }
		self.textShowing = YES;
		[self addTapGestureToMainView];
    }
    
    return self;
}

-(void) setPhotoFrom: (NSArray *) photos
{
	if (!photos || !photos.firstObject) {
		return;
	}
	UIImage* image = [[UIImage alloc] initWithData:photos.firstObject];

    self.mainImage.contentMode = UIViewContentModeScaleAspectFit;
    self.mainImage.backgroundColor =[UIColor blackColor];
    self.mainImage.image = image;
    self.mainImage.layer.masksToBounds = YES;
    self.mainImage.clipsToBounds = YES;
    self.mainImage.userInteractionEnabled = YES;
    self.mainImage.clipsToBounds = YES;
    self.mainImage.frame = CGRectMake(0, self.SV_PhotoList.frame.size.height, self.frame.size.width, self.frame.size.height - self.SV_PhotoList.frame.size.height);
}



//fills our scrollview with pinch views of our media list
-(void) fillScrollView:(NSMutableArray *) photos
{
    [self formatSV];
    [self bringSubviewToFront:self.SV_PhotoList];
    
    for (UIImage * image in photos)
    {
		NSMutableArray *media = [[NSMutableArray alloc]init];
		[media addObject: image];

        PinchView * pv = [[PinchView alloc] initWithRadius:RADIUS withCenter:[self getNextCenter] andMedia:media];
        [self formatPV:pv];
        [self addTapGesture:pv];
        [self.SV_PhotoList addSubview:pv];
    }
    [self editSVContentSize];
}

//formats a pinchivew
-(void)formatPV:(PinchView *)pv
{
    //give it a dorp shadow
    [pv createLensingEffect:RADIUS];
    //remove it's border
    [pv removeBorder];
}

-(void) formatSV
{
    self.SV_PhotoList.showsHorizontalScrollIndicator = NO;
    self.SV_PhotoList.showsVerticalScrollIndicator = NO;
}

-(void) editSVContentSize
{
    UIView * view = self.SV_PhotoList.subviews.lastObject;
    self.SV_PhotoList.contentSize = CGSizeMake(view.frame.origin.x + view.frame.size.width + BETWEEN_ELEMENT_OFFSET*3 , 0);
}

-(void) addTapGesture: (UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectTapped:)];
    [view addGestureRecognizer:tap];
}


//when a pv is tapped we swap it's image for the one on display
-(void) pinchObjectTapped:(UITapGestureRecognizer *) gesture {
    PinchView * pv = (PinchView *) gesture.view;
    NSArray * photos = [pv getPhotos];
    [self setPhotoFrom: photos];
}

-(void) addTapGestureToMainView {
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewTapped:)];
	[self addGestureRecognizer:tap];
}

-(void) mainViewTapped:(UITapGestureRecognizer *) gesture {
	self.textShowing = !self.textShowing;
	[self showText:self.textShowing];
}

-(void) showText:(BOOL)show {
	[(BaseArticleViewingExperience*)self.superview showText:show];
}

//calculates the next center point for the next pinch view using the last pinch view
-(CGPoint) getNextCenter
{
    if(!self.SV_PhotoList.subviews.count)return CGPointMake((BETWEEN_ELEMENT_OFFSET+RADIUS), (RADIUS + ELEMENT_TOP_OFFSET));
    
    UIView * pv = self.SV_PhotoList.subviews.lastObject;
	//we multiply the radius by 3 because the next center is a diameter and a half (plus offset) from the x origin of the last
    int x_cord = pv.frame.origin.x+ RADIUS*3 + BETWEEN_ELEMENT_OFFSET;
    int y_cord = RADIUS + ELEMENT_TOP_OFFSET;
    return CGPointMake(x_cord, y_cord);
}

@end
