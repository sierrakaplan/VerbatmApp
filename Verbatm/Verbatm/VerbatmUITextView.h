//
//  verbatmUITextView.h
//  Verbatm
//
//  Created by Iain Usiri on 9/9/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VerbatmUITextView;


//Iain
@interface VerbatmUITextView : UITextView
    @property (strong, nonatomic) UIScrollView * mainScrollView; //expecting the view to be on a scroll view
@end