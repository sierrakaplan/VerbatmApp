//
//  CoverPicturePinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CoverPicturePinchView.h"
#import "Styles.h"

@interface CoverPicturePinchView()

@property (strong, nonatomic) UILabel* addCoverPicLabel;

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CoverPicturePinchView

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self formatSelf];
	}
	return self;
}

-(instancetype) initWithRadius:(float)radius withCenter:(CGPoint)center {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self formatSelf];
	}
	return self;
}

-(void) formatSelf {
	[self setBackgroundColor: [UIColor clearColor]];
	[self formatAddCoverPicLabel];
	self.layer.borderColor = [UIColor COVER_PIC_CIRCLE_COLORE].CGColor;
}

-(void) formatAddCoverPicLabel {
	self.addCoverPicLabel = [[UILabel alloc] initWithFrame:self.bounds];
	self.addCoverPicLabel.textAlignment = NSTextAlignmentCenter;
	self.addCoverPicLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.addCoverPicLabel.numberOfLines = 3;
	self.addCoverPicLabel.text = @"Cover Picture";
    [self.addCoverPicLabel setTextColor:[UIColor TELL_YOUR_STORY_COLOR]];
	self.addCoverPicLabel.font = [UIFont fontWithName:ADD_COVER_PIC_FONT size: ADD_COVER_PIC_TEXT_SIZE];
	[self.background addSubview: self.addCoverPicLabel];
}

-(void) setImage: (UIImage*) image {
	[self.imageView setImage:image];
	[self.addCoverPicLabel removeFromSuperview];
	[self.background insertSubview:self.imageView atIndex:0];
    self.containsImage = YES;
}

-(UIImage*) getImage {
	return [self.imageView image];
}

-(void) removeImage {
	[self.imageView removeFromSuperview];
	[self.background addSubview: self.addCoverPicLabel];
}

#pragma mark - Lazy Instantiation

-(UIImageView*)imageView {
	if(!_imageView) _imageView = [[UIImageView alloc] initWithFrame: self.background.frame];
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
	_imageView.layer.masksToBounds = YES;
	return _imageView;
}

@end
