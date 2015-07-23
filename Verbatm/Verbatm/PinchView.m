//
//  verbatmCustomPinchView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 11/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "VerbatmImageView.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "UIEffects.h"


@interface PinchView()
@property(strong,nonatomic)IBOutlet UIView* background;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewer;
@property (weak, nonatomic) IBOutlet UITextView *textView;

//array of videos, photos, and text
@property (strong, nonatomic) NSMutableArray* media;
@property (strong, nonatomic) NSMutableArray* photos;
@property (strong, nonatomic) NSMutableArray* videos;
//array of PinchObjects
@property (strong, nonatomic) NSMutableArray* pinched;
//@property (strong, nonatomic) NSString* text;

@property (readwrite,nonatomic) BOOL containsText;
@property (readwrite, nonatomic) BOOL containsVideo;
@property (readwrite, nonatomic) BOOL containsPhoto;

#define SHADOW_OFFSET_FACTOR 25
#define DIVISION_FACTOR_FOR_TWO 2

@end

@implementation PinchView

//Instantiates an instance of the custom view
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andMedia:(NSMutableArray*)mediaArray
{
    if((self = [super init]))
    {
        
        //load from Nib file..this initializes the background view and all its subviews
        [[NSBundle mainBundle] loadNibNamed:@"PinchView" owner:self options:nil];
        
        //set up the properties
        CGRect frame = CGRectMake(center.x - radius, center.y - radius, radius*2, radius*2);
        [self specifyFrame:frame];
        self.background.layer.masksToBounds = YES;
        
        //initialize arrays
        self.media = [[NSMutableArray alloc] init];
		self.photos = [[NSMutableArray alloc] init];
		self.videos = [[NSMutableArray alloc] init];

		self.containsText = NO;
		self.containsPhoto = NO;
		self.containsVideo = NO;
        
        [self initSubviews];
        if(mediaArray){
            [self.media addObjectsFromArray: mediaArray];
			[self setDataTypes];
            [self renderMedia];
        }

        [self addBorderToPinchView];
    }
    return self;
}

// adds photos to photos array and videos to videos array
// sets if there is text, photos, and videos
-(void)setDataTypes {

	for(id object in self.media){

		//text
		if([object isKindOfClass: [UITextView class]]){
			self.containsText = YES;

		//photo
		} else if([object isKindOfClass: [NSData class]]){
			self.containsPhoto = YES;
			[self.photos addObject:object];

		//video from preview or parse
		} else if([object isKindOfClass: [AVAsset class]] || [object isKindOfClass: [NSURL class]]){
			self.containsVideo = YES;
			[self.videos addObject:object];
		}
	}
}

+(PinchView *)pinchObjectFromPinchObject: (PinchView *) pv
{
	NSMutableArray* newMedia = [[NSMutableArray alloc] initWithArray:pv.media copyItems: YES];
    PinchView * newPinchView = [[PinchView alloc]initWithRadius:pv.frame.size.width/2 withCenter:pv.center andMedia:newMedia];
    return newPinchView;
}

-(void)initSubviews
{
    //add background as a subview
    [self addSubview: self.background];
    
    //set frames
    self.videoView.frame =  CGRectZero;
    self.textView.frame = CGRectZero;
    self.imageViewer.frame = CGRectZero;

    self.background.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];
    self.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];
    self.textView.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];

}

-(void) formatTextView {
	[self.textView setScrollEnabled:NO];
	self.textView.textColor = [UIColor TEXT_AVE_COLOR];
	//must be editable to change font
	[self.textView setEditable:YES];
	self.textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE];
	[self.textView setEditable:NO];
	float textViewContentSize = [UIEffects measureHeightOfUITextView:self.textView];
	NSLog(@"%f", self.textView.frame.size.height);
	if (textViewContentSize < self.textView.frame.size.height/3.f) {
		self.textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE_REALLY_REALLY_BIG];
	} else if (textViewContentSize < self.textView.frame.size.height/2.f) {
		self.textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE_REALLY_BIG];
	} else if (textViewContentSize < self.textView.frame.size.height*(3.f/4.f)) {
		self.textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE_BIG];
	}
}

//adds a thin circular border to the view
-(void)addBorderToPinchView
{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

//adds a picture to the custom view
-(void)changePicture:(UIImage*)image
{
    //only works if we already have a picture
    if(![self thereIsOnlyOneMedium] || [self hasMultipleMedia] || !self.containsPhoto) return;
    self.imageViewer.image = image;
}

-(void) changeText:(UITextView *) textview
{
    //should only work if there is text in the pinchview
    if(![self thereIsOnlyOneMedium] || [self hasMultipleMedia] || !self.containsText) return;
    UITextView* view = [self.media firstObject];
    view.text = textview.text;
    self.textView.text = textview.text;
}


/*This specifies the frame of the background and all the subviews
 *It modifies the object to have a circular shape by setting the 
 *corner radius
 */
-(void)specifyFrame:(CGRect)frame
{
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    self.center = center;
    self.frame = frame;
    self.background.frame = self.bounds;
    self.background.layer.cornerRadius = frame.size.width/2;
    self.layer.cornerRadius = frame.size.width/2;
    self.autoresizesSubviews = YES; // This makes sure that moving the background canvas moves all the associated subviews too.
}

-(void)specifyCenter:(CGPoint) center
{
    self.center = center;
    self.frame = CGRectMake(center.x - self.frame.size.width/2, center.y - self.frame.size.width/2, self.frame.size.width,self.frame.size.height);
    self.background.frame = self.bounds;
    self.background.layer.cornerRadius = self.frame.size.width/2;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.autoresizesSubviews = YES; // This makes sure that moving the background canvas moves all the associated subviews too.
}

//allows the user to change the width and height of the frame keeping the same center
-(void) changeWidthTo: (double) width
{
    if(width < MIN_PINCHVIEW_SIZE) return;
    self.autoresizesSubviews = YES;
    
    CGPoint center = self.center;
    CGRect new_frame = CGRectMake(center.x- width/2, center.y - width/2, width, width);
    CGRect new_bounds_frame =CGRectMake(0, 0, width, width);
    
   
    self.frame = new_frame;
    self.background.frame = new_bounds_frame;
    self.videoView.frame = new_bounds_frame;
    
    if (self.videoView.playerLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [CATransaction setDisableActions:YES];
        self.videoView.playerLayer.frame=self.bounds;
        [CATransaction commit];
        
        self.videoView.playerLayer.cornerRadius = self.frame.size.width/2;
        self.background.layer.cornerRadius = self.frame.size.width/2;
        self.layer.cornerRadius = self.frame.size.width/2;
        self.clipsToBounds = YES;
    }
}


-(void)removeBorder
{
    self.layer.borderWidth = 0;
}

-(void)createLensingEffect:(float)radius
{
    //remove previous shadows
    self.layer.shadowPath = nil;
    
    //create the shadow or lensing effect
    self.layer.shadowOffset = CGSizeMake(radius/SHADOW_OFFSET_FACTOR, radius/SHADOW_OFFSET_FACTOR);
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 1;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius].CGPath;
}


//This renders the pinch object unto the screen in terms of the dynamics of the
//way it should look
-(void)renderMedia
{
    if(self.containsVideo && self.containsText && self.containsPhoto){
        [self renderThreeViews];
    }else if( [self thereIsOnlyOneMedium]){
        [self renderSingleView];
    }else{
        [self renderTwoMedia];
    }
    [self displayMedia];
}



//This renders a single view on the pinch object
-(void)renderSingleView
{
    if(self.containsText){
        self.textView.frame = self.background.frame;
    }else if(self.containsVideo){
        self.videoView.frame = self.background.frame;
        [self.background bringSubviewToFront:self.videoView];
    }else{
        self.imageViewer.frame = self.background.frame;
        [self.background bringSubviewToFront:self.imageViewer];
    }
}

//this renders two media in a vertical split view kind of way on the pinch object.
-(void)renderTwoMedia
{
    CGRect frame1 = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO , self.background.frame.size.height);
    CGRect frame2 = CGRectMake(self.background.frame.origin.x + self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO, self.background.frame.origin.y, self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO, self.background.frame.size.height);
    if(self.containsText){
        self.textView.frame = frame1;
        if(self.containsPhoto){
            self.imageViewer.frame = frame2;
        }else{
            self.videoView.frame = frame2;
        }
    }else{
        self.videoView.frame = frame1;
        self.imageViewer.frame = frame2;
        [self.background bringSubviewToFront:self.videoView];
        [self.background bringSubviewToFront:self.imageViewer];
    }
}
       

//This renders three views on the pinch view object.
-(void)renderThreeViews
{
    //computation to determine the relative positions of each of the views
    self.textView.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.background.frame.size.height/DIVISION_FACTOR_FOR_TWO);
    self.imageViewer.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y + self.textView.frame.size.height, self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO, self.background.frame.size.height - self.textView.frame.size.height);
    self.videoView.frame = CGRectMake(self.background.frame.origin.x + self.imageViewer.frame.size.width, self.imageViewer.frame.origin.y , self.background.frame.size.width - self.imageViewer.frame.size.width, self.imageViewer.frame.size.width);
}

//This function displays the media on the view.
-(void)displayMedia
{

	self.textView.text = @"";
	//	if(!self.inDataFormat){
	for(id object in self.media)
    {
		//text
		if([object isKindOfClass: [UITextView class]])
        {
			UITextView* textView = (UITextView*)object;
			self.textView.text = [self.textView.text stringByAppendingString:textView.text];
			self.textView.text = [self.textView.text stringByAppendingString:@"\r\r"];
		//photo
		} else if([object isKindOfClass: [NSData class]]){
			NSData* image = (NSData*)object;
			[self.imageViewer setImage: [[UIImage alloc] initWithData:image]];
			self.imageViewer.contentMode = UIViewContentModeScaleAspectFill;
			self.imageViewer.layer.masksToBounds = YES;
		//video
		} else if([object isKindOfClass: [AVAsset class]])
        {
			[self.videoView playVideoFromAsset: object];
			[self.videoView muteVideo];
			[self.videoView repeatVideoOnEnd:YES];
		}
	}

	if (self.containsText) {
		[self formatTextView];
	}

	if(self.containsVideo)
    {
		if(self.videoView.playerLayer)
        {
			AVPlayerLayer* playerLayer = self.videoView.playerLayer;
			[playerLayer removeFromSuperlayer];
			 playerLayer.frame = self.videoView.bounds;
			[self.videoView.layer addSublayer:playerLayer];
		}
	}
}


//This merges two verbatm pinch objects into one.
+(PinchView*)pinchTogether:(NSMutableArray*)toBeMerged
{
    if(toBeMerged.count == 0) return nil;
    PinchView* firstObject = (PinchView*)[toBeMerged firstObject];
    PinchView* result = [[PinchView alloc] initWithRadius:firstObject.frame.size.width/2.0 withCenter:firstObject.center andMedia:nil];
    result.pinched = [[NSMutableArray alloc] init];
    for(int i = 0; i < toBeMerged.count; i++){
        PinchView* pinchObject = (PinchView*)[toBeMerged objectAtIndex:i];
        if(pinchObject.pinched){
            for(PinchView* subView in pinchObject.pinched){
                [PinchView append:subView toPinchObject:result];
            }
        }else{
            [PinchView append:pinchObject toPinchObject:result];
        }
    }
    [result renderMedia];
    return result;
}

+(void)append:(PinchView*)pinchObject toPinchObject:(PinchView*)result
{
    [result.media addObjectsFromArray: pinchObject.media];
	[result.photos addObjectsFromArray: pinchObject.photos];
	[result.videos addObjectsFromArray: pinchObject.videos];
    [result.pinched addObject:pinchObject];
    result.containsPhoto =  result.containsPhoto || pinchObject.containsPhoto;
    result.containsText =  result.containsText || pinchObject.containsText;
    result.containsVideo = result.containsVideo || pinchObject.containsVideo;
}

//keeping this just in case
-(BOOL)thereIsOnlyOneMedium
{
    if(self.containsText && self.containsVideo && self.containsPhoto) return false;
    if(self.containsPhoto && self.containsText)return false;
    if(self.containsText && self.containsVideo) return false;
    if(self.containsVideo && self.containsPhoto) return false;
    return  self.containsPhoto || self.containsText || self.containsVideo;
}


//this function pulls a pinch object apart into the componenent media.
//It returns an array of pinch objects
+(NSMutableArray*)openCollection:(PinchView*)collection
{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithArray: collection.pinched];
    for(PinchView* object in arr){
        object.center = collection.center;
    }
    //[arr insertObject:to_be_seperated atIndex: 0];
    return arr;
}

//Pinches apart two media that were previously pinched together.
//Undoes a pinch apart
//The function returns null if the object to be pinched apart does not actually consist
//of more than one media object.
+(NSMutableArray*)pinchApart:(PinchView*)collection
{
    if(collection.media.count < 2)return nil;
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    PinchView* result = [[PinchView alloc]initWithRadius: collection.background.frame.size.width withCenter:collection.center andMedia: [collection.media lastObject]];
    [collection.media removeObject: [collection.media lastObject]];
    [arr addObject:collection];
    [arr addObject: result];
    return arr;
}

#pragma mark - necessary info to return -
//returns all the strings of the media in the media array which are textViews.
-(NSString*)getText
{
    return self.textView.text;
}

//Tells whether it is a collection consisting of more than one type of media
-(BOOL)isCollection
{
    return ![self thereIsOnlyOneMedium];
}

//tells you if the pinch object has multiple media objects in its array.
//This applies, whether it is a collection or not.
-(BOOL)hasMultipleMedia
{
    return self.media.count > 1;
}

-(NSMutableArray*)mediaObjects
{
    return self.media;
}

//returns mutable array of AVAsset*
-(NSMutableArray*)getVideos {
	return self.videos;
}


//returns mutable array of NSData*
-(NSMutableArray*) getPhotos {
	return self.photos;
}

#pragma mark - manipulating playing of videos -


//this is only to occur when the player layer has been removed (perhaps due to previewing)
//and we need to add a new layer and restart the video
-(void) restartVideo
{
	if (self.videoView.playerLayer) {
		return;
	}
	[self displayMedia];
}

#pragma mark - selection interface -

-(void)markAsDeleting
{
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 2.0f;
}

-(void)unmarkAsDeleting
{
    [self addBorderToPinchView];
}
-(void)markAsSelected
{
    self.layer.borderColor = [UIColor blueColor].CGColor;
    self.layer.borderWidth = 2.0f;
}

-(void)unmarkAsSelected
{
    
    [self addBorderToPinchView];
}

-(void)offScreen
{
    
    if(self.videoView.playerLayer)
    {
        [self.videoView pauseVideo];
    }
}

-(void)onScreen
{
	if(self.videoView.playerLayer)
    {
		[self.videoView continueVideo];
	}
    //[self displayMedia];
}



@end


