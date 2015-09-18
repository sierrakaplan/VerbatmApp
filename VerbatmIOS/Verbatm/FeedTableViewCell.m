//

//  verbatmArticle_TableViewCell.m

//  Verbatm

//

//  Created by Iain Usiri on 3/29/15.

//  Copyright (c) 2015 Verbatm. All rights reserved.

//

#import "FeedTableViewCell.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Durations.h"


@interface FeedTableViewCell()


@property (strong, nonatomic) UIImage* coverImage;
#pragma mark - Square with text in the center of the cell -
@property (strong, nonatomic) UIView * storyTextView;
@property (strong, nonatomic) UILabel * povTitle;
@property (strong, nonatomic) UILabel * povCreatorUsername;

#pragma mark - Left and right semi circles containing the cover picture -
@property (strong, nonatomic) UIView * leftCircle;
@property (strong, nonatomic) UIView * rightCircle;
//Frames for the background circles
@property (nonatomic) CGRect leftCircleFrame;
@property (nonatomic) CGRect rightCircleFrame;
// views that move with semi circles when pinched together to cover text view
@property (nonatomic) UIView* leftCircleCoverRect;
@property (nonatomic) UIView* rightCircleCoverRect;
//Frames for the cover rects
@property (nonatomic) CGRect leftCoverRectFrame;
@property (nonatomic) CGRect rightCoverRectFrame;

//Frame for circles when they are pinched together
@property (nonatomic) CGRect circleFrameCenter;
//Semi circle image views
@property (strong, nonatomic) UIImageView* leftSemiCircle;
@property (strong, nonatomic) UIImageView* rightSemiCircle;

@property (nonatomic) BOOL isPinching;

#pragma mark - Data to help with pinching gesture -
@property (nonatomic) CGPoint lastLeftmostPoint;
@property (nonatomic) CGPoint lastRightmostPoint;

//for when this is a placeholder cell and the content is being pushed to the cloud
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL isPlaceHolder;

#define CIRCLE_DIAMETER (self.frame.size.height - STORY_CELL_PADDING*2)
#define PINCH_TOGETHER_DURATION 0.2f
#define PINCH_APART_DURATION 0.4f
#define PINCH_THRESHOLD 50.f

@end

@implementation FeedTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
	if (self) {
        self.isPlaceHolder = NO;
		self.isPinching = NO;
	}
	return self;
}

- (void)awakeFromNib {
	// Initialize code if made in storyboard
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	// Configure the view for the selected state
}

-(void)layoutSubviews {
	[super layoutSubviews];
	[self formatSelf];
	[self formatTextSubview];
    if(self.isPlaceHolder)[self startActivityIndicatrForPlaceholder];
	[self formatCoverRects];
	[self formatSemiCircles];
	[self addPinchGestureToSelf];
}

-(void) formatSelf {
	[self setBackgroundColor:[UIColor clearColor]];
}

-(void) formatTextSubview {

	CGRect textViewFrame = CGRectMake(STORY_CELL_PADDING + CIRCLE_DIAMETER/2.f, STORY_CELL_PADDING,
									  self.frame.size.width - STORY_CELL_PADDING*2 - CIRCLE_DIAMETER,
									  self.frame.size.height - STORY_CELL_PADDING*2);
	self.storyTextView = [[UIView alloc] initWithFrame: textViewFrame];
	[self.storyTextView setBackgroundColor:[UIColor STORY_BACKGROUND_COLOR]];

	[self.povTitle setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
										FEED_TEXT_GAP,
										textViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
										TITLE_LABEL_HEIGHT)];

	[self.povCreatorUsername setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
												  textViewFrame.size.height - USERNAME_LABEL_HEIGHT,
												  textViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
												  USERNAME_LABEL_HEIGHT)];

	[self formatUILabel: self.povTitle
			   withFont: [UIFont fontWithName:TITLE_FONT size:TITLE_FONT_SIZE]
		   andTextColor: [UIColor TITLE_TEXT_COLOR]
	   andNumberOfLines: 4];

	[self formatUILabel: self.povCreatorUsername
			   withFont: [UIFont fontWithName:USERNAME_FONT size:USERNAME_FONT_SIZE]
		   andTextColor: [UIColor USERNAME_TEXT_COLOR]
	   andNumberOfLines: 1];

	[self.storyTextView addSubview: self.povTitle];
	[self.storyTextView addSubview: self.povCreatorUsername];
	[self addSubview: self.storyTextView];
}

-(void) formatUILabel: (UILabel*)label withFont: (UIFont*)font andTextColor: (UIColor*) textColor
	 andNumberOfLines: (NSInteger) numLines {
	[label setFont:font];
	[label setTextColor:textColor];
	[label setLineBreakMode: NSLineBreakByWordWrapping];
	[label setNumberOfLines: numLines];
	[label sizeToFit];
	[label setFrame: CGRectMake(label.frame.origin.x, label.frame.origin.y,
								self.storyTextView.frame.size.width - FEED_TEXT_X_OFFSET*2,
								label.frame.size.height)];
	[label setTextAlignment: NSTextAlignmentCenter];
	label.backgroundColor = [UIColor clearColor];
}

//Creates two circle shaped views with image views as subviews formatted to
//half the width of their backgrounds so that they appear as half circles
-(void) formatSemiCircles {
	self.leftCircleFrame = CGRectMake(STORY_CELL_PADDING, STORY_CELL_PADDING,
										CIRCLE_DIAMETER, CIRCLE_DIAMETER);
	self.rightCircleFrame = CGRectMake(self.frame.size.width - STORY_CELL_PADDING - CIRCLE_DIAMETER,
									   STORY_CELL_PADDING,CIRCLE_DIAMETER, CIRCLE_DIAMETER);
	CGFloat center = self.frame.size.width/2.f;
	self.circleFrameCenter = CGRectMake(center - CIRCLE_DIAMETER/2.f, STORY_CELL_PADDING,
											CIRCLE_DIAMETER, CIRCLE_DIAMETER);
	self.leftCircle = [self getBackgroundCircleWithFrame: self.leftCircleFrame];
	self.rightCircle = [self getBackgroundCircleWithFrame: self.rightCircleFrame];

	[self formatSemiCircleImageView: self.leftSemiCircle withFrame: self.leftCircleFrame onLeft:YES];
	[self formatSemiCircleImageView: self.rightSemiCircle withFrame: self.rightCircleFrame onLeft:NO];

	[self.leftCircle addSubview: self.leftSemiCircle];
	[self.rightCircle addSubview: self.rightSemiCircle];

	[self addSubview: self.leftCircle];
	[self addSubview: self.rightCircle];
}

-(void) formatCoverRects {
	CGFloat width = self.storyTextView.frame.size.width/2.f;
	self.leftCoverRectFrame = CGRectMake(self.storyTextView.frame.origin.x - width,
										 self.storyTextView.frame.origin.y,
										 width,
										 self.storyTextView.frame.size.height);
	self.leftCircleCoverRect.frame = self.leftCoverRectFrame;
	self.rightCoverRectFrame = CGRectOffset(self.leftCircleCoverRect.frame, self.storyTextView.frame.size.width + width, 0);
	self.rightCircleCoverRect.frame = self.rightCoverRectFrame;
	self.leftCircleCoverRect.backgroundColor = [UIColor colorWithRed:FEED_BACKGROUND_COLOR green:FEED_BACKGROUND_COLOR blue:FEED_BACKGROUND_COLOR alpha:1.f];
	self.rightCircleCoverRect.backgroundColor = [UIColor colorWithRed:FEED_BACKGROUND_COLOR green:FEED_BACKGROUND_COLOR blue:FEED_BACKGROUND_COLOR alpha:1.f];
	[self addSubview: self.leftCircleCoverRect];
	[self addSubview: self.rightCircleCoverRect];
}

-(UIView*) getBackgroundCircleWithFrame: (CGRect) frame {
	UIView* backgroundCircle = [[UIView alloc] initWithFrame: frame];
	[backgroundCircle setBackgroundColor:[UIColor clearColor]];
	backgroundCircle.layer.cornerRadius = frame.size.width/2;
	backgroundCircle.autoresizesSubviews = YES;
	backgroundCircle.clipsToBounds = YES;
	return backgroundCircle;
}

-(void) formatSemiCircleImageView: (UIImageView*) imageView withFrame: (CGRect) frame onLeft: (BOOL) onLeft {
	float xOrigin = onLeft ? 0 : 0 + frame.size.width/2.f;
	CGRect semiCircleFrame = CGRectMake(xOrigin, 0, frame.size.width/2.f, frame.size.height);
	[imageView setFrame: semiCircleFrame];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.layer.masksToBounds = YES;
	imageView.clipsToBounds = YES;
	imageView.backgroundColor = [UIColor blackColor];
}

#pragma mark - Set Content -

-(void) setContentWithUsername:(NSString *) username andTitle: (NSString *) title
				 andCoverImage: (UIImage*) coverImage {
	self.povTitle.text = title;
	self.povCreatorUsername.text = username;
	UIImage* leftHalf = [self halfPicture:coverImage leftHalf:YES];
	UIImage* rightHalf = [self halfPicture:coverImage leftHalf:NO];
	[self.leftSemiCircle setImage: leftHalf];
	[self.rightSemiCircle setImage: rightHalf];
}

-(void) setLoadingContentWithUsername:(NSString *) username andTitle: (NSString *) title
						andCoverImage: (UIImage*) coverImage {
	[self setContentWithUsername:username andTitle:title andCoverImage:coverImage];
    self.isPlaceHolder = YES;
}

-(void)startActivityIndicatrForPlaceholder{
    [self startActivityIndicator];
}
//TODO: make this a category
-(UIImage*) halfPicture: (UIImage*) image leftHalf:(BOOL) leftHalf {
	float xOrigin = leftHalf ? 0 : image.size.width/2.f;
	CGRect cropRect = CGRectMake(xOrigin, 0, image.size.width/2.f, image.size.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
	UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(imageRef);
	return result;
}

#pragma mark - Activity Indicator -
//creates an activity indicator on our placeholder view
//shifts the frame of the indicator if it's on the screen
-(void)startActivityIndicator {
    if(self.activityIndicator.isAnimating){
        self.activityIndicator.center = self.center;
        return;
    }
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
        self.activityIndicator.hidesWhenStopped = YES;
    
        [self addSubview:self.activityIndicator];
        [self bringSubviewToFront:self.activityIndicator];
        [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
    if(!self.activityIndicator.isAnimating) return;
    [self.activityIndicator stopAnimating];
}

#pragma mark - Pinch Gesture -

-(void)addPinchGestureToSelf{
	UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:
											   @selector(pinchingSemiCirclesTogether:)];
	[self addGestureRecognizer: pinchGesture];
}

//moves the views frame to the provided offset
-(void)translateView:(UIView *) view withXOffset:(CGFloat) offset {
	view.frame = CGRectMake(view.frame.origin.x + offset, view.frame.origin.y, view.frame.size.width,
							view.frame.size.height);
}

// Captures pinching gesture so that the two half circles can be pinched
// together to select an article
-(void)pinchingSemiCirclesTogether:(UIPinchGestureRecognizer *)sender{

	switch(sender.state) {
		case UIGestureRecognizerStateBegan: {
			if(sender.numberOfTouches != 2) return;
			CGPoint touch1 = [sender locationOfTouch:0 inView:self];
			CGPoint touch2 = [sender locationOfTouch:1 inView:self];
			if (touch2.x < touch1.x) {
				CGPoint temp = touch1;
				touch1 = touch2;
				touch2 = temp;
			}

			self.lastLeftmostPoint = touch1;
			self.lastRightmostPoint = touch2;
			self.isPinching = YES;

			break;
		}
		case UIGestureRecognizerStateChanged: {
			if (!self.isPinching) return;
			if(sender.numberOfTouches != 2) return;
			CGPoint touch1 = [sender locationOfTouch:0 inView:self];
			CGPoint touch2 = [sender locationOfTouch:1 inView:self];
			if (touch2.x < touch1.x) {
				CGPoint temp = touch1;
				touch1 = touch2;
				touch2 = temp;
			}

			CGFloat offset = (touch1.x - self.lastLeftmostPoint.x) > (touch2.x - self.lastRightmostPoint.x) ? (touch1.x - self.lastLeftmostPoint.x) : (touch2.x - self.lastRightmostPoint.x);
			self.leftCircle.frame = CGRectOffset(self.leftCircle.frame, offset, 0);
			self.rightCircle.frame = CGRectOffset(self.rightCircle.frame, -offset, 0);
			self.leftCircleCoverRect.frame = CGRectOffset(self.leftCircleCoverRect.frame, offset, 0);
			self.rightCircleCoverRect.frame = CGRectOffset(self.rightCircleCoverRect.frame, -offset, 0);

			self.lastLeftmostPoint = touch1;
			self.lastRightmostPoint = touch2;

			if ([self semiCirclesShouldBePinched]) {
				self.isPinching = NO;
				[self animateSemiCirclesTogether];
			}

			break;
		}
		case UIGestureRecognizerStateEnded: {
			if (!self.isPinching) return;
			self.isPinching = NO;
			if ([self semiCirclesShouldBePinched]) {
				[self animateSemiCirclesTogether];
			} else {
				[self animateSemiCirclesBackToOrigin];
			}

			break;
		}
		default: {
			return;
		}
	}

}

//checks if semi circles are close enough together to animate together
-(BOOL) semiCirclesShouldBePinched {
	if ((fabs(self.leftCircle.frame.origin.x - self.circleFrameCenter.origin.x) +
		 fabs(self.rightCircle.frame.origin.x - self.circleFrameCenter.origin.x)) < PINCH_THRESHOLD) {
		return YES;
	}
	return NO;
}

/*animates the semicircles either to the center or to their sides*/
-(void)positionSemiCirclesCenter:(BOOL)toCenter {
	if(toCenter){
		[UIView animateWithDuration:0.8 animations:^{
            //CGPoint  myCenter = self.center;
			//self.leftSemiCircle.frame = CGRectMake(myCenter.x - ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
			//self.rightSemiCircle.frame = CGRectMake(myCenter.x +((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
		}];

	}else{
		[UIView animateWithDuration:0.8 animations:^{
            //CGPoint  myCenter = self.center;
			//self.leftSemiCircle.frame = CGRectMake(myCenter.x - ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
			//self.rightSemiCircle.frame = CGRectMake(myCenter.x +((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
		}];
	}
}

#pragma mark - Lazy Instantiation -

-(void) animateSemiCirclesTogether {
	[UIView animateWithDuration: PINCH_TOGETHER_DURATION animations:^{
		//adjustment because there's like a 1px gap between halved images
		self.leftCircle.frame = CGRectOffset(self.circleFrameCenter, 1, 0);
		self.rightCircle.frame = self.circleFrameCenter;
		self.leftCircleCoverRect.frame = CGRectOffset(self.leftCoverRectFrame, self.storyTextView.frame.size.width/2.f, 0);
		self.rightCircleCoverRect.frame = CGRectOffset(self.rightCoverRectFrame, -(self.storyTextView.frame.size.width/2.f), 0);
	} completion:^(BOOL finished) {
		[self.delegate successfullyPinchedTogetherAtIndexPath:self.indexPath];
	}];
}

-(void) animateSemiCirclesBackToOrigin {
	[UIView animateWithDuration: PINCH_APART_DURATION animations:^{
		self.leftCircle.frame = self.leftCircleFrame;
		self.rightCircle.frame = self.rightCircleFrame;
		self.leftCircleCoverRect.frame = self.leftCoverRectFrame;
		self.rightCircleCoverRect.frame = self.rightCoverRectFrame;
	} completion:^(BOOL finished) {
	}];
}

-(void) didSelect {
	if (self.rightCircle.frame.origin.x != self.circleFrameCenter.origin.x) {
		[self animateSemiCirclesTogether];
	}
	[self didPinchTogether];
}

-(void) didPinchTogether {
	UIImageView* coverPhotoImageView = [[UIImageView alloc] initWithImage: self.coverImage];
	coverPhotoImageView.frame = self.circleFrameCenter;
	[self addSubview:coverPhotoImageView];
	[UIView animateWithDuration: 1.5f animations:^{
		coverPhotoImageView.frame = self.superview.superview.bounds;
	} completion:^(BOOL finished) {

	}];
}

#pragma mark - Lazy Instantiation -

-(UIImageView*) leftSemiCircle {
	if(!_leftSemiCircle) {
		_leftSemiCircle = [[UIImageView alloc] init];
	}
	return _leftSemiCircle;
}

    -(UIImageView *) rightSemiCircle {
	if(!_rightSemiCircle) {
		_rightSemiCircle = [[UIImageView alloc] init];
	}
	return _rightSemiCircle;
}

-(UIView*) leftCircleCoverRect {
	if(!_leftCircleCoverRect) {
		_leftCircleCoverRect = [[UIView alloc] init];
	}
	return _leftCircleCoverRect;
}

-(UIView*) rightCircleCoverRect {
	if(!_rightCircleCoverRect) {
		_rightCircleCoverRect = [[UIView alloc] init];
	}
	return _rightCircleCoverRect;
}

-(UILabel *) povTitle {
	if(!_povTitle){
		_povTitle = [[UILabel alloc]init];
	}
	return _povTitle;
}
-(UILabel *) povCreatorUsername{
	if(!_povCreatorUsername) {
		_povCreatorUsername = [[UILabel alloc]init];
	}
	return _povCreatorUsername;
}
@end

