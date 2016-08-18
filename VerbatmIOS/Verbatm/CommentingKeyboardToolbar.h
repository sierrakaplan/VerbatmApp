//
//  CommentingKeyboardToolbar.h
//  Verbatm
//
//  Created by Iain Usiri on 8/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentingKeyboardToolbarProtocol <NSObject>

-(void)doneButtonSelectedWithFinalString:(NSString *) commentString;

@end

@interface CommentingKeyboardToolbar : UIView
@property (nonatomic, readonly) UITextView * commentTextView;
@property (nonatomic, weak) id<CommentingKeyboardToolbarProtocol> delegate;
@end
