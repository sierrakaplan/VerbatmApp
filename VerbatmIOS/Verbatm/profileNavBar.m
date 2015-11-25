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

    #define THREAD_BUTTON_WIDTH 150.f
    #define OFFSET 15.f
    #define THREAD_BAR_BUTTON_FONT_SIZE 17.f
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
    
    CGRect barFrame =CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height/2.f);
    self.navigationBar = [[CustomNavigationBar alloc] initWithFrame:barFrame
                                                 andBackgroundColor:[UIColor blackColor]];
    
    [self.navigationBar createLeftButtonWithTitle:@"Settings" orImage:nil];
    [self.navigationBar createRightButtonWithTitle:@"Edit" orImage:nil];
    [self.navigationBar createMiddleTitleWithText:@"Iain Usiri"];
    [self addSubview:self.navigationBar];
    self.backgroundColor = [UIColor blackColor];
}



-(void)prepareTabViewForThreads:(NSArray *) threads{
    
    CGRect scrollViewFrame = CGRectMake(0,(self.frame.size.height / 2.f), self.frame.size.width,
                                        ((self.frame.size.height / 2.f)));
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [self addSubview:scrollView];
    
    CGFloat xCoordinate = 0.f;
    
    for(NSString * threadTitle in threads) {
        CGRect buttonFrame = CGRectMake(xCoordinate,0.f, THREAD_BUTTON_WIDTH, scrollViewFrame.size.height);
        UIButton * newButton = [[UIButton alloc] initWithFrame:buttonFrame];
        newButton.backgroundColor = [UIColor lightGrayColor];
        [newButton addTarget:self action:@selector(threadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newButton addSubview:[self formatTextForButtonLabel:threadTitle andFrame:newButton.bounds]];
        [scrollView addSubview:newButton];
        xCoordinate += THREAD_BUTTON_WIDTH + 1.f;
    }
    
    self.threadNavScrollView = scrollView;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self adjustScrollViewFrame];
}

-(void) adjustScrollViewFrame {
    CGSize scrollViewContentSize = CGSizeMake(self.threadNavScrollView.subviews.count * THREAD_BUTTON_WIDTH, 0);
    self.threadNavScrollView.contentSize = scrollViewContentSize;
    self.threadNavScrollView.scrollEnabled = YES;
    self.threadNavScrollView.showsHorizontalScrollIndicator = NO;
    self.threadNavScrollView.bounces = NO;
}

-(UILabel *)formatTextForButtonLabel:(NSString *) titleText andFrame:(CGRect) frame{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.text = titleText;
    label.font = [UIFont fontWithName:NAVIGATION_BAR_BUTTON_FONT size:THREAD_BAR_BUTTON_FONT_SIZE];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    return label;
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
