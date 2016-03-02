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
#import "Styles.h"
#import "SizesAndPositions.h"
@interface POVScrollView() <POVViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;
@property (strong, nonatomic) NSMutableArray * povViews;
@property (weak, nonatomic) POVView * visiblePOV;//the pov that the user can currently see


@end

@implementation POVScrollView

-(instancetype) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.autoresizesSubviews = YES;
		self.feedScrollView = NO;
		self.backgroundColor = [UIColor blackColor];
		self.scrollEnabled = YES;
		self.pagingEnabled = YES;
        self.bounces = NO;
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
		noPOVSLabel.text = @"There are no stories in this channel.";
		noPOVSLabel.font = [UIFont fontWithName:DEFAULT_FONT size:20.f];
		noPOVSLabel.textColor = [UIColor whiteColor];
		noPOVSLabel.textAlignment = NSTextAlignmentCenter;
		noPOVSLabel.lineBreakMode = NSLineBreakByWordWrapping;
		noPOVSLabel.numberOfLines = 3;
		[self addSubview:noPOVSLabel];
	}
    
	[self.activityIndicator stopAnimating];
	AVETypeAnalyzer * analyzer = [[AVETypeAnalyzer alloc]init];

	CGFloat xPosition = 0.f;
	for (POV* pov in povs) {
		
        @autoreleasepool {
			
            CGRect povFrame = CGRectMake(xPosition, 0.f, self.bounds.size.width, self.bounds.size.height);
			NSMutableArray* aves = [analyzer getAVESFromPinchViews:pov.pinchViews withFrame:self.bounds inPreviewMode:NO];
			POVView* povView = [[POVView alloc] initWithFrame:povFrame andPovParseObject:nil];
            povView.delegate = self;
			povView.autoresizesSubviews = YES;
			povView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[povView renderAVES: aves];
			
            if (self.feedScrollView) {
                Channel * povChannel ;//= [[Channel alloc] initWithChannelName:pov.channelName numberOfFollowers:@(20) andUserName:pov.creatorName]; TODO
				[povView addCreatorInfoFromChannel:povChannel];
			}
            
			[self addSubview: povView];
			[self.povViews addObject:povView];
			xPosition += self.bounds.size.width;
		}
	}
	self.contentSize = CGSizeMake(povs.count * self.bounds.size.width, 0.f);
}

-(void)playPOVOnScreen{
    int povIndex = self.contentOffset.x/self.frame.size.width;
    for(int i = 0; i < self.povViews.count; i++){
        UIView * subView = self.povViews[i];
        if([subView isKindOfClass:[POVView class]]){
            if(i == povIndex ){
                [(POVView *)subView povOnScreen];
                self.visiblePOV = (POVView *)subView;
            }else{//we must explicitly tell each view they are off screen
                [(POVView *)subView povOffScreen];
            }
        }
    }
}

-(POVView *) getPOVOnScreen{
    int povIndex = self.contentOffset.x/self.frame.size.width;
    
    if((povIndex >= 0) && (povIndex < self.povViews.count)){
        return self.povViews[povIndex];
    }
    return nil;
}

-(void) clearPOVs {
	for(POVView* povView in self.povViews){
		[povView clearArticle];
	}
	self.povViews = nil;
	for (UIView* subview in self.subviews) {
		[subview removeFromSuperview];
	}
	[self.activityIndicator startAnimating];
}

-(void) headerShowing: (BOOL) showing {
    for(int i = 0; i < self.povViews.count; i++){
        UIView * subView = self.povViews[i];
        if([subView isKindOfClass:[POVView class]]){
            if (showing) {
                [(POVView *)subView shiftLikeShareBarDown:NO];
            } else {
               [(POVView *)subView shiftLikeShareBarDown:YES];
            }
        }
    }
}


#pragma mark - POVView delegate - 

-(void) likeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo {
	//todo:
//    [self.customDelegate povLikeButtonLiked:liked onPOV:povInfo];
}

-(void) shareOptionSelectedForParsePostObject: (PFObject *)pov {
    [self.customDelegate povshareButtonSelectedForParsePostObject: pov];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray *)povViews{
    if(!_povViews)_povViews = [[NSMutableArray alloc] init];
    return _povViews;
}

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
