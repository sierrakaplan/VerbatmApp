//
//  v_textview.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

//Chris and Aishwarya want the text to always have a border. Thus in adding to the superview
//please give a frame that is a lttle smalller than expected.
@interface TextAVE : UITextView
-(void)setTextViewText:(NSString*)text;
-(void)setTextViewAttributedText:(NSMutableAttributedString*)text;
-(void)removeTextVerticalCentering;
@end
