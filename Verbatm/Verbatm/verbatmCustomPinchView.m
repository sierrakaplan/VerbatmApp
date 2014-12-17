//
//  verbatmCustomPinchView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 11/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomPinchView.h"
#import "verbatmCustomImageView.h"


@interface verbatmCustomPinchView()
@property(strong,nonatomic)IBOutlet UIView* background;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewer;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) NSMutableArray* media;
@property (readwrite,nonatomic) BOOL there_is_text;
@property (readwrite, nonatomic) BOOL there_is_video;
@property (readwrite, nonatomic) BOOL there_is_picture;
@property (strong, nonatomic) MPMoviePlayerController *mp;


#define MEDIA_TYPE_TEXT @"TEXT"
#define MEDIA_TYPE_VIDEO @"VIDEO"
#define MEDIA_TYPE_PHOTO @"PHOTO"
#define TIME_TO_ANIMATE 0.01
#define SHADOW_OFFSET_FACTOR 25
#define DIVISION_FACTOR_FOR_THREE 2
#define DIVISION_FACTOR_FOR_TWO 2

@end

@implementation verbatmCustomPinchView

//Lucio
//Instantiates an instance of the custom view without any media types inputted
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andMedia:(id)medium
{
    if((self = [super init])){
        
        //load from Nib file
        [[NSBundle mainBundle] loadNibNamed:@"verbatmCustomPinchView" owner:self options:nil];
        
        //set up the properties
        CGRect frame = CGRectMake(center.x - radius, center.y - radius, radius*2, radius*2);
        [self specifyFrame:frame];
        [self createLensingEffect:radius];
        
        //initialize arrays
        self.media = [[NSMutableArray alloc]init];
        
        //add Medium to the list of media
        if([medium isKindOfClass: [UITextView class]]){
             self.there_is_text = YES;
        }else if([medium isKindOfClass: [verbatmCustomImageView class]]){
            self.there_is_video = ((verbatmCustomImageView*)medium).isVideo;
            self.there_is_picture = !self.there_is_video;
        }
        //add background as a subview
        [self addSubview: self.background];
        [self.media addObject: medium];
        [self renderMedia];
    }
    return self;
}


//Lucio
//adds a text to the custom view
-(void)addTextToCurrentMedia:(UITextView*)textview
{
    [self.media addObject:textview];
    self.there_is_text = YES;
}

//Lucio
//adds a video to the custom view
-(void)addVideoToCurrentMedia:(ALAsset*)video
{
    [self.media addObject: video];
    self.there_is_video = YES;
}

//Lucio
//adds a picture to the custom view
-(void)addPictureToCurrentMedia:(UIImageView*)imageview
{
    [self.media addObject: imageview];
    self.there_is_picture = YES;
}

//Lucio.
//moves the view by a delta relative to the center.
-(void)specifyFrame:(CGRect)frame
{
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2 , frame.origin.y + frame.size.height/2);
    self.center = center;
    self.frame = frame;
    self.background.frame = self.bounds;
    self.background.layer.cornerRadius = frame.size.width/2;
    self.layer.cornerRadius = frame.size.width/2;
    self.autoresizesSubviews = YES; // This makes sure that moving the background canvas moves all the associated subviews too.
    [self createLensingEffect:frame.size.width/2];
}

-(void)createLensingEffect:(float)radius
{
    //remove previous shadows
    self.layer.shadowPath = nil;
    //create the shadow or lensing effect
    self.layer.shadowOffset = CGSizeMake(radius/SHADOW_OFFSET_FACTOR, radius/SHADOW_OFFSET_FACTOR);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius].CGPath;
    self.background.layer.masksToBounds = YES;
}


//This renders the pinch object unto the screen in terms of the dynamics of the
//way it should look
-(void)renderMedia
{
    if(self.there_is_video && self.there_is_text && self.there_is_picture){
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
    if(self.there_is_text){
        self.textField.frame = self.background.frame;
    }else if(self.there_is_video){
        self.textField.frame = CGRectMake(0, 0, 0, 0);
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
    if(self.there_is_text){
        self.textField.frame = frame1;
        if(self.there_is_picture){
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
    self.textField.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.background.frame.size.height/DIVISION_FACTOR_FOR_THREE);
    self.imageViewer.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y + self.textField.frame.size.height, self.background.frame.size.width/DIVISION_FACTOR_FOR_TWO, self.background.frame.size.height - self.textField.frame.size.height);
    self.videoView.frame = CGRectMake(self.background.frame.origin.x + self.imageViewer.frame.size.width, self.imageViewer.frame.origin.y , self.background.frame.size.width - self.imageViewer.frame.size.width, self.imageViewer.frame.size.width);
}

//This function displays the media on the view.
-(void)displayMedia
{
    self.textField.text = @"";
    for(id object in self.media){
        if([object isKindOfClass: [UITextView class]]){
            self.textField.text = [self.textField.text stringByAppendingString: ((UITextView*)object).text];
            //[self.background bringSubviewToFront: self.textField];
        }else if(!((verbatmCustomImageView*)object).isVideo){
            UIImage* image = [(verbatmCustomImageView*)object image];
            [self.imageViewer setImage:image];
            //[self.background bringSubviewToFront: self.imageViewer];
        }else{
            AVURLAsset *avurlAsset = [AVURLAsset URLAssetWithURL: ((verbatmCustomImageView*)object).asset.defaultRepresentation.url options:nil];
            [self playVideo: avurlAsset];
           // self.videoView.layer.masksToBounds = YES;
        }
    }
}


-(void)playVideo:(AVURLAsset*)asset
{
    // Create an AVPlayerItem using the asset
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    // Create the AVPlayer using the playeritem
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //MUTE THE PLAYER
    [self mutePlayer:player forAsset:asset];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    
    // Create an AVPlayerLayer using the player
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    // Add it to your view's sublayers
    [self.videoView.layer addSublayer:playerLayer];
    // You can play/pause using the AVPlayer object
    [player play];
}

//mutes the player
-(void)mutePlayer:(AVPlayer*)avPlayer forAsset:(AVURLAsset*)asset
{
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =  [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    [[avPlayer currentItem] setAudioMix:audioZeroMix];
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
       
       
//This merges two verbatm pinch objects into one. 
+(verbatmCustomPinchView*)pinchTogether:(NSMutableArray*)to_be_merged
{
    if(to_be_merged.count == 0) return nil;
    verbatmCustomPinchView* result = (verbatmCustomPinchView*)[to_be_merged firstObject];
    if(to_be_merged.count == 1) return result;
    for(int i = 1; i < to_be_merged.count; i++){
        verbatmCustomPinchView* pinchObject = (verbatmCustomPinchView*)[to_be_merged objectAtIndex:i];
        [result.media addObjectsFromArray: pinchObject.media];
        result.there_is_picture =  result.there_is_picture || pinchObject.there_is_picture;
        result.there_is_text =  result.there_is_text || pinchObject.there_is_text;
        result.there_is_video = result.there_is_video || pinchObject.there_is_video;
    }
    to_be_merged = nil;
    [result renderMedia];
    return result;
}

//keeping this just in case
-(BOOL)thereIsOnlyOneMedium
{
    if(self.there_is_text && self.there_is_video && self.there_is_picture) return false;
    if(self.there_is_picture && self.there_is_text)return false;
    if(self.there_is_text && self.there_is_video) return false;
    if(self.there_is_video && self.there_is_picture) return false;
    return  self.there_is_picture || self.there_is_text || self.there_is_video;
}


//this function pulls a pinch object apart into the componenent media.
//It returns an array of pinch objects
+(NSMutableArray*)openCollection:(verbatmCustomPinchView*)to_be_seperated
{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for(id object in to_be_seperated.media){
        verbatmCustomPinchView* result = [[verbatmCustomPinchView alloc]initWithRadius: to_be_seperated.background.frame.size.width/2 withCenter:to_be_seperated.center andMedia:object];
        [arr addObject: result];
    }
    return arr;
}

//Pinches apart two media that were previously pinched together.
//Undoes a pinch apart
//The function returns null if the object to be pinched apart does not actually consist
//of more than one media object.
+(NSMutableArray*)pinchApart:(verbatmCustomPinchView*)to_be_pinched_apart
{
    if(to_be_pinched_apart.media.count < 2)return nil;
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    verbatmCustomPinchView* result = [[verbatmCustomPinchView alloc]initWithRadius: to_be_pinched_apart.background.frame.size.width withCenter:to_be_pinched_apart.center andMedia: [to_be_pinched_apart.media lastObject]];
    [to_be_pinched_apart.media removeObject: [to_be_pinched_apart.media lastObject]];
    [arr addObject:to_be_pinched_apart];
    [arr addObject: result];
    return arr;
}


#pragma mark - setup info -

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"verbatmCustomPinchView" owner:self options:nil];
        [self addSubview: self.background];
    }
    return self;
}


#pragma mark - necessary info to return -
//returns all the strings of the media in the media array which are textfields.
-(NSString*)getTextFromPinchObject
{
    return self.textField.text;
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
@end
