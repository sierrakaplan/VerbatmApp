//
//  TextPinchView.m
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "TextPinchView.h"
#import "Styles.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "TextOverMediaView.h"


#import "UIView+Effects.h"

@implementation TextPinchView

@synthesize textColor = _textColor;
@synthesize  imageName = _imageName;

//todo:
-(AnyPromise *) getLargerImageWithHalfSize:(BOOL)half {
    AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
        if(self.beingPublished){
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve([self getImageScreenshotWithTextInHalf:half]);
            });
        } else {
            resolve([self getImage]);
        }
    }];
    
    return promise;
}

-(UIColor *) textColor {
    
    if (!_textColor) {
        _textColor = [UIColor TEXTPINCHVIEW_PAGE_VIEW_DEFAULT_COLOR];
    }
    
    return _textColor;
}

-(NSString *)imageName {
    
    if(!_imageName){
        _imageName = DEFAULT_TEXT_BACKGROUND_IMAGE;
    }
    
    return _imageName;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
