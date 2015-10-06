//

//  verbatmArticle_TableViewCell.m

//  Verbatm

//

//  Created by Iain Usiri on 3/29/15.

//  Copyright (c) 2015 Verbatm. All rights reserved.

//

#import "FeedTableViewCell.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Durations.h"
#import "UIImage+ImageEffectsAndTransforms.h"

@interface FeedTableViewCell()

#pragma mark - Square with text in the center of the cell -

@property (nonatomic) CGRect storyTextViewFrame;

@property (strong, nonatomic) UILabel * povTitle;
@property (strong, nonatomic) UILabel * povCreatorUsername;

@property (strong, nonatomic) UILabel * dateCreatedLabel;
@property (strong, nonatomic) UILabel * numLikesLabel;
@property (strong, nonatomic) UIImageView* likeIconView;
@property (strong, nonatomic) UIImage* likedImage;
@property (strong, nonatomic) UIImage* notLikedImage;

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
#define PINCH_THRESHOLD 150.f
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
    if(self.isPlaceHolder) {
		[self startActivityIndicatrForPlaceholder];
	}
	[self formatCoverRectsWithStoryTextViewFrame: self.storyTextViewFrame];
	[self formatSemiCircles];
	[self addPinchGestureToSelf];
}

-(void) formatSelf {
	[self setBackgroundColor:[UIColor clearColor]];
}

-(void) formatTextSubview {

	self.storyTextViewFrame = CGRectMake(STORY_CELL_PADDING + CIRCLE_DIAMETER/2.f, STORY_CELL_PADDING,
									  self.frame.size.width - STORY_CELL_PADDING*2 - CIRCLE_DIAMETER,
									  self.frame.size.height - STORY_CELL_PADDING*2);
	UIView* storyTextView = [[UIView alloc] initWithFrame: self.storyTextViewFrame];
	[storyTextView setBackgroundColor:[UIColor STORY_BACKGROUND_COLOR]];

	[self.povTitle setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
										FEED_TEXT_GAP,
										self.storyTextViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
										TITLE_LABEL_HEIGHT)];

	[self.povCreatorUsername setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
												  self.povTitle.frame.origin.y + self.povTitle.frame.size.height + FEED_TEXT_GAP,
												  self.storyTextViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
												  USERNAME_LABEL_HEIGHT)];

	[self formatUILabel: self.povTitle
			   withFont: [UIFont fontWithName:TITLE_FONT size:FEED_TITLE_FONT_SIZE]
		   andTextColor: [UIColor TITLE_TEXT_COLOR]
	   andNumberOfLines: 2 withCellWidth: storyTextView.frame.size.width];

	[self formatUILabel: self.povCreatorUsername
			   withFont: [UIFont fontWithName:USERNAME_FONT size:USERNAME_FONT_SIZE]
		   andTextColor: [UIColor TITLE_TEXT_COLOR]
	   andNumberOfLines: 2 withCellWidth: storyTextView.frame.size.width];

	[storyTextView addSubview: self.povTitle];
	[storyTextView addSubview: self.povCreatorUsername];
	[storyTextView addSubview: [self formatDateAndLikesViewFromTextViewFrame: self.storyTextViewFrame]];
	[self addSubview: storyTextView];
}

-(UIView*) formatDateAndLikesViewFromTextViewFrame: (CGRect) textViewFrame {
	UIView* dateAndLikesView = [[UIView alloc] initWithFrame:CGRectMake(FEED_TEXT_X_OFFSET,
																		textViewFrame.size.height - DATE_AND_LIKES_LABEL_HEIGHT,
																		textViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
																		DATE_AND_LIKES_LABEL_HEIGHT)];

	[self.dateCreatedLabel setFrame: CGRectMake(0, 0, dateAndLikesView.frame.size.width/2.f, DATE_AND_LIKES_LABEL_HEIGHT)];
	self.likeIconView.frame = CGRectMake(dateAndLikesView.frame.size.width/2.f, 0, DATE_AND_LIKES_LABEL_HEIGHT, DATE_AND_LIKES_LABEL_HEIGHT);
	[self.numLikesLabel setFrame: CGRectMake(dateAndLikesView.frame.size.width/2.f + self.likeIconView.frame.size.width + 5.f,
											 0, dateAndLikesView.frame.size.width - self.dateCreatedLabel.frame.size.width - self.likeIconView.frame.size.width,
											 DATE_AND_LIKES_LABEL_HEIGHT)];

	[dateAndLikesView addSubview: self.dateCreatedLabel];
	[dateAndLikesView addSubview: self.likeIconView];
	[dateAndLikesView addSubview: self.numLikesLabel];

	return dateAndLikesView;
}

-(void) formatUILabel: (UILabel*)label withFont: (UIFont*)font andTextColor: (UIColor*) textColor
	 andNumberOfLines: (NSInteger) numLines withCellWidth: (CGFloat) cellWidth {
	[label setFont:font];
	[label setTextColor:textColor];
	[label setLineBreakMode: NSLineBreakByWordWrapping];
	[label setNumberOfLines: numLines];
	[label sizeToFit];
	[label setFrame: CGRectMake(label.frame.origin.x, label.frame.origin.y,
								cellWidth - FEED_TEXT_X_OFFSET*2,
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

-(void) formatCoverRectsWithStoryTextViewFrame: (CGRect) storyTextViewFrame {
	CGFloat width = storyTextViewFrame.size.width/2.f;
	self.leftCoverRectFrame = CGRectMake(storyTextViewFrame.origin.x - width,
										 storyTextViewFrame.origin.y,
										 width,
										 storyTextViewFrame.size.height);
	self.leftCircleCoverRect.frame = self.leftCoverRectFrame;
	self.rightCoverRectFrame = CGRectOffset(self.leftCircleCoverRect.frame, storyTextViewFrame.size.width + width, 0);
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
				 andCoverImage: (UIImage*) coverImage andDateCreated: (GTLDateTime*) dateCreated
				   andNumLikes: (NSNumber*) numLikes likedByCurrentUser: (BOOL) likedByCurrentUser {
	self.title = title;
	self.povTitle.text = title;
	self.povCreatorUsername.text = username;
	if (dateCreated) {
		self.dateCreatedLabel.text = @""; //TODO: [NSString stringWithFormat: @"%@", dateCreated.stringValue];
	}

	switch(numLikes.longLongValue) {
		case 0: {
			[self.likeIconView setHidden:YES];
			self.numLikesLabel.text = @"";
			break;
		}
		case 1: {
			[self.likeIconView setHidden:NO];
			self.numLikesLabel.text = [NSString stringWithFormat: @"%lld like", numLikes.longLongValue];
			break;
		}
		default: {
			[self.likeIconView setHidden:NO];
			self.numLikesLabel.text = [NSString stringWithFormat: @"%lld likes", numLikes.longLongValue];
		}
	}

	if (likedByCurrentUser) {
		[self.likeIconView setImage:self.likedImage];
	} else {
		[self.likeIconView setImage:self.notLikedImage];
	}

	UIImage* leftHalf = [coverImage halfPictureLeftHalf:YES];
	UIImage* rightHalf = [coverImage halfPictureLeftHalf:NO];
	[self.leftSemiCircle setImage: leftHalf];
	[self.rightSemiCircle setImage: rightHalf];
}

-(void) setLoadingContentWithUsername:(NSString *) username andTitle: (NSString *) title
						andCoverImage: (UIImage*) coverImage {
	[self setContentWithUsername:username andTitle:title andCoverImage:coverImage andDateCreated: nil
					 andNumLikes: [NSNumber numberWithLongLong:0] likedByCurrentUser:NO];
    self.isPlaceHolder = YES;
}

-(void) updateCellLikedByCurrentUser: (BOOL) likedByCurrentUser withNewNumLikes: (long long) newNumLikes {
	if (likedByCurrentUser) {
		[self.likeIconView setImage:self.likedImage];
	} else {
		[self.likeIconView setImage:self.notLikedImage];
	}

	switch(newNumLikes) {
		case 0: {
			[self.likeIconView setHidden:YES];
			self.numLikesLabel.text = @"";
			break;
		}
		case 1: {
			[self.likeIconView setHidden:NO];
			self.numLikesLabel.text = [NSString stringWithFormat: @"%lld like", newNumLikes];
			break;
		}
		default: {
			[self.likeIconView setHidden:NO];
			self.numLikesLabel.text = [NSString stringWithFormat: @"%lld likes", newNumLikes];
		}
	}
}

#pragma mark - Activity Indicator -

-(void)startActivityIndicatrForPlaceholder{
	[self startActivityIndicator];
}

//creates an activity indicator on our placeholder view
//shifts the frame of the indicator if it's on the screen
-(void)startActivityIndicator{
    if(self.activityIndicator.isAnimating){
        self.activityIndicator.center = self.center;
        [self bringSubviewToFront:self.activityIndicator];
    }else{
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.center = self.center;
        [self addSubview:self.activityIndicator];
        [self bringSubviewToFront:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }
}

-(void)stopActivityIndicator {
    if(!self.activityIndicator.isAnimating) return;
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

#pragma mark - Selected & Deselected -

// If it was selected (by a tap for example)
// Then animate the circles together before calling delegate method
-(void) wasSelected {
	[self animateSemiCirclesTogetherWithDuration: PINCH_TOGETHER_DURATION*1.5];
}

// After being selected needs to reset where semi circles are
// Resets frames of right and left circle and right and left cover rects
-(void) deSelect {
	self.rightCircle.frame = self.rightCircleFrame;
	self.leftCircle.frame = self.leftCircleFrame;
	self.rightCircleCoverRect.frame = self.rightCoverRectFrame;
	self.leftCircleCoverRect.frame = self.leftCoverRectFrame;
}

#pragma mark - Pinch Gesture -

-(void)addPinchGestureToSelf{
	UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:
											   @selector(pinchingSemiCirclesTogether:)];
	[self addGestureRecognizer: pinchGesture];
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
				[self animateSemiCirclesTogetherWithDuration: PINCH_TOGETHER_DURATION];
			}

			break;
		}
		case UIGestureRecognizerStateEnded: {
			if (!self.isPinching) return;
			self.isPinching = NO;
			if ([self semiCirclesShouldBePinched]) {
				[self animateSemiCirclesTogetherWithDuration: PINCH_TOGETHER_DURATION];
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

-(void) animateSemiCirclesTogetherWithDuration: (CGFloat) duration {
	[UIView animateWithDuration: duration animations:^{
		//adjustment because there's like a 1px gap between halved images
		self.leftCircle.frame = CGRectOffset(self.circleFrameCenter, 1, 0);
		self.rightCircle.frame = self.circleFrameCenter;
		self.leftCircleCoverRect.frame = CGRectOffset(self.leftCoverRectFrame, self.storyTextViewFrame.size.width/2.f, 0);
		self.rightCircleCoverRect.frame = CGRectOffset(self.rightCoverRectFrame, -(self.storyTextViewFrame.size.width/2.f), 0);
	} completion:^(BOOL finished) {
		if (finished) {
			[self.delegate successfullyPinchedTogetherCell: self];
		}
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

-(UILabel *) numLikesLabel {
	if (!_numLikesLabel) {
		_numLikesLabel = [[UILabel alloc] init];
		[_numLikesLabel setFont: [UIFont fontWithName:DATE_AND_LIKES_FONT size:DATE_AND_LIKES_FONT_SIZE]];
		[_numLikesLabel setTextColor:[UIColor TITLE_TEXT_COLOR]];
		[_numLikesLabel setTextAlignment: NSTextAlignmentLeft];
	}
	return _numLikesLabel;
}

-(UILabel *) dateCreatedLabel {
	if (!_dateCreatedLabel) {
		_dateCreatedLabel = [[UILabel alloc] init];
		[_dateCreatedLabel setFont: [UIFont fontWithName:DATE_AND_LIKES_FONT size:DATE_AND_LIKES_FONT_SIZE]];
		[_dateCreatedLabel setTextColor:[UIColor TITLE_TEXT_COLOR]];
		[_dateCreatedLabel setTextAlignment: NSTextAlignmentLeft];
	}
	return _dateCreatedLabel;
}

- (UIImageView *)likeIconView {
	if (!_likeIconView) {
		_likeIconView = [[UIImageView alloc] initWithImage:self.notLikedImage];
		_likeIconView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _likeIconView;
}

-(UIImage*) likedImage {
	if (!_likedImage) {
		_likedImage = [UIImage imageNamed: FEED_LIKED_ICON];
	}
	return _likedImage;
}

-(UIImage*) notLikedImage {
	if (!_notLikedImage) {
		_notLikedImage = [UIImage imageNamed: FEED_NOT_LIKED_ICON];
	}
	return _notLikedImage;
}

@end

