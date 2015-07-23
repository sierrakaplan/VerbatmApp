//
//  VerbatmImageScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/22/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VerbatmImageScrollView.h"

@implementation VerbatmImageScrollView

-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		[self format];
	}
	return self;
}

-(void)format {
	self.pagingEnabled = YES;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
}

-(void)renderPhotos:(NSArray*)photos {

	for (NSData* imageData in photos)
	{
		UIImage*image = [[UIImage alloc] initWithData: imageData];
		UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
		imageview.frame = [self getNextFrame];
		imageview.clipsToBounds = YES;
		imageview.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:imageview];
	}
	[self adjustContentSize];
}

//gives you the frame for the next iamgeview that you'll add to the end of the list
-(CGRect) getNextFrame
{
	if(!self.subviews.count) return self.bounds;
	UIView * view = self.subviews.lastObject;
	return CGRectMake(view.frame.origin.x +view.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
}

//resets the content size of the scrollview
-(void) adjustContentSize {
	self.contentSize = CGSizeMake((self.frame.size.width* self.subviews.count), 0);
}

-(void)setImagesToFullScreen {
	for(UIView * view in self.subviews) {
		view.contentMode = UIViewContentModeScaleAspectFit;
		view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
	}
}

@end
