//
//  verbatmCustomImageScrollView.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmImageScrollView.h"
#import "VerbatmImageView.h"
#import "verbatmPullBarView.h"

@interface VerbatmImageScrollView () <UITextViewDelegate,pullBarDelegate>

#pragma mark FilteredPhotos
@property (nonatomic, strong) UIImage * filter_Original;
@property (nonatomic, strong) UIImage * filter_BW;
@property (nonatomic, strong) UIImage * filter_WARM;
@property (nonatomic, strong) NSString * filter;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;
//@property (nonatomic, strong) AVPlayer  * ourPlayer;
//@property(nonatomic, strong) MPMoviePlayerController *moviePlayer;
//@property (nonatomic,strong) AVPlayerViewController * mixPlayer;



#define TEXT_BOX_FONT_SIZE 20
#define VIEW_WALL_OFFSET 20

#define BACKGROUND_COLOR clearColor
#define FONT_COLOR whiteColor

#define PULLBAR_HEIGHT 36

@end


@implementation VerbatmImageScrollView

-(instancetype) initCustomViewWithFrame:(CGRect)frame
{
	self = [super init];
	if(self)
	{
		self.backgroundColor = [UIColor blackColor];
		self.frame = frame;
		self.scrollEnabled = YES;
	}
	return self;
}

#pragma mark - Text View -

-(void)adjustImageScrollViewContentSizing
{
	[self setDashedBorderToView:self.textView];
}


//called when the keyboard is up. The Gap gives you the amount of visible space after
//the keyboard is up
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap
{
	if(gap)
	{

		self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, gap - VIEW_WALL_OFFSET);
	}else
	{
		self.textView.frame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2, self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);
	}

	[self adjustImageScrollViewContentSizing];

}


-(void) createTextViewFromTextView: (UITextView *) textView
{
	if(self.gestureView)//be sure to remove it
	{
		[self.gestureView removeFromSuperview];
		self.gestureView = nil;
	}

	if(!textView)
	{
		self.textView = [[VerbatmUITextView alloc] init];
		self.textView.backgroundColor = [UIColor clearColor];
		self.textView.frame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2, self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);
		[self formatTextViewAppropriately:self.textView];
		[self addSubview:self.textView];
	}else
	{
		self.textView = [[VerbatmUITextView alloc] init];
		self.textView.text = textView.text;
		self.textView.frame = CGRectMake((VIEW_WALL_OFFSET/2), VIEW_WALL_OFFSET/2, self.frame.size.width -VIEW_WALL_OFFSET, self.frame.size.height-VIEW_WALL_OFFSET);

		//adjusts the frame of the textview andthe contentsize of the scrollview if need be
		[self adjustImageScrollViewContentSizing];

		[self formatTextViewAppropriately:self.textView];
		[self addToolBarToView];
		[self addSubview:self.textView];
	}
}

//creates a toolbar to add onto the keyboard
-(void)addToolBarToView
{
	CGRect frame = CGRectMake(0,0, self.frame.size.width, PULLBAR_HEIGHT);
	VerbatmPullBarView * toolBar = [[VerbatmPullBarView alloc] initWithFrame:frame];
	toolBar.customeDelegate = self;
	self.textView.inputAccessoryView = toolBar;
}

/*not to be implemented only to get rid of the protocal warnings*/
-(void)undoButtonPressed
{

}

-(void)previewButtonPressed
{

}
-(void)saveButtonPressed
{

}

-(void)keyboardButtonPressed
{
	[self.textView resignFirstResponder];
}


//Calculate the appropriate bounds for the text view
//We only return a frame that is larger than the default frame size
-(CGRect) calculateBoundsForOpenTextView: (UIView *) view
{
	CGSize  tightbounds = [view sizeThatFits:view.bounds.size];

	return CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tightbounds.height);
}

//makes the cursors white
-(void)makeCursorWhite
{
	[[UITextView appearance] setTintColor:[UIColor whiteColor]];
}


//Iain
//Formats a textview to the appropriate settings
-(void) formatTextViewAppropriately: (VerbatmUITextView *) textView
{
	//Set delegate for text new view
	[textView setDelegate:self];
	[textView setFont:[[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:TEXT_BOX_FONT_SIZE]];
	textView.backgroundColor = [UIColor BACKGROUND_COLOR];//sets the background as clear
	textView.textColor = [UIColor FONT_COLOR];

	//ensure keyboard is black
	textView.keyboardAppearance = UIKeyboardAppearanceDark;
	[self setDashedBorderToView:textView];

	textView.scrollEnabled = YES;
	self.scrollEnabled = YES;
}



//sets the dashed boder around the text view
-(void) setDashedBorderToView: (UIView *) view
{
	//border definitions
	float cornerRadius = 0;
	float borderWidth = 1;
	int dashPattern1 = 10;
	int dashPattern2 = 10;
	UIColor *lineColor = [UIColor whiteColor];

	//drawing boundary
	CGRect frame = view.bounds;

	CAShapeLayer *_shapeLayer = [CAShapeLayer layer];

	//creating a path
	CGMutablePathRef path = CGPathCreateMutable();

	//drawing a border around a view
	CGPathMoveToPoint(path, NULL, 0, frame.size.height - cornerRadius);
	CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
	CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
	CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
	CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
	CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
	CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
	CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
	CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);

	//path is set as the _shapeLayer object's path
	_shapeLayer.path = path;
	CGPathRelease(path);

	_shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
	_shapeLayer.frame = frame;
	_shapeLayer.masksToBounds = NO;
	[_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
	_shapeLayer.fillColor = [[UIColor clearColor] CGColor];
	_shapeLayer.strokeColor = [lineColor CGColor];
	_shapeLayer.lineWidth = borderWidth;
	_shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:dashPattern1], [NSNumber numberWithInt:dashPattern2], nil];
	_shapeLayer.lineCap = kCALineCapRound;
	//_shapeLayer is added as a sublayer of the view, the border is visible

	for (int i=0; i<view.layer.sublayers.count; i++) {
		if([view.layer.sublayers[i] isKindOfClass:[CAShapeLayer class]])
		{
			[view.layer.sublayers[i] removeFromSuperlayer];
		}
	}
	[view.layer addSublayer:_shapeLayer];
	view.layer.cornerRadius = cornerRadius;
}

#pragma mark - Image or Video View -
-(void)addVideo: (AVAsset*) video {
	self.videoView = [[UIView alloc]init];
	[self playVideo:video];
}

-(void)addImage: (NSData*) image
{

	if(self.gestureView)//be sure to remove it
	{
		[self.gestureView removeFromSuperview];
		self.gestureView = nil;
	}

	//create a new scrollview to place the images
	self.imageView = [[VerbatmImageView alloc]init];
	self.imageView.image = [[UIImage alloc] initWithData:image];
	self.imageView.asset = image;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
	[self createFilteredImages];
	[self addSwipeToOpenedView];
	self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - manipulating playing of videos -

-(void)playVideo:(AVAsset*)asset
{
//	self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:asset.URL];
//	[self.moviePlayer prepareToPlay];
//	self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//	self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
//	self.moviePlayer.controlStyle= MPMovieControlStyleNone;
//	[self.moviePlayer.view setFrame: self.bounds];  // player's frame must match parent's

//	[self.moviePlayer play];

	// Create an AVPlayerItem using the asset
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
	// Create the AVPlayer using the playeritem
	AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

	player.muted = NO;
	player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(playerItemDidReachEnd:)
//												 name:AVPlayerItemDidPlayToEndTimeNotification
//											   object:[player currentItem]];

	// Create an AVPlayerLayer using the player
	AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	playerLayer.frame = self.bounds;
	playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	// Add it to your view's sublayers
	[self.videoView.layer addSublayer:playerLayer];
	self.playerLayer = playerLayer;

	[self addSubview:self.videoView];
	[self bringSubviewToFront:self.videoView];
//	self.gestureView =[[UIView alloc] initWithFrame:self.bounds];
//	[self addSubview:self.gestureView];
//	[self bringSubviewToFront:self.gestureView];

	// You can play/pause using the AVPlayer object
	[player play];
}

-(void)pauseVideo
{
	if(!self.playerLayer) return;
	AVPlayer* player = self.playerLayer.player;
	[player pause];
}

-(void)continueVideo
{

	if(!self.playerLayer) return;
	AVPlayer* player = self.playerLayer.player;
	[player play];
}

-(void)unmuteVideo
{
	if(self.playerLayer) {
		[self.playerLayer.player setMuted:NO];
	}
}

-(void)muteVideo
{
	if(self.playerLayer) {
		[self.playerLayer.player setMuted:YES];
	}
}

-(void)createFilteredImages
{
	//original "filter"
	NSData *data = (NSData *) self.imageView.asset;

	//warm filter
	CIImage *beginImage =  [CIImage imageWithData:data];

	CIContext *context = [CIContext contextWithOptions:nil];

	CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues: kCIInputImageKey, beginImage, nil];
	CIImage *outputImage = [filter outputImage];

	CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];

	self.filter_WARM = [UIImage imageWithCGImage:cgimg];


	CIImage *beginImage1 =  [CIImage imageWithData:data];

	CIFilter *filter1 = [CIFilter filterWithName:@"CIPhotoEffectMono"
								   keysAndValues: kCIInputImageKey, beginImage1, nil];

	CIImage *outputImage1 = [filter1 outputImage];

	CGImageRef cgimg1 =[context createCGImage:outputImage1 fromRect:[outputImage1 extent]];

	self.filter_BW = [UIImage imageWithCGImage:cgimg1];

	CGImageRelease(cgimg);
	//free the buffer after use
	//free(buffer);
}



-(void)addSwipeToOpenedView
{
	UISwipeGestureRecognizer * leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(filterViewSwipe:)];
	leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	[self addGestureRecognizer:leftSwipe];
}


-(void)filterViewSwipe: (UISwipeGestureRecognizer *) sender
{
	if(self.filter && [self.filter isEqualToString:@"BW"])
	{
		self.imageView.image = self.filter_Original;
		self.filter = @"Original";
	}else if (self.filter && [self.filter isEqualToString:@"WARM"])
	{
		self.imageView.image = self.filter_BW;
		self.filter = @"BW";
	}else
	{
		self.imageView.image = self.filter_WARM;
		self.filter = @"WARM";
	}
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
@end
