//
//  TextPinchView.m
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "TextPinchView.h"
#import "Styles.h"


@implementation TextPinchView

@synthesize textColor = _textColor;

-(AnyPromise *) getLargerImageWithHalfSize:(BOOL)half; {
    AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
                                                    resolve([self getImage]);
    }];
    return promise;
}

-(UIColor *) textColor {
    if (!_textColor) {
        _textColor = [UIColor TEXTPINCHVIEW_PAGE_VIEW_DEFAULT_COLOR];
    }
    return _textColor;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
