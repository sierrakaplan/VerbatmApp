//
//  CoverPhotoAVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CoverPhotoAVE.h"
#import "Styles.h"
#import "UIEffects.h"

@interface CoverPhotoAVE()

#define TITLE_OFFSET 20.f

@end

@implementation CoverPhotoAVE

-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage*) image andTitle:(NSString*) title {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor whiteColor]];
		UIColor* titleTextColor = [UIColor whiteColor];
		if (image) {
			[self addSubview: [self getImageViewContainerForImage:image]];
		} else {
			titleTextColor = [UIColor blackColor];
		}
		[self addTitleViewWithTitle: title andTextColor: titleTextColor];
	}
	return self;
}

-(UIView*) getImageViewContainerForImage:(UIImage*) image {
	//scale image
	CGSize imageSize = [UIEffects getSizeForImage:image andBounds:self.bounds];
	image = [UIEffects scaleImage:image toSize:imageSize];

	UIView* imageContainerView = [[UIView alloc] initWithFrame:self.bounds];
	[imageContainerView setBackgroundColor:[UIColor blackColor]];
	UIImageView* photoView = [self getImageViewForImage:image];
	UIImageView* blurPhotoView = [UIEffects getBlurImageViewForImage:image withFrame:self.bounds];
	[imageContainerView addSubview:blurPhotoView];
	[imageContainerView addSubview:photoView];
	return imageContainerView;
}

// returns image view with image centered
-(UIImageView*) getImageViewForImage:(UIImage*) image {
	UIImageView* photoView = [[UIImageView alloc] initWithImage:image];
	photoView.frame = self.bounds;
	photoView.clipsToBounds = YES;
	photoView.contentMode = UIViewContentModeScaleAspectFit;
	return photoView;
}

-(void) addTitleViewWithTitle:(NSString*) title andTextColor:(UIColor*) textColor {

	CGRect titleFrame = CGRectMake(TITLE_OFFSET, TITLE_OFFSET, self.frame.size.width - TITLE_OFFSET*2.f,
								   self.frame.size.height - TITLE_OFFSET*2.f);
	UILabel* titleLabel = [[UILabel alloc] initWithFrame: titleFrame];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:TITLE_FONT_SIZE];
	titleLabel.textColor = textColor;

	if (![title length]) {
		title = @"No Title Entered";
	}
	titleLabel.text = title;
	[self addSubview: titleLabel];
}

@end
