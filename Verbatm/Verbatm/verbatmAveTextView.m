//
//  verbatmAveTextView.m
//  Verbatm
//
//  Created by Iain Usiri on 7/19/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmAveTextView.h"

@implementation verbatmAveTextView

/*
 this prevents the textview from being selectable but allows it to be scrollable.
 */
- (BOOL)canBecomeFirstResponder
{
    return NO;
}


@end
