//
//  v_textview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_textview.h"
#import "ILTranslucentView.h"

@interface v_textview()
#define DEFAULT_FONT_FAMILY @"Arial"
#define DEFAULT_FONT_SIZE 17
@end
@implementation v_textview

//provide for a little bit of spacing on top and belows
/*
 *This function initializes the text view to the frame issue
 */
-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])){
        //prevents editing and selecting the view
        self.editable = NO;
        self.selectable = NO;
        self.backgroundColor = [UIColor blackColor];
        [self addObserver:self forKeyPath: @"contentSize" options: (NSKeyValueObservingOptionNew) context:NULL];
    }
    return self;
}

/*This sets the text of the text view. The text is formatted to suit the
 *specification of the designers
 */
-(void)setTextViewText:(NSString*)text
{
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attrStr addAttribute:NSKernAttributeName value:@(2.0) range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:10] ;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
     [self setTextViewAttributedText: attrStr];
}

/*Sets the attributed text of the view
 */
-(void)setTextViewAttributedText:(NSMutableAttributedString*)text
{
    self.attributedText = text;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    [self setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
}


//Pulled from stack overflow.
//Keeps the text centered in the view.
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    if ([tv contentSize].height < [tv bounds].size.height) {
        tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
}

@end
