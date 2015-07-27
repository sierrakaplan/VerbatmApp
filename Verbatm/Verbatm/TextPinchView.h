//
//  TextPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"

@interface TextPinchView : PinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andText:(NSString*)text;

-(void) changeText:(NSString *) text;

+(void) formatTextView:(UITextView*)textView;

@end
