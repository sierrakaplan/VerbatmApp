//
//  PageViewingExperience.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/1/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "PageViewingExperience.h"

@interface PageViewingExperience()



@end

@implementation PageViewingExperience

-(instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
		self.hasLoadedMedia = NO;
		self.currentlyOnScreen = NO;
		self.currentlyLoadingMedia = NO;
        self.clipsToBounds = YES;
        [self createBorder];
        self.autoresizesSubviews= YES;
        self.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
    }
    return self;
}


-(void)createBorder{
    [self.layer setBorderWidth:0.5];
    [self.layer setCornerRadius:0.0];
    [self.layer setBorderColor:[UIColor blackColor].CGColor];
}

-(void)onScreen {}

-(void)offScreen {}

-(void)almostOnScreen {}

-(LoadingIndicator *) customActivityIndicator{
	if(!_customActivityIndicator){
		CGPoint newCenter = CGPointMake(self.center.x, self.frame.size.height * 1.f/2.f);
		_customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:newCenter andImage:[UIImage imageNamed:LOAD_ICON_IMAGE]];
		[self addSubview:_customActivityIndicator];
	}
	return _customActivityIndicator;
}

@end
