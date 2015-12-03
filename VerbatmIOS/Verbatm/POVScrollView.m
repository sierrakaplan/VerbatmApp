//
//  POVScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "AVETypeAnalyzer.h"
#import "POV.h"
#import "POVView.h"
#import "POVScrollView.h"

@interface POVScrollView()

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

#define NO_POVS_LABEL_WIDTH 300.f

@end

@implementation POVScrollView

-(instancetype) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor blackColor];
		self.scrollEnabled = YES;
		self.pagingEnabled = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		[self.activityIndicator startAnimating];
	}
	return self;
}

-(void) displayPOVs: (NSArray*)povs {
	if (!povs || !povs.count) {
		UILabel* noPOVSLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2.f - NO_POVS_LABEL_WIDTH/2.f, 0.f,
																		 NO_POVS_LABEL_WIDTH, self.frame.size.height)];
		noPOVSLabel.text = @"There are no stories in this thread.";
		noPOVSLabel.textColor = [UIColor whiteColor];
		noPOVSLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:noPOVSLabel];
	}
	[self.activityIndicator stopAnimating];
	AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc]init];

	CGFloat xPosition = 0.f;
	for (POV* pov in povs) {
		CGRect povFrame = CGRectMake(xPosition, 0.f, self.bounds.size.width, self.bounds.size.height);
		NSMutableArray* aves = [analyzer getAVESFromPinchViews:pov.pinchViews withFrame:self.bounds inPreviewMode:NO];
		POVView* povView = [[POVView alloc] initWithFrame:povFrame andPOVInfo:nil];
		[povView renderAVES: aves];
		[self addSubview: povView];
		xPosition += self.bounds.size.width;
	}
	self.contentSize = CGSizeMake(povs.count * self.bounds.size.width, 0.f);
}


-(void)playPOVOnScreen{
    NSInteger povIndex = self.contentOffset.x/self.frame.size.width;
    for(int i = 0; i < self.subviews.count; i++){
        UIView * subView = self.subviews[i];
        
        if([subView isKindOfClass:[POVView class]]){
            if( i == povIndex ){
                [(POVView *)subView povOnScreen];
            }else{
                [(POVView *)subView povOffScreen];
            }
        }
    }
}





-(void) clearPOVs {
	for (UIView* subview in self.subviews) {
		[subview removeFromSuperview];
	}
	[self.activityIndicator startAnimating];
}

#pragma mark - Lazy Instantiation -

-(UIActivityIndicatorView*) activityIndicator {
	if (!_activityIndicator) {
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicator.color = [UIColor grayColor];
		_activityIndicator.hidesWhenStopped = YES;
		_activityIndicator.center = self.center;
		[self addSubview:_activityIndicator];
	}
	return _activityIndicator;
}

@end
