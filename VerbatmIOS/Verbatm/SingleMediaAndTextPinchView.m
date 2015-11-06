//
//  SingleMediaAndTextPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 11/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	This class could be every individual pinch view in a collection view, but is not a collection view
//	Contains text over a single media.
//

#import "SingleMediaAndTextPinchView.h"

@implementation SingleMediaAndTextPinchView

#pragma mark - Lazy Instantiation -

-(NSString*) text {
	if (!_text) {
		_text = @"";
	}
	return _text;
}

-(NSNumber*) textYPosition {
	if (!_textYPosition) {
		_textYPosition = [NSNumber numberWithFloat: 0.f];
	}
	return _textYPosition;
}

@end
