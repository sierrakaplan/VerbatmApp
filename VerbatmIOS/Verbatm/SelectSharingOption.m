//
//  SelectSharingOption.m
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "SelectionView.h"
#import "Styles.h"
#import "SelectSharingOption.h"
#import "SelectOptionButton.h"
#import "SizesAndPositions.h"

#define WALL_OFFSET_X 30.f
#define WALL_OFFSET_Y 20.f

#define IMAGE_TEXT_SPACING 20.f
#define MAX_BAR_NUMBER 3.f //number of bars visible before scrolling
#define BAR_HEIGHT_TOGGLE 25.f //constant that we reduce the bar height by for aesthetics
#define BAR_HEIGHT ((self.frame.size.height/MAX_BAR_NUMBER)-BAR_HEIGHT_TOGGLE)
#define SELECTION_BUTTON_WIDTH 20.f

@interface SelectSharingOption ()
@property (nonatomic) SelectOptionButton * selectedButton;
@end

@implementation SelectSharingOption


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self presentSelectionOptions];
    }
    return self;
}




-(void)presentSelectionOptions{
    
    //Facebook BAR -- center
    CGRect fb_barFrame = CGRectMake(0.f, self.frame.size.height/2.f -
                                    (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT);
    UIView * facebookBar = [self createBarWithFrame:fb_barFrame logo:[UIImage imageNamed:@"Facebook_logo"] andTitle:@"Facebook"];
    [self addSubview:facebookBar];
    
    
    
    CGFloat  remainingTopHeight = fb_barFrame.origin.y;
    
    
    //VERBATM BAR -- top
    CGRect barFrame = CGRectMake(0.f, (remainingTopHeight/2.f) -
                                 (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT);
    UIView * verbatmBar = [self createBarWithFrame:barFrame logo:[UIImage imageNamed:@"verbatmLogo"] andTitle:@"Verbatm"];
    [self addSubview:verbatmBar];
    
   
    
    //Twitter BAR -- bottom
    CGRect tw_barFrame = CGRectMake(0.f, facebookBar.frame.origin.y +
                                    facebookBar.frame.size.height +
                                    (remainingTopHeight/2.f) - (BAR_HEIGHT/2.f), self.frame.size.width, BAR_HEIGHT);
    UIView * twitterBar = [self createBarWithFrame:tw_barFrame logo:[UIImage imageNamed:@"Twitter-Logo-square"] andTitle:@"Twitter"];
    [self addSubview:twitterBar];
    
}


-(SelectionView *) createBarWithFrame: (CGRect) frame logo:(UIImage *) logoImage andTitle:(NSString *) title{
    
    SelectionView * ourBar = [[SelectionView alloc] initWithFrame:frame];
    
    CGFloat imageHeight = frame.size.height;
    CGRect viewFrame = CGRectMake(WALL_OFFSET_X, 0.f, imageHeight, imageHeight);
    UIImageView * verbatmView = [[UIImageView alloc] initWithFrame:viewFrame];
    UIImage * logo = logoImage;
    [verbatmView setImage:logo];
    
    CGRect labelFrame = CGRectMake(viewFrame.origin.x + viewFrame.size.width +
                                          IMAGE_TEXT_SPACING, 0.f, imageHeight+ 50, imageHeight);
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [nameLabel setAttributedText:[self getButtonAttributeStringWithText:title]];
//    [nameLabel setText:title];
//    [nameLabel setTextColor:[UIColor whiteColor]];
    
    
    CGRect buttonFrame = CGRectMake(frame.size.width - WALL_OFFSET_X - SELECTION_BUTTON_WIDTH ,
                                    (imageHeight/2.f) - (SELECTION_BUTTON_WIDTH/2.f),
                                    SELECTION_BUTTON_WIDTH, SELECTION_BUTTON_WIDTH);
    
    SelectOptionButton * selectionButton = [[SelectOptionButton alloc] initWithFrame:buttonFrame];
    
    if([title isEqualToString:@"Verbatm"]){
        selectionButton.buttonSharingOption = Verbatm;
        
    }else if ([title isEqualToString:@"Facebook"]){
        selectionButton.buttonSharingOption = Facebook;

    }else if ([title isEqualToString:@"Twitter"]){
        selectionButton.buttonSharingOption = Twitter;
    }
        
//    [selectionButton addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    ourBar.shareOptionButton = selectionButton;
    
    [ourBar addSubview:verbatmView];
    [ourBar addSubview:nameLabel];
    [ourBar addSubview:selectionButton];
    [self addTapGestureToView:ourBar];
    
    return ourBar;
}


-(NSAttributedString *)getButtonAttributeStringWithText:(NSString *)text{
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:REPOST_BUTTON_TEXT_FONT_SIZE]}];
}


-(void)unselectAllOptions{
    [self.selectedButton setButtonSelected:NO];
}

-(void)addTapGestureToView:(UIView *) tapView{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionSelectionMade:)];
    [tapView addGestureRecognizer:tap];
}


-(void)optionSelectionMade:(UITapGestureRecognizer *) gesture {
    SelectionView * selectedView = (SelectionView *) gesture.view;
    [self optionSelected:selectedView.shareOptionButton];
}

-(void) optionSelected:(UIButton *)sender {
    SelectOptionButton * selectionButton = (SelectOptionButton *)sender;
    if([selectionButton buttonSelected]){//if it's already selected then remove it
        [selectionButton setButtonSelected:NO];
        [self.sharingDelegate shareOptionDeselected:selectionButton.buttonSharingOption];
        self.selectedButton = nil;
    }else{
        if(self.selectedButton){//only one button can be selected at once
            [self.selectedButton setButtonSelected:NO];
        }
        
        [selectionButton setButtonSelected:YES];
        [self.sharingDelegate shareOptionSelected:selectionButton.buttonSharingOption];
        [self.sharingDelegate shareOptionDeselected:self.selectedButton.buttonSharingOption];
        self.selectedButton = selectionButton;
    }
}

//creates and returns a button you can toggle on and off
//-(UIButton *) getToggleButton{
//    
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
