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

#pragma mark - Square with text in the center of the cell -
@property (strong, nonatomic) UIView * storyTextView;
@property (strong, nonatomic) UILabel * povTitle;
@property (strong, nonatomic) UILabel * povCreatorUsername;

#pragma mark - Left and right semi circles containing the cover picture -
@property (strong, nonatomic) UIImageView * leftSemiCircle;
@property (strong, nonatomic) UIImageView * rightSemiCircle;

#pragma mark - Data to help with pinching gesture -
@property (nonatomic) CGPoint lastLeftmostPoint;
@property (nonatomic) CGPoint lastRightmostPoint;


#define CIRCLE_DIAMETER (self.frame.size.height - STORY_CELL_PADDING*2)

@end

@implementation FeedTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
	if (self) {
		[self formatSelf];
		[self formatTextSubview];
		[self formatImagePinchViews];
		[self addPinchGestureToSelf];
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
}

-(void) formatSelf {
	[self setBackgroundColor:[UIColor clearColor]];
}

-(void) formatTextSubview {

	CGRect textViewFrame = CGRectMake(STORY_CELL_PADDING + CIRCLE_DIAMETER/2.f, STORY_CELL_PADDING,
									  self.frame.size.width - STORY_CELL_PADDING*2 - CIRCLE_DIAMETER,
									  self.frame.size.height - STORY_CELL_PADDING*2);
	self.storyTextView = [[UIView alloc] initWithFrame: textViewFrame];
	[self.storyTextView setBackgroundColor:[UIColor colorWithRed: STORY_BACKGROUND_COLOR green:STORY_BACKGROUND_COLOR blue:STORY_BACKGROUND_COLOR alpha:1]];

	[self.povTitle setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
										FEED_TEXT_GAP,
										textViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
										TITLE_LABEL_HEIGHT)];

    [self.povCreatorUsername setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
												  textViewFrame.size.height - USERNAME_LABEL_HEIGHT,
												  textViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
												  USERNAME_LABEL_HEIGHT)];

	[self formatUILabel:self.povTitle
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
-(void) formatImagePinchViews {

	CGRect leftCircleFrame = CGRectMake(STORY_CELL_PADDING, STORY_CELL_PADDING,
										CIRCLE_DIAMETER, CIRCLE_DIAMETER);
	CGRect rightCircleFrame = CGRectMake(self.frame.size.width - STORY_CELL_PADDING - CIRCLE_DIAMETER, STORY_CELL_PADDING,
										 CIRCLE_DIAMETER, CIRCLE_DIAMETER);

	UIView* leftBackground = [self getBackgroundCircleWithFrame: leftCircleFrame];
	UIView* rightBackground = [self getBackgroundCircleWithFrame: rightCircleFrame];

	[leftBackground addSubview: self.leftSemiCircle];
	[rightBackground addSubview: self.rightSemiCircle];

	[self formatSemiCircleImageView: self.leftSemiCircle withFrame: leftCircleFrame onLeft:YES];
	[self formatSemiCircleImageView: self.rightSemiCircle withFrame: rightCircleFrame onLeft:NO];

	[self addSubview: leftBackground];
	[self addSubview: rightBackground];
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

//TODO: make this a category
-(UIImage*) halfPicture: (UIImage*) image leftHalf:(BOOL) leftHalf {
	float xOrigin = leftHalf ? 0 : image.size.width/2.f;
	CGRect cropRect = CGRectMake(xOrigin, 0, image.size.width/2.f, image.size.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
	UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(imageRef);
	return result;
}

#pragma mark - Pinch Gesture -

-(void)addPinchGestureToSelf{

	UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:
											   @selector(pinchingSemiCirclesTogether:)];
	//TODO: [self addGestureRecognizer: pinchGesture];
}

//moves the views frame to the provided offset
-(void)translateView:(UIView *) view withXOffset:(CGFloat) offset{
	view.frame = CGRectMake(view.frame.origin.x + offset, view.frame.origin.y, view.frame.size.width,
							view.frame.size.height);
}

-(void)pinchingSemiCirclesTogether:(UIPinchGestureRecognizer *)sender{
	//make sure it's only two touches that are registered
	if(sender.numberOfTouches != 2) return;
	switch(sender.state) {
		case UIGestureRecognizerStateBegan: {
			CGPoint touch1 = [sender locationOfTouch:0 inView:self];
			CGPoint touch2 = [sender locationOfTouch:1 inView:self];
			if(touch1.x < touch2.x){
				self.lastLeftmostPoint = touch1;
				self.lastRightmostPoint = touch2;
			}else{
				self.lastLeftmostPoint = touch2;
				self.lastRightmostPoint = touch1;
			}
			break;
		}
		case UIGestureRecognizerStateChanged: {
			CGPoint touch1 = [sender locationOfTouch:0 inView:self];
			CGPoint touch2 = [sender locationOfTouch:1 inView:self];
			if(touch1.x < touch2.x){
				[self translateView: [self.leftSemiCircle superview] withXOffset:touch1.x - self.lastLeftmostPoint.x];
				[self translateView: [self.rightSemiCircle superview] withXOffset:touch2.x - self.lastRightmostPoint.x];
				self.lastLeftmostPoint = touch1;
				self.lastRightmostPoint = touch2;
			}else{
				[self translateView: [self.rightSemiCircle superview] withXOffset:touch2.x - self.lastLeftmostPoint.x];
				[self translateView: [self.rightSemiCircle superview] withXOffset:touch1.x - self.lastRightmostPoint.x];
				self.lastLeftmostPoint = touch2;
				self.lastRightmostPoint = touch1;
			}
			break;
		}
		case UIGestureRecognizerStateEnded: {
			//TODO: check if the two circles were pinched far enough together to open a story or move them back
			break;
		}
		default: {
			return;
		}
	}

}


/*animates the semicircles either to the center or to their sides*/
-(void)positionSemiCirclesCenter:(BOOL)toCenter{

	if(toCenter){
		[UIView animateWithDuration:0.8 animations:^{
			CGPoint  myCenter = self.center;

			//            self.leftSemiCircle.frame = CGRectMake(myCenter.x - ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
			//            self.rightSemiCircle.frame = CGRectMake(myCenter.x +((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
		}];

	}else{
		[UIView animateWithDuration:0.8 animations:^{
			CGPoint  myCenter = self.center;
			//
			//            self.leftSemiCircle.frame = CGRectMake(myCenter.x - ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
			//            self.rightSemiCircle.frame = CGRectMake(myCenter.x +((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
		}];

	}

}

#pragma mark - Lazy Instantiation -

-(UIImageView *)leftSemiCircle {
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

-(UILabel *) povTitle {
	if(!_povTitle)_povTitle = [[UILabel alloc]init];
	return _povTitle;
}

-(UILabel *) povCreatorUsername{
	if(!_povCreatorUsername)_povCreatorUsername = [[UILabel alloc]init];
	return _povCreatorUsername;
}


@end

