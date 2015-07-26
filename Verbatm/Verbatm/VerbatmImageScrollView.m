//
//  VerbatmImageScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VerbatmImageScrollView.h"
#import "UIEffects.h"
#import "Styles.h"

@interface VerbatmImageScrollView()

@property (nonatomic) BOOL hasBlurBackground;

@end

@implementation VerbatmImageScrollView

-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.hasBlurBackground = NO;
		[self format];
	}
	return self;
}

-(void)format {
	self.pagingEnabled = YES;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
}

-(void)renderPhotos:(NSArray*)photos withBlurBackground:(BOOL)withBackground {

	for (NSData* imageData in photos)
	{
		UIImage*image = [[UIImage alloc] initWithData: imageData];
		UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
		CGRect imageViewFrame = [self getNextFrame];
		imageview.frame = imageViewFrame;
		imageview.clipsToBounds = YES;
		imageview.contentMode = UIViewContentModeScaleAspectFit;

		if (withBackground) {
			UIImage* blurImage = [UIEffects blurredImageWithImage:image andFilterLevel:FILTER_LEVEL_BLUR];
			UIImageView* blurBackground = [[UIImageView alloc] initWithImage:blurImage];
			blurBackground.frame = imageViewFrame;
			blurBackground.clipsToBounds = YES;
			blurBackground.contentMode = UIViewContentModeScaleAspectFill;
			[self addSubview:blurBackground];
		}
		[self addSubview:imageview];
	}
	self.hasBlurBackground = withBackground;
	[self adjustContentSize];
}

//gives you the frame for the next iamgeview that you'll add to the end of the list
-(CGRect) getNextFrame
{
	if(!self.subviews.count) return self.bounds;
	UIView * view = self.subviews.lastObject;
	return CGRectMake(view.frame.origin.x +view.frame.size.width, 0, self.bounds.size.width, self.bounds.size.height);
}

//resets the content size of the scrollview
-(void) adjustContentSize {
	NSInteger numImages = self.hasBlurBackground ? self.subviews.count/2 : self.subviews.count;
	self.contentSize = CGSizeMake((self.frame.size.width* numImages), 0);
}

-(void)setImageHeights {
	for(UIImageView * view in self.subviews) {
		view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
	}
}

@end
