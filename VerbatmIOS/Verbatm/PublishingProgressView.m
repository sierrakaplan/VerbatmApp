//
//  PublishingProgressView.m
//  Verbatm
//
//  Created by Iain Usiri on 6/22/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PublishingProgressView.h"
#import "PublishingProgressView.h"
#import "PublishingProgressManager.h"
#import "UIView+Effects.h"

@interface PublishingProgressView ()
    @property (nonatomic) UIImageView * screenShotImageHolder;
    @property (nonatomic) UIProgressView * progressView;
    @property (nonatomic, strong) NSProgress* publishingProgress;
@end

@implementation PublishingProgressView


-(instancetype)initWithFrame:(CGRect)frame
{
     self = [super initWithFrame:frame];
    if(self){
        self.publishingProgress = [[PublishingProgressManager sharedInstance] progressAccountant];
        [self setProgressBackgroundImage:[[PublishingProgressManager sharedInstance] getProgressBackgroundImage]];
        [self presentProgressView];
    }
    return self;
}

-(void)setProgressBackgroundImage:(UIImage *) image{
     if(image){
             [self.screenShotImageHolder setImage:image];
            [self.screenShotImageHolder createBlurViewOnViewWithStyle:UIBlurEffectStyleLight];
                [self addSubview:self.screenShotImageHolder];
    }
}

-(UIImageView *)screenShotImageHolder{
      if(!_screenShotImageHolder)_screenShotImageHolder = [[UIImageView alloc] initWithFrame:self.bounds];
      return _screenShotImageHolder;
}

-(void)presentProgressView{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.progressView setTrackTintColor:[UIColor grayColor]];
    
    [self.progressView setFrame:CGRectMake(0.f, 0.f, self.frame.size.width - 30.f, self.progressView.frame.size.height)];
     [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 40.0)];
  
     if ([self.progressView respondsToSelector:@selector(setObservedProgress:)]) {
              [self.progressView setObservedProgress: self.publishingProgress];
        } else {
                 [self.publishingProgress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
        }
    
     UIView * edgeView = [[UIView alloc] initWithFrame:self.progressView.frame];
    
    [edgeView.layer setCornerRadius:15.f];
    [edgeView setClipsToBounds:YES];
    [edgeView setBackgroundColor:[UIColor clearColor]];

    CGFloat edgeViewWidth = self.frame.size.width - 30.f;
    CGFloat edgeViewHeight = 40.f;
    [edgeView setFrame:CGRectMake( self.frame.size.width/2.f - edgeViewWidth/2, self.frame.size.height/2.f - edgeViewHeight/2.,edgeViewWidth, edgeViewHeight)];

    [edgeView addSubview:self.progressView];
    [self addSubview:edgeView];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
      if (object == self.publishingProgress && [keyPath isEqualToString:@"completedUnitCount"] ) {
              [self.progressView setProgress:self.publishingProgress.fractionCompleted animated:YES];
        }
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
