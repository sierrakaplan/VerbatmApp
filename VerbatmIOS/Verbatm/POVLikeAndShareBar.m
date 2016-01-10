//
//  POVLikeAndShareBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//


#import "Icons.h"
#import "POVLikeAndShareBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"


@interface POVLikeAndShareBar ()
@property (nonatomic,strong) UIButton * likeButton;
@property (nonatomic,strong) UIButton * numLikesButton;
@property (nonatomic, strong) UIButton * shareButon;
@property (nonatomic,strong) UIButton * numSharesButton;
@property (nonatomic, strong) UILabel * pageNumberLabel;


@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) NSNumber * totalNumberOfPages;//number of pages on our related AVE

#define BUTTON_WALLOFFSET 5.f
#define NUMBER_FONT_SIZE 18.f
#define ICON_SPACING_GAP 5.f
#define NUMBER_TEXT_FONT TAB_BAR_FOLLOWERS_FONT
#define NUMBER_TEXT_FONT_SIZE 25.f


#define OF_TEXT_FONT TAB_BAR_FOLLOWERS_FONT
#define OF_TEXT_FONT_SIZE 18.f
@end



@implementation POVLikeAndShareBar



-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage {
    
    self = [super initWithFrame:frame];
    if(self){
        [self creatButtonsWithNumLike:numLikes andNumShare:numShares];
        if(numPages.integerValue > 1){//make sure there are multiple pages
            [self createCounterLabelStartingAtPage:startPage outOf:numPages];
        }
        self.totalNumberOfPages = numPages;
    }
    return self;
}


-(void) createCounterLabelStartingAtPage:(NSNumber *) startPage outOf:(NSNumber *) totalPages{
    NSAttributedString * pageCounterText = [self createCounterStringStartingAtPage:startPage outOf:totalPages];
    CGRect labelFrame = CGRectMake(self.frame.size.width - BUTTON_WALLOFFSET - pageCounterText.size.width, BUTTON_WALLOFFSET, pageCounterText.size.width, self.frame.size.height - (BUTTON_WALLOFFSET*2));
    
    self.pageNumberLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [self.pageNumberLabel setAttributedText:pageCounterText];
    [self addSubview:self.pageNumberLabel];
}


//creates the text for the numbers at the bottom right that show what page you're on and how
//many there are left
-(NSAttributedString *) createCounterStringStartingAtPage:(NSNumber *) startPage outOf:(NSNumber *) totalPages{
    
    //create attributed string of number of pages
    
    NSDictionary * numberTextAttributes =@{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName: [UIFont fontWithName:NUMBER_TEXT_FONT size:NUMBER_TEXT_FONT_SIZE]};
    
    
    NSMutableAttributedString * pageWeAreOn = [[NSMutableAttributedString alloc] initWithString:startPage.stringValue attributes:numberTextAttributes];
    
    NSAttributedString * totalNumberOfPages = [[NSMutableAttributedString alloc] initWithString:totalPages.stringValue attributes:numberTextAttributes];
    
    //the small "of" word between numbers. eg 1of5
    NSDictionary * ofTextAttributes =@{
                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSFontAttributeName: [UIFont fontWithName:OF_TEXT_FONT size:OF_TEXT_FONT_SIZE]};
    
    NSMutableAttributedString * ofText = [[NSMutableAttributedString alloc] initWithString:@"of" attributes:ofTextAttributes];
    
    [pageWeAreOn appendAttributedString:ofText];
    [pageWeAreOn appendAttributedString:totalNumberOfPages];
    return pageWeAreOn;
}


-(void) creatButtonsWithNumLike:(NSNumber *) numLikes andNumShare:(NSNumber *) numShares{
    
    //create like button
    CGRect likeButtonFrame = CGRectMake(BUTTON_WALLOFFSET, BUTTON_WALLOFFSET,
                                        LIKE_BUTTON_SIZE_WIDTH, LIKE_BUTTON_SIZE_HEIGHT);
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setFrame:likeButtonFrame];
    self.likeButtonLikedImage = [UIImage imageNamed:LIKE_ICON_PRESSED];
    self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_ICON_UNPRESSED];
    [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.likeButton];
    
    
    //create Number of likes button
    self.numLikesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //create "followers" text
    NSDictionary * followersTextAttributes =@{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:NUMBER_FONT_SIZE]};
    
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:numLikes.stringValue attributes:followersTextAttributes];
    
    [self.numLikesButton setAttributedTitle:followersText forState:UIControlStateNormal];
    CGSize textSize = [numLikes.stringValue sizeWithAttributes:followersTextAttributes];
    
    CGRect likeNumberButtonFrame = CGRectMake(self.likeButton.frame.origin.x +
                                              self.likeButton.frame.size.width + ICON_SPACING_GAP, BUTTON_WALLOFFSET,
                                              textSize.width, self.frame.size.height - (BUTTON_WALLOFFSET*2));
     [self.numLikesButton setFrame:likeNumberButtonFrame];
    
    [self.numLikesButton addTarget:self action:@selector(numLikesButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.numLikesButton];
    
    
    
    //create share button
    CGRect shareButtonFrame = CGRectMake(self.numLikesButton.frame.origin.x +
                                        self.numLikesButton.frame.size.width + ICON_SPACING_GAP,
                                        BUTTON_WALLOFFSET,
                                        LIKE_BUTTON_SIZE_WIDTH, LIKE_BUTTON_SIZE_WIDTH);
    
    self.shareButon = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButon setFrame:shareButtonFrame];
    [self.shareButon setImage:[UIImage imageNamed:SHARE_ICON] forState:UIControlStateNormal];
    [self.shareButon addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.shareButon];

    
    //create numSharesButton of likes button
    self.numSharesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //create "followers" text
    
    NSAttributedString * sharesText = [[NSAttributedString alloc] initWithString:numShares.stringValue attributes:followersTextAttributes];
    
    [self.numSharesButton setAttributedTitle:sharesText forState:UIControlStateNormal];
    CGSize textSizeNumShares = [numShares.stringValue sizeWithAttributes:followersTextAttributes];
    CGRect shareNumberButtonFrame = CGRectMake(self.shareButon.frame.origin.x +
                                               self.shareButon.frame.size.width +
                                               BUTTON_WALLOFFSET, BUTTON_WALLOFFSET,
                                              textSizeNumShares.width, self.frame.size.height - (BUTTON_WALLOFFSET*2));
    [self.numSharesButton setFrame:shareNumberButtonFrame];
    
    [self.numSharesButton addTarget:self action:@selector(numSharesButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.numSharesButton];
}

//the icon is selected
-(void)shareButtonPressed{
    [self.delegate shareButtonPressed];
}
//the icon is selected
-(void) likeButtonSelected {
    
    if(self.isLiked){
        [self.likeButton setImage:self.likeButtonLikedImage forState:UIControlStateNormal];
        self.isLiked = NO;
    }else{
        [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
        self.isLiked = YES;
    }

    [self.delegate likeButtonPressed];
}

//allows us to change our page number to the next number
-(void)setPageNumber:(NSNumber *) pageNumber{
    if(pageNumber.integerValue < self.totalNumberOfPages.integerValue ||
       pageNumber.integerValue >= 1){
        if(self.pageNumberLabel)[self.pageNumberLabel removeFromSuperview];
        [self createCounterLabelStartingAtPage:pageNumber outOf:self.totalNumberOfPages];
    }
}


//the actual number view is selected
-(void) numLikesButtonSelected {
    
}

//the actual number view is selected
-(void) numSharesButtonSelected {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
