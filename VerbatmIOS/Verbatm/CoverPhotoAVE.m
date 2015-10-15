//
//  CoverPhotoAVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CoverPhotoAVE.h"
#import "Styles.h"
#import "UIImage+ImageEffectsAndTransforms.h"

@interface CoverPhotoAVE()

#define TITLE_CENTER_Y_OFFSET 50.f
#define TITLE_HEIGHT_BUFFER 30
#define TITLE_WIDTH_BUFFER 30
#define COVER_PHOTO_TITLE_FONT_SIZE 30
@end

@implementation CoverPhotoAVE

-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage*) image andTitle:(NSString*) title {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor whiteColor]];
		UIColor* titleTextColor = [UIColor blackColor];
		if (image) {
			[self addSubview: [self getImageViewContainerForImage:image]];
		}

		[self addTitleViewWithTitle: title andTextColor: titleTextColor];
	}
	return self;
}

-(UIView*) getImageViewContainerForImage:(UIImage*) image {
	UIView* imageContainerView = [[UIView alloc] initWithFrame:self.bounds];
	[imageContainerView setBackgroundColor:[UIColor blackColor]];
	UIImageView* photoView = [self getImageViewForImage:image];
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
	UILabel* titleLabel = [[UILabel alloc]init];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	titleLabel.numberOfLines = 0;
	titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:COVER_PHOTO_TITLE_FONT_SIZE];
    
	titleLabel.textColor = textColor;

	if (![title length]) {
		title = @"No Title Entered";
	}
	titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [titleLabel sizeToFit];
    titleLabel.frame = self.bounds;
    
	[self addSubview: titleLabel];
}

@end
