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

#import "Styles.h"
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

-(UIColor *) textColor {
	if (!_textColor) {
		_textColor = [UIColor TEXT_PAGE_VIEW_DEFAULT_COLOR];
	}
	return _textColor;
}

-(NSNumber *)textAlignment {
	if (!_textAlignment) {
		_textAlignment = [NSNumber numberWithInt: 0];
	}
	return _textAlignment;
}

-(NSNumber *)textSize {
	if (!_textSize) {
		_textSize = [NSNumber numberWithFloat: TEXT_PAGE_VIEW_DEFAULT_FONT_SIZE];
	}
	return _textSize;
}

@end
