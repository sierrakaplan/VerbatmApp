//
//  PublishingProgressView.m
//  Verbatm
//
//  Created by Iain Usiri on 6/16/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PublishingProgressView.h"
#import "PublishingProgressManager.h"
#import "UIView+Effects.h"
@interface PublishingProgressView ()
@property (nonatomic) UIImageView * screenShotImageHolder;
@end

@implementation PublishingProgressView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setProgressBackgroundImage:[[PublishingProgressManager sharedInstance] getProgressBackgroundImage]];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
