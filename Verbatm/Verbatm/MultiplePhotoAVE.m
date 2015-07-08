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
#import <AssetsLibrary/AssetsLibrary.h>

#define ELEMENT_TOP_OFFSET 10 //the gap between pinvhviews and the top of the screen
#define BETWEEN_ELEMENT_OFFSET 10 //the gap between pinchviews on the left and right
#define RADIUS ((self.SV_PhotoList.frame.size.height/2)- ELEMENT_TOP_OFFSET)

@interface MultiplePhotoAVE ()

#pragma mark - textview properties -
@property (strong, nonatomic) TextAVE* textView;
@property (strong, nonatomic) UIVisualEffectView* bgBlurImage;
@property (nonatomic) CGPoint lastPoint;
@property (strong, nonatomic) UIView* pullBarView;
@property (strong, nonatomic) UIView* whiteBorderBar;

@property (nonatomic) BOOL isTitle;
@property (nonatomic) CGRect absoluteFrame;
#define BORDER_HEIGHT 2
#define BORDER_COLOR whiteColor
#define WHITE_BORDER_FRAME CGRectMake(0, self.pullBarView.frame.size.height - BORDER_HEIGHT, self.frame.size.width, BORDER_HEIGHT)
#define OFFSET_FROM_TOP 80
#define SIDE_BORDER 30
#define EXTRA  20
#define TEXT_CONTENT_OFFSET 100
#define MIN_WORDS 20
#define DEFAULT_FONT_FAMILY @"AmericanTypewriter-Light"
#define DEFAULT_FONT_SIZE 20
#define THRESHOLD 1.8
#define PULLBAR_COLOR clearColor
#define TEXT_VIEW_DEFAULT_FRAME CGRectMake(SIDE_BORDER, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA)
#define BLUR_VIEW_FRAME CGRectMake(0, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP)

#pragma mark - photoview properties-

@property (weak, nonatomic) IBOutlet VerbatmImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIScrollView *SV_PhotoList;

@end


@implementation MultiplePhotoAVE


//we use this initializer when there is text to be added
-(id)initWithFrame:(CGRect)frame andAssets:(NSMutableArray *)photoList andText:(NSString*)textUsed
{
    //load from Nib file...this initializes the background view and all its subviews
    self = [[[NSBundle mainBundle] loadNibNamed:@"MultiplePhotoAVE" owner:self options:nil]firstObject];
    if(self)
    {
        self.frame = frame;
        [self setPhotoFrom:photoList];
        [self fillScrollView:photoList];//if there are many photos then we have a scrollview
        [self handleTextViewDetailsFromText:textUsed];
    }
    
    return self;
}


#pragma mark - adding a text view-

-(void)handleTextViewDetailsFromText:(NSString *) text
{
    [self formatTextViewWithText: text];
    [self checkWordCount:text];
    [self setSizesToFit];
    self.userInteractionEnabled = YES;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.textAlignment = NSTextAlignmentCenter;
    [self bringSubviewToFront:self.textView];
    [self bringSubviewToFront: self.pullBarView];
    [self addSwipeGesture];
}


-(void)createBorderPath
{
    self.whiteBorderBar = [[UIView alloc] initWithFrame:WHITE_BORDER_FRAME];
    self.whiteBorderBar.backgroundColor = [UIColor BORDER_COLOR];
    [self.pullBarView addSubview:self.whiteBorderBar];
}


//everytime we reset the pullbar frame we call this to reset the white bar
-(void)setWhiteBarFrame
{
    self.whiteBorderBar.frame = WHITE_BORDER_FRAME;
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
        [self.textView setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
        [self.textView removeTextVerticalCentering];
    }else{
        
        [self createPullBar];
        [self createBlur];
    }
}

-(void)formatTextViewWithText:(NSString*) text
{
    self.textView = [[TextAVE alloc]initWithFrame: TEXT_VIEW_DEFAULT_FRAME];
    [self.textView setTextViewText: text];
    self.textView.textColor = [UIColor whiteColor];
    [self addSubview: self.textView];
    [self.textView setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
}

-(void) createPullBar
{
    //add pullbar
    self.pullBarView = [[UIView alloc] initWithFrame:CGRectMake(0, OFFSET_FROM_TOP ,self.frame.size.width,EXTRA*2)];
    self.pullBarView.backgroundColor = [UIColor PULLBAR_COLOR];
    self.absoluteFrame = self.pullBarView.frame;
    [self addSubview: self.pullBarView];
    [self.bgBlurImage bringSubviewToFront:self.pullBarView];
    [self createBorderPath];
}

-(void)createBlur
{
    //Add the blur
    UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.bgBlurImage = [[UIVisualEffectView  alloc]initWithEffect:blur];
    self.bgBlurImage.frame = BLUR_VIEW_FRAME;
    self.bgBlurImage.alpha = 1.0;
    [self insertSubview:self.bgBlurImage belowSubview:self.textView];
}
-(void)resetFrames
{
    self.pullBarView.frame = self.absoluteFrame;
    self.textView.frame = TEXT_VIEW_DEFAULT_FRAME;
    self.bgBlurImage.frame = BLUR_VIEW_FRAME;
    [self setWhiteBarFrame];
}
-(void)addSwipeGesture
{
    if(self.isTitle || !self.textView)return;
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositiontextView:)];
    [self.pullBarView addGestureRecognizer:panGesture];
}


//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositiontextView:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self];
    if(sender.state == UIGestureRecognizerStateBegan){
        BOOL atTopmostLevel = self.pullBarView.frame.origin.y == self.absoluteFrame.origin.y;
        if(translation.y < 0 && atTopmostLevel){
            return; //prevent pulling up beyond original position
        }
        BOOL atLowestLevel = (self.pullBarView.frame.origin.y + self.pullBarView.frame.size.height) == self.frame.size.height;
        if(translation.y >  0 && atLowestLevel) return; //prevents pulling down below height of pullbar.
        self.lastPoint = translation;
        return;
    }else if(sender.state == UIGestureRecognizerStateEnded){
        self.lastPoint = translation;
        [UIView animateWithDuration:0.2 animations:^{
            int y_location = self.pullBarView.frame.origin.y + self.pullBarView.frame.size.height;
            int mid_pt = self.frame.size.height/2;
            if(y_location < THRESHOLD*mid_pt){
                [self resetFrames];
            }else{
                self.textView.frame = CGRectMake(SIDE_BORDER, self.frame.size.height, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA);
                self.bgBlurImage.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA);
                self.pullBarView.frame = CGRectMake(0, self.frame.size.height - 3*EXTRA, self.frame.size.width,3*EXTRA);
                [self setWhiteBarFrame];
            }
        } completion:^(BOOL finished) {
            self.lastPoint = CGPointZero;
        }];
        return;
    }
    self.pullBarView.frame = CGRectOffset(self.pullBarView.frame, 0, translation.y - self.lastPoint.y );
    if(self.absoluteFrame.origin.y > self.pullBarView.frame.origin.y){
        [self resetFrames];
        self.lastPoint = CGPointZero;
        return;
    }
    self.bgBlurImage.frame = CGRectOffset(self.bgBlurImage.frame,  0, translation.y - self.lastPoint.y );
    self.textView.frame = CGRectOffset(self.textView.frame,  0, translation.y - self.lastPoint.y );
    self.lastPoint = translation;
}



/*This function sets the textView's size to fit superview's frame.
 *It ensures that the text layer is always centered in the super view and
 *it text fits in perfectly.
 */
-(void)setSizesToFit
{
    self.textView.textAlignment = NSTextAlignmentCenter;
    [self.textView sizeToFit];
}



#pragma mark - purely multiple photos-



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
    }
    
    return self;
}

-(void) setPhotoFrom: (NSArray *) photos
{
    self.mainImage.contentMode = UIViewContentModeScaleAspectFit;
    self.mainImage.backgroundColor =[UIColor blackColor];
    self.mainImage.image = (UIImage*)photos.firstObject;
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
        PinchView * pv = [[PinchView alloc] initWithRadius:RADIUS withCenter:[self getNextCenter] Images:@[image] videoData:nil andText:nil];
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
-(void) pinchObjectTapped:(UITapGestureRecognizer *) gesture
{
    PinchView * pv = (PinchView *) gesture.view;
    
//    verbatmCustomPinchView * new_pv = [[verbatmCustomPinchView alloc] initWithRadius:RADIUS withCenter:pv.center Images: @[self.mainImage.image] videoData:nil andText:nil];
//    [pv removeFromSuperview];
//    [self.SV_PhotoList addSubview:new_pv];
    
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
