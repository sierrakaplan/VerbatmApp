//
//  TextOnlyPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/11/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
// THIS IS THE CLASS WITH SCROLLING TEXT FOR NEW DIRECTION

#import "TextOnlyPinchView.h"

@interface TextOnlyPinchView()

@property (strong) NSString *text;

@end

@implementation TextOnlyPinchView


-(instancetype)initWithRadius:(CGFloat)radius withCenter:(CGPoint)center andText:(NSString*)text {
	self = [super initWithRadius:radius withCenter:center];
	if (self && text) {
		self.text = text;
	}
	return self;
}

@end
