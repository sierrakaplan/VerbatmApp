//
//  verbatmContainerViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 9/21/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "BlurBaseVC.h"
#import "ILTranslucentView.h"


@interface BlurBaseVC ()
    @property (weak, nonatomic) IBOutlet ILTranslucentView *blurView;
    @property(nonatomic) CGRect blurViewInitialFrame;
    @property (nonatomic) BOOL canRaise;
@end

@implementation BlurBaseVC


-(void) viewDidLoad
{
    //format the blurview
    [self formatBlurView];
    //make placeholders white
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyboard)];
    [self.blurView addGestureRecognizer:tap];
    [self setPlaceholderColors];
}

//removes the keyboard if present
-(void)removeKeyboard
{
    if([self.sandwhichWhat isFirstResponder])
    {
        [self.view endEditing:YES];
    }else if([self.sandwichWhere isFirstResponder])
    {
        [self.view endEditing:YES];
    }
}

//Format blurview
-(void) formatBlurView
{
    self.blurView.translucentStyle = UIBarStyleBlack;
    self.blurView.translucentAlpha = 2;
    self.blurViewInitialFrame = self.blurView.frame;
}


//Iain
//gives the placeholders a white color
-(void) setPlaceholderColors
{
    if ([self.sandwhichWhat respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.sandwhichWhat.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.sandwhichWhat.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    if ([self.sandwichWhere respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.sandwichWhere.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.sandwichWhere.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}


@end
