//
//  ChatCell.h
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

/*Simply creates and displays text in a rounded cell.
 You cannot change the text after it's first set.
 The cell is to be used in the chat feed.
 */

#import <UIKit/UIKit.h>

@interface ChatCell : UITextView
-(instancetype) initWithText:(NSString *) text screenWidth:(CGFloat) width isLoggedInUser:(BOOL) isUs;
@end
