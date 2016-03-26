//
//  SingleMediaAndTextPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 11/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"

@interface SingleMediaAndTextPinchView : PinchView

/* media, text, textYPosition, textColor, textAlignment, textSize */
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSNumber *textYPosition;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) NSNumber *textAlignment;
@property (strong, nonatomic) NSNumber *textSize;

@end
