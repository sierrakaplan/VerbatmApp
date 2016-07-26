//
//  TextPinchView.m
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "TextPinchView.h"

@implementation TextPinchView

-(AnyPromise *) getLargerImageWithHalfSize:(BOOL)half; {
    AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
                                                    resolve([self getImage]);
    }];
    return promise;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
