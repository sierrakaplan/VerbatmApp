//
//  followInfoBar.m
//  Verbatm
//
//  Created by Iain Usiri on 1/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "followInfoBar.h"

#import "Styles.h"
#import "SizesAndPositions.h"

@interface followInfoBar ()

@property (nonatomic) UIButton * myFollowers;
@property (nonatomic) UIButton * whoIAmFollowing;


@end

@implementation followInfoBar


-(instancetype)initWithFrame:(CGRect)frame WithNumberOfFollowers:(NSNumber *) myFollowers andWhoIFollow:(NSNumber *) whoIFollow {
    self = [super initWithFrame:frame];
    if(self){
        [self createButtonsWithNumberOfFollowers:myFollowers andWhoIFollow:whoIFollow];
    }
    return self;
}


-(void)createButtonsWithNumberOfFollowers:(NSNumber *) myFollowers andWhoIFollow:(NSNumber *) whoIFollow{
    
    CGRect myFollowersFrame = CGRectMake(0.f,0.f, self.frame.size.width/2.f, self.frame.size.height);
    
    CGRect whoIAmFollowingFrame = CGRectMake(self.frame.size.width/2.f,0.f, self.frame.size.width/2.f, self.frame.size.height);
    
    [self addSubview:[self getInfoViewWithTitle:@"Follower(s)" andNumber:myFollowers andViewFrame:myFollowersFrame andSelectionSelector:@selector(myFollowersListSelected)]];
    
     [self addSubview:[self getInfoViewWithTitle:@"Following" andNumber:whoIFollow andViewFrame:whoIAmFollowingFrame andSelectionSelector:@selector(whoIAmFollowingSeleceted)]];
}



//note -- selector is for when the button is pressed
-(UIButton *) getInfoViewWithTitle:(NSString *) title andNumber:(NSNumber *) number andViewFrame:(CGRect) viewFrame andSelectionSelector:(SEL) selector{
    
    CGRect titleFrame = CGRectMake(0.f,0.f, self.frame.size.width/2.f, self.frame.size.height/2.f);
    
    CGRect numberFrame = CGRectMake(0.f,self.frame.size.width/2.f, self.frame.size.width/2.f, self.frame.size.height/2.f);
    
    
    NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
                                                [UIColor whiteColor],
                                            NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:FOLLOWERS_TEXT_FONT_SIZE]};
    
    
    //create bolded number
    NSString * numberString = [number stringValue];
    
    NSAttributedString * numberAttributed = [[NSAttributedString alloc] initWithString:numberString attributes:informationAttribute];
    
    NSAttributedString * titleAttributed = [[NSAttributedString alloc] initWithString:title attributes:informationAttribute];
    
    
    

    //create frame for text label
    CGSize textSize = [title sizeWithAttributes:informationAttribute];
    CGFloat height = self.frame.size.height/2.f;
    
    CGRect titleLabelFrame = CGRectMake(0.f, 0.f, textSize.width, height);
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setAttributedText:titleAttributed];
    
    
    //create frame for text number
    CGSize numberTextSize = [numberString sizeWithAttributes:informationAttribute];
    CGFloat numberHeight = self.frame.size.height/2.f;
    CGRect numberLabelFrame = CGRectMake(0.f, numberHeight, numberTextSize.width, numberHeight);
    UILabel * numberLabel = [[UILabel alloc] initWithFrame:numberFrame];
    [numberLabel setBackgroundColor:[UIColor clearColor]];
    [numberLabel setAttributedText:numberAttributed];
    
    
    UIButton * baseView = [[UIButton alloc]initWithFrame:viewFrame];
    [baseView setBackgroundColor:CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED];
    [baseView addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:titleLabel];
    [baseView addSubview:numberLabel];
    
    return baseView;
}

//list of people that follow me and the channels
-(void)myFollowersListSelected{
    //to-do
}

//list of people that I follow
-(void)whoIAmFollowingSeleceted{
    //to-do
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
