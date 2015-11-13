//
//  SingleMediaAndTextPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 11/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"

@interface SingleMediaAndTextPinchView : PinchView

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSNumber* textYPosition; // float value

@end
