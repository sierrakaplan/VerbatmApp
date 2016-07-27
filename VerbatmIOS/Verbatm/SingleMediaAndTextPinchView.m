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

@interface SingleMediaAndTextPinchView()

#define TEXT_KEY @"text_key"
#define TEXT_Y_POSITION_KEY @"text_y_position_key"
#define TEXT_COLOR_KEY @"text_color_key"
#define TEXT_ALIGNMENT_KEY @"text_alignment_key"
#define TEXT_SIZE_KEY @"text_size_key"

@end

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

-(NSString *)fontName{
    if(!_fontName){
        _fontName = TEXT_PAGE_VIEW_DEFAULT_FONT;
    }
    return _fontName;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.textYPosition forKey:TEXT_Y_POSITION_KEY];
	[coder encodeObject:self.text forKey:TEXT_KEY];
	[coder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.textColor]  forKey:TEXT_COLOR_KEY];
	[coder encodeObject:self.textAlignment forKey:TEXT_ALIGNMENT_KEY];
	[coder encodeObject:self.textSize forKey:TEXT_SIZE_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.text = [decoder decodeObjectForKey:TEXT_KEY];
		self.textYPosition = [decoder decodeObjectForKey:TEXT_Y_POSITION_KEY];
		self.textColor = [NSKeyedUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:TEXT_COLOR_KEY]];
		self.textAlignment = [decoder decodeObjectForKey:TEXT_ALIGNMENT_KEY];
		self.textSize = [decoder decodeObjectForKey:TEXT_SIZE_KEY];
	}
	return self;
}

@end
