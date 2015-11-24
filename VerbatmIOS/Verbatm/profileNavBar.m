//
//  profileNavBar.m
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "profileNavBar.h"
#import "CustomNavigationBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "CustomNavigationBar.h"

@interface profileNavBar ()
    @property (nonatomic, strong)  NSArray * topicsBar;
    @property(nonatomic, strong) UIScrollView * threadNavScrollView;

    @property(nonatomic) CustomNavigationBar * navigationBar;

    #define THREAD_BUTTON_WIDTH 200.f
@end

@implementation profileNavBar



//expects an array of thread names (nsstring)
-(instancetype) initWithFrame:(CGRect)frame andThreads:(NSArray *) threads andUserName:(NSString *) userName{
    self = [super initWithFrame:frame];
    
    if(self){
        [self createNavigationBarWithTitle:userName];
        [self prepareTabViewForThreads:threads];
    }
    
    return self;
}



-(void) createNavigationBarWithTitle:(NSString *) userName{
    
    CGRect barFrame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2.f);
    self.navigationBar = [[CustomNavigationBar alloc] initWithFrame:barFrame
                                                 andBackgroundColor:[UIColor blackColor]];
    
    [self.navigationBar createLeftButtonWithTitle:@"Settings" orImage:nil];
    [self.navigationBar createRightButtonWithTitle:@"Edit" orImage:nil];
    [self.navigationBar createMiddleTitleWithText:userName];
    [self addSubview:self.navigationBar];
}



-(void)prepareTabViewForThreads:(NSArray *) threads{
    
    CGRect scrollViewFrame = CGRectMake(0,(self.frame.size.height/2.f) , self.frame.size.width,(self.frame.size.height/2.f));
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [self addSubview:scrollView];
    
    CGFloat xCoordinate = 0;
    
    for(NSString * threadTitle in threads) {
        CGRect buttonFrame = CGRectMake(xCoordinate,0, THREAD_BUTTON_WIDTH, scrollViewFrame.size.height);
        UIButton * newButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [newButton addTarget:self action:@selector(threadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        newButton.titleLabel.text = threadTitle;
        [self formatTextForButtonLabel:newButton];
        [scrollView addSubview:newButton];
        xCoordinate += THREAD_BUTTON_WIDTH;
    }
    self.threadNavScrollView = scrollView;
    [self adjustScrollViewFrame];
}

-(void) adjustScrollViewFrame {
    
    UIView * lastView = [self.threadNavScrollView.subviews lastObject];
    CGSize scrollViewContentSize = CGSizeMake(lastView.frame.origin.y + lastView.frame.size.width, 0);
    self.threadNavScrollView.contentSize = scrollViewContentSize;
    
}

-(void)formatTextForButtonLabel:(UIButton *) button{
    
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    UILabel * label = button.titleLabel;
    label.font = [UIFont fontWithName:NAVIGATION_BAR_BUTTON_FONT size:NAVIGATION_BAR_BUTTON_FONT_SIZE];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor NAVIGATION_BAR_TEXT_COLOR];
}


-(void) threadButtonPressed:(UIButton*) sender{
    
    
    
    
    
}












/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
