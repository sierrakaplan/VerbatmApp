//
//  TextPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TextPinchView.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "UIEffects.h"

@interface TextPinchView()

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) UITextView *textView;

@end

@implementation TextPinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andText:(NSString*)text {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		self.containsText = YES;
		self.text = text;
		[self.background addSubview:self.textView];
		[self renderMedia];
	}
	return self;
}

#pragma mark - Lazy Instantiation -

-(UITextView*)textView {
	if(!_textView) _textView = [[UITextView alloc] init];
	return _textView;
}

-(NSString *) text {
	if(!_text) _text = @"";
	return _text;
}

#pragma mark - Formatting -

+(void) formatTextView:(UITextView*)textView {
	[textView setScrollEnabled:NO];
	textView.textColor = [UIColor TEXT_AVE_COLOR];
	textView.backgroundColor = [UIColor PINCHVIEW_BACKGROUND_COLOR];
	//must be editable to change font
	[textView setEditable:YES];
	textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE];
	[textView setEditable:NO];
	float textViewContentSize = [UIEffects measureContentHeightOfUITextView:textView];
	NSLog(@"%f", textView.frame.size.height);
	if (textViewContentSize < textView.frame.size.height/3.f) {
		textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE_REALLY_REALLY_BIG];
	} else if (textViewContentSize < textView.frame.size.height/2.f) {
		textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE_REALLY_BIG];
	} else if (textViewContentSize < textView.frame.size.height*(3.f/4.f)) {
		textView.font = [UIFont fontWithName:TEXT_AVE_FONT size:PINCHVIEW_FONT_SIZE_BIG];
	}
}

#pragma mark - Render Media -

//This should be overriden in subclasses
-(void)renderMedia {
	self.textView.frame = self.background.frame;
	[self displayMedia];
}

//This function displays the media on the view.
-(void)displayMedia {
	self.textView.text = self.text;
	[TextPinchView formatTextView:self.textView];
}

#pragma mark - Get & Change text -

-(NSString*) getText {
	return self.text;
}

-(void) changeText:(NSString *) text {
	self.text = text;
	[self renderMedia];
}

@end
