//
//  photoVideoWrapperViewForText.h
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

/*
 This frame takes care of photos or videos in AVEs. They are added as subviews to the frame.
 The function of this frame is to manage the textviews that are placed on top - and to know when to present them and not present them.
 */


#import <UIKit/UIKit.h>

@interface TextViewWrapper : UIView

@property (nonatomic, strong) UITextView * textView;
-(void)showText;
-(void)hideText;

@end
