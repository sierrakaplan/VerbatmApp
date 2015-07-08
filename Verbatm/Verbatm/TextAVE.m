//
//  v_textview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "TextAVE.h"
#import "ILTranslucentView.h"

@interface TextAVE() <UITextViewDelegate>
#define DEFAULT_FONT_FAMILY @"Arial"
#define DEFAULT_FONT_SIZE 17
#define DEFAULT_TEXT_COLOR blackColor
#define BACKGRND_COLOR @"D6CEC3"
#define LINE_SPACING 10
#define CHARACTER_SPACING 2.0
@end
@implementation TextAVE

//provide for a little bit of spacing on top and belows
/*
 *This function initializes the text view to the frame issue
 */
-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        //prevents editing and selecting the view
        self.editable = NO;
        self.selectable = NO;
        self.delegate = self;
        self.backgroundColor = [self getColorFromHexString: BACKGRND_COLOR];
        [self addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

-(void)removeTextVerticalCentering
{
    
    [self removeObserver:self forKeyPath: @"contentSize"];
    
}

/*This function converts a hex string into a uicolor*/
-(UIColor*)getColorFromHexString:(NSString*)hex
{
    unsigned int rgb = 0;
    NSScanner* scanner = [NSScanner scannerWithString: BACKGRND_COLOR];
    [scanner scanHexInt: &rgb];
    double red = ((rgb & 0xFF0000) >> 16)/310.0;
    double green = ((rgb & 0xFF00) >> 8)/310.0;
    double blue = (rgb & 0xFF)/310.0;
    return [UIColor colorWithRed: red green: green blue: blue alpha:1.0];
}

/*This sets the text of the text view. The text is formatted to suit the
 *specification of the designers
 */
-(void)setTextViewText:(NSString*)text
{
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attrStr addAttribute:NSKernAttributeName value:@(CHARACTER_SPACING) range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing: LINE_SPACING] ;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
    [self setTextViewAttributedText: attrStr];
}

/*Sets the attributed text of the view
 */
-(void)setTextViewAttributedText:(NSMutableAttributedString*)text
{
    self.attributedText = text;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor DEFAULT_TEXT_COLOR];
    [self setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
}


//Pulled from stack overflow.
//Keeps the text centered vertically in the view.
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    if ([tv contentSize].height < [tv bounds].size.height) {
        tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
}


-(void)dealloc
{
    @try{
        [self removeObserver:self forKeyPath: @"contentSize"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

@end
